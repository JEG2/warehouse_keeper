require_relative "key_map"
require_relative "animation"

module WarehouseKeeper
  class Screen
    IMAGES_DIR = File.join(__dir__, *%w[.. .. images])

    def initialize(window, screen_manager, *extra_args)
      @window         = window
      @screen_manager = screen_manager
      @images         = { }
      @key_map        = KeyMap.new
      @animations     = [ ]

      init_screen(*extra_args)
      init_images
      init_keys
      init_animations
    end

    attr_reader :images, :key_map, :window, :screen_manager, :animations
    private     :images, :key_map, :window, :screen_manager, :animations

    # hooks that subclasses can override
    def init_screen(*extra_args); end
    def init_images;              end
    def init_keys;                end
    def init_animations;          end

    def update
      key_map.trigger(window)
      animations.reject! { |animation|
        animation.trigger
        animation.finished?
      }
    end

    def draw
      fail NotImplementedError, "Screen subclasses must provide a draw()"
    end

    private

    def load_image(name, file_name, tileable, image_type = Gosu::Image)
      images[name] = image_type.new( window,
                                     File.join(IMAGES_DIR, "#{file_name}.png"),
                                     tileable )
    end

    def draw_image(name, x, y, z = 0)
      images[name].draw(x, y, z)
    end

    def map_key(*args, &block)
      key_map.map_key(*args, &block)
    end

    def animate(*args)
      animation = Animation.new(*args)
      yield animation
      animations << animation
    end
  end
end
