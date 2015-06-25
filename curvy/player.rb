class Player

  #
  # We care about:
  #
  #  - Current thickness
  #  - Is producing a line? (i.e. king mode)
  #  - Position
  #  - Avatar ID
  #

  attr_accessor :avatar_id, :thickness, :printing_line, :position

  def initialize(id)
    @avatar_id = id
    @thickness = 1
    @printing_line = false
  end

  def is_printing_line?
    @printing_line
  end

end
