soda = require("soda")
describe "networkInteractions", ->
  it "should give a player an id", ->
    browser1 = soda.createClient(
      host: "localhost"
      port: 4444
      url: "http://localhost:8080"
      browser: "firefox"
    )

    browser2 = soda.createClient(
      host: "localhost"
      port: 4444
      url: "http://localhost:8080"
      browser: "firefox"
    )

    id1 = undefined
    id2 = undefined
    finishedFirst = false
    finishedSecond = false
    
    runs(->
      browser1.session (err) ->
        browser1.open "/", (err, body) ->
          browser1.waitForPageToLoad 5000, (err, body) ->
            console.log err
            evalResult = undefined
            browser1.getEval "var tetris = 'JAMES'; storedVars['evalResult'] = tetris;", (err, body) ->
              console.log "<<<<<<<<<<<<<INSIDE getEval>>>>>>>>>>>>>>>>"
              console.log err
              console.log body
              console.log "<<<<<<<<<<<<<>>>>>>>>>>>>>>>>"
              browser1.testComplete (err, body) ->
                console.log "done"
                finishedFirst = true
                finishedSecond = true

    )

  
    waitsFor(->
      return finishedFirst == true
    , "First browser never completed", 20000);

    runs(->
      #browser2.chain.session().open("/").waitForPageToLoad(5000).end (err) ->
      #  browser2.testComplete ->
      #    console.log "done 2"
      #    finishedSecond = true
      #    throw err  if err
    )

    waitsFor( ->
      return finishedSecond == true
    , "Second browser never completed", 20000);

    runs(->
      console.log browserTitle1
      console.log browserTitle2
      expect(browserTitle1).toEqual(browserTitle2)
    )
