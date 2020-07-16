defmodule Rivulet.TestConsumer do
  alias Rivulet.Kafka.Consumer.Message
  alias Rivulet.Kafka.Partition

  def start_link(%Rivulet.Consumer.Config{} = config) do
    Rivulet.Consumer.start_link(__MODULE__, config)
  end

  def init(_) do
    {:ok, {}}
  end

  def handle_messages(%Partition{}, messages, state) when is_list(messages) do
    messages
    |> Enum.each(fn %Message{raw_key: k, raw_value: v} ->
      IO.puts("#{inspect(k)} = #{inspect(v)}")
    end)

    {:ok, :ack, state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, {:error, :unknown_message}, state}
  end
end
