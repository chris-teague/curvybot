require 'em-websocket'
require 'em-websocket-client'
require 'pry'
require_relative 'curvy'
require_relative 'personality'
require_relative 'random_bot'

EM.run {

  conn = EventMachine::WebSocketClient.connect("ws://curvy.cteague.com.au")
  @curvy = Curvy.new(conn)

  conn.callback do
    @curvy.whoami
  end

  conn.stream do |msg|
    @curvy.receive(msg.to_s)
  end

}
