Buffer = require('buffer').Buffer
socket = require('dgram').createSocket('udp4')

# Yet another statsd client implementation : this time , in coffeescript


class Client
  constructor: (@host, @port) ->

  send: (data,sample_rate) ->
    sample_rate = 1 if not sample_rate?
    samples = {}

    # Pick random samples from the data to send to the server
    if sample_rate < 1
      if Math.random() <= sample_rate
        for key, value of data
          samples[key] = value + '|@' + sample_rate
    else
      samples = data

    # send the samples to the server, one by one
    for key,value of samples
      send_data = new Buffer("#{key}:#{value}")
      socket.send send_data, 0 , send_data.length, @port, @host, (err, n)->
        console.log err if err?

  update_stats: (stats, delta, sample_rate) ->
    stats = [ stats ] if typeof(stats) is "string"
    delta = 1 if not delta?
    data = {}

    for element in stats
      data[element] = delta + '|c'

    @send(data, sample_rate)

  increment: (stats, sample_rate) ->
    @update_stats stats, 1 , sample_rate

  decrement: (stats, sample_rate) ->
    @update_stats stats, -1 , sample_rate

  timing: (stat , time, sample_rate) ->
    stats = {}
    stats[stat] = time + '|ms'
    @send stats, sample_rate

module.exports = Client