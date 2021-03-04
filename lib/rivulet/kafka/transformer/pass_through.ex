defmodule Rivulet.Transformer.PassThrough do
  use Rivulet.Transformer

  alias Rivulet.Kafka.Consumer.Message

  def handle_message(%Message{} = m) do
    {m.key, m.value}
  end
end
