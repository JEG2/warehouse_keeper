require "minitest/autorun"

require_relative "../lib/warehouse_keeper/level"

describe WarehouseKeeper::Level do
  let(:minimal) { WarehouseKeeper::Level.parse( "######\n" +
                                                "#@$ .#\n" +
                                                "######\n" ) }

  it "parses walls" do
    minimal[0, 0].must_be_instance_of(WarehouseKeeper::Level::Wall)
  end

  it "parses floor" do
    minimal[3, 1].must_be_instance_of(WarehouseKeeper::Level::Floor)
  end

  it "parses goal" do
    minimal[4, 1].must_be_instance_of(WarehouseKeeper::Level::Goal)
  end

end
