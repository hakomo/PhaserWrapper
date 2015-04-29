
class Limited

    constructor: ->
        @_max = 100
        @_maxMax = 999
        @_min = 0
        @_now = 100

    isMin: -> @now is @min
    isMax: -> @now is @max

    maximize: -> @now = @max

    nowFrom0: -> @now - @min
    maxFrom0: -> @max - @min

    proportion: -> @nowFrom0() / @maxFrom0()

Object.defineProperty Limited.prototype, 'now',
    get: -> @_now
    set: (value) ->
        @_now = Math.min Math.max(@min, value), @max

Object.defineProperty Limited.prototype, 'min',
    get: -> @_min
    set: (@_min) ->
        @max = @max

Object.defineProperty Limited.prototype, 'max',
    get: -> @_max
    set: (value) ->
        @_max = Math.min Math.max(@min, value), @maxMax
        @now = @now

Object.defineProperty Limited.prototype, 'maxMax',
    get: -> @_maxMax
    set: (@_maxMax) ->
        @max = @max
