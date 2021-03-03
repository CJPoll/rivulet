defmodule Rivulet.Kafka.Producer do
  alias Rivulet.Kafka.{Client, Partition}
  alias Rivulet.Kafka.Producer.Message

  require Logger

  @type partition_strategy :: :random | :hash | integer
  @type key :: binary
  @type value :: binary

  @type produce_return ::
          nil
          | :ok
          | {:ok, integer}
          | {:error, :closed}
          | {:error, :inet.posix()}
          | {:error, any}
          | iodata
          | :leader_not_available

  @spec produce_async(Partition.topic(), partition_strategy, key, value) ::
          produce_return
          | {:error, :schema_not_found}
          | {:error, term}
  def produce_async(topic, partition \\ :hash, key, message) do
    client = Client.default_name()
    :brod.produce(client, topic, partition, key, message)
  end

  def produce_async(%Message{
        topic: topic,
        key: key,
        value: value,
        partition_strategy: partition_strategy,
        partition: partition
      }) do
    partition = partition || partition_strategy
    produce_async(topic, partition, key, value)
  end

  @spec produce_async([Message.t()]) :: [{:ok, term} | {:error, term}]
  def produce_async(messages) do
    messages
    |> Enum.map(&produce_async/1)
    |> Enum.map(fn
      {:ok, call_ref} ->
        {:ok, call_ref}

      {:error, _reason} = err ->
        Logger.error("Bulk produceing failed: #{inspect(err)}")
        raise "Bulk produce failed for reason: #{inspect(err)}"
    end)
  end

  def config do
    case Application.get_env(:rivulet, :producer) do
      nil -> default_config()
      custom_config -> Keyword.merge(default_config(), custom_config)
    end
  end

  def default_config do
    [
      # by default this is -1, meaning "all", within :brod (options are 0, 1, -1)
      required_acks: 1,
      # the max number of time the producer should wait to receive a response that message was received by all required insync replicas before timing out. default is: 10000ms
      ack_timeout: 10000,
      # by default this is 3 within :brod, -1 means "retry indefinitely"
      max_retries: 3,
      # by default this is 500ms within :brod
      retry_backoff_ms: 500
    ]
  end
end
