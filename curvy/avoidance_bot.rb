class AvoidanceBot < Personality

  # attr_accessor :desired_direction, :random_direction_details

  def position_updated
    if going_to_hit_wall?
      avoid_wall
    else
      continue
    end
  end

  protected

    def going_to_hit_wall?
      line_in_direction = (position + (direction_vector.normalize * 500).to_a)
      current = @geo_factory.point(position[0], position[1])
      future  = @geo_factory.point(line_in_direction[0], line_in_direction[1])
      line    = @geo_factory.line(current, future)

      if @battlefield.boundaries.intersects?(line)
        # going to hit.
        # get distance
        # get distance left
        # get distance right

        binding.pry

        # line_in_left = (position + (direction_vector.normalize * 500).to_a)
        # line         = @geo_factory.line(current, future)

        # current = @geo_factory.point(position[0], position[1])
        # distance_left = @battlefield.boundaries.intersects?(line)

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
        @random_direction_details = [[:left!, :right!, :straight!].shuffle.first, rand(10..100)]
      end
    end

end
