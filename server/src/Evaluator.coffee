{DiceFace} = require './DiceFace.js'
DICEFACESYMBOLS = DiceFace.symbols

class Evaluator
  constructor: ->
  getFuncFromOp: (type, op) ->
    if(type == 'binop') # handles binary operations
      switch op[0]
        when DICEFACESYMBOLS.plus     then return (lhs, rhs) => @evaluate(lhs) + @evaluate(rhs)
        when DICEFACESYMBOLS.minus    then return (lhs, rhs) => @evaluate(lhs) - @evaluate(rhs)
        when DICEFACESYMBOLS.multiply then return (lhs, rhs) => @evaluate(lhs) * @evaluate(rhs)
        when DICEFACESYMBOLS.divide   then return (lhs, rhs) => @evaluate(lhs) / @evaluate(rhs)  
        when DICEFACESYMBOLS.power    then return (lhs, rhs) => Math.pow(@evaluate(lhs), @evaluate(rhs))
    else if(type == 'unaryop') # handles unary operations
      switch op[0]
        when DICEFACESYMBOLS.sqrt     then return (rhs) => Math.sqrt(@evaluate(rhs))
        when DICEFACESYMBOLS.minus    then return (rhs) => - @evaluate(rhs)
        when DICEFACESYMBOLS.plus     then return (rhs) => @evaluate(rhs)
  evaluate: (node) ->
    switch node.type
      when 'number' # handles number nodes, also known as atoms or leaves.
        num = 0
        for i in [0...node.token.length]
          num = num*10
          num += node.token[i]
        return num
      when 'binop' # handles binary operator nodes
        func = @getFuncFromOp('binop', node.token)
        return func(node.children[0], node.children[1])
      when 'unaryop' # handles unary operator nodes
        func = @getFuncFromOp('unaryop', node.token)
        return func(node.children[0])
module.exports.Evaluator = Evaluator;

