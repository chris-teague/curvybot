#
# Handles any round based messages & triggers appripriate actions
#
class Round

  def initialize(curvy)
    @curvy = curvy
  end

  def new(json)
    puts "TIME TO PARTY, NEW ROUND"
  end

  def end(json)
    @curvy.round_end
  end

  def winner(json)
    @curvy.round_winner(json)
  end

end
