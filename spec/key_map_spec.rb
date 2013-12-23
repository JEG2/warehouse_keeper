require "minitest/autorun"

require_relative "../lib/warehouse_keeper/key_map"

describe WarehouseKeeper::KeyMap do
  class Trigger
    def initialize
      @count = 0
    end

    attr_reader :count

    def trigger
      @count += 1
    end

    def triggered?
      @count > 0
    end
  end

  def keys(mapping)
    keys = Minitest::Mock.new
    mapping.each do |key, down|
      keys.expect(:button_down?, down, [key])
    end
    keys
  end

  let(:flag) { Trigger.new }
  let(:map)  { WarehouseKeeper::KeyMap.new }

  it "triggers mapped code when keys are pressed" do
    map.map_key(42) do
      flag.trigger
    end
    map.trigger(keys(42 => true))
    flag.must_be(:triggered?)
  end

  it "doesn't trigger mapped code if the key isn't pressed" do
    map.map_key(42) do
      flag.trigger
    end
    map.trigger(keys(42 => false))
    flag.wont_be(:triggered?)
  end

  it "can map multiple keys to the same action" do
    map.map_key(1, 2) do
      flag.trigger
    end
    map.trigger(keys(1 => false, 2 => true))
    flag.must_be(:triggered?)
  end

  it "supports an optional delay on key mappings" do
    map.map_key(42, delay: 0.1) do
      flag.trigger
    end
    map.trigger(keys(42 => true))
    map.trigger(keys(42 => true))  # too fast, ignored
    sleep 0.1
    map.trigger(keys(42 => true))
    flag.count.must_equal(2)
  end
end
