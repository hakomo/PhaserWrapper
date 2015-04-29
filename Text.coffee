
class Text extends Phaser.Text

    constructor: (game, x, y, text, style) ->
        super game, x, y, text?.toString(), style
        @updateAnchor()
        @y = @my y

    setStyle: (style) ->
        style or= {}
        style.fill or= 'white'
        style.font or= '18px Gennokaku'

        style.lineHeight or= 32

        super style
        @updateAnchor()

    my: (y) ->
        Math.round y + 3 + (@style.lineHeight - @determineFontProperties(
            @style.font).fontSize - @style.strokeThickness) * (0.5 - @anchor.y)

    updateText: ->
        @lineSpacing = @style.lineHeight - @determineFontProperties(
            @style.font).fontSize - @style.strokeThickness
        super

    updateAnchor: ->
        @anchor?.set @style.anchorX or 0, @style.anchorY or 0

Text.Center = align: 'center', anchorX: 0.5
Text.Right = align: 'right', anchorX: 1

Phaser.GameObjectFactory.prototype.yatext = (x, y, text, style, group) ->
    (group ? @world).add new Text @game, x, y, text, style

Phaser.GameObjectCreator.prototype.yatext = (x, y, text, style) ->
    new Text @game, x, y, text, style
