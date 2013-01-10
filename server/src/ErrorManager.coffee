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
    submitNotChallengeMode      : 9
    alreadyGaveOpinion          : 10
    alreadySubmittedSolution    : 11
    doesntUseOneUnallocated     : 12
    doesntUseAllRequired        : 13
    usesForbidden               : 14
    outOfBoundsDice             : 15
    duplicateDice               : 16
    possibleSubmitSolution      : 17
    goalAlreadySet              : 18
    gameFull                    : 19
    moveDuringChallenge         : 20
    moveWithoutGoal             : 21
    notYourTurn                 : 22


  @throw: (errorCode, jsonParams, errorMessage) ->
    error = new Error(errorMessage)
    error.code = errorCode
    if(jsonParams?) then error.params = jsonParams
    error.msg = errorMessage
    throw error


module.exports.ErrorManager = ErrorManager