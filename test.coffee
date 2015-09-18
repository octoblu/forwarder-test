toDeviceCon = meshblu.createConnection({uuid: toDevice.uuid, token: toDevice.token})
fromDeviceCon = meshblu.createConnection({uuid: fromDevice.uuid, token: fromDevice.token})
device2con = meshblu.createConnection({uuid: device2.uuid, token: device2.token})

fromDeviceCon.on 'ready', (stuff) ->
    debug 'from device online', stuff
    setInterval ->
        fromDeviceCon.message {devices: '*' , payload: 'taco'}
        console.log 'tick'
      , 2000

toDeviceCon.on 'ready', (stuff) ->
  toDeviceCon.subscribe {uuid: fromDevice.uuid}, (result) ->
    debug 'subscribe message ' , result
  toDeviceCon.on 'message', (result) ->
    debug 'message recieved', result

device2con.on 'ready', (stuff) ->
  device2con.subscribe {uuid: fromDevice.uuid}, (result) ->
    debug 'dev 2 subscribe message ' , result
  device2con.on 'message', (result) ->
    debug 'dev 2 message recieved', result
