{DICEFACES} = require './DiceFace.js'
DICEFACESYMBOLS = DICEFACES.symbols

class Evaluator
  constructor: ->
  getFuncFromOp: (type, op) ->
    if(type == 'binop')
      switch op
        when DICEFACESYMBOLS.plus     then (lhs, rhs) => @evaluate(lhs) + @evaluate(rhs)
        when DICEFACESYMBOLS.minus    then (lhs, rhs) => @evaluate(lhs) - @evaluate(rhs)
        when DICEFACESYMBOLS.multiply then (lhs, rhs) => @evaluate(lhs) * @evaluate(rhs)
        when DICEFACESYMBOLS.divide   then (lhs, rhs) => @evaluate(lhs) / @evaluate(rhs)
    else if(type == 'unaryop')
      (rhs) => - @evaluate(rhs)
  evaluate: (node) ->
    switch node.type
      when 'number'
        return node.token
      when 'binop'
        func = @getFuncFromOp('binop', node.token)
        return func(node.children[0], node.children[1])
      when 'unaryop'
        func = @getFuncFromOp('unaryop', node.token)
        return func(node.children[0])
module.exports.Evaluator = Evaluator;

