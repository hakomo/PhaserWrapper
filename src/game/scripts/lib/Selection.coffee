
class Selection

    constructor: (@context, o, a) ->
        @game = @context.game

        @_index = 0
        @scroll = 0

        o or= {}
        @lineWidth = o.lineWidth or 200
        @lineHeight = o.lineHeight or 32
        @scrollbarWidth = o.scrollbarWidth or 150
        @scrollbarHeight = o.scrollbarHeight or 4
        @direction = (not o.direction) or o.direction is Selection.Right
        @length = a.length

        [@columns, @lines] = @getMatrix o
        @pages = (@length - 1) // (if @direction then @lines else @columns) + 1
        @width = @columns * @lineWidth
        @height = @lines * @lineHeight

        @container = o.background or @game.add.graphics()

        @location = @calcLocation o

        unless o.background
            @drawBackground o, Color.number(0.5, 0.2, 0.4), 0xffffff

            @scrollbar = @makeScrollbar Color.number(0.5, 0.2, 0.4), 0xffffff
            if @scrollbar
                @container.addChild @scrollbar

        caption = @makeOrGetCaption o
        if caption
            @container.addChild caption

        mask = @makeMask()
        @container.addChild mask

        @scroller = @game.add.image()
        mask.addChild @scroller

        @cursor = o.cursor or @makeCursor 0xffffff, 0.3
        if @cursor
            @scroller.addChild @cursor

        for e, i in a
            if typeof e is 'string' or e instanceof PIXI.DisplayObject
                a[i] = left: e

        @addText a
        @addDisplay a

        [@callbacks..., @default] = for callbacks in a.concat [o]
            n = {}
            for key, callback of callbacks when typeof callback is 'function'
                n[key] = callback
            n

        for callbacks in @callbacks
            callbacks.alpha = [callbacks, @default].reduce(((c, callbacks) ->
                c or ['horizontalHold', 'verticalHold'].reduce ((c, func) ->
                    c or not not callbacks[func]), false), false) | 0
        @cursor?.children[0]?.alpha = @callbacks[0].alpha

        @call 'focus'

    getMatrix: ({ columns, lines }) ->
        if columns and lines
            [columns, lines]
        else if columns
            [columns, (@length + columns - 1) // columns]
        else if lines
            [(@length + lines - 1) // lines, lines]
        else
            [1, @length]

    calcLocation: ({ x, y, left }) ->
        point = @container.position.clone()
        parent = @container.parent
        while parent
            point.add parent.x, parent.y
            parent = parent.parent

        new Phaser.Point (x ? (@game.width - @width) // 2) - point.x,
            (y ? (@game.height - @height) // 2) - point.y +
            @lineHeight / (2 - y?) * left?

    drawBackground: ({ left }, fill, line) ->
        @container.beginFill fill
            .drawRect @location.x, @location.y - 8 - @lineHeight * left?,
                @width, @height + 16 + @lineHeight * left?
            .endFill().lineStyle 2, line
            .drawRect @location.x + 2, @location.y - 6 - @lineHeight * left?,
                @width - 4, @height + 12 + @lineHeight * left?

    makeScrollbar: (fill, line) ->
        if @direction
            if @pages <= @columns
                return null

            x = @location.x + (@width - @scrollbarWidth) / 2
            y = @location.y + @height + 13

            @container.beginFill(fill).lineStyle()
                .drawRect x - 1, y - 1,
                    @scrollbarWidth + 2, @scrollbarHeight + 2

            # for i in [0...2]
            #     @makeTriangle fill, line, x + i * (@scrollbarWidth + 12) - 6,
            #         y + @scrollbarHeight / 2, i * 2 - 1, 0,
            #         @scrollbarHeight * 2, @container

            @game.make.graphics().beginFill line
                .drawRect x, y,
                    @scrollbarWidth * @columns // @pages, @scrollbarHeight

        else
            if @pages <= @lines
                return null

            x = @location.x + @width + 5
            y = @location.y + (@height - @scrollbarWidth) / 2

            @container.beginFill(fill).lineStyle()
                .drawRect x - 1, y - 1,
                    @scrollbarHeight + 2, @scrollbarWidth + 2

            # for i in [0...2]
            #     @makeTriangle fill, line, x + @scrollbarHeight / 2, y + i *
            #         (@scrollbarWidth + 12) - 6, 0, i * 2 - 1,
            #         @scrollbarHeight * 2, @container

            @game.make.graphics().beginFill line
                .drawRect x, y,
                    @scrollbarHeight, @scrollbarWidth * @lines // @pages

    # makeTriangle: (fill, line, x, y, dx, dy, l, out) ->
    #     lx = l / 2 * Math.abs dx
    #     ly = l / 2 * Math.abs dy
    #     lc = l * Math.cos Math.PI / 6
    #
    #     (out or @game.make.graphics()).beginFill(fill).lineStyle 2, line
    #         .drawPolygon x + lc * dx, y + lc * dy,
    #             x - ly, y - lx, x + ly, y + lx

    makeOrGetCaption: ({ left }) ->
        if typeof left is 'string'
            @game.make.yatext @location.x + 8,
                @location.y - @lineHeight, left, lineHeight: @lineHeight

        else if left instanceof PIXI.DisplayObject
            left.position.set @location.x + 8, @location.y - @lineHeight
            left

        else
            null

    makeMask: ->
        x = 0
        y = 0
        if @columns is 1 and (@length <= @columns * @lines or not @direction)
            x = 90
        else if @lines is 1 and (@length <= @columns * @lines or @direction)
            y = 90

        mask = @game.make.image @location.x, @location.y
        mask.mask = @game.add.graphics().beginFill()
            .drawRect -x, -y, @width + x * 2, @height + y * 2
        mask.addChild mask.mask
        mask

    makeCursor: (color, alpha) ->
        cursor = @game.make.graphics()
            .beginFill(color, alpha).lineStyle 1, color
            .drawRect 2, 0, @lineWidth - 5, @lineHeight - 1
        @game.add.tween(cursor).to alpha: 0.4,
            700, undefined, true, 0, -1, true

        # if @columns is 1 and (@length <= @columns * @lines or not @direction)
        #     t = @makeTriangle color, color, -4, @lineHeight / 2, -1, 0, 16
        #     cursor.addChild @makeTriangle color, color,
        #         @lineWidth + 4, @lineHeight / 2, 1, 0, 16, t
        #
        # else if @lines is 1 and (@length <= @columns * @lines or @direction)
        #     t = @makeTriangle color, color, @lineWidth / 2, -4, 0, -1, 16
        #     cursor.addChild @makeTriangle color, color,
        #         @lineWidth / 2, @lineHeight + 4, 0, 1, 16, t
        cursor

    addText: (a) ->
        styles = for align, i in ['left', 'center', 'right']
            align: align, anchorX: i / 2, lineHeight: @lineHeight

        for x in [0...(if @direction then @pages else @columns)]
            if @direction
                textss = a[x * @lines...(x + 1) * @lines]

            else
                ys = (y * @columns + x for y in [0...@pages])
                textss = (a[y] for y in ys when y < @length)

            for style in styles
                index = -1
                texts = for texts, i in textss
                    if typeof texts[style.align] is 'string'
                        index = i
                        texts[style.align]
                    else
                        ''

                if index >= 0
                    tx = x * @lineWidth + style.anchorX * (@lineWidth - 16) + 8
                    @scroller.addChild @game.add.yatext tx, 0,
                        texts[0..index].join('\n'), style

    addDisplay: (a) ->
        for { left }, i in a when left instanceof PIXI.DisplayObject
            @scroller.addChild left

            if @direction
                left.position.set i // @lines * @lineWidth,
                    i % @lines * @lineHeight

            else
                left.position.set i % @columns * @lineWidth,
                    i // @columns * @lineHeight

    show: ->
        @container.visible = true

    hide: ->
        @container.visible = false

    destroy: ->
        @container.destroy()

    update: (keys) ->
        if @direction
            lines = @lines
            x = keys.horizontalHold
            y = keys.verticalHold

        else
            lines = @columns
            x = keys.verticalHold
            y = keys.horizontalHold

        n = @index // lines * lines + (@index % lines + y) %%
            (@index // lines is @pages - 1 and @length % lines or lines)
        unless @index is n
            @index = n
            return

        n = Math.min @length - 1,
            (@index // lines + x) %% @pages * lines + @index % lines
        unless @index is n
            @index = n
            return

        for key of @callbacks[@index] when keys[key]
            @call key, keys[key]
            return
        for key of @default when keys[key]
            @call key, keys[key]
            return
        @call 'default', keys

    focus: ->
        @cursor?.alpha = 1
        @cursor?.children[0]?.alpha = @callbacks[@index].alpha

        if @direction
            @cursor?.position.set @index // @lines * @lineWidth,
                @index % @lines * @lineHeight
            @scroller.x = -@scroll * @lineWidth

            @scrollbar?.x = @scroll * @scrollbarWidth *
                (1 - @columns / @pages) // (@pages - @columns)

        else
            @cursor?.position.set @index % @columns * @lineWidth,
                @index // @columns * @lineHeight
            @scroller.y = -@scroll * @lineHeight

            @scrollbar?.y = @scroll * @scrollbarWidth *
                (1 - @lines / @pages) // (@pages - @lines)
        @call 'focus'

    blur: ->
        @cursor?.alpha = 0
        @call 'blur'

    call: (func, state) ->
        (@callbacks[@index][func] or @default[func])?.call @context, @, state

Object.defineProperty Selection.prototype, 'index',
    get: -> @_index
    set: (n) ->
        n = Math.min Math.max(0, n), @length - 1
        unless @_index is n
            @blur()
            @_index = n

            if @direction
                columns = @columns
                lines = @lines
            else
                columns = @lines
                lines = @columns

            if n // lines < @scroll
                @scroll = n // lines
            else if n // lines >= @scroll + columns
                @scroll = n // lines - columns + 1
            @focus()

Selection.Right = 1
Selection.Down = 2
