module WarehouseKeeper
  class Game
    def initialize(start_level)
      @current_level = start_level.is_a?(Integer) &&
                       start_level.between?(1, 89) ? start_level : 1
      reset

      @player_x     = nil
      @player_y     = nil
      @total_gems   = 0
      @gems_on_goal = 0
      find_player_and_count_gems
    end

    attr_reader :level

    attr_reader :current_level, :player_x, :player_y, :total_gems, :gems_on_goal
    private     :current_level, :player_x, :player_y, :total_gems, :gems_on_goal

    def reset
      @level = Level.from_file(current_level)
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

    private

    def find_player_and_count_gems
      level.each_with_index do |row, y|
        row.each_with_index do |cell, x|
          if level[x, y].is_a?(Level::Floor) &&
             level[x, y].contents.is_a?(Level::Player)
            @player_x = x
            @player_y = y
          elsif level[x, y].is_a?(Level::Floor) &&
             level[x, y].contents.is_a?(Level::Gem)
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
        ( cell.contents.is_a?(Level::Gem) &&
          cell_beyond.is_a?(Level::Floor) &&
          cell_beyond.contents.nil? ) )
    end

    def move_to(cell, beyond)
      if cell.contents.is_a?(Level::Gem)
        beyond.contents = cell.contents
        cell.contents   = nil
        if beyond.is_a?(Level::Goal) && !cell.is_a?(Level::Goal)
          @gems_on_goal += 1
        elsif !beyond.is_a?(Level::Goal) && cell.is_a?(Level::Goal)
          @gems_on_goal -= 1
        end
        return next_level if solved?
      end
      player                             = level[player_x, player_y].contents
      level[player_x, player_y].contents = nil
      cell.contents                      = player
    end
  end
end
