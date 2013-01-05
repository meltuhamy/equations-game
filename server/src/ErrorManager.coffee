class ErrorManager

  @codes:
    parseError                  : 0
    parserTooManyDigits         : 1
    parserMultBrackWithoutTimes : 2
    parserUnbalancedBrack       : 3
    parserSqrtNeg               : 4
    parserDivByZero             : 5
    goalEmpty                   : 6
    goalTooLarge                : 7
    goalNotParse                : 8


  @throw: (errorCode, jsonParams, errorMessage) ->
    error = new Error(errorMessage)
    error.code = errorCode
    if(jsonParams?) then error.params = jsonParams
    error.msg = errorMessage
    throw error


module.exports.ErrorManager = ErrorManager