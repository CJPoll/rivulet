defmodule TestApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Rivulet.Kafka.Client
  alias Rivulet.Kafka.Consumer.Config

  def start(_type, _args) do
    "kafka:9092"
    |> Client.bootstrap_servers()
    |> Client.start_client(Client.default_name!(), Client.default_config())

    test_consumer_config = %Config{
      client_id: Client.default_name!(),
      consumer_group_name: "rivulet-consumer-group",
      topics: ["test-topic"]
    }

    children = [
      {TestApp.TestConsumer, [test_consumer_config]}
    ]

    opts = [strategy: :one_for_one, name: TestApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
