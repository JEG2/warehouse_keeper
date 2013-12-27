require_relative "level"

module WarehouseKeeper
  class Game
    def initialize(start_level)
      @current_level = start_level.is_a?(Integer) &&
                       start_level.between?(1, 90) ? start_level : 1
      reset
    end

    attr_reader :current_level, :level

    attr_reader :player_x, :player_y, :total_gems, :gems_on_goal
    private     :player_x, :player_y, :total_gems, :gems_on_goal

    def reset
      @level = Level.from_file(current_level)
      find_player_and_count_gems
    end

    def move_up
      try_move_to(:y, -1)
    end

    def move_right
      try_move_to(:x, 1)
    end

    def move_down
      try_move_to(:y, 1)
    end

    def move_left
      try_move_to(:x, -1)
    end

    def solved?
      gems_on_goal == total_gems
    end

    def next_level
      @current_level += 1
      reset
    end

    def over?
      level.nil?
    end

    private

    def find_player_and_count_gems
      @player_x     = nil
      @player_y     = nil
      @total_gems   = 0
      @gems_on_goal = 0

      return if level.nil?

      level.each_with_index do |row, y|
        row.each_with_index do |cell, x|
          if level[x, y].has_player?
            @player_x = x
            @player_y = y
          elsif level[x, y].has_gem?
            @total_gems   += 1
            @gems_on_goal += 1 if level[x, y].is_a?(Level::Goal)
          end
        end
      end
    end

    def try_move_to(axis, offset)
      xy                      = [player_x, player_y]
      xy[axis == :x ? 0 : 1] += offset
      move_xy                 = xy.dup
      cell                    = level[*xy]
      xy[axis == :x ? 0 : 1] += offset
      beyond                  = level[*xy]
      if can_move_to?(cell, beyond)
        move_to(cell, beyond)
        @player_x, @player_y = move_xy
      end
    end

    def can_move_to?(cell, cell_beyond)
      cell.is_a?(Level::Floor) &&
      ( cell.contents.nil? ||
        ( cell.has_gem? &&
          cell_beyond.is_a?(Level::Floor) &&
          cell_beyond.contents.nil? ) )
    end

    def move_to(cell, beyond)
      if cell.has_gem?
        beyond.contents = cell.contents
        cell.contents   = nil
        if beyond.is_a?(Level::Goal) && !cell.is_a?(Level::Goal)
          @gems_on_goal += 1
        elsif !beyond.is_a?(Level::Goal) && cell.is_a?(Level::Goal)
          @gems_on_goal -= 1
        end
      end
      player                             = level[player_x, player_y].contents
      level[player_x, player_y].contents = nil
      cell.contents                      = player
    end
  end
end
