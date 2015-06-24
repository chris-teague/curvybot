#
# Handles any room based messages & triggers appripriate actions
#
# Note: Tightly coupled to curvy object. This is simply to neaten
#       up the Curvy object.
#
class Room

  def initialize(curvy)
    @curvy = curvy
  end

  def open(json)
    return if @curvy.in_room
    @curvy.connection.send_msg([["room:join" , { name: json['name'] }, @curvy.id]].to_json)

    @curvy.in_room = true
  end

  def join(json)
    if json["player"]["client"] == @curvy.id
      @curvy.player_id = json["player"]["id"]
      @curvy.signal_ready
    end
  end

  def players(json)
    @curvy.players = json["players"]
  end

  def game_start(json)
    @curvy.issue_ready
    @curvy.playing = true
  end

  def game_stop(json)
    @curvy.playing = false
  end

end
