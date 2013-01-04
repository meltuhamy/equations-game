class ErrorManager

  @codes: 
	  goalEmpty   : 0
	  goalNotParse: 1

  @throw: (errorCode, jsonParams, errorMessage) ->
    error = new Error(errorMessage)
    error.code = errorCode
    if(jsonParams?) then error.params = jsonParams
    error.msg = errorMessage
    throw error


module.exports.ErrorManager = ErrorManager