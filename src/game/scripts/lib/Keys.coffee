
# Phaser.Key と Phaser.Keyboard のラッパー

# Phaser.Key は基本さわらない。さわるときは気をつける。

# 例えば Z キーを押しても Enter キーを押しても同じ動作をしたいときに
# keys.z.isDown or keys.enter.isDown
# なんて長いし書き忘れそうだしいやだ。代わりに
# keys.zIsDown
# を使う。

# Phaser.Key.justDown には副作用があり直接さわりたくない。
# keys.z.justDown
# ではなく
# keys.zJustDown
# を使う。

# メニュー画面で矢印キーを押すとカーソルが移動し、
# 押しっぱなしにするとカーソルが一定間隔で移動し続けるような機能を提供する。
# @Delay 一定間隔で移動しはじめるまでの時間
# @Interval 一定間隔の時間
# keys.upIsHold
# のように使う。

# keys.downIsDown - keys.upIsDown
# なんて長くていやだ。代わりに
# keys.horizontal
# keys.vertical
# keys.horizontalHold
# keys.verticalHold
# を使う。

class Keys

    constructor: (@game, keys = []) ->
        @Delay = 300
        @Interval = 100

        @keys = for ks in ['up', 'down', 'left', 'right'
                ['z', 'enter'], ['x', 'esc']].concat keys
            if typeof ks is 'string'
                ks = [ks]

            for key in ks
                @[key] = @game.input.keyboard
                    .addKey Phaser.Keyboard[key.toUpperCase()]

            keys: ks
            isDown: ks[0] + 'IsDown'
            justDown: ks[0] + 'JustDown'
            isHold: ks[0] + 'IsHold'
            timeDown: '_' + ks[0] + 'TimeDown'
            timeHold: '_' + ks[0] + 'TimeHold'

    update: ->
        for { keys, isDown, justDown, isHold, timeDown, timeHold } in @keys
            @[isDown] = false
            @[justDown] = false
            @[isHold] = false

            for key in keys
                @[isDown] or= @[key].isDown
                @[justDown] = @[key].justDown or @[justDown]

            if @[justDown]
                @[isHold] = true

                @[timeDown] = 0
                for key in keys
                    @[timeDown] = Math.max @[timeDown], @[key].timeDown
                @[timeHold] = @[timeDown]

            else if @[isDown]
                if @[timeDown] is @[timeHold]
                    time = @Delay
                else
                    time = @Interval

                if @game.time.elapsedSince(@[timeHold]) >= time
                    @[isHold] = true
                    @[timeHold] += time

        @horizontal = @rightIsDown - @leftIsDown
        @vertical = @downIsDown - @upIsDown

        @horizontalHold = @rightIsHold - @leftIsHold
        @verticalHold = @downIsHold - @upIsHold
