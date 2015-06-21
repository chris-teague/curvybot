class RandomBot < Personality

  attr_accessor :desired_direction

  MAP_SIZE=8000

  def position_updated

    if !@desired_direction.nil?
      # see if direction achieved?

      puts "DIRECTION: #{direction}"
      puts "DESIRED:   #{@desired_direction}"

      if direction.to_i < @desired_direction + 3 && direction.to_i > @desired_direction - 3
        puts 'ACHIEVED DESIRED DIRECTION'
        straight!
        @desired_direction = nil
      else
        spin_towards_desired_direction
      end
    end

    if going_to_hit_wall?
      avoid_wall
    end
  end

  protected

    def going_to_hit_wall?
      @position[0] < 800 || @position[1] < 800 || @position[0] > 7200 || @position[1] > 7200
    end

    def avoid_wall
      # puts 'AVOID THE WALL!'
      set_desired_direction_as_center
    end

    def set_desired_direction_as_center
      return if @desired_direction
      center_vector = [MAP_SIZE/2 - @position[0], MAP_SIZE/2 - @position[1]]
      @desired_direction = Math.atan2(*center_vector) * 180/ Math::PI
    end

    def spin_towards_desired_direction
      # puts "DESIRED DIRECTION: #{@desired_direction}"
      dir = @desired_direction - direction

      if dir >= 0 && dir < 180
        left!
      elsif dir >= 180
        right!
      elsif dir < 0 && dir >= -180
        left!
      elsif dir < -180
        right!
      end
    end

end
