#
#    RubyIZUMI
#
#    Copyright (C) 2008 Takuma Mori, SGRA Corporation
#    <mori@sgra.co.jp> <http://www.sgra.co.jp/en/>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

require 'generator'

module IZUMI
  class Server
    def initialize(host, port)
      @host = host
      @port = port
    end

    def run(pool)
#      loop_tcpserver(pool)
      loop_eventmachine(pool)
      IzumiLogger.info "Exit."
    end

  private
    def on_accept(io, pool)
      begin
        session = RTMP::Session.new(io, pool)
        session.do_session
      rescue => e
        puts "Exception caught: #{e}"
      ensure
        io.close
      end
    end

    def loop_eventmachine(pool)
      require 'rubygems'
      require 'eventmachine'
      
      require 'fiberio'
      require 'emconnection'

      begin
        EventMachine::run do
          EventMachine.start_server(@host, @port, EMConnection, Proc.new do |io|
            on_accept(io, pool)
          end)
          IzumiLogger.info "Server started (Ruby/EventMachine). Ver:#{RTMP::FmsVer} Pid:#{$$} Port:#{@port}"
        end
      rescue Interrupt
      end
    end

    def loop_tcpserver(pool)
      require 'socket'

      TCPSocket.do_not_reverse_lookup = true # disable DNS reverse lookup
      
      gs = nil
      begin
        gs = TCPServer.open(@port)
        IzumiLogger.info "Server started (TCPServer). Ver:#{RTMP::FmsVer} Pid:#{$$} Port:#{@port}"
        loop do
          Thread.start(gs.accept) do |sock|
            on_accept(sock, pool)
          end
        end
      rescue Interrupt
      ensure
        gs.close
      end
    end
  end

end
