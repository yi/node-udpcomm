dgram = require("dgram")
debuglog = require("debug")("udpcomm::UDPHub")

LAZY_TIMEOUT = 10000

# 用于二进制流消息验证的签名值
SIGNATURE = 6258000

SGF_UDP_HEAD_LENGTH = 11

class UDPHub

  # constructor function
  # @param {uint} listenToPort, port to start this service
  constructor:(@listenToPort, @host="127.0.0.1") ->
    @server = dgram.createSocket("udp4")

    # key: client port, value: update at
    @clientPorts = {}

    # key: channel Id, value: channel id
    @clientChannelId = {}

    @deadPorts = []

    # handle message received from clients
    @server.on "message", (buf, rinfo) =>
      port = rinfo.port
      ip = rinfo.address
      #debuglog("[UDPHub(#{this.listenToPort})::onMessage]server, from:#{ip}:#{port}, got:#{buf.toString('hex')}")

      # validate sende's host
      unless ip is @host
        return console.error "[UDPHub(#{this.listenToPort})::onMessage] ignore msg from outside server #{ip} "

      # validate buf content
      if not Buffer.isBuffer(buf) or buf.length <=  SGF_UDP_HEAD_LENGTH or buf.readUInt32BE(0) isnt SIGNATURE
        return console.warn "[UDPHub(#{this.listenToPort})::onMessage] invalid buf:#{buf}"

      channelId =  buf.readUInt32BE(4)
      #debuglog("[UDPHub(#{this.listenToPort})::onMessage] channelId:#{channelId}")
      this.clientPorts[port] = Date.now()
      this.clientChannelId[port] = channelId

      this.broadcast(buf, channelId, port)
      return

    @server.on "listening", () =>
      address = this.server.address()
      debuglog("[on listening] listening #{address.address}:#{address.port}")
      return

    return

  # start this udp hub service
  start : ->
    debuglog "[start] #{@host}:#{@listenToPort}"
    @server.bind(@listenToPort, @host)
    return

  # stop this udp hub service
  stop : ->
    this.server.close()
    return

  # broadcast message
  broadcast : (buf, channelId, ignorePort) ->
    #debuglog "[broadcast] ignorePort:#{ignorePort}, buf.length:#{buf.length}"
    ignorePort = ignorePort.toString()

    @deadPorts.length = 0
    #@deadPorts.splice(0, @deadPorts.length) if @deadPorts.length > 0

    # all timestamp < aliveLine ports are dead ports
    aliveLine = Date.now() - LAZY_TIMEOUT

    for port, timestamp of @clientPorts
      continue unless port isnt ignorePort
      if(timestamp < aliveLine)
        #console.log "[UDPHub::broadcast] dead client:#{port}"
        @deadPorts.push(port)
      else if @clientChannelId[port] is channelId
        debuglog "[broadcast] from:#{ignorePort} to:#{port} buf.length:#{buf.length}"
        @server.send(buf, SGF_UDP_HEAD_LENGTH, buf.length - SGF_UDP_HEAD_LENGTH, port, "127.0.0.1")

    for port in @deadPorts
      delete @clientPorts[port]
      delete @clientChannelId[port]

    return

module.exports = UDPHub
