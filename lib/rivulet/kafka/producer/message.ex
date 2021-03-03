defmodule Rivulet.Kafka.Producer.Message do
  @enforce_keys [:topic, :partition_strategy, :encoding_strategy, :value]
  defstruct [:topic, :partition, :partition_strategy, :encoding_strategy, :key, :value]

  alias Rivulet.Kafka.{Partition, Producer}

  @type t :: %__MODULE__{
          topic: Partition.topic(),
          # Don't set this directly - used by the publish module after resolving the partition_strategy.
          partition: Partition.partition_number(),
          partition_strategy: Producer.partition_strategy(),
          encoding_strategy: Producer.encoding_strategy(),
          key: Producer.key(),
          value: Producer.value()
        }
end
