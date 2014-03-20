{UDPShoutor} = require "../udpcomm"

PORT = 9999

channelId = 5

onMessage =  (msg, rinfo)->
  console.log "[client(#{process.pid})] msg:#{msg.toString()}, from:#{rinfo.address}:#{rinfo.port}"

shoutor = new UDPShoutor(PORT, channelId , onMessage )

setInterval(()->
  message = new Buffer("channelId:#{channelId} pid:#{process.pid}, time:#{Date.now()}")
  shoutor.sendMessage message
, 1000)
