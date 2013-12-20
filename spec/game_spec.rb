require "minitest/autorun"

require_relative "../lib/warehouse_keeper/game"

describe WarehouseKeeper::Game do
  LEVEL_1_SOLUTION = %w[
    up left left left up up up left up left left down left left down down down
    right right right right right right right right right right right up right
    down left left left left left left left left left left left left up left
    left down right right right right right right right right right right right
    right right down right right left up left left left left left left left up
    up up left up left left down down down up up left left down down down right
    right right right right right right right right right right up right right
    left down left left left left left left left up up up left left up left down
    down down up up left left down down down right right right right right right
    right right right right right down right up left left left left left left
    left up up up left left up up up right down down up up left left down down
    down down down up up left left down down down right right right right right
    right right right right right right right right left left left left left
    left left left up up up left left up left down down down up up left left
    down down down right right right right right right right right right right
    right right left up right
  ]

  it "loads the requested level" do
    level_1 = WarehouseKeeper::Game.new(1)
    level_1.level[11, 8].must_be(:has_player?)

    level_2 = WarehouseKeeper::Game.new(2)
    level_2.level[7, 4].must_be(:has_player?)
  end

  it "defaults to level one" do
    default = WarehouseKeeper::Game.new(nil)
    default.level[11, 8].must_be(:has_player?)
  end

  it "ignores out of range levels" do
    default = WarehouseKeeper::Game.new(0)
    default.level[11, 8].must_be(:has_player?)
  end

  it "can move the player to a legal square" do
    game = WarehouseKeeper::Game.new(1)
    game.level[11, 8].must_be(:has_player?)
    game.move_up
    game.level[11, 7].must_be(:has_player?)
  end

  it "ignores moves into walls" do
    game = WarehouseKeeper::Game.new(1)
    game.level[11, 8].must_be(:has_player?)
    game.move_down
    game.level[11, 8].must_be(:has_player?)
  end

  it "allows the player to push gems" do
    game = WarehouseKeeper::Game.new(7)
    game.level[5, 2].must_be(:has_player?)
    game.level[5, 3].must_be(:has_gem?)
    game.move_down
    game.level[5, 3].must_be(:has_player?)
    game.level[5, 4].must_be(:has_gem?)
  end

  it "doesn't allow the player to push a gem into things" do
    game = WarehouseKeeper::Game.new(12)
    game.level[7, 3].must_be(:has_gem?)
    game.level[7, 4].must_be(:has_player?)
    game.move_up
    game.level[7, 3].must_be(:has_gem?)
    game.level[7, 4].must_be(:has_player?)
  end

  it "knows when a level is solved" do
    game = WarehouseKeeper::Game.new(1)
    LEVEL_1_SOLUTION.each do |direction|
      game.wont_be(:solved?)
      game.send("move_#{direction}")
    end
    game.must_be(:solved?)
  end

  it "can advance to the next level" do
    game = WarehouseKeeper::Game.new(1)
    game.level[11, 8].must_be(:has_player?)
    game.next_level
    game.level[7, 4].must_be(:has_player?)
  end

  it "knows when it is out of levels" do
    game = WarehouseKeeper::Game.new(90)
    game.wont_be(:over?)
    game.next_level
    game.must_be(:over?)
  end
end
