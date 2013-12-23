require "gosu"

module WarehouseKeeper
  class Window < Gosu::Window
    WIDTH      = 700
    HEIGHT     = 510
    FULLSCREEN = false

    IMAGES_DIR = File.join(__dir__, *%w[.. .. images])

    KEY_DELAY = 0.25

    def initialize(start_level)
      super(WIDTH, HEIGHT, FULLSCREEN)
      self.caption = "Warehouse Keeper"

      @game = Game.new(start_level)

      @images = { }
      load_image(:floor,     "Stone Block",         true)
      load_image(:goal,      "Wood Block",          true)
      load_image(:wall,      "Wall Block Tall",     true)
      load_image(:player,    "Character Horn Girl", false)
      load_image(:floor_gem, "Gem Orange",          false)
      load_image(:goal_gem,  "Gem Green",           false)

      @scale_factor = [ HEIGHT.to_f / game.level.height / 80,
                        WIDTH.to_f  / game.level.width  / 101 ].min

      @key_map = KeyMap.new
      key_map.map_key(Gosu::KbEscape) do
        close
      end
      key_map.map_key(Gosu::KbR) do
        game.reset
      end
      key_map.map_key(Gosu::KbUp, Gosu::KbW, delay: KEY_DELAY) do
        move(:up)
      end
      key_map.map_key(Gosu::KbRight, Gosu::KbD, delay: KEY_DELAY) do
        move(:right)
      end
      key_map.map_key(Gosu::KbDown, Gosu::KbS, delay: KEY_DELAY) do
        move(:down)
      end
      key_map.map_key(Gosu::KbLeft, Gosu::KbA, delay: KEY_DELAY) do
        move(:left)
      end
    end

    attr_reader :game, :images, :scale_factor, :key_map
    private     :game, :images, :scale_factor, :key_map

    def update
      key_map.trigger(self)
    end

    def draw
      scale(scale_factor) do
        game.level.each_with_index do |row, y|
          row.each_with_index do |cell, x|
            x_offset, y_offset = x * 101, y * 80
            case cell
            when WarehouseKeeper::Level::Goal
              draw_image(:goal, x_offset, y_offset)
              draw_contents(cell, x_offset, y_offset)
            when WarehouseKeeper::Level::Floor
              draw_image(:floor, x_offset, y_offset)
              draw_contents(cell, x_offset, y_offset)
            when WarehouseKeeper::Level::Wall
              draw_image(:wall, x * 101, y * 80)
            end
          end
        end
      end
    end

    private

    def load_image(name, file_name, tileable)
      images[name] = Gosu::Image.new( self,
                                      File.join(IMAGES_DIR, "#{file_name}.png"),
                                      tileable )
    end

    def draw_image(name, x, y, z = 0)
      images[name].draw(x, y, z)
    end

    def draw_contents(cell, x, y)
      return if cell.contents.nil?
      name = cell.contents.class.name[/\w+\z/].downcase
      if name == "gem"
        name = "#{cell.class.name[/\w+\z/].downcase}_#{name}"
      end
      draw_image(name.to_sym, x, y - 36)
    end

    def move(direction)
      game.send("move_#{direction}")
      game.next_level if game.solved?
    end
  end
end
