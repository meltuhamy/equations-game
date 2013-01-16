{DiceFace} = require '../DiceFace.js'
DICEFACESYMBOLS = DiceFace.symbols
{Evaluator} = require '../Evaluator.js'

{ExpressionParser, Node} = require '../Parser.js'

describe "evaluator", ->
  it "should evaluate a unary negative expression", ->
    p = new ExpressionParser
    tree = p.parse([DICEFACESYMBOLS.minus, DICEFACESYMBOLS.three], true)
    e = new Evaluator
    val = e.evaluate(tree)
    expect(val).toEqual(-3)

  it "should evaluate a unary sqrt expression", ->
    p = new ExpressionParser
    tree = p.parse([DICEFACESYMBOLS.sqrt, DICEFACESYMBOLS.three], true)
    e = new Evaluator
    val = e.evaluate(tree)
    expect(val).toEqual(Math.sqrt(3))

  it "should evaluate binary operator plus", ->
    p = new ExpressionParser
    tree = p.parse([DICEFACESYMBOLS.one, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.two], true)
    e = new Evaluator
    val = e.evaluate(tree)
    expect(val).toEqual(3)

  it "should evaluate a fractional expression", ->
    p = new ExpressionParser
    tree = p.parse([DICEFACESYMBOLS.one,DICEFACESYMBOLS.divide, DICEFACESYMBOLS.three], true)
    e = new Evaluator
    val = e.evaluate(tree)
    expect(val).toEqual(1.0/3)

  it "should evaluate binary operator minus", ->
    p = new ExpressionParser
    tree = p.parse([DICEFACESYMBOLS.one, DICEFACESYMBOLS.minus, DICEFACESYMBOLS.two], true)
    e = new Evaluator
    val = e.evaluate(tree)
    expect(val).toEqual(-1)

  it "should evaluate binary operator times", ->
    p = new ExpressionParser
    tree = p.parse([DICEFACESYMBOLS.three, DICEFACESYMBOLS.multiply, DICEFACESYMBOLS.eight], true)
    e = new Evaluator
    val = e.evaluate(tree)
    expect(val).toEqual(24)

  it "should evaluate binary operator power", ->
    p = new ExpressionParser
    tree = p.parse([DICEFACESYMBOLS.three, DICEFACESYMBOLS.power, DICEFACESYMBOLS.three], true)
    e = new Evaluator
    val = e.evaluate(tree)
    expect(val).toEqual(27)

  it "should evaluate complex expressions", ->
    p = new ExpressionParser
    tree = p.parse([DICEFACESYMBOLS.one, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.two, DICEFACESYMBOLS.minus, DICEFACESYMBOLS.three], true)
    e = new Evaluator
    val = e.evaluate(tree)
    expect(val).toEqual(0)

  it "should evaluate complex expressions", ->
    p = new ExpressionParser
    tree = p.parse([DICEFACESYMBOLS.one, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.two, DICEFACESYMBOLS.multiply, DICEFACESYMBOLS.three], true)
    e = new Evaluator
    val = e.evaluate(tree)
    expect(val).toEqual(7)

  it "should evaluate complex expressions", ->
    p = new ExpressionParser
    tree = p.parse([DICEFACESYMBOLS.bracketL, DICEFACESYMBOLS.one, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.two,DICEFACESYMBOLS.bracketR, DICEFACESYMBOLS.multiply, DICEFACESYMBOLS.three], true)
    e = new Evaluator
    val = e.evaluate(tree)
    expect(val).toEqual(9)

  it "should evaluate complex expressions", ->
    p = new ExpressionParser
    tree = p.parse([DICEFACESYMBOLS.one, DICEFACESYMBOLS.multiply, DICEFACESYMBOLS.two, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.three], true)
    e = new Evaluator
    val = e.evaluate(tree)
    expect(val).toEqual(5)

  it "should evaluate complex expressions", ->
    p = new ExpressionParser
    tree = p.parse([DICEFACESYMBOLS.bracketL, DICEFACESYMBOLS.one, DICEFACESYMBOLS.plus, DICEFACESYMBOLS.two,DICEFACESYMBOLS.bracketR, DICEFACESYMBOLS.power, DICEFACESYMBOLS.two, DICEFACESYMBOLS.divide, DICEFACESYMBOLS.four], true)
    e = new Evaluator
    val = e.evaluate(tree)
    expect(val).toEqual(2.25)