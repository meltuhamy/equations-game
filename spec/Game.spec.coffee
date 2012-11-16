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
    testPassed = game.checkGoal([1,2,3])
    expect(testPassed).toEqual(true)

  it "should prevent goals that use more than six dice", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three]
    test = -> game.checkGoal([1,2,3,4,5,6,7])
    expect(test).toThrow("Goal uses more than six dice")

  it "should check the goal uses resources dice only", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three]
    test = -> game.checkGoal([-1,2,3])
    expect(test).toThrow("Goal has out of bounds array index")

  
  it "should prevent goals using pairs of the same dice", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three]
    test = -> game.checkGoal([1,1])
    expect(test).toThrow("Goal uses duplicates dice")

  it "should prevent goals using a duplicate dice with other dice", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three]
    test = -> game.checkGoal([1,1,2,3])
    expect(test).toThrow("Goal uses duplicates dice")

  it "should prevent goals with several duplicates", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three]
    test = -> game.checkGoal([0,0,2,2])
    expect(test).toThrow("Goal uses duplicates dice")

###  it "should not allow unbalanced brackets when setting the goal", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.plus,DICEFACESYMBOLS.three]
    test = -> game.checkGoal([25,1,2,3])
    expect(test).toThrow("Error Unbalanced Parenthesis")

  it "should not count brackets as dice", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three]
    testPassed = game.checkGoal([1,2,3,24,4,5,6,25])
    expect(testPassed).toEqual(true)

  it "should work for nested brackets", ->
    game = new Game
    game.state.unallocated = [DICEFACESYMBOLS.one,DICEFACESYMBOLS.two,DICEFACESYMBOLS.three]
    testPassed = game.checkGoal([1,24,2,3,24,4,25,5,6,25])
    expect(testPassed).toEqual(true)###