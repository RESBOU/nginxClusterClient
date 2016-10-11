require! {
  lweb3: lweb
  'lweb3/transports/client/tcp': { tcpClient }
}

export Node = tcpClient.extend4000 do
  register: -> true

if require.main is module
  true
