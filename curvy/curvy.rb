require 'json'
# require 'insult_generator'

#
# Curvy Bot manager
#
#  - handle high level flows of joining, id assignment & state
#    related to the bot
#
class Curvy

  attr_accessor :rooms, :id, :player_id, :connection, :dead,
                :in_room, :room_name, :playing, :next_ready,
                :avatar, :bot, :battlefield

  MESSAGE  = /(room|round|bonus):(\w*)/

  NAME = "Curvybot#{rand(1000)}"

  def initialize(connection)
    @in_room      = false
    @ready        = false
    @next_ready   = false
    @playing      = false # is this still required?
    @avatar       = false
    @dead         = false

    @connection   = connection
    @room         = Room.new(self, @connection)
    @round        = Round.new(self)
    @battlefield  = Battlefield.new
    @bonus        = Bonus.new

    EM.add_periodic_timer(10) do
      @connection.send_msg('[["activity",true]]')
    end
  end

  def name
    @bot ? @bot.name : NAME
  end

  def back_to_lobby
    @ready        = false
    @next_ready   = false
    @playing      = false
    @avatar       = false
    @dead         = false
  end

  def chat(message)
    @connection.send_msg([['room:talk', { content: message }, @id]].to_json)
  end

  #
  # Websocket Message Delegation / Routing
  #

  def receive(msg)
    return if msg.empty?
    return if msg =~ /^\d+$/

    json = JSON.parse(msg)
    json.each do |msg|
      case msg.first
      when 0          then set_id(msg.last)
      when @id        then @room.joined_room(msg.last)
      when 'ready'    then set_avatar(msg.last, json)
      when 'position' then set_positions(msg.last)
      when 'point'    then set_point(msg.last)
      when 'die'      then set_dead(msg.last)
      when 'property' then set_property(msg.last)
      when MESSAGE    then parse_message(*msg)
      else
        puts "RECEIVED UNHANDLED MESSAGE: #{msg}"
      end
    end
  # rescue Exception => e
  #   puts "Exception: #{e}"
  #   puts "Mesasge Content:"
  #   puts "----"
  #   puts "#{msg}"
  #   puts "----"
  end

  def parse_message(action, json)
    class_type, *methods = action.split(':')
    instance = instance_variable_get("@#{class_type}")
    instance.send(methods.join('_'), json)
  end

  #
  # Event handlers that don't have a better place to live at this stage.
  #

  def whoami
    @connection.send_msg '[["whoami",null,0]]'
  end

  def set_id(id)
    @id = id
    @room.fetch_rooms
  end

  #
  # FIXME: This is somehwat random as to what avatar_id gets consumed
  # FIXME: This belongs to a game or battlefield instance, not curvy
  #
  def set_avatar(json, raw_msg)
    if @next_ready
      @next_ready = false
      @avatar = json["avatar"]
      @battlefield.players.add(Player.new(json["avatar"]))
      @bot = AvoidanceBot.new(@connection, @avatar, @position, @battlefield)
    else
      @battlefield.players.add(Player.new(json["avatar"]))
    end
  end

  def set_positions(json)
    @bot.position = json[1] if @bot && json[0] == @avatar
  end

  def set_point(json)
    @battlefield.update_point(json[0], json[1])
  end

  def set_property(json)
    @battlefield.update_property(json)
  end

  #
  # FIXME: Belongs elsewhere, battlefield or personality maybe?
  #
  def set_dead(json)
    if json["avatar"] == @avatar
      puts "BOT: Whoops, I died :("
      @dead = true
    end
  end

end
