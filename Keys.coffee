
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

    constructor: (@game) ->
        @Delay = 300
        @Interval = 100
        @Keys = ['up', 'down', 'left', 'right',
            ['z', 'enter'], ['x', 'esc'], ['c', 'shift']]

        for key, i in @Keys when typeof key is 'string'
            @Keys[i] = [key]

        for keys in @Keys
            for key in keys
                @[key] = @game.input.keyboard
                    .addKey Phaser.Keyboard[key.toUpperCase()]

    update: ->
        for keys in @Keys
            isDown = keys[0] + 'IsDown'
            justDown = keys[0] + 'JustDown'
            isHold = keys[0] + 'IsHold'
            timeDown = '_' + keys[0] + 'TimeDown'
            timeHold = '_' + keys[0] + 'TimeHold'

            @[isDown] = (@[key].isDown for key in keys)
                .reduce (a, b) -> a or b

            @[justDown] = (@[key].justDown for key in keys)
                .reduce (a, b) -> a or b

            @[isHold] = false

            if @[justDown]
                @[isHold] = true

                @[timeDown] = (@[key].timeDown for key in keys)
                    .reduce (a, b) -> Math.max a, b
                @[timeHold] = @[timeDown]

            else if @[isDown]
                time = if @[timeDown] is @[timeHold] then @Delay else @Interval

                if @game.time.elapsedSince(@[timeHold]) >= time
                    @[isHold] = true
                    @[timeHold] += time

        @horizontal = @rightIsDown - @leftIsDown
        @vertical = @downIsDown - @upIsDown

        @horizontalHold = @rightIsHold - @leftIsHold
        @verticalHold = @downIsHold - @upIsHold
