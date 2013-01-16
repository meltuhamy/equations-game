{DiceFace} = require '../DiceFace.js'
DICEFACESYMBOLS = DiceFace.symbols

{Evaluator} = require '../Evaluator.js'
{ExpressionParser, Node} = require '../Parser.js'
{Player} = require '../Player.js'
{Game} = require '../Game.js'


describe "game", ->
  it "should accept a valid goal with three dice", ->
    game = new Game
    game.globalDice = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.plus,DICEFACESYMBOLS.six]
    testPassed = game.checkGoal([0,1,2])
    expect(testPassed).toEqual(true)

  it "should prevent goals that use more than six dice", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three, DICEFACESYMBOLS.three, DICEFACESYMBOLS.three, DICEFACESYMBOLS.three, DICEFACESYMBOLS.three]
    test = -> game.checkGoal([0,1,2,3,4,5,6])
    expect(test).toThrow("Goal uses more than six dice")

  it "should check the goal uses resources dice only", ->
    game = new Game
    game.globalDice = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three]
    test = -> game.checkGoal([-6,0,1])
    expect(test).toThrow("Goal has out of bounds array index")

  
  it "should prevent goals using pairs of the same dice", ->
    game = new Game
    game.globalDice = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three]
    test = -> game.checkGoal([1,1])
    expect(test).toThrow("Goal uses duplicates dice")

  it "should prevent goals using a duplicate dice with other dice", ->
    game = new Game
    game.globalDice = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three]
    test = -> game.checkGoal([0,0,1,2])
    expect(test).toThrow("Goal uses duplicates dice")

  it "should prevent goals with several duplicates", ->
    game = new Game
    game.globalDice = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three]
    test = -> game.checkGoal([0,0,2,2])
    expect(test).toThrow("Goal uses duplicates dice")

  it "should add two players to game", ->
    game = new Game([],2)
    game.addClient(31,"bob")
    game.addClient(32,"sam")
    l = game.playerManager.players.length
    expect(l).toEqual(2)

  it "should add two players to game and one submit a right answer", ->
    game = new Game([],2)
    e = new Evaluator
    p = new ExpressionParser 
    game.challengeMode = true
    game.globalDice = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.plus,DICEFACESYMBOLS.two,DICEFACESYMBOLS.one,DICEFACESYMBOLS.multiply,DICEFACESYMBOLS.three]
    game.addClient(31,"bob")
    game.addClient(32,"sam")
    game.setGoal([0,1,2])
    game.submitPossible(32)
    game.submitSolution(32, [5])
    expect(e.evaluate(game.goalTree)).toEqual(3)

  it "should add two players to game anone submit a right answer while the other submits a wrong answer", ->
    game1 = new Game([],2)
    e = new Evaluator
    p = new ExpressionParser 
    game1.challengeMode = true
    game1.globalDice = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.plus,DICEFACESYMBOLS.two,DICEFACESYMBOLS.one,DICEFACESYMBOLS.multiply,DICEFACESYMBOLS.three, DICEFACESYMBOLS.one,DICEFACESYMBOLS.plus,DICEFACESYMBOLS.two,DICEFACESYMBOLS.one,DICEFACESYMBOLS.multiply,DICEFACESYMBOLS.three]
    game1.addClient(31,"bob")
    game1.addClient(32,"sam")
    game1.setGoal([0,1,2])
    game1.submitPossible(31)
    game1.submitPossible(32)
    game1.submitSolution(31, [0,1,2])
    game1.submitSolution(32, [0,1,2])
    expect(e.evaluate(game1.goalTree)).toEqual(3)
    expect(game1.playerManager.rightAnswers[game1.playerManager.playerSocketIds.indexOf(31)]==false)
    expect(game1.playerManager.rightAnswers[game1.playerManager.playerSocketIds.indexOf(32)]==true)