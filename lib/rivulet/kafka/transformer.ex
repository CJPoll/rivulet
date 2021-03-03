defmodule Rivulet.Transformer do
  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)
    end
  end

  alias Rivulet.Kafka.Producer.Message

  @type key :: binary
  @type value :: binary

  @callback handle_message(Message.t()) ::
              nil | {key, value} | [{key, value} | nil]
end
