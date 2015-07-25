#
# Handles any round based messages & triggers appripriate actions
#
class Round

  def initialize(curvy)
    @curvy = curvy
  end

  def new(json=nil)
    GC.enable
    GC.start
    GC.disable
    puts "TIME TO PARTY, NEW ROUND"
    @curvy.bot.battlefield.new_round
  end

  def end(json)
    @curvy.dead = false
  end

  def winner(json)
    @curvy.chat('Whoop!') if json['winner'] == @curvy.avatar
  end

end
