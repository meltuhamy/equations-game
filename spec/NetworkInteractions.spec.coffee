###
soda = require("soda")
fs = require 'fs'
{print} = require 'sys'
spawn = require('child_process').spawn

startServer = (callback) ->
  checkedListeningOnce = false
  newNode = spawn 'node', ['server.js']
  newNode.stderr.on 'data', (data) ->
    process.stderr.write "\nSERVER: " + data.toString()
  newNode.stdout.on 'data', (data) ->
    print "\nSERVER: " + data.toString()
    if(!checkedListeningOnce && data.toString()=="Listening\n")
      checkedListeningOnce = true
      setTimeout( -> 
        callback()
      , 1000)
  newNode.on 'exit', (code) ->
    console.log "SERVER QUIT"
  return newNode

killServer = (nodeProcess) ->
  nodeProcess.kill('SIGTERM')

#Define what URL will be in each browser etc.
browserSettings = 
  host: "localhost"
  port: 4444
  url: "http://localhost:8080"
  browser: "firefox"

describe "networkInteractions", ->
  it "should give each player a unique id", ->

    #
    #HOW THIS WORKS
    #1. Define the browser settings and set them up
    #2. Do the stuff we want to do using the browsers
    #3. In the mean time, wait until the browsers are finished doing what we want
    #4. Use the stuff we got from the browsers to do the actual jasmine test.
    #

    #Start the server
    serverReady = false
    server = startServer(-> serverReady = true)

    #Wait for server to be ready
    waitsFor(->
      return serverReady == true
    , "Server never became ready", 20000);

    # A busy-wait lock that gets released when browsers close
    browsersClosed = false

    # These are the ids we are going to get from the browser windows
    id1 = undefined
    id2 = undefined

    runs( ->
      # Define two browser windows.
      browser1 = soda.createClient(browserSettings)
      browser2 = soda.createClient(browserSettings)

      # Open browser 1
      browser1.session (err) ->
        browser1.open "/", (err, body) ->
          # Wait for the page (dom) to load. If more than 5000 milliseconds pass and the page hasn't loaded, exit.
          browser1.waitForPageToLoad 5000, (err, body) ->
            # Page is now loaded. Wait for getting rooms to load
            browser1.waitForElementPresent 'id=gameslist', (err, body) ->
              # Click on first room
              browser1.click 'css=tr[data-gamenumber=0]', (err, body) ->
                # Now, repeatedly check if Game.myPlayerId is defined. 20000 is the timeout
                browser1.waitForCondition "typeof window.Game.myPlayerId !== 'undefined'", 20000, (err, body) ->
                  # Game.myPlayerId is finally defined. Now, get it's result and store it in body (the param call back)
                  browser1.getEval "storedVars['evalResult'] = window.Game.myPlayerId;", (err, body) ->
                    id1 = body
                    #OK, we're done with browser 1 but don't want to close it yet because we need to open
                    #a new browser window to check what tha player id for *it* is.
                    #Open a new browser
                    browser2.session (err) ->
                      browser2.open "/", (err, body) ->
                        # Wait for the page to load
                        browser2.waitForPageToLoad 5000, (err, body) ->
                          browser2.waitForElementPresent 'id=gameslist', (err, body) ->
                            # Click on first room
                            browser2.click 'css=tr[data-gamenumber=0]', (err, body) ->
                              # Wait up to 20000 milliseconds ultil the myPlayerId is defined.
                              browser2.waitForCondition "typeof window.Game.myPlayerId !== 'undefined'", 20000, (err, body) ->
                                # Get Game.myPlayerId
                                browser2.getEval "storedVars['evalResult'] = window.Game.myPlayerId;", (err, body) ->
                                  id2 = body
                                  #Great, we now have the player id of browser 1 and browser two. Close browser 2.
                                  browser2.testComplete (err, body) ->
                                    # Browser 2 is now closed. Now close browser 1.
                                    browser1.testComplete (err, body) ->
                                      #Browser 1 *and* browser 2 are now close. We can now release the lock.
                                      browsersClosed = true
    )

    # Busy wait until the browsers close. Uses browsersClosed to test this.
    waitsFor(->
      return browsersClosed == true
    , "Browser test never completed", 100000);

    # We need a 'runs' here to say "only run the runs code AFTER the waiting is done"
    runs(->
      # Finally, do the unit test (this is normal jasmine stuff)
      expect(id1).not.toEqual(id2)

      #Important: Exit the server!
      killServer(server)
    )





  it "Only one player should be the goal setter.", ->
    #Start the server
    serverReady = false
    server = startServer(-> serverReady = true)

    #Wait for server to be ready
    waitsFor(->
      return serverReady == true
    , "Server never became ready", 20000);

    # A busy-wait lock that gets released when browsers close
    browsersClosed = false

    # Boolean values to indicate if the goalmake div exists in each browser
    goalmake1 = false
    goalmake2 = false
    
    runs( ->
      browser1 = soda.createClient(browserSettings)
      browser2 = soda.createClient(browserSettings)

      browser1.session (err) ->
        browser1.open "/", (err, body) ->
          browser1.waitForPageToLoad 5000, (err, body) ->
            browser1.waitForElementPresent 'id=gameslist', (err, body) ->
              browser1.click 'css=tr[data-gamenumber=0]', (err, body) ->
                browser1.waitForCondition "typeof window.Game.myPlayerId !== 'undefined'", 20000, (err, body) ->
                  browser2.session (err) ->
                    browser2.open "/", (err, body) ->
                      browser2.waitForPageToLoad 5000, (err, body) ->
                        browser2.waitForElementPresent 'id=gameslist', (err, body) ->
                          browser2.click 'css=tr[data-gamenumber=0]', (err, body) ->
                            browser2.waitForCondition "typeof window.Game.myPlayerId !== 'undefined'", 20000, (err, body) ->
                              browser1.getEval 'storedVars["evalResult"] = window.document.getElementById("goalmake") !== null', (err, body) ->
                                goalmake1 = body
                                browser2.getEval 'storedVars["evalResult"] = window.document.getElementById("goalmake") !== null', (err,body) ->
                                  goalmake2 = body
                                  browser2.testComplete (err, body) ->
                                    browser1.testComplete (err, body) ->
                                      browsersClosed = true
    )


    waitsFor(->
      return browsersClosed == true
    , "Browser test never completed", 100000);

    runs(->
      expect(goalmake1).not.toEqual(goalmake2)
      killServer(server)
    )
###