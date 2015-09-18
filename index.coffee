debug = require('debug')('forwarder-cli')
meshblu = require 'meshblu'
_ = require 'lodash'

conn = meshblu.createConnection({})

uuid = token = ''
device1 = device2 = forwarder = {}

conn.register {type: 'test-user'}, (device) ->
#  debug 'registered device', device
  uuid = device.uuid
  token = device.token
  connx = meshblu.createConnection({uuid: uuid, token: token})

  connx.on 'ready', (stuff) ->
    connx.whoami {}, (result) ->
    #  debug 'I AM OF TYPE: ', result

    connx.register {type: 'forwarder-device'}, (forwarderDevice) ->
      forwarder = forwarderDevice
      connx.register {type: 'device-one'}, (deviceone) ->
        device1 = deviceone
        connx.register {type: 'device-two'}, (devicetwo) ->
          device2 = devicetwo
          connx.claimdevice device1, (result) ->
            connx.claimdevice device2, (result) ->
              connx.claimdevice forwarder, (result) ->
              connx.mydevices {}, (result) ->
              #  debug 'devices', result
                subscribePair device1, forwarder, connx
                subscribePair device2, forwarder, connx

                device2con = meshblu.createConnection({uuid: device2.uuid, token: device2.token})

                device2con.on 'ready', (stuff) ->
                    debug 'device 2online', stuff
                    setInterval ->
                        device2con.message {devices: device1.uuid , payload: 'taco'}
                        console.log 'tick'
                      , 2000

                device1con = meshblu.createConnection({uuid: device1.uuid, token: device1.token})

                device1con.on 'ready', (stuff) ->
                    debug 'device 2online', stuff
                    setInterval ->
                        device1con.message {devices: device2.uuid , payload: 'taco'}
                        console.log 'tick'
                      , 2000

subscribePair = (fromDevice, forwardDevice, connx) ->
  connx.device fromDevice, (result) ->
    debug 'true forwarder', forwardDevice
    #fromDevice.receiveWhitelist = [forwardDevice.uuid]
    if !_.has(fromDevice,'receiveWhitelist')
       fromDevice.receiveWhitelist = []
       fromDevice.receiveWhitelist.push(forwardDevice.uuid)
    else
       fromDevice.receiveWhitelist.push(forwardDevice.uuid)
    connx.update fromDevice, (result) ->
      debug 'updated receiveWhitelist', result
      connx.device forwardDevice, (device) ->
          debug 'got forwarder', device.device
          device = device.device
          if !_.has(device.options,'subscribeList')
             device.options = {}
             device.options.subscribeList = []
             device.options.subscribeList.push(fromDevice.uuid)
          else
             device.options.subscribeList.push(fromDevice.uuid)
          connx.update device, (result) ->
            debug 'updated forwarder subscribe list', result
