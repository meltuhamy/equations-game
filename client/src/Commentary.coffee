###*
 * class Commentary - Generate user-friendly worded logs of moves made in the game
###
class Commentary

  # {Json[]} Log Entries. Each entry is a json w/ both a short & long description
  @log: undefined

  @append: (short, long) ->
    @log.push {short: short, long: long}

  @logGoalFormed: (goalArray) ->
    goalSetterName = Game.getPlayerByName(firstTurnPlayerId)
    goalString = DiceFace.printFaces(goalArray)
    # A short description
    short = "#{goalSetterName} formed the goal: " + goalString
    # The long explanation
    long = "#{goalSetterName} formed the goal: " + goalString
    long += "Now we take it in turns to change unallocated (grey) to either: Required (orange), Optional (green), Forbidden (red)"
    long += "If you think you can solve the goal using all the Required dice then click Now"
    long += "If you don't think you can solve goal click Never"


  @logNowChallenge: (challengerId) ->
    challengerName = Game.getPlayerByName(challengerId)
    # A short description
    short = "#{challengerName} made a Now Challenge"
    # The long explanation
    long = "#{challengerName} made a Now Challenge. #{challengerName} believes that the goal"
    long += "can be reached with the current dice allocations."
    long += "Now everyone needs to choose whether the agree or disagree with #{challengerName}."
    long += "If you also think we can reach the goal right now, click Agree."
    long += "If you think it's imposssible to get the goal, click Disagree."
    long += "If you click Agree, you'll need to make an equation."


  @logNeverChallenge: (challengerId) ->
    challengerName = Game.getPlayerByName(challengerId)
    # A short description
    short = "#{challengerName} made a Never Challenge"
    # The long explanation
    long = "#{challengerName} made a Never Challenge. #{challengerName} believes that the goal"
    long += "can't be reached with the current dice allocations."
    long += "Now everyone needs to choose whether the agree or disagree with #{challengerName}."
    long += "If you also think it's imposssible to get the goal, click Agree."
    long += "If you think we can reach the goal right now, click Disagree."
    long += "If you click Disagree, you'll need to make an equation."

