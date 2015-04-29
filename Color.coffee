
Color =
    number: (h, s, l) ->
        c = Phaser.Color.HSLtoRGB h, s, l
        c.r << 16 | c.g << 8 | c.b

    string: (h, s, l) ->
        c = Phaser.Color.HSLtoRGB h, s, l
        Phaser.Color.RGBtoString c.r, c.g, c.b
