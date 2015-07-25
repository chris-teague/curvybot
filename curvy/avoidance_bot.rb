class AvoidanceBot < Personality

  attr_accessor :next_move, :previous_move, :random_direction_details, :updating

  DistanceToPanic = 2200

  NAME = "AvoidyBot#{rand(1000)}"

  def position_updated
    if @updating
      return
    end
    Thread.new {
      @updating = true
      avoid_wall
      @updating = false
    }
  end

  def name
    NAME
  end

  protected

    def apply_next_move
      send(@next_move[:direction]) if @next_move[:direction] != @previous_move
      @previous_move = @next_move[:direction]
      @next_move[:count] = @next_move[:count] - 1
      @next_move = nil if @next_move[:count] <= 0
    end

    def distance_in_direction(angle, direction_to_turn)
      sv = direction_with_angle(angle).normalize * DistanceToPanic
      point = @geo_factory.point(position[0] + sv[0], position[1] + sv[1])
      line  = @geo_factory.line(current_direction, point)
      {
        distance: @battlefield.boundaries.intersection(line).distance(current_direction),
        direction: direction_to_turn
      }
    end

    def current_direction
      @geo_factory.point(position[0], position[1])
    end

    def avoid_wall
      @battlefield.started_game!

      return unless direction_vector
      return if direction_vector.norm == 0.0

      results =
      [distance_in_direction(  0, :straight!),
       distance_in_direction(-35, :left!),
       distance_in_direction( 35, :right!)]

      if results.select { |a| a[:distance] != 0.0 }.count > 0
        direction = results.map { |a| a[:distance] = DistanceToPanic if a[:distance] == 0.0; a }.
          sort_by { |a| -a[:distance] }.first[:direction]
        send(direction) unless @previous_move == direction
        @previous_move = direction
      else
        if outside_of_danger_zone
          randomly_continue
        else
          puts 'INSIDE DANGERZONE'
        end
      end
    end

    SaveZoneDistance = 1100

    def outside_of_danger_zone
      position[0] > (0 + SaveZoneDistance) && position[0] < (@battlefield.size - SaveZoneDistance) &&
      position[1] > (0 + SaveZoneDistance) && position[1] < (@battlefield.size - SaveZoneDistance)
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
        @random_direction_details = [[:left!, :right!, :straight!].shuffle.first, rand(1..8)]
      end
    end

end
