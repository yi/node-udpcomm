UDPShoutor = require "../util/udpshoutor"

channelId = (4 * Math.random() >> 0) + 1

onMessage =  (msg, rinfo)->
  console.log "[client(#{process.pid})] msg:#{msg.toString()}, from:#{rinfo.address}:#{rinfo.port}"

shoutor = new UDPShoutor(9999, channelId , onMessage )

setInterval(()->
  message = new Buffer("channelId:#{channelId} pid:#{process.pid}, time:#{Date.now()}")
  shoutor.sendMessage message
, 1000)
