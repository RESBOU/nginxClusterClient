require! {
  os
  bluebird: p
  lweb3: lweb
  'lweb3/transports/client/nssocket': { nssocketClient }
}

export Node = nssocketClient.extend4000 do
  initialize: ->
    @addProtocol new lweb.protocols.query.client!

  register: (data={}) -> new p (resolve,reject) ~>
    @connect()
    @query add: data, (msg) ~>
      @addProtocol new lweb.protocols.query.server!
      @onQuery ping: true, (msg,reply) -> reply.end pong: msg.ping
      resolve msg
    
if require.main is module
  node = new Node do
    server: 'localhost'
    port: 2010
    
  node.register name: "#{ os.hostname() }.#{ process.pid }" ip: os.hostname(), port: 8274
  .then -> console.log "registered", it
