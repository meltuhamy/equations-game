###
Tests:

-(5+5)
---+++5
+++---5
1++2
1--2
-1--3
2*3
*3
**3
###
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
    # expr is an array of tokens
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
      if @expr[@idx] != ')' then throw new Error("Error Unbalanced Parenthesis")
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
    else
      throw new Error("UNEXPECTED TOKEN: #{c}")

    node

  isDigit : (c) -> 9 >= c >= 0 
  matchNumber:()-> this.match(this.isDigit)
  
  atEnd: () -> @idx == @expr.length

  match:(matchFn) ->
    str = ""
    str += @expr[@idx++] while !this.atEnd() and matchFn(@expr[@idx])
    str


p = new MathParser()
prettyPrint p.parse "**3"

# Export these so I can test them
exports.MathParser = MathParser
exports.Evaluator = Evaluator