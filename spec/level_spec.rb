require "minitest/autorun"

require_relative "../lib/warehouse_keeper/level"

describe WarehouseKeeper::Level do
  let(:minimal) { WarehouseKeeper::Level.parse( "######\n" +
                                                "#@$ .#\n" +
                                                "######\n" ) }
  let(:tricky) {
    WarehouseKeeper::Level.parse(<<END_LEVEL)
    #####
    #   #
    #$  #
  ###  $##
  #  $ $ #
### # ## #   ######
#   # ## #####  ..#
# $  $          ..#
##### ### #@##  ..#
    #     #########
    #######
END_LEVEL
  }

  it "parses walls" do
    minimal[0, 0].must_be_instance_of(WarehouseKeeper::Level::Wall)
  end

  it "parses floor" do
    minimal[3, 1].must_be_instance_of(WarehouseKeeper::Level::Floor)
  end

  it "parses goal" do
    minimal[4, 1].must_be_instance_of(WarehouseKeeper::Level::Goal)
  end

  it "parses the player" do
    minimal[1, 1].must_be_instance_of(WarehouseKeeper::Level::Floor)
    minimal[1, 1].must_be(:has_player?)
  end

  it "parses gems" do
    minimal[2, 1].must_be_instance_of(WarehouseKeeper::Level::Floor)
    minimal[2, 1].must_be(:has_gem?)
  end

  it "parses gems on goals" do
    level = WarehouseKeeper::Level.parse( "#####\n" +
                                          "#@ *#\n" +
                                          "#####\n" )
    level[3, 1].must_be_instance_of(WarehouseKeeper::Level::Goal)
    level[3, 1].must_be(:has_gem?)
  end

  it "makes all levels square" do
    tricky.map { |row| row.size }.uniq.size.must_equal(1)
  end

  it "knows the dimensions of the level" do
    tricky.width.must_equal(19)
    tricky.height.must_equal(11)
  end

  it "ignores cells outside the board" do
    tricky[10, 5].must_be_instance_of(WarehouseKeeper::Level::Void)
    tricky[3, 5].must_be_instance_of(WarehouseKeeper::Level::Floor)
  end

  it "ignores comments and blank lines" do
    noisy = WarehouseKeeper::Level.parse(<<END_LEVEL)
; This is a comment

######
#@$ .#
######
; 1
END_LEVEL
    noisy.to_a.size.must_equal(3)
  end

  it "can parse a level from a file" do
    level_2 = WarehouseKeeper::Level.from_file(2)
    level_2[0, 0].must_be_instance_of(WarehouseKeeper::Level::Wall)
    level_2[12, 0].must_be_instance_of(WarehouseKeeper::Level::Void)
  end

  it "asking for a level not in the file returns nil" do
    WarehouseKeeper::Level.from_file(1_000_000).must_be_nil
  end
end
