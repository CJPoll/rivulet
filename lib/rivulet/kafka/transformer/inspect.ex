defmodule Rivulet.Transformer.Inspect do
  use Rivulet.Transformer

  alias Rivulet.Kafka.Consumer.Message

  def handle_message(%Message{} = m) do
    IO.inspect({m.key, m.value})
    nil
  end
end
