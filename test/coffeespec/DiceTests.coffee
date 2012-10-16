describe "dice", ->
  it "should be either a number or an operator", ->
    theDice = new Dice('paper', '1')
    expect(theDice.type).toBe('invalid')

describe "dice", ->
  it "if type is number then should be a number", ->
    theDice = new Dice('number', 'p')
    expect(theDice.type).toBe('invalid')
###
describe "dice", ->
  it "if type is operattion then should be an operator", ->
    theDice = new Dice('operator', 'l')
    expect(theDice.type).toBe('invalid')
###