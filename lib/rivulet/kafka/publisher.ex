defmodule Rivulet.Kafka.Publisher do
  alias Rivulet.Kafka.Publisher.Message
  alias Rivulet.Kafka.Partition

  require Logger

  @type partition_strategy :: :random | {:key, binary} | integer
  @type encoding_strategy :: :avro | :raw | :json
  @type key :: bitstring | Avro.decoded_message()
  @typedoc """
  If the encoding_strategy is :raw, the function takes a bitstring. If another
  encoding strategy is specified, the function accepts whatever structures the
  underlying encoding accepts.
  """
  @type value :: bitstring | term

  @type produce_return ::
          nil
          | :ok
          | {:ok, integer}
          | {:error, :closed}
          | {:error, :inet.posix()}
          | {:error, any}
          | iodata
          | :leader_not_available

  @spec publish_async(Partition.topic(), partition_strategy, key, value) ::
          produce_return
          | {:error, :schema_not_found}
          | {:error, term}
  def publish_async(topic, partition \\ :hash, key, message) do
    client = Rivulet.client_name()
    :brod.produce(client, topic, partition, key, message)
  end

  def publish_async(%Message{} = message) do
    partition = message.partition || message.partition_strategy
    publish_async(message.topic, partition, message.key, message.value)
  end

  @spec publish_async([Message.t()]) :: [{:ok, term} | {:error, term}]
  def publish_async(messages) do
    messages
    |> Enum.map(&publish_async/1)
    |> Enum.map(fn
      {:ok, call_ref} ->
        {:ok, call_ref}

      {:error, _reason} = err ->
        Logger.error("Bulk publishing failed: #{inspect(err)}")
        raise "Bulk Publish failed for reason: #{inspect(err)}"
    end)
  end
end
