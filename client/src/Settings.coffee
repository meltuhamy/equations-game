class Settings
  @containerId: "container"

  ###*
   * Takes a previous Date and says how long ago it was
   * @param  {Date} olderDate The previous date of something that happened some time ago
   * @param  {Date} laterData The date that is taken to be now
   * @return {[type]}           [description]
  ###
  
  @getFriendlyDate: (olderDate, nowDate) ->
    # Note we are using Javascript dates (Js dates use the Unix/Posix Epoch)
    delta = laterData - olderDate
    SECOND = 1
    MINUTE = 60 * SECOND
    HOUR = 60 * MINUTE
    DAY = 24 * HOUR
    MONTH = 30 * DAY
    if (delta < 0)
      "not yet"
    else if (delta < 1 * MINUTE)
      if(ts.getSeconds() == 1) then "one second ago" else ts.getSeconds() + " seconds ago"
    else if (delta < 2 * MINUTE) 
      "a minute ago"
    else if (delta < 45 * MINUTE)
      ts.getMinutes() + " minutes ago"
    else if (delta < 90 * MINUTE)
      "an hour ago"
    else if (delta < 24 * HOUR)
      ts.getHours() + " hours ago"
    if (delta < 48 * HOUR)
      "yesterday"
    if (delta < 30 * DAY)
      ts.getDays() + " days ago";
    if (delta < 12 * MONTH)
      months = Math.Floor(ts.getDays() / 30)
      if (months <= 1) then "one month ago" else months + " months ago"
    else
      years = Math.Floor(ts.getDays() / 365)
      if (years <= 1) then "one year ago" else years + " years ago"