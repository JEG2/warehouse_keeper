require "minitest/autorun"

describe WarehouseKeeper::Level do
  let(:minimal) { WarehouseKeeper::Level.parse( "######" +
                                                "#@$ .#" +
                                                "######" ) }

  it "parses walls" do
    minimal[0, 0].is_a?(WarehouseKeeper::Level::Wall)
  end
end
