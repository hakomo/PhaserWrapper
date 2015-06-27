
Phaser.GameObjectCreator.prototype.background = (x, y, width, height, o) ->
    o or= {}
    columns = o.columns or 1
    lines = o.lines or 1

    g = @game.make.graphics x, y
        .beginFill Color.number 0.5, 0.2, 0.4
        .drawRect 0, 0, (width - 4) * columns + 4, (height - 4) * lines + 4
        .endFill().lineStyle 2, 0xffffff
    for y in [0...lines]
        for x in [0...columns]
            g.drawRect x * (width - 4) + 2, y * (height - 4) + 2,
                width - 4, height - 4
    g

Phaser.GameObjectFactory.prototype.background = (x, y, width, height, o) ->
    (o and o.group or @world).add @game.make.background x, y, width, height, o
