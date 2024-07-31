defmodule Rivulet.Kafka.Consumer.Message do
  require Record
  import Record

  Record.defrecord(
    :kafka_message,
    Record.extract(:kafka_message, from_lib: "brod/include/brod.hrl")
  )

  defstruct offset: nil,
            key: nil,
            value: nil,
            failed?: false,
            failed_reason: nil

  @type t :: %__MODULE__{
          offset: non_neg_integer,
          key: binary,
          value: binary,
          failed?: boolean,
          failed_reason: nil | term
        }

  def from_wire_message(messages) when is_list(messages) do
    messages
    |> Enum.map(&from_wire_message/1)
    |> Enum.sort(fn %__MODULE__{} = a, %__MODULE__{} = b ->
      a.offset <= b.offset
    end)
  end

  def from_wire_message(msg) when is_record(msg, :kafka_message) do
    %__MODULE__{
      offset: kafka_message(msg, :offset),
      key: kafka_message(msg, :key),
      value: kafka_message(msg, :value)
    }
  end

  defguard is_message(message) when :erlang.map_get(:__struct__, message) == __MODULE__

  def message?(message) when is_message(message), do: true
  def message?(_), do: false

  def failed(%__MODULE__{} = message, reason) do
    %__MODULE__{message | failed?: true, failed_reason: reason}
  end

  def failed?(%__MODULE__{failed?: failed}), do: failed

  def key(%__MODULE__{key: key}), do: key

  def key(%__MODULE__{} = message, key) do
    %__MODULE__{message | key: key}
  end

  def value(%__MODULE__{value: value}), do: value

  def value(%__MODULE__{} = message, value) do
    %__MODULE__{message | value: value}
  end
end
