
# Phaser.SoundManager の拡張

# 音量をまとめて調節したい。だが @volume では
# 効果音とミュージックのそれぞれをまとめて調節できない。かわりに
# @soundVolume
# @musicVolume
# を使う。

# ある音は固定の音量で再生することが多い。
# 音量の記述を個々の再生箇所にばらけさせたくない。
# sounds = [
#     [key, urls, volume, autoDecode]
#     [key, urls, volume, autoDecode]]
# musics = [
#     [key, urls, volume, autoDecode]
#     [key, urls, volume, autoDecode]]
# game.sound.preload sounds, musics
# 以上を State.preload メソッド内で呼ぶ。
# game.sound.yaplay key, volume, repeat
# を volume を省略して呼ぶと preload 時に指定した volume で再生される。

# ミュージックは同時に 2 つ以上再生しない。
# そのためメモリの確保を抑えたい。
# game.sound.create()
# を State.create メソッド内で呼ぶ。

# ミュージック再生時に現在再生されているミュージックを止めたい。
# game.sound.yaplay key, volume, repeat
# を使う。

# また、ミュージックを止めたい。
# game.sound.stop()
# を使う。

do (p = Phaser.SoundManager.prototype) ->
    p.preload = (sounds, musics) ->
        @soundVolume = 100
        @_musicVolume = 80
        @current = null

        @sounds = {}
        for [key, urls, volume, autoDecode] in sounds
            @game.load.audio key, urls, autoDecode ? true
            @sounds[key] = volume ? 1

        for [key, urls, volume, autoDecode] in musics
            @game.load.audio key, urls, autoDecode ? true
            @sounds[key] = volume: volume ? 1

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
