
# Phaser.Text のラッパー

# constructor の text が 0 のときに表示されないバグを修正。

# デフォルト style を変更。

# style から @anchor を設定できる。
# game.add.yatext 0, 0, '',
#     anchorX: 0.5
#     anchorY: 0.5
# のように使う。
# @anchor は直接さわらない。

# 日本語を垂直方向の真ん中に表示できる。
# text.y = text.my y
# game.add.tween(text).to y: text.my y
# のように使う。
# @y を変更するときは @my を通す。
# constructor のときは自動で通るので通さなくてよい。

# style に lineHeight を追加。
# game.add.yatext 0, 0, '',
#     lineHeight: 32
# のように使う。
# @lineSpacing は直接さわらない。

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
