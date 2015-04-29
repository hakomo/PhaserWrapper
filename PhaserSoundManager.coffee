
do (p = Phaser.SoundManager.prototype) ->
    p.preload = (sounds, musics) ->
        @soundVolume = 100
        @_musicVolume = 80
        @current = null

        @sounds = {}
        for [key, urls, volume, autoDecode] in sounds
            @game.load.audio key, urls, autoDecode ? true
            @sounds[key] = volume

        for [key, urls, volume, autoDecode] in musics
            @game.load.audio key, urls, autoDecode ? true
            @sounds[key] = volume: volume

    p.create = ->
        for key, sound of @sounds when typeof sound isnt 'number'
            sound.sound = @game.sound.add key

    p.yaplay = (key, volume, repeat) ->
        if typeof @sounds[key] is 'number'
            @game.sound.play key, (volume ? @sounds[key]) *
                @soundVolume / 100, repeat ? false

        else
            @stop()

            @current = @sounds[key].sound
            @current.restart '', 0, (volume ? @sounds[key].volume) *
                @musicVolume / 100, repeat ? true

    p.stop = ->
        @current?.stop()
        @current = null

    Object.defineProperty p, 'musicVolume',
        get: -> @_musicVolume
        set: (value) ->
            if @current
                volume = @current.volume / @musicVolume
                @_musicVolume = value
                @current.volume = volume * @musicVolume

            else
                @_musicVolume = value
