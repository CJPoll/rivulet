defmodule Rivulet.Kafka.Consumer do
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

  @behaviour :brod_group_subscriber

  # Public API

  defmacro __using__(_) do
    quote do
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
    :brod_group_subscriber.start_link(
      config.client_id,
      config.consumer_group_name,
      config.topics,
      config.group_config,
      config.consumer_config,
      :message_set,
      _CallbackModule = __MODULE__,
      _CallbackInitArg = {callback_module, extra}
    )
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
    :brod_group_subscriber.ack(ref, topic, partition, offset)
  end

  # Callback Functions

  def init(_group_id, {callback_module, extra}) do
    {:ok, state} = apply(callback_module, :init, [extra])
    {:ok, {callback_module, state}}
  end

  def handle_message(topic, partition, messages, {callback_module, state})
      when Record.is_record(messages, :kafka_message_set) and is_binary(topic) do
    partition = %Partition{topic: topic, partition: partition}

    messages =
      messages
      |> kafka_message_set(:messages)
      |> Message.from_wire_message()

    case apply(callback_module, :handle_messages, [partition, messages, state]) do
      {:ok, state} ->
        {:ok, {callback_module, state}}

      {:ok, :ack, state} ->
        {:ok, :ack, {callback_module, state}}
    end
  end
end
