soda = require("soda")
describe "networkInteractions", ->
  it "should give a player an id", ->
    browser1 = soda.createClient(
      host: "localhost"
      port: 4444
      url: "http://localhost:8080"
      browser: "firefox"
    )

    browserTitle1 = undefined;
    browserTitle2 = undefined;
    finishedFirst = false
    finishedSecond = false
    
    runs(->
      browser1.chain.session().open("/").getTitle((title) ->
        browserTitle1 = title
      ).end (err) -> 
        browser1.testComplete ->
          console.log "done 1"
          finishedFirst = true
    )

  
    waitsFor(->
      return finishedFirst == true
    , "First browser never completed", 20000);

    runs(->
      browser2 = soda.createClient(
        host: "localhost"
        port: 4444
        url: "http://localhost:8080"
        browser: "firefox"
      )

      browser2.chain.session().open("/").getTitle((title) ->
        browserTitle2 = title
      ).end (err) ->
        browser2.testComplete ->
          console.log "done 2"
          finishedSecond = true
          throw err  if err
    )

    waitsFor( ->
      return finishedSecond == true
    , "Second browser never completed", 20000);

    runs(->
      console.log browserTitle1
      console.log browserTitle2
      expect(browserTitle1).toEqual(browserTitle2)
    )
