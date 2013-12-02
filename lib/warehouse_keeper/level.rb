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
    end

    attr_reader :player_start_x, :player_start_y

    def [](x,y)
      return if x < 0 || y < 0 || x >= @rows.first.size || y >= @rows.size
      @rows[y][x]
    end

    def each(&block)
      @rows.each(&block)
    end
  end
end
