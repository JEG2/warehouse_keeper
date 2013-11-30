module WarehouseKeeper
  class Level
    class Wall; end
    class Player; end
    class Gem; end
    class Floor; end
    class Goal; end

    KEY = {
      "#" => Wall,
      "@" => Player,
      "$" => Gem,
      " " => Floor,
      "." => Goal
    }

    def self.parse(string)
      input = string.split("\n")
      rows = input.map { |row| row.split(//).map { |cell|
        KEY[cell].new
        } }
      new(rows)
    end

    def initialize(rows)
      @rows = rows
    end

    def [](x,y)
      @rows[y][x]
    end
  end
end
