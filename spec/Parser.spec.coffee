{DICEFACES} = require '../DiceFace.js'
DICEFACESYMBOLS = DICEFACES.symbols
{Evaluator} = require '../Evaluator.js'

{ExpressionParser, Node} = require '../Parser.js'

describe "parser", ->
  it "should construct a node", ->
    node = new Node(type: "number", token: DICEFACESYMBOLS.one, children:[])
    expect(node.type).toEqual "number"
    expect(node.token).toEqual DICEFACESYMBOLS.one
    expect(node.children).toEqual []
 
  it "should parse single digit numbers", ->
    p = new ExpressionParser

    tree = p.parse [DICEFACESYMBOLS.one]
    expect(tree.type).toEqual "number"
    
    expect(tree.token).toEqual [DICEFACESYMBOLS.one]
    expect(tree.children).toEqual []
    

  it "should parse >= two digit numbers", ->
    p = new ExpressionParser
    tree = p.parse [12]   # "12"
    expect(tree.type).toEqual "number"
    expect(tree.token).toEqual [12]
    expect(tree.children).toEqual []

    tree = p.parse [DICEFACESYMBOLS.one, DICEFACESYMBOLS.two, DICEFACESYMBOLS.three] # "123"
    expect(tree.type).toEqual "number"
    expect(tree.token).toEqual [DICEFACESYMBOLS.one, DICEFACESYMBOLS.two, DICEFACESYMBOLS.three]
    expect(tree.children).toEqual []

  it "should parse unary operators on single digit numbers", ->
    p = new ExpressionParser
    tree = p.parse [DICEFACESYMBOLS.minus, DICEFACESYMBOLS.one]   # "-1"
    expect(tree.type).toEqual "unaryop"
    expect(tree.token).toEqual [DICEFACESYMBOLS.minus]
    expect(tree.children.length).toEqual 1 #Should only have one child

    child1 = tree.children[0]
    expect(child1.type).toEqual "number"
    expect(child1.token).toEqual [DICEFACESYMBOLS.one]
    expect(child1.children).toEqual []

  it "should parse unary operators on >= 2 digit numbers", ->
    p = new ExpressionParser
    tree = p.parse [DICEFACESYMBOLS.minus, DICEFACESYMBOLS.one, DICEFACESYMBOLS.two]   # "-12"
    expect(tree.type).toEqual "unaryop"
    expect(tree.token).toEqual [DICEFACESYMBOLS.minus]
    expect(tree.children.length).toEqual 1 #Should only have one child

    child1 = tree.children[0]
    expect(child1.type).toEqual "number"
    expect(child1.token).toEqual [DICEFACESYMBOLS.one, DICEFACESYMBOLS.two]
    expect(child1.children).toEqual []

    tree = p.parse [DICEFACESYMBOLS.minus, DICEFACESYMBOLS.one, DICEFACESYMBOLS.two, DICEFACESYMBOLS.three]   # "-12"
    expect(tree.type).toEqual "unaryop"
    expect(tree.token).toEqual [DICEFACESYMBOLS.minus]
    expect(tree.children.length).toEqual 1 #Should only have one child

    child1 = tree.children[0]
    expect(child1.type).toEqual "number"
    expect(child1.token).toEqual [DICEFACESYMBOLS.one, DICEFACESYMBOLS.two, DICEFACESYMBOLS.three]
    expect(child1.children).toEqual []

  it "should parse binary operators on single digits", ->
    p = new ExpressionParser
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

  it "should evaluate a number", ->
    p = new ExpressionParser
    tree = p.parse [DICEFACESYMBOLS.minus, DICEFACESYMBOLS.one, DICEFACESYMBOLS.two]

    e = new Evaluator
    console.log tree
    console.log e.evaluate tree
    #expect(val).toEqual(3)

  #it "should parse combinations of binary and unary operators", ->
   # console.log "Need to implement this!"
