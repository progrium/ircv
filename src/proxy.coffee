exports = window.net = {}

class SocketProxy
  constructor: ->
    @port = chrome.extension.connect(chrome.i18n.getMessage("@@extension_id"))
    @port.onMessage.addListener (msg) =>
      this[msg.method].apply this, if msg.args? then msg.args else []
    @listeners = {}

  on: (ev, cb) ->
    (@listeners[ev] ?= []).push cb
  once: (ev, cb) ->
    @on ev, f = (args...) =>
      @removeListener ev, f
      cb(args...)
    f.listener = cb
  emit: (ev, args...) ->
    l(args...) for l in (@listeners[ev] ? [])

  connect: (port, host='localhost') ->
    @port.postMessage method: 'connect', args: [port, host]

  write: (data) ->
    @port.postMessage method: 'write', args: [data]

  destroy: ->
    @port.postMessage method: 'destroy'

  end: ->
    @port.postMessage method: 'end'

  setTimeout: (ms, cb) ->
    @port.postMessage method: 'setTimeout'
    @once 'timeout', cb

exports.Socket = SocketProxy
