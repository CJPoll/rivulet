defmodule Rivulet.Kafka.Consumer.Config do
  alias Rivulet.Kafka.Partition

  @enforce_keys [:client_id, :consumer_group_name, :topics]

  defstruct [
    :client_id,
    :consumer_group_name,
    :topics,
    group_config: [
      offset_commit_policy: :commit_to_kafka_v2,
      offset_commit_interval_seconds: 5
    ],
    consumer_config: [begin_offset: :earliest, offset_reset_policy: :reset_to_earliest]
  ]

  @type t :: %__MODULE__{
          client_id: atom,
          consumer_group_name: String.t(),
          topics: [Partition.topic()],
          group_config: Keyword.t(),
          consumer_config: Keyword.t()
        }
end
