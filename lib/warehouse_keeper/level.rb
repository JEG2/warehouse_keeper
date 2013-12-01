module WarehouseKeeper
  class Level
    class Void; end
    class Wall; end
    class Floor
      def initialize(contents = nil)
        @contents = contents
      end

      attr_accessor :contents
    end
    class Goal < Floor; end

    class Player; end
    class Gem; end

    PARSE_KEY = {
      "-" => lambda { Void.new              },
      "#" => lambda { Wall.new              },
      " " => lambda { Floor.new             },
      "." => lambda { Goal.new              },
      "@" => lambda { Floor.new(Player.new) },
      "$" => lambda { Floor.new(Gem.new)    }
    }

    def self.parse(string)
      # build square board
      clean = string.gsub(/^ *(?:;.*)?\n/, "")
      width = clean.lines.map { |row| row.rstrip.size }.max
      rows  = clean.lines.map { |row| row.rstrip.ljust(width).chars }

      # fill-in void
      2.times do
        rows.each do |row|
          row.fill("-", 0, row.index("#"))
          row.fill("-", row.rindex("#") + 1)
        end
        rows = rows.transpose
      end

      # construct level
      new(
        rows.map { |row|
          row.map { |cell| PARSE_KEY[cell].call }
        }
      )
    end

    def self.from_file( num, path = File.join( __dir__,
                                               *%w[ ..
                                                    ..
                                                    levels
                                                    original_and_extra.txt ] ) )
      buffer = [ ]
      File.foreach(path) do |line|
        if line =~ /\A\s*;\s*(\d+)/
          if $1.to_i == num
            return parse(buffer.join)
          else
            buffer.clear
          end
        else
          buffer << line
        end
      end
    end

    include Enumerable

    def initialize(rows)
      @rows = rows
      find_player
    end

    def [](x,y)
      return if x < 0 || y < 0 || x >= @rows.first.size || y >= @rows.size
      @rows[y][x]
    end

    def each(&block)
      @rows.each(&block)
    end

    def move_up
      going_to = self[@player_xy.first, @player_xy.last - 1]
      beyond   = self[@player_xy.first, @player_xy.last - 2]
      move_to(going_to, beyond, @player_xy.first, @player_xy.last - 1) \
        if can_move_to?(going_to, beyond)
    end

    def move_right
      going_to = self[@player_xy.first + 1, @player_xy.last]
      beyond   = self[@player_xy.first + 2, @player_xy.last]
      move_to(going_to, beyond, @player_xy.first + 1, @player_xy.last) \
        if can_move_to?(going_to, beyond)
    end

    def move_down
      going_to = self[@player_xy.first, @player_xy.last + 1]
      beyond   = self[@player_xy.first, @player_xy.last + 2]
      move_to(going_to, beyond, @player_xy.first, @player_xy.last + 1) \
        if can_move_to?(going_to, beyond)
    end

    def move_left
      going_to = self[@player_xy.first - 1, @player_xy.last]
      beyond   = self[@player_xy.first - 2, @player_xy.last]
      move_to(going_to, beyond, @player_xy.first - 1, @player_xy.last) \
        if can_move_to?(going_to, beyond)
    end

    private

    def find_player
      @player_xy = nil
      @rows.each_with_index do |row, y|
        row.each_with_index do |cell, x|
          if self[x, y].is_a?(Floor) && self[x, y].contents.is_a?(Player)
            @player_xy = [x, y]
            break
          end
        end
        break if @player_xy
      end
    end

    def can_move_to?(cell, cell_beyond)
      cell.is_a?(Floor) &&
      ( cell.contents.nil? ||
        ( cell.contents.is_a?(Gem) &&
          cell_beyond.is_a?(Floor) &&
          cell_beyond.contents.nil? ) )
    end

    def move_to(cell, beyond, x, y)
      if cell.contents.is_a?(Gem)
        beyond.contents = cell.contents
        cell.contents   = nil
      end
      player                     = self[*@player_xy].contents
      self[*@player_xy].contents = nil
      cell.contents              = player
      @player_xy                 = [x, y]
    end
  end
end
