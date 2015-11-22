# This issue fixed by [r28](https://code.google.com/p/rubyizumi/source/detail?r=28)(version 0.10). Thanks to Yaacov! #

## Issue on Flash Player update 9,0,124,0 (FMS3.0.1) ##

## The Issue ##

If you play with new Flash Player 9,0,124,0, you can't see any video streaming served by RubyIZUMI. It seems some change on RTMP handshake.

## Bypassing Handshake to FMS3.0.1 ##

The following code i wrote is to pass through handshake to FMS3 (RTMP::Session#handshake, The address ”1.2.3.4” is FMS3 (Edge) IP address) . If you use this patch, you can play with 9,0,124,0 :)

```
def handshake
  s = TCPSocket.open(”1.2.3.4”, 1935)
  @sock.read(1)
  s.write(”\3”)
  d1 = @sock.read(HandshakeSize)
  s.write(d1)
  s.read(1)
  @sock.write(”\3”)
  d2 = s.read(HandshakeSize)
  d3 = s.read(HandshakeSize)
  @sock.write(d2)
  @sock.write(d3)
  @sock.read(HandshakeSize)
  s.close
  IzumiLogger.debug ”<> handshaked 3.0.1”
end
```

  * d1: Flash Player -> RubyIZUMI (Client request?)
  * d2: RubyIZUMI -> Flash Player (Server response?)
  * d3: RubyIZUMI -> Flash Player (???)

## Tried some times using this code and i found: ##
  * **d3 can not equal d1 (9,0,115,0 or older version can equal these)**
  * d1 and d2 seems contain uptime in first 4byte (I guess the other bytes are generated using this uptime value)
  * d3 seems simply random ;)

## References ##
  * Old handshake algorithm: http://www.mail-archive.com/red5@osflash.org/msg04906.html
  * RTMP Protocol (osflash): http://www.osflash.org/rtmp/protocol#handshake
