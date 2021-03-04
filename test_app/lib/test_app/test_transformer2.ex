defmodule TestApp.TestTransformer2 do
  use Rivulet.Transformer

  def handle_message(%Rivulet.Kafka.Consumer.Message{} = m) do
    {m.key, m.value}
  end
end
