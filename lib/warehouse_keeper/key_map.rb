module WarehouseKeeper
  class KeyMap
    class MappedAction
      def initialize(action, delay)
        @action       = action
        @delay        = delay
        @last_trigger = nil
      end

      attr_reader :action, :delay, :last_trigger
      private     :action, :delay, :last_trigger

      def trigger
        time = Time.now
        if delay.nil? || last_trigger.nil? || time - last_trigger >= delay
          action.call
          @last_trigger = time
        end
      end
    end

    def initialize
      @map = { }
    end

    attr_reader :map
    private     :map

    def map_key(*codes, &action)
      options = codes.last.is_a?(Hash) ? codes.pop : Hash.new

      fail ArgumentError, "at least one key code is required" if codes.empty?

      codes.each do |code|
        map[code] = MappedAction.new(action, options.fetch(:delay) { nil })
      end
    end

    def trigger(keys)
      map.each do |code, mapping|
        if keys.button_down?(code)
          mapping.trigger
        end
      end
    end
  end
end
