#
# Models the state of play of the gamefield in Curvytron
#
require 'set'

class Battlefield

  attr_accessor :players

  def initialize
    @players = Set.new
  end

  PerPlayerSize = 80.0

  def size
    baseSquareSize = PerPlayerSize * PerPlayerSize
    (Math.sqrt(baseSquareSize + ((players.count - 1) * baseSquareSize / 5)) * 100.0).to_i
  end

  def update_position(avatar_id, position)
    p = @players.select { |p| p.avatar_id == avatar_id }.first
    if p
      if p.position && position != p.position
        puts 'DRAW A LINE'
      else
        p.position = position
        puts 'FIRST LINE GO DOWN NOW FOR U'
      end
    end
  end

end
