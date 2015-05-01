
class Selection

    constructor: (@context, o, a) ->
        @game = @context.game

        @position = new Phaser.Point

        o or= {}
        @lineWidth = o.lineWidth or 200
        @lineHeight = o.lineHeight or 32
        @scrollbarWidth = o.scrollbarWidth or 150
        @scrollbarHeight = o.scrollbarHeight or 8
        @direction = (not o.direction) or o.direction is Selection.Right
        @length = a.length

        [@columns, @lines] = @getMatrix o
        @pages = (@length - 1) // (if @direction then @lines else @columns) + 1
        @width = @columns * @lineWidth
        @height = @lines * @lineHeight

        if o.background instanceof PIXI.DisplayObjectContainer
            @container = o.background
        else
            @container = @game.add.graphics()

        @location = @calcLocation o

        if o.background is Selection.Light or not o.background
            @drawBackground Color.number(0.5, 0.2, 0.5),
                Color.number 0.5, 0.5, 0.2

            @scrollbar = @makeScrollbar Color.number(0.5, 0.2, 0.5),
                Color.number 0.5, 0.5, 0.2

        else if o.background is Selection.Dark
            @drawBackground Color.number(0, 0, 0.2), Color.number 0, 0, 0.6

            @scrollbar = @makeScrollbar Color.number(0, 0, 0.2),
                Color.number 0, 0, 0.6

        else
            @scrollbar = null

        if @scrollbar
            @container.addChild @scrollbar

        mask = @makeMask()
        @container.addChild mask

        @scroll = @game.add.image()
        mask.addChild @scroll

        @cursor = @makeOrGetCursor o
        if @cursor
            @scroll.addChild @cursor

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
        @focus()

    getMatrix: (o) ->
        if o.columns and o.lines
            [o.columns, o.lines]
        else if o.columns
            [o.columns, (@length + o.columns - 1) // o.columns]
        else if o.lines
            [(@length + o.lines - 1) // o.lines, o.lines]
        else
            [1, @length]

    calcLocation: (o) ->
        point = @container.position.clone()
        parent = @container.parent
        while parent
            point.add parent.x, parent.y
            parent = parent.parent

        new Phaser.Point (o.x ? (@game.width - @width) // 2) - point.x,
            (o.y ? (@game.height - @height) // 2) - point.y

    drawBackground: (fill, line) ->
        @container.beginFill(fill).lineStyle 2, line
            .drawRect @location.x + 1, @location.y - 7,
                @width - 2, @height + 14

    makeScrollbar: (fill, line) ->
        if @direction
            if @pages <= @columns
                return null

            x = @location.x + (@width - @scrollbarWidth) / 2
            y = @location.y + @height + 14

            @container.beginFill(line).lineStyle()
                .drawRect x - 2, y - 2,
                    @scrollbarWidth + 4, @scrollbarHeight + 4

            for i in [0...2]
                @makeTriangle fill, line, x + i * (@scrollbarWidth + 12) - 6,
                    y + @scrollbarHeight / 2, i * 2 - 1, 0, 16, @container

            @game.make.graphics().beginFill fill
                .drawRect x, y,
                    @scrollbarWidth * @columns // @pages, @scrollbarHeight

        else
            if @pages <= @lines
                return null

            x = @location.x + @width + 6
            y = @location.y + (@height - @scrollbarWidth) / 2

            @container.beginFill(line).lineStyle()
                .drawRect x - 2, y - 2,
                    @scrollbarHeight + 4, @scrollbarWidth + 4

            for i in [0...2]
                @makeTriangle fill, line, x + @scrollbarHeight / 2, y + i *
                    (@scrollbarWidth + 12) - 6, 0, i * 2 - 1, 16, @container

            @game.make.graphics().beginFill fill
                .drawRect x, y,
                    @scrollbarHeight, @scrollbarWidth * @lines // @pages

    makeTriangle: (fill, line, x, y, dx, dy, l, out) ->
        lx = l / 2 * Math.abs dx
        ly = l / 2 * Math.abs dy
        lc = l * Math.cos Math.PI / 6

        (out or @game.make.graphics()).beginFill(fill).lineStyle 2, line
            .drawPolygon x + lc * dx, y + lc * dy,
                x - ly, y - lx, x + ly, y + lx,

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

    makeOrGetCursor: (o) ->
        if o.cursor is Selection.Dark or not o.cursor
            @makeCursor 0, 0.5
        else if o.cursor is Selection.Light
            @makeCursor 0xffffff, 0.3
        else if o.cursor is Selection.None
            null
        else
            o.cursor

    makeCursor: (color, alpha) ->
        cursor = @game.make.graphics()
            .beginFill(color, alpha).lineStyle 2, color
            .drawRect 1, 1, @lineWidth - 2, @lineHeight - 2
        @game.add.tween(cursor).to alpha: 0.4,
            700, undefined, true, 0, -1, true

        if @columns is 1 and (@length <= @columns * @lines or not @direction)
            t = @makeTriangle color, color, -4, @lineHeight / 2, -1, 0, 16
            cursor.addChild @makeTriangle color, color,
                @lineWidth + 4, @lineHeight / 2, 1, 0, 16, t

        else if @lines is 1 and (@length <= @columns * @lines or @direction)
            t = @makeTriangle color, color, @lineWidth / 2, -4, 0, -1, 16
            cursor.addChild @makeTriangle color, color,
                @lineWidth / 2, @lineHeight + 4, 0, 1, 16, t
        cursor

    addText: (a) ->
        styles = for align, i in ['left', 'center', 'right']
            align: align, anchorX: i / 2, lineHeight: @lineHeight

        for x in [0...(if @direction then @pages else @columns)]
            if @direction
                textss = a[x * @lines...(x + 1) * @lines]

            else
                ys = for y in [0...@pages]
                    y * @columns + x
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
                    @scroll.addChild @game.add.yatext tx, 0,
                        texts[0..index].join('\n'), style

    addDisplay: (a) ->
        for displays, i in a when displays.left instanceof PIXI.DisplayObject
            @scroll.addChild displays.left

            if @direction
                displays.left.position.set i // @lines * @lineWidth,
                    i % @lines * @lineHeight

            else
                displays.left.position.set i % @columns * @lineWidth,
                    i // @columns * @lineHeight

    update: (keys) ->
        if @direction
            columns = @columns
            lines = @lines
            x = keys.horizontalHold
            y = keys.verticalHold

        else
            columns = @lines
            lines = @columns
            x = keys.verticalHold
            y = keys.horizontalHold

        n = @position.x // lines * lines + (@position.x + y) %% (@position.x //
            lines is @pages - 1 and @length % lines or lines)
        unless @position.x is n
            @blur()
            @position.x = n
            @focus()
            return

        n = Math.min @length - 1, (@position.x // lines + x) %%
            @pages * lines + @position.x % lines
        unless @position.x is n
            @blur()
            @position.x = n

            if n // lines < @position.y
                @position.y = n // lines
            else if n // lines >= @position.y + columns
                @position.y = n // lines - columns + 1
            @focus()
            return

        for callbacks in [@callbacks[@position.x], @default]
            for key of callbacks when keys[key]
                @call key, keys[key]
                return
        @call 'default', keys

    focus: ->
        @cursor?.visible = true
        @cursor?.children[0]?.alpha =
            [@callbacks[@position.x], @default].reduce(((c, callbacks) ->
                c or ['horizontalHold', 'verticalHold'].reduce ((c, func) ->
                    c or not not callbacks[func]), false), false) | 0

        if @direction
            @cursor?.position.set @position.x // @lines * @lineWidth,
                @position.x % @lines * @lineHeight
            @scroll.x = -@position.y * @lineWidth

            @scrollbar?.x = @position.y * @scrollbarWidth *
                (1 - @columns / @pages) // (@pages - @columns)

        else
            @cursor?.position.set @position.x % @columns * @lineWidth,
                @position.x // @columns * @lineHeight
            @scroll.y = -@position.y * @lineHeight

            @scrollbar?.y = @position.y * @scrollbarWidth *
                (1 - @lines / @pages) // (@pages - @lines)
        @call 'focus'

    blur: ->
        @cursor?.visible = false
        @call 'blur'

    call: (func, state) ->
        (@callbacks[@position.x][func] or
            @default[func])?.call @context, @, @position.x, state

Selection.Right = 1
Selection.Down = 2

Selection.None = 1
Selection.Light = 2
Selection.Dark = 3
