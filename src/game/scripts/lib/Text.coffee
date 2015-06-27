
Phaser.GameObjectCreator.prototype.yatext = (x, y, text, style) ->
    text = text?.toString()

    style or= {}
    style.fill or= 'white'
    style.font or= '18px Gennokaku'

    if style.edge
        style.stroke = 'black'
        style.strokeThickness = 4

    else
        style.shadowColor = 'black'
        style.shadowOffsetX = 1
        style.shadowOffsetY = 1

    anchorX = style.anchorX or 0
    anchorY = style.anchorY or 0
    lineHeight = style.lineHeight or 32

    style.align = ['left', 'center', 'right'][anchorX * 2]

    sprite = @game.make.sprite x, y

    sprite.text = @game.make.text 0, 0, text, style
    sprite.text.lineSpacing = lineHeight - style.strokeThickness -
        sprite.text.determineFontProperties(style.font).fontSize
    sprite.text.y += Math.round sprite.text.lineSpacing * (0.5 - anchorY) + 3
    sprite.text.anchor.set anchorX, anchorY
    sprite.addChild sprite.text
    sprite

Phaser.GameObjectFactory.prototype.yatext = (x, y, text, style, group) ->
    (group or @world).add @game.make.yatext x, y, text, style
