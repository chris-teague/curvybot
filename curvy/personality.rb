#
# Inherit this to get your bot started!
#
# Provides basic interface for tracking position, direction & issuing
# commands to determine direction.
#
# Implement 'position_updated' to do your thang
#

require 'rgeo'
require 'matrix'

Point = Struct.new(:x,:y) do
  def self.to_proc
    lambda{ |x| self.new *x }
  end

  def rotate( degrees, origin=Point.new(0.0,0.0) )
    radians = degrees * Math::PI/180.0
    x2 = x-origin.x; y2 = y-origin.y
    cos = Math.cos(radians); sin = Math.sin(radians)
    self.class.new(
      x2*cos - y2*sin + origin.x,
      x2*sin + y2*cos + origin.y
    )
  end
end

class Personality

  # This gets called on every position update, implement this in your
  # concrete class for behaviour.
  def position_updated
    raise "NotImplementedError"
  end

  LEFT     = -1
  RIGHT    = 1
  STRAIGHT = 0

  NAME = "PleaseNameMe#{rand(1000)}"

  attr_accessor :id, :connection, :position, :battlefield, :direction, :previous_position

  def initialize(connection, id, position, battlefield)
    @connection  = connection
    @id          = id
    @position    = position
    @battlefield = battlefield
    @geo_factory = ::RGeo::Cartesian.preferred_factory
  end

  def left!
    puts "Moving Left"
    move!(LEFT)
  end

  def right!
    puts "Moving Right"
    move!(RIGHT)
  end

  def straight!
    puts "Moving Straight"
    move!(STRAIGHT)
  end

  def move!(direction)
    @connection.send_msg([['player:move', { avatar: @id, move: direction }]].to_json)
  end

  def direction
    return nil unless @previous_position
    Math.atan2(*direction_vector) * 180 / Math::PI
  end

  def direction_vector
    return nil unless @previous_position
    Vector[@position[0] - @previous_position[0], @position[1] - @previous_position[1]]
  end

  def direction_left
    turned_left = Point.new(direction_vector[0], direction_vector[1]).rotate(15)
    Vector[turned_left[0], turned_left[1]]
  end

  def direction_right
    turned_right = Point.new(direction_vector[0], direction_vector[1]).rotate(-15)
    Vector[turned_right[0], turned_right[1]]
  end

  def position=(value)
    @previous_position = position
    @position = value
    position_updated
  end

  def map_size
    @battlefield.size
  end

  def name
    NAME
  end

end
