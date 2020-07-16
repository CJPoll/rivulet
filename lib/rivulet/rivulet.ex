defmodule Rivulet do
  defdelegate publish_async(topic, key, value), to: Rivulet.Kafka.Publisher
  defdelegate publish_async(topic, partition_strategy, key, value), to: Rivulet.Kafka.Publisher

  @spec client_name!() :: term | no_return
  def client_name!() do
    unless client_name = Application.get_env(:rivulet, :default_client) do
      raise "Application.get_env(:rivulet, :default_client) not configured"
    end

    client_name
  end

  @spec client_name() :: nil | pid
  def client_name do
    Application.get_env(:rivulet, :default_client)
  end
end
