# This is effectively a proxy service for net.Socket objects. We create
# actual socket connections here in this background page that we
# interact with via Chrome messaging API from content scripts. Content
# scripts, however, can just use a proxy.SocketProxy object as if it
# were a net.Socket object. See proxy.coffee for the "client" to the
# code below.

sockets = []

listener = (port) ->
  socket = new net.Socket
  sockets.push(socket)
  port.onDisconnect.addListener ->
    socket.destroy()
    sockets.splice sockets.indexOf(socket), 1
  port.onMessage.addListener (msg) ->
    socket[msg.method].apply socket, if msg.args? then msg.args else []
  socket.emit = (ev, args...) ->
    port.postMessage method: 'emit', args: [ev].concat(args)

chrome.extension.onConnect.addListener listener
chrome.extension.onConnectExternal.addListener listener
