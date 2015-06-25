class Player

  # We care about:
  #
  # Current thickness
  # Is producing a line? (i.e. king mode)
  #

  attr_accessor :avatar_id, :thickness, :producing_line, :position

  def initialize(id)
    @avatar_id = id
    @thickness = 1
    @producing_line = false
  end

end
