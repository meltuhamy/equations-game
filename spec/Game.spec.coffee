{DiceFace} = require '../DiceFace.js'
DICEFACESYMBOLS = DiceFace.symbols

{Evaluator} = require '../Evaluator.js'
{ExpressionParser, Node} = require '../Parser.js'
{Player} = require '../Player.js'
{Game} = require '../Game.js'


describe "game", ->
  it "should accept a valid with three dice", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.plus,DICEFACESYMBOLS.six]
    testPassed = game.checkGoal([0,1,2])
    expect(testPassed).toEqual(true)

  it "should prevent goals that use more than six dice", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three, DICEFACESYMBOLS.three, DICEFACESYMBOLS.three, DICEFACESYMBOLS.three, DICEFACESYMBOLS.three]
    test = -> game.checkGoal([0,1,2,3,4,5,6])
    expect(test).toThrow("Goal uses more than six dice")

  it "should check the goal uses resources dice only", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three]
    test = -> game.checkGoal([-6,0,1])
    expect(test).toThrow("Goal has out of bounds array index")

  
  it "should prevent goals using pairs of the same dice", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three]
    test = -> game.checkGoal([1,1])
    expect(test).toThrow("Goal uses duplicates dice")

  it "should prevent goals using a duplicate dice with other dice", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three]
    test = -> game.checkGoal([0,0,1,2])
    expect(test).toThrow("Goal uses duplicates dice")

  it "should prevent goals with several duplicates", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three]
    test = -> game.checkGoal([0,0,2,2])
    expect(test).toThrow("Goal uses duplicates dice")

  it "should add two players to game", ->
    game = new Game([],2)
    game.addClient(31)
    game.addClient(32)
    l = game.players.length
    expect(l).toEqual(2)

  it "should add two players to game and one submit a right answer", ->
    game = new Game([],2)
    e = new Evaluator
    p = new ExpressionParser 
    game.challengeMode = true
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.plus,DICEFACESYMBOLS.two,DICEFACESYMBOLS.one,DICEFACESYMBOLS.multiply,DICEFACESYMBOLS.three]
    game.addClient(31)
    game.addClient(32)
    game.setGoal([0,1,2])
    game.submitPossible(32)
    game.submitSolution(32, [DICEFACESYMBOLS.one,DICEFACESYMBOLS.multiply,DICEFACESYMBOLS.three])
    expect(e.evaluate(game.goalTree)).toEqual(e.evaluate(p.parse(game.submittedSolutions[game.playerSocketIds.indexOf(32)])))

  it "should add two players to game anone submit a right answer while the other submits a wrong answer", ->
    game = new Game([],2)
    e = new Evaluator
    p = new ExpressionParser 
    game.challengeMode = true
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.plus,DICEFACESYMBOLS.two,DICEFACESYMBOLS.one,DICEFACESYMBOLS.multiply,DICEFACESYMBOLS.three]
    game.addClient(31)
    game.addClient(32)
    game.setGoal([0,1,2])
    game.submitPossible(31)
    game.submitSolution(31, [DICEFACESYMBOLS.one,DICEFACESYMBOLS.multiply,DICEFACESYMBOLS.two])
    game.submitSolution(32, [DICEFACESYMBOLS.one,DICEFACESYMBOLS.multiply,DICEFACESYMBOLS.three])
    #!expect(e.evaluate(game.goalTree)).toEqual(e.evaluate(p.parse(game.submittedSolutions[game.playerSocketIds.indexOf(31)])))
    expect(e.evaluate(game.goalTree)).toEqual(e.evaluate(p.parse(game.submittedSolutions[game.playerSocketIds.indexOf(32)])))
    expect(game.rightAnswers[game.playerSocketIds.indexOf(31)]==false)
    expect(game.rightAnswers[game.playerSocketIds.indexOf(32)]==true)

###
  it "should not allow unbalanced brackets when setting the goal", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.plus,DICEFACESYMBOLS.three]
    test = -> game.checkGoal([-1,0,1,2, -2])
    expect(test).toThrow("Error Unbalanced Parenthesis")

  it "should not count brackets as dice", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three, DICEFACESYMBOLS.four, DICEFACESYMBOLS.five, DICEFACESYMBOLS.six, DICEFACESYMBOLS.seven]
    testPassed = game.checkGoal([0,1,2,-1,3,4,5,-2])
    expect(testPassed).toEqual(true)

  it "should work for nested brackets", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three, DICEFACESYMBOLS.four, DICEFACESYMBOLS.five, DICEFACESYMBOLS.six, DICEFACESYMBOLS.seven]
    testPassed = game.checkGoal([0,-1,1,2,-1,3,-2,4,5,-2])
    expect(testPassed).toEqual(true)###