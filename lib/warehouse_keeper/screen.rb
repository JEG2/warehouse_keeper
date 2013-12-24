require_relative "key_map"

module WarehouseKeeper
  class Screen
    IMAGES_DIR = File.join(__dir__, *%w[.. .. images])

    def initialize(window)
      @images  = { }
      @key_map = KeyMap.new
      @window  = window

      init_images
      init_keys(self)
    end

    attr_reader :images, :key_map, :window
    private     :images, :key_map, :window

    def update
      key_map.trigger(window)
    end

    def draw
      fail NotImplementedError, "Screen subclasses must provide a draw()"
    end

    private

    def init_images
      # do nothing:  this is a hook that subclasses can override
    end

    def init_keys(screen_manager)
      # do nothing:  this is a hook that subclasses can override
    end

    def load_image(name, file_name, tileable)
      images[name] = Gosu::Image.new( window,
                                      File.join(IMAGES_DIR, "#{file_name}.png"),
                                      tileable )
    end

    def draw_image(name, x, y, z = 0)
      images[name].draw(x, y, z)
    end

    def map_key(*args, &block)
      key_map.map_key(*args, &block)
    end
  end
end
