require 'em-websocket-client'
require 'pry'

require_relative('curvy/personality')

EM.run {

  Dir[File.join(File.dirname(__FILE__), 'curvy', '*.rb')].each { |file| require file }

  conn = EventMachine::WebSocketClient.connect("ws://curvy.cteague.com.au")
  @curvy = Curvy.new(conn)

  conn.callback do
    @curvy.whoami
  end

  conn.stream do |msg|
    @curvy.receive(msg.to_s)
  end

}
