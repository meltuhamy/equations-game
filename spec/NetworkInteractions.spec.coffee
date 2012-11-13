soda = require("soda")
describe "networkInteractions", ->
  it "should give each player a unique id", ->

    ###
    HOW THIS WORKS
    1. Define the browser settings and set them up
    2. Do the stuff we want to do using the browsers
    3. In the mean time, wait until the browsers are finished doing what we want
    4. Use the stuff we got from the browsers to do the actual jasmine test.

    ###

    #Define what URL will be in each browser etc.
    browserSettings = 
      host: "localhost"
      port: 4444
      url: "http://localhost:8080"
      browser: "firefox"

    # Define two browser windows.
    browser1 = soda.createClient(browserSettings)
    browser2 = soda.createClient(browserSettings)

    # These are the ids we are going to get from the browser windows
    id1 = undefined
    id2 = undefined

    # A busy-wait lock that gets released when browsers close
    browsersClosed = false
    
    # Open browser 1
    browser1.session (err) ->
      browser1.open "/", (err, body) ->
        # Wait for the page (dom) to load. If more than 5000 milliseconds pass and the page hasn't loaded, exit.
        browser1.waitForPageToLoad 5000, (err, body) ->
          # Page is now loaded. Now, repeatedly check if Game.myPlayerId is defined. 20000 is the timeout
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
  

    # Busy wait until the browsers close. Uses finishedTest to test this.
    waitsFor(->
      return browsersClosed == true
    , "Browser test never completed", 100000);

    # We need a 'runs' here to say "only run the runs code AFTER the waiting is done"
    runs(->
      # Finally, do the unit test (this is normal jasmine stuff)
      expect(id1).not.toEqual(id2)
    )
