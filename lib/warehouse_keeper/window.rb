require "gosu"

module WarehouseKeeper
  class Window < Gosu::Window
    WIDTH        = 700
    HEIGHT       = 510
    FULLSCREEN   = false
    WINDOW_TITLE = "Warehouse Keeper"

    def initialize(start_level)
      super(WIDTH, HEIGHT, FULLSCREEN)
      self.caption = WINDOW_TITLE

      @screen_manager = ScreenManager.new(self)
      @screen_manager.add_screen(:announce, AnnounceScreen)
      @screen_manager.add_screen(:play, PlayScreen)
      @screen_manager.activate_screen(:announce, Game.new(start_level))
    end

    attr_reader :screen_manager
    private     :screen_manager

    def update
      screen_manager.update
    end

    def draw
      screen_manager.draw
    end
  end
end
