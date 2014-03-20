require 'mocha'
should = require('chai').should()

{UDPHub, UDPShoutor} = require "../udpcomm"

PORT = 9999

CHANNEL_ID = (4 * Math.random() >> 0) + 1

describe "this is a test", ()->

  before, ->
    server = new UDPHub(PORT)
    server.start()



onMessage =  (msg, rinfo)->
  console.log "[client(#{process.pid})] msg:#{msg.toString()}, from:#{rinfo.address}:#{rinfo.port}"

shoutor = new UDPShoutor(9999, channelId , onMessage )

setInterval(()->
  message = new Buffer("channelId:#{channelId} pid:#{process.pid}, time:#{Date.now()}")
  shoutor.sendMessage message
, 1000)



  it "should be ok", ->
    true

