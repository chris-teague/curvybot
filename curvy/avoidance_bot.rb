class AvoidanceBot < Personality

  attr_accessor :next_move, :previous_move, :random_direction_details

  DistanceToPanic = 1000

  NAME = "AvoidyBot#{rand(1000)}"

  def position_updated
    if next_move_sorted?
      apply_next_move
    elsif going_to_hit_wall?
      avoid_wall
    else
      #randomly_continue
    end
  end

  def name
    NAME
  end

  protected

    def next_move_sorted?
      puts 'Next move sorted'
      @next_move
    end

    def apply_next_move
      send(@next_move[:direction]) if @next_move[:direction] != @previous_move
      @previous_move = @next_move[:direction]
      @next_move[:count] = @next_move[:count] - 1
      @next_move = nil if @next_move[:count] <= 0
    end

    def going_to_hit_wall?
      return false if direction_vector.nil? || direction_vector.norm == 0

      dv = direction_vector.normalize * DistanceToPanic
      current = @geo_factory.point(position[0], position[1])
      future  = @geo_factory.point(position[0] + dv[0], position[1] + dv[1])
      line    = @geo_factory.line(current, future)

      @battlefield.started_game!

      line.intersects?(@battlefield.boundaries)
    end

    def avoid_wall
      # going to hit.
      # get distance
      # get distance left
      # get distance right
      current = @geo_factory.point(position[0], position[1])

      lv = direction_left.normalize * (@battlefield.size * 2)
      rv = direction_right.normalize * (@battlefield.size * 2)
      sv = direction_vector.normalize * (@battlefield.size * 2)

      left_point     = @geo_factory.point(position[0] + lv[0], position[1] + lv[1])
      right_point    = @geo_factory.point(position[0] + rv[0], position[1] + rv[1])
      straight_point = @geo_factory.point(position[0] + sv[0], position[1] + sv[1])

      line_left      = @geo_factory.line(current, left_point)
      line_right     = @geo_factory.line(current, right_point)
      line_straight  = @geo_factory.line(current, straight_point)

      distance_straight = { distance: @battlefield.boundaries.intersection(line_straight).distance(current), direction: :straight! }
      distance_left     = { distance: @battlefield.boundaries.intersection(line_left).distance(current),  direction: :left! }
      distance_right    = { distance: @battlefield.boundaries.intersection(line_right).distance(current), direction: :right! }

      result = [distance_straight, distance_left, distance_right].sort_by { |a| -a[:distance] }.first

      puts "WALL DISTANCE:"
      puts "LEFT: #{distance_left} RIGHT: #{distance_right} STRAIGHT: #{distance_straight}"
      puts "MOVING: #{result[:direction]}"
      send(result[:direction])

      if result[:distance] > 800
        count = 8
      else
        count = 12
      end

      @next_move = { direction: direction, count: count }
      @previous_move = direction

      # all = @geo_factory.collection([@battlefield.boundaries, line_left, line_right, line_straight])

      puts 'MOVE OUT THE WAY!'

    end

    def randomly_continue
      if @random_direction_details
        direction, count = @random_direction_details
        if count > 0
          send(direction)
          @random_direction_details = [direction, count - 1]
        else
          @random_direction_details = nil
        end
      else
        @random_direction_details = [[:left!, :right!, :straight!].shuffle.first, rand(1..70)]
      end
    end

end
