defmodule Rivulet.Kafka.Consumer2 do
  defstruct [:pid]

  require Record

  alias Rivulet.Kafka.Partition
  alias Rivulet.Kafka.Consumer.{Config, Message}

  Record.defrecord(
    :kafka_message_set,
    Record.extract(:kafka_message_set, from_lib: "brod/include/brod.hrl")
  )

  @type state :: term
  @type messages :: [Rivulet.Kafka.Consumer.Message.t()]

  @callback handle_messages(Partition.t(), messages, state) ::
              {:ok, state}
              | {:ok, :ack, state}

  @callback init(term) :: {:ok, state}

  @behaviour :brod_group_subscriber_v2

  defmodule State do
    alias Rivulet.Kafka.Partition
    defstruct [:callback_module, :partition, :tracked_state]

    def new(callback_module, %Partition{} = partition, tracked_state) do
      %__MODULE__{
        callback_module: callback_module,
        partition: partition,
        tracked_state: tracked_state
      }
    end

    def updated_state(%__MODULE__{tracked_state: tracked_state} = state, tracked_state), do: state

    def updated_state(%__MODULE__{} = state, tracked_state) do
      %__MODULE__{state | tracked_state: tracked_state}
    end
  end

  # Public API

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)
      def child_spec(args) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, args}
        }
      end
    end
  end

  @spec start_link(atom, Config.t(), [term]) :: GenServer.on_start()
  def start_link(callback_module, %Config{} = config, extra \\ []) do
    :brod_group_subscriber_v2.start_link(%{
      client: config.client_id,
      group_id: config.consumer_group_name,
      topics: config.topics,
      cb_module: __MODULE__,
      init_data: {callback_module, extra},
      message_type: :message_set,
      consumer_config: config.consumer_config,
      group_config: config.group_config
    })
  end

  @spec ack(atom | pid, Partition.t(), Partition.offset()) :: :ok | {:error, term}
  def ack(ref, %Partition{topic: topic, partition: partition}, offset)
      when is_binary(topic) and
             is_integer(partition) and
             is_integer(offset) do
    ack(ref, topic, partition, offset)
  end

  def ack(ref, topic, partition, offset)
      when is_binary(topic) and
             is_integer(partition) and
             is_integer(offset) do
    :brod_group_subscriber_v2.commit(ref, topic, partition, offset)
  end

  # Callback Functions

  def init(
        %{group_id: _group_id, topic: topic, partition: partition, commit_fun: _commit_function},
        {callback_module, extra}
      ) do
    {:ok, state} = apply(callback_module, :init, [extra])
    partition = Partition.new(topic, partition)
    state = State.new(callback_module, partition, state)
    {:ok, state}
  end

  def handle_message(messages, %State{} = state)
      when Record.is_record(messages, :kafka_message_set) do
    messages =
      messages
      |> kafka_message_set(:messages)
      |> Message.from_wire_message()

    case apply(state.callback_module, :handle_messages, [
           state.partition,
           messages,
           state.tracked_state
         ]) do
      {:ok, tracked_state} ->
        {:ok, State.updated_state(state, tracked_state)}

      {:ok, :ack, tracked_state} ->
        {:ok, :commit, State.updated_state(state, tracked_state)}
    end
  end
end
