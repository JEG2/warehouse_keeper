require "minitest/autorun"

require_relative "../lib/warehouse_keeper/animation"

describe WarehouseKeeper::Animation do
  let(:animation) { WarehouseKeeper::Animation.new }

  it "switches status when it starts animating" do
    animation.wont_be(:started?)
    animation.start_animating
    animation.must_be(:started?)
  end

  it "switches status when it finishes animating" do
    animation.wont_be(:finished?)
    animation.finish_animating
    animation.must_be(:finished?)
  end

  it "only calls the start code once" do
    calls = 0
    animation.start do
      calls += 1
    end
    3.times do
      animation.trigger
    end
    calls.must_equal(1)
  end

  it "calls the update code each time it is triggered" do
    calls = 0
    animation.update do
      calls += 1
    end
    3.times do
      animation.trigger
    end
    calls.must_equal(3)
  end

  it "allows the code to manually finish the animation" do
    calls = 0
    animation.update do
      calls += 1
      animation.finish_animating if calls == 2
    end
    3.times do
      animation.trigger
    end
    calls.must_equal(2)
  end

  it "can automatically finish an animation after a given length" do
    animation = WarehouseKeeper::Animation.new(0.1)
    calls = 0
    animation.update do
      calls += 1
    end
    animation.trigger
    animation.trigger  # too fast, not ended yet
    sleep 0.1          # enough time to end the animation
    animation.trigger  # a final update is trigger before things end
    animation.trigger
    calls.must_equal(3)
  end

  it "calls the finish code when the animation ends" do
    calls = 0
    animation.finish do
      calls += 1
    end
    3.times do |n|
      animation.trigger
      animation.finish_animating if n == 2
    end
    calls.must_equal(1)
  end

  it "knows how long the animation has been active" do
    animation.start_animating
    sleep 0.1
    animation.elapsed.must_be(:>=, 0.1)
  end
end
