class AvoidanceBot < Personality

  attr_accessor :desired_direction, :random_direction_details

  DistanceToPanic = 800

  def position_updated
    if going_to_hit_wall?
      avoid_wall
    else
      randomly_continue
    end
  end

  protected

    def going_to_hit_wall?
      return false if direction_vector.norm == 0

      dv = direction_vector.normalize * DistanceToPanic
      current = @geo_factory.point(position[0], position[1])
      future  = @geo_factory.point(position[0] + dv[0], position[1] + dv[1])
      line    = @geo_factory.line(current, future)

      @battlefield.started_game!

      if line.intersects?(@battlefield.boundaries)
        # going to hit.
        # get distance
        # get distance left
        # get distance right

        lv = direction_left.normalize * DistanceToPanic
        rv = direction_right.normalize * DistanceToPanic

        left_point  = @geo_factory.point(position[0] + lv[0], position[1] + lv[1])
        right_point = @geo_factory.point(position[0] + rv[0], position[1] + rv[1])

        line_left   = @geo_factory.line(current, left_point)
        line_right  = @geo_factory.line(current, right_point)

        distance_straight = { distance: line.distance(@battlefield.boundaries),       direction: :left! }
        distance_left     = { distance: line_left.distance(@battlefield.boundaries),  direction: :right! }
        distance_right    = { distance: line_right.distance(@battlefield.boundaries), direction: :straight! }

        direction = [distance_straight, distance_left, distance_right].sort_by { |a| a[:distance] }.first
        send(direction)

        true
      else
        false
      end
    end

    def avoid_wall
      set_desired_direction_as_center
    end

    def set_desired_direction_as_center
      return if @desired_direction
      center_vector = [map_size/2 - @position[0], map_size/2 - @position[1]]
      @desired_direction = Math.atan2(*center_vector) * 180/ Math::PI
    end

    def spin_towards_desired_direction
      # puts "DESIRED DIRECTION: #{@desired_direction}"
      dir = @desired_direction - direction

      if dir >= 0 && dir < 180
        left!
      elsif dir >= 180
        left!
      elsif dir < 0 && dir >= -180
        left!
      elsif dir < -180
        left!
      end
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
