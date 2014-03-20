# udpcomm

Provide a simple hub-like UPD datagram communication mechanism for NodeJs

This module includes 2 class:
  * UDPShoutor - send and receive messages from other shouters
  * UDPHub - a hub mechanism to distribute message from shouters

## Install
Install the module with:

```bash
npm install udpcomm
```

## Usage
```javascript

// fire up the udp hub
(function() {
  var UDPHub, server;

  UDPHub = require("../udpcomm").UDPHub;

  server = new UDPHub(9999);

  server.start();

}).call(this);

// in another process, run the shouter
(function() {
  var PORT, UDPShoutor, channelId, onMessage, shoutor;

  UDPShoutor = require("../udpcomm").UDPShoutor;

  PORT = 9999;

  channelId = 5;

  onMessage = function(msg, rinfo) {
    return console.log("[client(" + process.pid + ")] msg:" + (msg.toString()) + ", from:" + rinfo.address + ":" + rinfo.port);
  };

  shoutor = new UDPShoutor(PORT, channelId, onMessage);

  setInterval(function() {
    var message;
    message = new Buffer("channelId:" + channelId + " pid:" + process.pid + ", time:" + (Date.now()));
    return shoutor.sendMessage(message);
  }, 1000);

}).call(this);


// in third process, run the same shouter
// and you will see how it work

```


## License
Copyright (c) 2014 Yi
Licensed under the MIT license.
