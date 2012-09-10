dgram = require("dgram")

LAZY_TIMEOUT = 10000

ALLOW_HOST1 = "127.0.0.1"
ALLOW_HOST2 = "localhost"

# 用于二进制流消息验证的签名值
SGF_SIGNATURE = 6258000

SGF_UDP_HEAD_LENGTH = 11

class UDPHub

  # constructor function
  # @param {uint} listenToPort, port to start this service
  constructor:(listenToPort) ->
    this.server = dgram.createSocket("udp4")

    # key: client port, value: update at
    this.clientPorts = {}

    # key: channel Id, value: channel id
    this.clientChannelId = {}

    this.deadPorts = []

    this.listenToPort = listenToPort

    # handle message received from clients
    this.server.on("message", (buf, rinfo) =>
      port = rinfo.port
      ip = rinfo.address
      #console.log("[UDPHub(#{this.listenToPort})::onMessage]server, from:#{ip}:#{port}, got:#{buf.toString('hex')}")
      # validate sende's host
      unless ip is ALLOW_HOST1 or ip is ALLOW_HOST2
        return console.error "[UDPHub(#{this.listenToPort})::onMessage] ignore msg from outside server #{ip} "
      # validate buf content
      if not Buffer.isBuffer(buf) or buf.length <=  SGF_UDP_HEAD_LENGTH or buf.readUInt32BE(0) isnt SGF_SIGNATURE
        return console.warn "[UDPHub(#{this.listenToPort})::onMessage] invalid buf:#{buf}"

      channelId =  buf.readUInt32BE(4)
      this.clientPorts[port] = Date.now()
      this.clientChannelId[port] = channelId

      this.broadcast(buf, channelId, port)
      return
    )

    this.server.on("listening", () =>
      address = this.server.address()
      console.info("[udphub::listening] listening #{address.address}:#{address.port}")
    )

    return

  # start this udp hub service
  start : ->
    this.server.bind(this.listenToPort)
    return

  # stop this udp hub service
  stop : ->
    this.server.close()
    return

  # broadcast message
  broadcast : (buf, channelId, ignorePort) ->
    console.log "[broadcast] ignorePort:#{ignorePort}, buf.length:#{buf.length}"

    ignorePort = ignorePort.toString()

    this.deadPorts.splice(0, this.deadPorts.length) if this.deadPorts.length > 0

    # all timestamp < aliveLine ports are dead ports
    aliveLine = Date.now() - LAZY_TIMEOUT

    for port, timestamp of this.clientPorts
      continue unless port isnt ignorePort
      if(timestamp < aliveLine)
        #console.log "[UDPHub::broadcast] dead client:#{port}"
        this.deadPorts.push(port)
      else if this.clientChannelId[port] is channelId
        #console.log "[UDPHub::broadcast] from #{ignorePort} to 127.0.0.1:#{port}"
        this.server.send(buf, SGF_UDP_HEAD_LENGTH, buf.length - SGF_UDP_HEAD_LENGTH, port, "127.0.0.1")

    for port in this.deadPorts
      delete this.clientPorts[port]
      delete this.clientChannelId[port]

    #console.log "[broadcast] clients:"
    #console.dir this.clientPorts
    #console.dir this.clientChannelId
    return

module.exports = UDPHub
