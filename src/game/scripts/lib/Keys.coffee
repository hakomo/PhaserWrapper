
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
        @RepeatDelay = 300
        @RepeatInterval = 100

        @DirectionDelay = 100

        @Neutral = 0
        @NeutralToFour = 1
        @Four = 2
        @Diagonal = 3
        @DiagonalToFour = 4

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

        @direction = new Phaser.Point
        @directionHold = new Phaser.Point
        @state = @Neutral
        @prev = new Phaser.Point
        @time = 0
        @_p = new Phaser.Point

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
                    time = @RepeatDelay
                else
                    time = @RepeatInterval

                if @game.time.elapsedSince(@[timeHold]) >= time
                    @[isHold] = true
                    @[timeHold] += time

        @horizontal = @rightIsDown - @leftIsDown
        @vertical = @downIsDown - @upIsDown

        @horizontalHold = @rightIsHold - @leftIsHold
        @verticalHold = @downIsHold - @upIsHold

        @_p.set @horizontal, @vertical
        @setDirection @_p
        @updateState @_p

    setDirection: (p) ->
        isZero = @direction.isZero()
        @direction.set 0, 0
        @directionHold.set 0, 0

        if p.x and p.y
            @direction.copyFrom p

        else if @state is @NeutralToFour and
                (p.isZero() or p.equals(@prev) and
                @game.time.elapsedSince(@time) >= @DirectionDelay)
            @direction.copyFrom @prev

        else if @state is @Four and (p.x or p.y) and p.equals @prev
            @direction.copyFrom p

        else if @state is @DiagonalToFour and
                (p.x or p.y) and p.equals(@prev) and
                @game.time.elapsedSince(@time) >= @DirectionDelay
            @direction.copyFrom p

        if isZero and not @direction.isZero()
            @directionHold.copyFrom @direction

            @_directionTimeDown = @game.time.time #
            @_directionTimeHold = @_directionTimeDown

        else if not @direction.isZero()
            if @_directionTimeDown is @_directionTimeHold
                time = @RepeatDelay
            else
                time = @RepeatInterval

            if @game.time.elapsedSince(@_directionTimeHold) >= time
                @directionHold.copyFrom @direction
                @_directionTimeHold += time

    updateState: (p) ->
        if p.x and p.y
            @state = @Diagonal
            @prev.set 0, 0

        else if p.isZero()
            @state = @Neutral
            @prev.set 0, 0

        else if @state in [@Neutral, @Diagonal]
            ++@state
            @prev.copyFrom p
            @time = @latestMovedTime()

        else if p.equals @prev
            if @game.time.elapsedSince(@time) >= @DirectionDelay
                @state = @Four

        else
            @state = @NeutralToFour
            @prev.copyFrom p
            @time = @latestMovedTime()

    latestMovedTime: ->
        Math.max @up.timeUp, @up.timeDown, @down.timeUp, @down.timeDown,
            @left.timeUp, @left.timeDown, @right.timeUp, @right.timeDown
