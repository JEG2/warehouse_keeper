require 'gosu'

module WarehouseKeeper
  class Window < Gosu::Window

    WIDTH  = 800
    HEIGHT = 600

    def initialize
      super(WIDTH,HEIGHT,false)
      self.caption = "Warehouse Keeper"
      @level = WarehouseKeeper::Level.from_file(1)

      @floor = Gosu::Image.new(self, File.join(__dir__,
                                               %w[ .. .. images
                                                   Stone\ Block.png ]
                                               ), true)
      @goal = Gosu::Image.new(self, File.join(__dir__,
                                              %w[ .. .. images
                                                   Wood\ Block.png ]
                                              ), true)

      @wall = Gosu::Image.new(self, File.join(__dir__,
                                              %w[ .. .. images
                                                   Wall\ Block\ Tall.png ]
                                              ), true)

      @player = Gosu::Image.new(self, File.join(__dir__,
                                                %w[ .. .. images
                                                   Character\ Horn\ Girl.png ]
                                                ), true)
      @gem = Gosu::Image.new(self, File.join(__dir__,
                                                %w[ .. .. images
                                                   Gem\ Orange.png ]
                                                ), true)

    end

    def update
    end

    def draw
      y_scale = (HEIGHT.to_f / @level.to_a.size) / 80
      x_scale = (WIDTH.to_f / @level.first.size) / 101

      factor  = [y_scale, x_scale].min
      scale(factor) {
        @level.each_with_index do |row, y|
          row.each_with_index do |cell, x|
            if cell.is_a?(WarehouseKeeper::Level::Goal)
              @goal.draw(x * 101, y * 80, 0)
            elsif cell.is_a?(WarehouseKeeper::Level::Floor)
              @floor.draw(x * 101, y * 80, 0)

              if cell.contents.is_a?(WarehouseKeeper::Level::Player)
                @player.draw(x * 101, y * 80 - 36, 0)
              elsif cell.contents.is_a?(WarehouseKeeper::Level::Gem)
                @gem.draw(x * 101, y * 80 - 36, 0)
              end

            elsif cell.is_a?(WarehouseKeeper::Level::Wall)
              @wall.draw(x * 101, y * 80, 0)
            end
          end
        end
      }
    end

  end
end
