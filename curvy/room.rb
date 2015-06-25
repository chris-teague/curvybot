#
# Handles any room based messages & triggers appropriate actions
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

  def game(json)
    puts "GAME: #{json.to_s}"
  end

  def master(json)
    puts 'NEW MASTER'
  end

end
