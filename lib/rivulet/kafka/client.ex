defmodule Rivulet.Kafka.Client do
  alias Rivulet.Kafka.Producer

  defdelegate start_client(bootstrap_servers, name, config),
    to: :brod

  @spec default_name() :: term | nil
  def default_name do
    Application.get_env(:rivulet, :default_client)
  end

  @spec default_name!() :: term | no_return
  def default_name! do
    unless client_name = Application.get_env(:rivulet, :default_client) do
      raise "Application.get_env(:rivulet, :default_client) not configured"
    end

    client_name
  end

  @spec default_config() :: :brod.client_config()
  def default_config do
    [
      auto_start_producers: true,
      allow_topic_auto_creation: false,
      default_producer_config: Producer.config()
    ]
  end

  @doc """
  Expects a string in one of the following formats:

  - "some_host:9092"
  - "some_host:9092,other_host:9092"

  Where 9092 is the port the client should connect to. There can be any number of
  host/port pairs so long as they are comma-delimited.

  iex> Rivulet.bootstrap_servers("localhost:9092")
  [localhost: 9092]

  iex> Rivulet.bootstrap_servers("localhost:9092,other_host:9324")
  [localhost: 9092, other_host: 9324]
  """
  def bootstrap_servers(string) do
    string
    |> String.split(",")
    |> Enum.map(fn host_string ->
      case String.split(host_string, ":") do
        [host, port] ->
          # Brod requires our hosts to be atoms, so we have to atomize them if
          # we're pulling them from ENV vars
          {String.to_atom(host), String.to_integer(port)}

        [host] ->
          # Brod requires our hosts to be atoms, so we have to atomize them if
          # we're pulling them from ENV vars
          {String.to_atom(host), 9092}
      end
    end)
  end
end
