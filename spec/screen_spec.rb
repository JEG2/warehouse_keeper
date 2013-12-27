require "minitest/autorun"

require_relative "../lib/warehouse_keeper/screen"

describe WarehouseKeeper::Screen do
  let(:window)         { Minitest::Mock.new }
  let(:screen_manager) { Minitest::Mock.new }

  it "invokes initialization hooks as a screen is constructed" do
    # build a type of screen
    screen = Class.new(WarehouseKeeper::Screen) do
      # track which hooks are invoked
      def self.invoked
        @invoked ||= [ ]
      end
      superclass.instance_methods(false).grep(/\Ainit_/) do |method|
        define_method(method) do |*|
          self.class.invoked << method
        end
      end
    end

    # trigger the hooks
    screen.new(window, screen_manager)

    # verify that hooks were called
    %i[ init_screen init_images
        init_keys   init_animations ].must_equal(screen.invoked)
  end

  it "forwards extra contructor arguments to the screen initialization hook" do
    # build a type of screen
    screen = Class.new(WarehouseKeeper::Screen) do
      def init_screen(*args)
        @hook_args = args
      end
      attr_reader :hook_args
    end

    # trigger the hooks
    active = screen.new(window, screen_manager, 2, :extra)

    # verify the args
    active.hook_args.must_equal([2, :extra])
  end

  it "maintains and triggers a key map as needed" do
    triggered = false
    # build a type of screen
    screen    = Class.new(WarehouseKeeper::Screen) do
      define_method(:init_keys) do
        map_key(42) do
          triggered = true
        end
      end
    end

    # trigger key checking
    window.expect(:button_down?, true, [42])
    screen.new(window, screen_manager).update

    # verify that the key code was triggered
    window.verify
    triggered.must_equal(true)
  end

  it "runs animations as needed" do
    calls  = 0
    # build a type of screen
    screen = Class.new(WarehouseKeeper::Screen) do
      define_method(:init_animations) do
        animate do |animation|
          animation.update do
            calls += 1
            animation.finish_animating if calls == 2
          end
        end
      end
    end

    # run the animation a few times
    active = screen.new(window, screen_manager)
    3.times do
      active.update
    end

    # verify that it ran and was retired as expected
    calls.must_equal(2)
  end

  it "can manage loaded images" do
    image         = Minitest::Mock.new
    path          = File.join(WarehouseKeeper::Screen::IMAGES_DIR, "image.png")
    image_builder = Minitest::Mock.new
    image_builder.expect(:new, image, [window, path, true])
    # build a type of screen
    screen = Class.new(WarehouseKeeper::Screen) do
      define_method(:init_images) do
        load_image(:test, "image", true, image_builder)
      end
      def draw
        draw_image(:test, 1, 2, 3)
      end
    end

    # draw the image
    image.expect(:draw, :drawn, [1, 2, 3])
    screen.new(window, screen_manager).draw

    # verify that it ran and was retired as expected
    image_builder.verify
    image.verify
  end

  it "requires drawing code" do
    active = Class.new(WarehouseKeeper::Screen).new(window, screen_manager)
    -> do
      active.draw
    end.must_raise(NotImplementedError)
  end
end
