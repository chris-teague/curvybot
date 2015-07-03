#
# Handles any room based logic
#
# Listing, opening, joining, etc
#
class Room

  def initialize(curvy, connection)
    @connection = connection
    @curvy = curvy
    @added_player = false
  end

  #
  # Mapped from room:xyz messages
  #

  def open(json)
    return if @curvy.in_room
    @curvy.connection.send_msg([["room:join" , { name: json['name'] }, @curvy.id]].to_json)
    @curvy.in_room = true
  end

  def join(json)
    if json["player"]["client"] == @curvy.id
      @curvy.player_id = json["player"]["id"]
      room_ready
    end
  end

  def players(json)
    # @curvy.players = json["players"]
  end

  def game_start(json)
    @curvy.playing = true
    player_ready
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

  # Captures chat messages to the room. Ignore for now.
  def talk(json)
  end

  #
  # Other methods
  #

  def fetch_rooms
    EM.next_tick { @connection.send_msg([['room:fetch']].to_json) }
  end

  # FIXME: this can fail! Along with player_ready, needs addressing to be more reliable.
  def joined_room(json)
    return if @added_player
    if json['success'] == true
      puts "BOT: Joined Room"
      @added_player = true
      @connection.send_msg([["player:add", { name: @curvy.name, color: '#bada55' }, @curvy.id]].to_json)
    else
      puts 'NAME ALREADY TAKEN'
      # What now?
    end
  end

  protected

    #
    # FIXME: This is a painpoint...
    #
    def player_ready
      EM.add_timer(rand(0.1..2.1)) do
        @connection.send_msg('[["ready"]]')
        @curvy.next_ready = true
      end
    end

    def room_ready
      @connection.send_msg([['room:ready', { player: @curvy.player_id }, @id]].to_json) unless @ready
    end

end
