module WarehouseKeeper
  class Animation
    def initialize(length = nil)
      @length      = length
      @start_code  = nil
      @started_at  = nil
      @started     = false
      @update_code = nil
      @finish_code = nil
      @finished    = false
    end

    attr_reader :length, :start_code, :started_at, :update_code, :finish_code
    private     :length, :start_code, :started_at, :update_code, :finish_code

    def started?
      @started
    end

    def finished?
      @finished
    end

    def start(&code)
      @start_code = code
    end

    def update(&code)
      @update_code = code
    end

    def finish(&code)
      @finish_code = code
    end

    def start_animating
      start_code.call if start_code
      @started_at = Time.now
      @started    = true
    end

    def elapsed
      Time.now - started_at
    end

    def finish_animating
      finish_code.call if finish_code
      @finished = true
    end

    def trigger
      return if finished?

      start_animating  unless started?
      update_code.call if     update_code
      finish_animating if     length && elapsed >= length
    end
  end
end
