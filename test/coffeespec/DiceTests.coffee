describe "dice", ->
  it "should be either a number or an operator", ->
    theDice = new Dice('paper', '1')
    expect(theDice.type).toBe('invalid')