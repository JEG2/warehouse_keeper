require_relative "screen"

module WarehouseKeeper
  class PlayScreen < Screen
    TILE_WIDTH   = 101
    TILE_HEIGHT  = 80
    TILE_OVERLAP = 36

    KEY_DELAY = 0.25

    def initialize(window, game)
      @game = game

      super(window)
    end

    attr_reader :game
    private     :game

    def draw
      window.scale(scale_factor) do
        game.level.each_with_index do |row, y|
          row.each_with_index do |cell, x|
            x_offset, y_offset = x * TILE_WIDTH, y * TILE_HEIGHT
            case cell
            when Level::Goal
              draw_image(:goal, x_offset, y_offset)
              draw_contents(cell, x_offset, y_offset)
            when Level::Floor
              draw_image(:floor, x_offset, y_offset)
              draw_contents(cell, x_offset, y_offset)
            when Level::Wall
              draw_image(:wall, x * TILE_WIDTH, y * TILE_HEIGHT)
            end
          end
        end
      end
    end

    private

    def init_images
      load_image(:floor,     "Stone Block",         true)
      load_image(:goal,      "Wood Block",          true)
      load_image(:wall,      "Wall Block Tall",     true)
      load_image(:player,    "Character Horn Girl", false)
      load_image(:floor_gem, "Gem Orange",          false)
      load_image(:goal_gem,  "Gem Green",           false)
    end

    def init_keys(screen_manager)
      map_key(Gosu::KbEscape) do
        window.close
      end
      map_key(Gosu::KbR) do
        game.reset
      end
      map_key(Gosu::KbUp, Gosu::KbW, delay: KEY_DELAY) do
        move(:up)
      end
      map_key(Gosu::KbRight, Gosu::KbD, delay: KEY_DELAY) do
        move(:right)
      end
      map_key(Gosu::KbDown, Gosu::KbS, delay: KEY_DELAY) do
        move(:down)
      end
      map_key(Gosu::KbLeft, Gosu::KbA, delay: KEY_DELAY) do
        move(:left)
      end
    end

    def scale_factor
      @scale_factor ||= [
        window.height.to_f / game.level.height / TILE_HEIGHT,
        window.width.to_f  / game.level.width  / TILE_WIDTH
      ].min
    end

    def draw_contents(cell, x, y)
      return if cell.contents.nil?
      name = cell.contents.class.name[/\w+\z/].downcase
      if name == "gem"
        name = "#{cell.class.name[/\w+\z/].downcase}_#{name}"
      end
      draw_image(name.to_sym, x, y - TILE_OVERLAP)
    end

    def move(direction)
      game.send("move_#{direction}")
      game.next_level if game.solved?
    end
  end
end
