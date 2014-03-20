dgram = require 'dgram'
assert = require 'assert'
_ = require 'underscore'
debuglog = require("debug")("udpcomm::UDPShoutor")

# 用于二进制流消息验证的签名值
SIGNATURE = 6258000

class UDPShoutor

  # constructor function
  # @param {uint} communicationPort, the udp port number of hub service
  # @param {uint} channelId, an integer indicate shoutor's channel id
  # @param {String} host, Destination hostname or IP address
  # @param {onMsgCallback} an callback function when recive channel message from the hub
  constructor:(@communicationPort, @channelId, @host, onMsgCallback) ->

    assert(@communicationPort > 1024, "communicationPort must larger then 1024")
    assert(@channelId >= 0, "invalid channelId")

    if not onMsgCallback? and _.isFunction(@host)
      onMsgCallback = @host
      @host = "127.0.0.1"

    assert(@host?, "missing host")
    assert(_.isFunction(onMsgCallback), "missing callback")

    @client = dgram.createSocket("udp4")

    @client.on 'message', onMsgCallback
    #@client.on 'message', (msg, rinfo)->
      #debuglog "[on message] msg.length:#{message.length}, rinfo:%j", rinfo
      #onMsgCallback(msg, rinfo)
      #return

    # 4: uint - sgf signature, 4: uint- channel id, 1: byte: msg type, 2:short - body pay load
    @bufSignature = new Buffer(11)
    @bufSignature.fill(0)
    @bufSignature.writeUInt32BE(SIGNATURE, 0)
    @bufSignature.writeUInt32BE(channelId, 4)
    #console.log "[UDPShoutor] this.bufSignature:#{this.bufSignature.toString('hex')}"

  # send buffer message to udp hub service
  # @param {Buffer} buf, message buffer
  sendMessage : (buf) ->
    #console.log "[(#{this.channelId})sendMessage] buf:#{buf.toString('hex')}"
    return unless Buffer.isBuffer(buf) and buf.length > 0
    buf = Buffer.concat([@bufSignature, buf])
    debuglog "[sendMessage] to: #{@host}:#{@communicationPort}, msg length:#{buf.length}"
    @client.send(buf, 0, buf.length, @communicationPort , @host)


module.exports = UDPShoutor
