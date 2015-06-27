
Phaser.RandomDataGenerator.prototype.nm = (n, m, callback, context) ->
    m = Math.min m, n
    while m
        --n
        if @between(0, n) < m
            --m
            callback.call context, n, m

Phaser.RandomDataGenerator.prototype.shuffle = (a) ->
    a = a[..]
    while a.length
        a.splice(@between(0, a.length - 1), 1)[0]
