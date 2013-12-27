require_relative "screen"

module WarehouseKeeper
  class AnnounceScreen < Screen
    FONT_SIZE         = 72
    FULL_COLOR        = 255
    ANIMATION_SECONDS = 3.0

    def init_screen(game)
      @game    = game
      @font    = Gosu::Font.new(window, Gosu.default_font_name, FONT_SIZE)
      @white   = Gosu::Color::WHITE
      @opacity = 1.0
    end

    attr_reader :game, :font, :white, :opacity
    private     :game, :font, :white, :opacity

    def init_animations
      animate(ANIMATION_SECONDS) do |animation|
        animation.update do
          @opacity = animation.elapsed / ANIMATION_SECONDS
        end
        animation.finish do
          if game.over?
            window.close
          else
            screen_manager.activate_screen(:play, game)
          end
        end
      end
    end

    def draw
      announcement = game.over? ? "You Win" : "Level #{game.current_level}"
      color        = Gosu::Color.argb( FULL_COLOR - FULL_COLOR * opacity,
                                       white.red,
                                       white.green,
                                       white.blue )
      font.draw( announcement,
                 20,
                 window.height - (font.height + 20),
                 0,
                 1,
                 1,
                 color )
    end
  end
end
