{DiceFace} = require '../DiceFace.js'
DICEFACESYMBOLS = DiceFace.symbols
{Evaluator} = require '../Evaluator.js'

{ExpressionParser, Node} = require '../Parser.js'

describe "parser", ->
  it "should construct a node", ->
    node = new Node(type: "number", token: DICEFACESYMBOLS.one, children:[])
    expect(node.type).toEqual "number"
    expect(node.token).toEqual DICEFACESYMBOLS.one
    expect(node.children).toEqual []
 
  it "should parse single digit numbers", ->
    p = new ExpressionParser(true)

    tree = p.parse [DICEFACESYMBOLS.one]
    expect(tree.type).toEqual "number"
    
    expect(tree.token).toEqual [DICEFACESYMBOLS.one]
    expect(tree.children).toEqual []

  it "should parse two digit numbers", ->
    p = new ExpressionParser(true)
    tree = p.parse [1,2]   # "12"
    expect(tree.type).toEqual "number"
    expect(tree.token).toEqual [1,2]
    expect(tree.children).toEqual []

  it "shouldnt pass three ore more digit numbers", ->
    p = new ExpressionParser(true)
    test = -> p.parse [DICEFACESYMBOLS.one, DICEFACESYMBOLS.two, DICEFACESYMBOLS.three, DICEFACESYMBOLS.four] # "123"
    expect(test).toThrow("Can't have more than two digits, maytey")

  it "should parse unary operators on single digit numbers", ->
    p = new ExpressionParser(true)
    tree = p.parse [DICEFACESYMBOLS.minus, DICEFACESYMBOLS.one]   # "-1"
    expect(tree.type).toEqual "unaryop"
    expect(tree.token).toEqual [DICEFACESYMBOLS.minus]
    expect(tree.children.length).toEqual 1 #Should only have one child

    child1 = tree.children[0]
    expect(child1.type).toEqual "number"
    expect(child1.token).toEqual [DICEFACESYMBOLS.one]
    expect(child1.children).toEqual []

  it "should parse unary operators on 2 digit numbers", ->
    p = new ExpressionParser(true)
    tree = p.parse [DICEFACESYMBOLS.minus, DICEFACESYMBOLS.one, DICEFACESYMBOLS.two]   # "-12"
    expect(tree.type).toEqual "unaryop"
    expect(tree.token).toEqual [DICEFACESYMBOLS.minus]
    expect(tree.children.length).toEqual 1 #Should only have one child

    child1 = tree.children[0]
    expect(child1.type).toEqual "number"
    expect(child1.token).toEqual [DICEFACESYMBOLS.one, DICEFACESYMBOLS.two]
    expect(child1.children).toEqual []

  it "shouldnt parse unary ops on more than two digiti numbers", ->
    p = new ExpressionParser(true)
    test = -> p.parse [DICEFACESYMBOLS.minus, DICEFACESYMBOLS.one, DICEFACESYMBOLS.two, DICEFACESYMBOLS.three]   # "-12"
    expect(test).toThrow("Can't have more than two digits, maytey")

  it "should parse binary operators on single digits", ->
    p = new ExpressionParser(true)
    tree = p.parse [DICEFACESYMBOLS.one, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.two]

    expect(tree.type).toEqual "binop"
    expect(tree.token).toEqual [DICEFACESYMBOLS.plus]

    firstChild = tree.children[0]
    secondChild = tree.children[1]

    expect(firstChild.type).toEqual "number"
    expect(firstChild.token).toEqual [DICEFACESYMBOLS.one]
    expect(firstChild.children).toEqual []

    expect(secondChild.type).toEqual "number"
    expect(secondChild.token).toEqual [DICEFACESYMBOLS.two]
    expect(secondChild.children).toEqual []

  it "should parse complex bracketed expressions", ->
    p = new ExpressionParser(true)
    tree = p.parse [DICEFACESYMBOLS.bracketL, DICEFACESYMBOLS.one, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.bracketL, DICEFACESYMBOLS.two, DICEFACESYMBOLS.minus, DICEFACESYMBOLS.three, DICEFACESYMBOLS.bracketR, DICEFACESYMBOLS.bracketR]

  it "should parse", ->
    p = new ExpressionParser(true)
    tree = p.parse [DICEFACESYMBOLS.one, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.two, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.three]

  it "should flatten correctly", ->
    p = new ExpressionParser(true)
    tree = p.parse [DICEFACESYMBOLS.one, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.two, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.three] 
    flat = p.flatten(tree)
    expect(flat).toEqual([DICEFACESYMBOLS.one, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.two, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.three])

  it "should remove redundant brackets correctly", ->
    p = new ExpressionParser(true)
    tree = p.parse [DICEFACESYMBOLS.one, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.bracketL, DICEFACESYMBOLS.two, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.three, DICEFACESYMBOLS.bracketR] 
    flat = p.flatten(tree)
    expect(flat).toEqual([DICEFACESYMBOLS.one, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.two, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.three])

  it "should not parse", ->
    p = new ExpressionParser(true)
    test = -> p.parse [DICEFACESYMBOLS.one, DICEFACESYMBOLS.divide, DICEFACESYMBOLS.zero]
    expect(test).toThrow("You can't divide by zero you idiot")

  it "should not parse", ->
    p = new ExpressionParser(true)
    test = -> p.parse [DICEFACESYMBOLS.one, DICEFACESYMBOLS.divide, DICEFACESYMBOLS.bracketL, DICEFACESYMBOLS.three, DICEFACESYMBOLS.minus, DICEFACESYMBOLS.three, DICEFACESYMBOLS.bracketR]
    expect(test).toThrow("You can't divide by zero you idiot")

  it "should not parse", ->
    p = new ExpressionParser(true)
    test = -> p.parse [DICEFACESYMBOLS.sqrt, DICEFACESYMBOLS.bracketL, DICEFACESYMBOLS.minus, DICEFACESYMBOLS.two, DICEFACESYMBOLS.bracketR]
    expect(test).toThrow("You can't square root a negative")

  it "should not parse", ->
    p = new ExpressionParser(true)
    test = -> p.parse [DICEFACESYMBOLS.one, DICEFACESYMBOLS.multiply, DICEFACESYMBOLS.bracketL, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.bracketR, DICEFACESYMBOLS.two]
    expect(test).toThrow("Invalid value before bracket")

  it "should not parse", ->
    p = new ExpressionParser(true)
    test = -> p.parse [DICEFACESYMBOLS.one, DICEFACESYMBOLS.multiply, DICEFACESYMBOLS.bracketL, DICEFACESYMBOLS.bracketR, DICEFACESYMBOLS.two]
    expect(test).toThrow("Invalid value after bracket")

  it "should not parse", ->
    p = new ExpressionParser(true)
    test = -> p.parse [DICEFACESYMBOLS.one, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.bracketL]
    expect(test).toThrow("You can't finish with an operator")

  it "should not parse", ->
    p = new ExpressionParser(true)
    test = -> p.parse [DICEFACESYMBOLS.one, DICEFACESYMBOLS.bracketL, DICEFACESYMBOLS.two, DICEFACESYMBOLS.bracketR]
    expect(test).toThrow("Invalid syntax. Must use a cross to multiply")

  it "should not parse", ->
    p = new ExpressionParser(true)
    test = -> p.parse [DICEFACESYMBOLS.one, DICEFACESYMBOLS.plus]
    expect(test).toThrow("You can't finish with an operator")

  it "should not parse", ->
    p = new ExpressionParser(true)
    test = -> p.parse [DICEFACESYMBOLS.one, DICEFACESYMBOLS.minus, DICEFACESYMBOLS.bracketL, DICEFACESYMBOLS.two, DICEFACESYMBOLS.bracketR, DICEFACESYMBOLS.plus]
    expect(test).toThrow("You can't finish with an operator")

  #it "should parse combinations of binary and unary operators", ->
   # console.log "Need to implement this!"
