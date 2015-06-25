#
# Inherit this to get your bot started!
#
# Provides basic interface for tracking position, direction & issuing
# commands to determine direction.
#
# Implement 'position_updated' to do your thang
#
class Personality

  # This gets called on every position update, implement this in your
  # concrete class for behaviour.
  def position_updated
    raise "NotImplementedError"
  end

  attr_accessor :id, :connection, :position, :battlefield, :direction, :previous_position

  def initialize(connection, id, position, battlefield)
    @connection  = connection
    @id          = id
    @position    = position
    @battlefield = battlefield
  end

  def left!
    @connection.send_msg("[[\"player:move\",{\"avatar\":#{@id},\"move\":-1}]]")
  end

  def right!
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

  def map_size
    @battlefield.size
  end

end
