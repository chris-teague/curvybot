require 'json'
# require 'insult_generator'

class Curvy

  attr_accessor :rooms, :id, :player_id, :state, :connection

  ROOMMESSAGE  = /room:(\w*)/
  GAMEMESSAGE  = /game:(\w*)/
  ROUNDMESSAGE = /round:(\w*)/

  NAME = "Curvybot#{rand(1000)}"

  def initialize(connection)
    @state        = :closed
    @in_room      = false
    @added_player = false
    @ready        = false
    @next_ready   = false
    @playing      = false
    @avatar       = false
    @dead         = false
    @players      = 0
    @connection   = connection
    @positions    = {}
    EM.add_periodic_timer(10) do
      @connection.send_msg '[["activity",true]]'
    end
  end

  def back_to_lobby
    @ready        = false
    @next_ready   = false
    @playing      = false
    @avatar       = false
    @dead         = false
    @positions    = {}
  end

  def round_end
    @dead      = false
    @positions = {}
  end

  def round_winner(json)
    puts "WINNER: #{json['winner']}"
    chat('I won you cocks!') if json['winner'] == @avatar
  end

  #
  # What to do with messages received?
  #

  def receive(msg)
    return if msg.empty?

    json = JSON.parse(msg)
    json.each do |msg|
      case msg.first
      when 0            then set_id(msg.last)
      when @id          then joined_room(msg.last)
      when 'ready'      then set_avatar(msg.last, json)
      when 'position'   then set_positions(msg.last)
      when 'die'        then set_dead(msg.last)
      when ROOMMESSAGE  then room_message(*msg)
      when GAMEMESSAGE  then game_message(*msg)
      when ROUNDMESSAGE then round_message(*msg)
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

  def room_message(action, json)
    puts in_room? ? 'BOT: I am in a room' : 'BOT: I need to join a room!'
    case action
    when 'room:open'       then join(json["name"]) unless in_room?
    when 'room:join'       then get_player_id(json)
    when 'room:game:start' then issue_ready; @playing = true;
    when 'room:game:stop'  then @playing = false
    when 'room:game'       then signal_ready; @playing = true;
    when 'room:players'    then @players = json["players"]
    else
      puts "RECEIVED: #{action} #{json}"
    end
  end

  def game_message(action, json)
    case action
    when 'game:start' then issue_ready; @playing = true
    when 'game:stop'  then @playing = false
    else
      puts "RECEIVED: #{action} #{json}"
    end
  end

  def round_message(action, json=nil)
    case action
    when 'round:new'    then puts "TIME TO PARTY, NEW ROUND"
    when 'round:end'    then round_end
    when 'round:winner' then round_winner(json)
    else
      puts "RECEIVED: #{action} #{json}"
    end
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
    EM.next_tick { @connection.send_msg '[["room:fetch"]]' }
  end

  def join(room_name)
    puts "BOT: Joining room: #{room_name}"
    @connection.send_msg "[[\"room:join\",{\"name\":\"#{room_name}\"},#{id}]]"
    @in_room = true
  end

  # FIXME: this can fail!
  def joined_room(json)
    unless @added_player == true
      puts "BOT: Joined Room"
      @added_player = true
      @connection.send_msg "[[\"player:add\",{\"name\":\"#{NAME}\",\"color\":\"#bada55\"},#{@id}]]"
    end
  end

  def get_player_id(json)
    if json["player"]["client"] == @id
      @player_id = json["player"]["id"]
      signal_ready
    end
  end

  def signal_ready
    puts "BOT: I'm Ready!"
    @connection.send_msg "[[\"room:ready\",{\"player\":#{@player_id}},#{@id}]]" unless @ready
  end

  def shart_moving_yo
    moves = [-1, 0, 1]

    puts 'START MOVING YO'

    @bot = RandomBot.new(@connection, @avatar, @position, self)


    # @moving = :none

    # if @playing && @avatar && !@dead
    #   EM.add_periodic_timer(0.6) do

    #     move = nil

    #     if @moving == :none
    #       [:left, :right, :none].shuffle.first.tap do |x|
    #         case x
    #         when :left  then move = -1; @moving = :left
    #         when :right then move = 1;  @moving = :right
    #         end
    #       end
    #     else
    #       if rand(1..2) == 2
    #         move = 0;
    #         @moving = :none;
    #       end
    #     end

    #     # [["player:move",{"avatar":1,"move":-1}]]
    #     # [["player:move",{"avatar":2,"move":1}]]

    #     if move
    #       puts "MOVING: #{@moving} avatar: #{@avatar}"
    #       @connection.send_msg("[[\"player:move\",{\"avatar\":#{@avatar},\"move\":#{move}}]]")
    #     end

    #   end
    # end
  end

  def in_room?
    @in_room
  end

  # TODO: properly escape message so corrupt json doesn't get sent
  def chat(message)
    @connection.send_msg("[[\"room:talk\",{\"content\":\"#{message}\"},#{@id}]]")
  end

  def issue_ready
    puts 'BOT: Issuing Ready'
    EM.add_timer(rand(0..2.1)) do
      @connection.send_msg '[["ready"]]'
      @next_ready = true
    end
  end

  def set_dead(json)
    if json["avatar"] == @avatar
      puts "BOT: Whoops, I died :("
      @dead = true
    end
  end

  def set_avatar(json, raw_msg)
    if @next_ready
      @next_ready = false
      puts 'BOT: Setting Avatar'
      puts raw_msg
      @avatar = json["avatar"]
      shart_moving_yo
    else
      puts 'ALREADY READY'
    end
  end

  def set_positions(json)
    @positions[json[0]] == json[1]
    @bot.position = json[1] if @bot && json[0] == @avatar
  end

end