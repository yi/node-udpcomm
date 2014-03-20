dgram = require('dgram')

# 用于二进制流消息验证的签名值
SGF_SIGNATURE = 6258000

class UDPShoutor

  # constructor function
  # @param {uint} communicationPort, the udp port number of hub service
  # @param {uint} channelId, an integer indicate shoutor's channel id
  # @param {onMsgCallback} an callback function when recive channel message from the hub
  constructor:(communicationPort, channelId, onMsgCallback) ->
    #console.log "[UDPShoutor] communicationPort:#{communicationPort}, channelId:#{channelId}, onMsgCallback:#{onMsgCallback}"
    throw new Error "invalid argumens" unless communicationPort > 1024 and channelId >= 0 and onMsgCallback?

    this.communicationPort = communicationPort

    this.channelId = channelId

    this.client = dgram.createSocket("udp4")

    this.client.on 'message', onMsgCallback

    # 4: uint - sgf signature, 4: uint- channel id, 1: byte: msg type, 2:short - body pay load
    this.bufSignature = new Buffer(11)
    this.bufSignature.fill(0)
    this.bufSignature.writeUInt32BE(SGF_SIGNATURE, 0)
    this.bufSignature.writeUInt32BE(channelId, 4)
    #console.log "[UDPShoutor] this.bufSignature:#{this.bufSignature.toString('hex')}"

  # send buffer message to udp hub service
  # @param {Buffer} buf, message buffer
  sendMessage : (buf) ->
    #console.log "[(#{this.channelId})sendMessage] buf:#{buf.toString('hex')}"
    return unless Buffer.isBuffer(buf) and buf.length > 0
    buf = Buffer.concat([this.bufSignature, buf])
    #console.log "[sendMessage] after buf:#{buf.toString('hex')}"
    this.client.send(buf, 0, buf.length, this.communicationPort , "localhost")


module.exports = UDPShoutor
