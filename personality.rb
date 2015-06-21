# require 'math'

#
# Initialized on game start
#
class Personality

  # This gets called on every position update, implement this in your
  # concrete class for behaviour.
  def position_updated
    raise "NotImplementedError"
  end

  attr_accessor :id, :connection, :position, :curvy, :direction, :previous_position

  def initialize(connection, id, position, curvy)
    @connection = connection
    @id         = id
    @position   = position
    @curvy      = curvy
  end

  def left!
    puts 'MOVE LEFT'
    puts "[[\"player:move\",{\"avatar\":#{@id},\"move\":-1}]]"
    @connection.send_msg("[[\"player:move\",{\"avatar\":#{@id},\"move\":-1}]]")
  end

  def right!
    puts 'MOVE RIGHT'
    puts "[[\"player:move\",{\"avatar\":#{@id},\"move\":1}]]"
    @connection.send_msg("[[\"player:move\",{\"avatar\":#{@id},\"move\":1}]]")
  end

  def straight!
    @connection.send_msg("[[\"player:move\",{\"avatar\":#{@id},\"move\":0}]]")
  end

  def direction
    return nil unless @previous_position
    Math.atan2(*direction_vector) * 180/ Math::PI
  end

  def direction_vector
    return nil unless @previous_position
    [@position[0] - @previous_position[0], @position[1] - @previous_position[1]]
  end

  def position=(value)
    @previous_position = position
    @position = value
    position_updated
  end

end
