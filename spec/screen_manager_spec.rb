require "minitest/autorun"

require_relative "../lib/warehouse_keeper/screen_manager"

describe WarehouseKeeper::ScreenManager do
  let(:window)         { Object.new }
  let(:screen_manager) { WarehouseKeeper::ScreenManager.new(window) }

  it "can construct screens that have been added" do
    screen = Minitest::Mock.new
    screen.expect(:new, screen, [window, screen_manager])
    screen_manager.add_screen(:test, screen)
    screen_manager.activate_screen(:test)
    screen.verify
  end

  it "forwards extra arguments to the screen on activation" do
    screen = Minitest::Mock.new
    screen.expect(:new, screen, [window, screen_manager, :extra])
    screen_manager.add_screen(:test, screen)
    screen_manager.activate_screen(:test, :extra)
    screen.verify
  end

  it "tosses an error when trying to activate an unknown screen" do
    -> do
      screen_manager.activate_screen(:not_added)
    end.must_raise(KeyError)
  end

  it "forwards update and draw calls to the active screen" do
    screen = Minitest::Mock.new
    screen.expect(:new,    screen, [window, screen_manager])
    screen.expect(:update, :updated)
    screen.expect(:draw,   :drawn)
    screen_manager.add_screen(:test, screen)
    screen_manager.activate_screen(:test)
    screen_manager.update.must_equal(:updated)
    screen_manager.draw.must_equal(:drawn)
    screen.verify
  end
end
