defmodule TestApp.TestTransformer do
  use Rivulet.Transformer

  def handle_message(%Rivulet.Kafka.Consumer.Message{} = m) do
    [nil, {m.key, m.value}]
  end
end
