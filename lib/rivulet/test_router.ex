defmodule Rivulet.TestRouter do
  @moduledoc false
  use Rivulet.Kafka.Router,
    consumer_group: "test-rivulet"

  defstream "test-log" do
    transformer Rivulet.TestTransformer do
      publish_to("test-log-2",
        partition: :key
      )
    end

    transformer Rivulet.TestTransformer2 do
      publish_to("test-log-2",
        partition: :key
      )
    end
  end

  defstream "test-log-2" do
    transformer(Rivulet.Transformer.Inspect)
  end
end
