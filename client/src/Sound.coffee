###*
 * class Sound
 * A static class that does all the sound magic.
###
class Sound

  ###*
   * Preloads all audio
  ###
  @preload: (callback) ->
    assetsPath = "img/"
    manifest = [
      src: assetsPath + "R-Damage.mp3|" + assetsPath + "R-Damage.ogg"
      id: 6
      data: 1
    ,
      src: assetsPath + "spinner.gif"
      data: 1
      id: "spinner"
    ,
      src: assetsPath + "user-blue.png"
      data: 1
      id: "user-blue"
    ,
      src: assetsPath + "user-yellow.png"
      data: 1
      id: "user-yellow"
    ]
    @preloader = new createjs.PreloadJS();
    #Install SoundJS as a plugin, then PreloadJS will initialize it automatically.
    @preloader.installPlugin(createjs.SoundJS);

    #Available PreloadJS callbacks
    @preloader.onFileLoad = (event) ->
      # Indicates that a file has loaded.
    
    @preloader.onComplete = (event) =>
      if callback? then callback()

    #Load the manifest and pass 'true' to start loading immediately. Otherwise, you can call load() manually.
    @preloader.loadManifest manifest, true

  @stop: ->
    if @preloader? then @preloader.close()
    createjs.SoundJS.stop();

  ###*
   * Plays the sound specified by src then calls callback if set.
   * @param  {String}   src      This is the *id* of the file to be played. (see manifest in preload())
   * @param  {Function} callback If given, this will be called when the sound has finished playing
   * @return {Boolean}            Will return false if playback failed.
  ###
  @play: (src, callback) ->
    #Play the sound: play (src, interrupt, delay, offset, loop, volume, pan)
    instance = createjs.SoundJS.play(src, createjs.SoundJS.INTERRUPT_NONE, 0, 0, false, 1)
    if not instance? or instance.playState is createjs.SoundJS.PLAY_FAILED then return false
    instance.onComplete = (instance) ->
      if callback? then callback()
    return true