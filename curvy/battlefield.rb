#
# Models the state of play of the gamefield in Curvytron
#
require 'set'
require 'rgeo'
require 'matrix'
require 'rgeo/geo_json'

class Battlefield

  attr_accessor :players, :size, :started_game, :boundaries

  PerPlayerSize = 80.0

  def initialize
    @players = Set.new
    @geo_factory = ::RGeo::Cartesian.preferred_factory
    @boundaries = nil
  end

  def new_round
    @boundaries = nil
    @started_game = false
  end

  def started_game!
    return if @started_game
    puts 'Setting up GEO'
    top_left     = @geo_factory.point(0, 0)
    top_right    = @geo_factory.point(0, size)
    bottom_left  = @geo_factory.point(size, 0)
    bottom_right = @geo_factory.point(size, size)

    top    = @geo_factory.line(top_left, top_right)
    left   = @geo_factory.line(top_left, bottom_left)
    bottom = @geo_factory.line(bottom_left, bottom_right)
    right  = @geo_factory.line(top_right, bottom_right)

    @boundaries = @geo_factory.collection([top, left, bottom, right]).buffer(40)

    @started_game = true
  end

  def size
    @size ||= (Math.sqrt((PerPlayerSize * PerPlayerSize) + ((players.count - 1) * (PerPlayerSize * PerPlayerSize) / 5)) * 100.0).to_i
  end

  def update_point(avatar_id, new_position)

    started_game!

    if player = @players.select { |p| p.avatar_id == avatar_id }.first
      if player.position && new_position != player.position && player.is_printing_line?
        p1 = @geo_factory.point(*player.position)
        p2 = @geo_factory.point(*new_position)
        line = @geo_factory.line(p1,p2)
        @boundaries = @boundaries.union(line.buffer(35))

        player.position = new_position
      else
        player.position = new_position
        # First point, no line for now
      end
    end
  end

  # {"avatar"=>1, "property"=>"printing", "value"=>false}]
  def update_property(json)
    if player = @players.select { |p| p.avatar_id == json['avatar'] }.first
      if json['property'] == 'printing'
        player.printing_line = json['value']
      end
    end
  end

end
