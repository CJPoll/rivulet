defmodule TestApp.TestConsumer do
  use Rivulet.Kafka.Consumer2

  alias Rivulet.Kafka.Consumer.Config
  alias Rivulet.Kafka.Consumer2
  alias Rivulet.Kafka.Partition

  def start_link(%Config{} = config) do
    Consumer2.start_link(__MODULE__, config)
  end

  def init(_) do
    {:ok, {}}
  end

  def handle_messages(%Partition{} = partition, messages, state) when is_list(messages) do
    first = List.first(messages)
    last = List.last(messages)

    IO.inspect("Partition: #{partition.partition}, from #{first.offset} - #{last.offset}")

    {:ok, :ack, state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, {:error, :unknown_message}, state}
  end
end
