class Node
  type: undefined     # 'number'/'binop'/'unaryop'
  token: undefined    # The token
  children: []        # An array of Nodes
  constructor: (@type, @token, @children)->


flatten = (node) ->
  str = ""
  if node.children then str += "["
  str+= " "
  str += node.text
  if node.children
    str+=" "
    str += flatten(child) for child in node.children
  str+= " "
  if node.children then str +="]"
  str

prettyPrint = (node) -> console.log flatten(node)

class Evaluator
  constructor: ->
    @binOps = {
      '+': (lhs, rhs) => @evaluate(lhs) + @evaluate(rhs)
      '-': (lhs, rhs) => @evaluate(lhs) - @evaluate(rhs)
      '*': (lhs, rhs) => @evaluate(lhs) * @evaluate(rhs)
      '/': (lhs, rhs) => @evaluate(lhs) / @evaluate(rhs)
    }

    @unaryOps = {
      '+': (rhs) => @evaluate(rhs)
      '-': (rhs) => - @evaluate(rhs)
    }
  evaluate:(node) ->
    switch node.type
      when 'number'
        parseFloat node.text
      when 'binop'
        @binOps[node.text](node.children[0], node.children[1])
      when 'unaryop'
        @unaryOps[node.text](node.children[0])

class MathParser
  constructor: ()->

  parse:(expr) ->
    @expr = expr
    @idx =0
    this.handleAddMinus()

  handleAddMinus: () ->
    child1 = @handleMultiplyDivide()
    node = child1
    c = @expr[@idx]
    while c == '+' or c == '-'
      ++@idx
      child2 = @handleMultiplyDivide()
      node = {
        type : "binop"
        text : c
        children: [ child1, child2 ]
      }
      c = @expr[@idx]
      child1 = node
    node
  
  handleMultiplyDivide: () ->
    child1 = @handleUnaryOps()
    node = child1
    c = @expr[@idx]
    while c == '*' or c == '/'
      ++@idx
      child2 = @handleUnaryOps()
      node = {
        type : "binop"
        text : c
        children: [ child1, child2 ]
      }
      c = @expr[@idx]
      child1 = node
    node
  handleUnaryOps: () ->
    c = @expr[@idx]
    node = {}
    if c =='-' or c =='+'
      ++@idx
      node = {
        type: "unaryop"
        text: c
        children: [@handleUnaryOps()]
      }
    else
      node = @handleParen()
    node
  handleParen: () ->
    c = @expr[@idx]
    node = {}
    if c == '('
      ++@idx
      node = @handleAddMinus()
      if @expr[@idx] != ')' then throw "Error Unbalanced Parenthesis"
      ++@idx # move past the '('
    else
      node = @atom()
    node
  # Handle atomimic bits, numbers and variables
  atom:() ->
    c = @expr[@idx]
    node = {}
    if this.isDigit(c)
      node.type = "number"
      node.text= this.matchNumber()
    else if this.isIdent(c)
      node.type = "ident"
      node.text = this.matchIdent()

    node

  isDigit : (c) -> !!(c.match(/^\d/))
  matchNumber:()-> this.match(this.isDigit)

  isIdent : (c) -> !!(c.match(/^[a-zA-z]/))
  matchIdent:() -> this.match(this.isIdent)
  
  atEnd: () -> @idx == @expr.length

  match:(matchFn) ->
    str = ""
    str += @expr[@idx++] while !this.atEnd() and matchFn(@expr[@idx])
    str


p = new MathParser()
prettyPrint p.parse("(1+(2*6)-6/3*(5+5*9/2))/2+3")

# Export these so I can test them
exports.MathParser = MathParser
exports.Evaluator = Evaluator