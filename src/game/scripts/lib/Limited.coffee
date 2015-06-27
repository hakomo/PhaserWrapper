
# HP とか MP

# 現在値や最大値をテキトーに変更しても不正な値をとらない。
# 逆にソシャゲであるような行動力が最大値を超えたりはできない。

# ローグライクの力のような最小値が非 0 を抽象化する。

class Limited

    constructor: (o) ->
        o or= {}
        @_min = o.min ? 0
        @_maxMax = o.maxMax ? 999
        @setNow o.now ? o.max ? 200, true
        @max = o.max ? 200

    isMin: -> @now is @min
    isMax: -> @now >= @max

    maxFrom0: -> @max - @min

    width: (maxWidth, damage = 0, ignoreMax = false) ->
        now = Math.min Math.max(@min, @now - damage),
            if ignoreMax then @maxMax else @max
        Math.ceil maxWidth * (now - @min) / @maxFrom0()

    maximize: ->
        @setNow Math.max(@now, @max), true

    setNow: (now, ignoreMax = false) ->
        @_now = Math.min Math.max(@min, now),
            if ignoreMax then @maxMax else @max

Object.defineProperty Limited.prototype, 'now',
    get: -> @_now
    set: (now) ->
        @setNow now

Object.defineProperty Limited.prototype, 'min',
    get: -> @_min
    set: (@_min) ->
        @max = @max

Object.defineProperty Limited.prototype, 'max',
    get: -> @_max
    set: (max) ->
        exceeds = @now > @max
        @_max = Math.min Math.max(@min, max), @maxMax
        @setNow @now, exceeds

Object.defineProperty Limited.prototype, 'maxMax',
    get: -> @_maxMax
    set: (@_maxMax) ->
        @max = @max
