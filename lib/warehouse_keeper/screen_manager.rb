module WarehouseKeeper
  class ScreenManager
    def initialize(window)
      @screens = { }
      @active  = nil
      @window  = window
    end

    attr_reader :screens, :active, :window
    private     :screens, :active, :window

    def add_screen(name, screen_type)
      @screens[name] = screen_type
    end

    def activate_screen(name, *extra_args)
      @active = screens[name].new(window, self, *extra_args)
    end

    def update
      active.update
    end

    def draw
      active.draw
    end
  end
end
