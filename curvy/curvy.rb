require 'json'
# require 'insult_generator'

#
# Handle loading into room, etc
#
#
class Curvy

  attr_accessor :rooms, :id, :player_id, :state, :connection, :in_room, :room_name,
                :players, :playing

  MESSAGE  = /(room|round):(\w*)/

  NAME = "Curvybot#{rand(1000)}"

  def initialize(connection)
    @state        = :closed
    @in_room      = false
    @added_player = false
    @ready        = false
    @next_ready   = false
    @playing      = false # delete me??
    @avatar       = false
    @dead         = false
    @players      = 0
    @connection   = connection

    @room         = Room.new(self)
    @round        = Round.new(self)
    @battlefield  = Battlefield.new

    EM.add_periodic_timer(10) do
      @connection.send_msg('[["activity",true]]')
    end
  end

  def back_to_lobby
    @ready        = false
    @next_ready   = false
    @playing      = false
    @avatar       = false
    @dead         = false
  end

  def round_end
    @dead      = false
  end

  def round_winner(json)
    puts "WINNER: #{json['winner']}"
    chat('Motherfuckas I won!') if json['winner'] == @avatar
  end

  #
  # What to do with messages received?
  #

  def receive(msg)
    return if msg.empty?

    json = JSON.parse(msg)
    json.each do |msg|
      case msg.first
      when 0          then set_id(msg.last)
      when @id        then joined_room(msg.last)
      when 'ready'    then set_avatar(msg.last, json)
      when 'position' then set_positions(msg.last)
      when 'die'      then set_dead(msg.last)
      when MESSAGE    then puts msg.first; parse_message(*msg)
      else
        puts "RECEIVED: #{msg}"
      end
    end
  rescue Exception => e
    puts "Exception: #{e}"
    puts "Mesasge Content:"
    puts msg
    puts "----"
  end

  def parse_message(action, json)
    class_type, *methods = action.split(':')
    instance = instance_variable_get("@#{class_type}")
    instance.send(methods.join('_'), json)
  end

  def round_message(action, json=nil)
    @round.send(action.split(':')[1..-1].join('_'), json)
  end

  #
  # Actions to take
  #

  def whoami
    @state = :whoami
    @connection.send_msg '[["whoami",null,0]]'
  end

  def set_id(id)
    puts 'BOT: Setting Player ID'
    @id = id
    fetch_rooms
  end

  def fetch_rooms
    puts 'BOT: Fetching Rooms'
    EM.next_tick { @connection.send_msg('[["room:fetch"]]') }
  end

  # FIXME: this can fail!
  def joined_room(json)
    puts json
    return if @added_player
    if json['success'] == true
      puts "BOT: Joined Room"
      @added_player = true
      @connection.send_msg([["player:add", { name: NAME, color: '#bada55' }, @id]].to_json)
    else
      puts 'NAME ALREADY TAKEN'
    end
  end

  def signal_ready
    puts "BOT: I'm Ready!"
    @connection.send_msg "[[\"room:ready\",{\"player\":#{@player_id}},#{@id}]]" unless @ready
  end

  def in_room?
    @in_room
  end

  def chat(message)
    @connection.send_msg([['room:talk', { content: message }, @id]].to_json)
  end

  #
  # FIXME: This is a painpoint...
  #
  def issue_ready
    puts 'BOT: Issuing Ready'
    EM.add_timer(rand(0..2.1)) do
      @connection.send_msg '[["ready"]]'
      @next_ready = true
    end
  end

  #
  # As above, this is reliant on flakey logic.
  #
  def set_avatar(json, raw_msg)
    if @next_ready
      @next_ready = false
      @avatar = json["avatar"]
      @battlefield.players.add(Player.new(json["avatar"]))
      @bot = RandomBot.new(@connection, @avatar, @position, @battlefield)
    else
      @battlefield.players.add(Player.new(json["avatar"]))
    end
  end

  def set_dead(json)
    if json["avatar"] == @avatar
      puts "BOT: Whoops, I died :("
      @dead = true
    end
  end

  def set_positions(json)
    @battlefield.update_position(json[0], json[1])
    @bot.position = json[1] if @bot && json[0] == @avatar
  end

end