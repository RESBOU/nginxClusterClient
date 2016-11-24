require! {
  os
  bluebird: p
  lweb3: lweb
  'lweb3/transports/client/tcp': { tcpClient }
  events: { EventEmitter }
}

export LoadBalancerClient = tcpClient.extend4000 do
  initialize: ->
    @addProtocol new lweb.protocols.query.client!
    @addProtocol new lweb.protocols.query.server!
    @onQuery ping: true, (msg,reply) -> reply.end pong: msg.ping

  register: (data={}) -> new p (resolve,reject) ~> 
    @connect!
    .then ~> @pquery add: data
    .timeout 3000
    .then ~>
      @trigger 'register'
      resolve data
      
    .catch reject

export class LoadBalancerClientReconnect
  (opts) -> @ <<< opts

  register: (data={}) ->
    if @client? then @client.end()
    @client = new LoadBalancerClient @{ host, port }
    @client.once 'end', ~> setTimeout (~> @register data), 1000
    @client.register data

if require.main is module
  settings = do
    server: 
      host: 'localhost'
      port: 2010
    port: 3000
    
  console.log  'registering...', settings
  node = new LoadBalancerClient settings.server
      
  node.register (name: "#{ os.hostname() }-#{ process.pid }") <<< settings{ port, ip }
  .then -> console.log "registered :)", it
  .catch -> console.log 'init failed!', it
