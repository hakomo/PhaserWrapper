
Util =
    jump: (target, x2, y2, t = 700, g = 0.002) ->
        first = target.game.add.tween(target).to x: x2,
            t, undefined, true

        if target.body
            gravity = target.body.gravity.clone()
            velocity = target.body.velocity.clone()
            target.body.gravity.set 0, 0
            target.body.velocity.set 0, 0

            first.onComplete.addOnce ({ body }) ->
                body.gravity.copyFrom gravity
                body.velocity.copyFrom velocity

        y0 = target.y
        v0 = (y2 - y0 - t * t * g / 2) / t
        t0 = -v0 / g
        y1 = v0 * t0 + t0 * t0 * g / 2 + y0

        second = target.game.add.tween(target).to y: y1,
            t0, ((k) -> (k * t0) * (k * t0 * g / 2 + v0) / (y1 - y0)), true
        second.chain target.game.add.tween(target).to y: y2,
            (t - t0), (k) -> k * k * (t - t0) * (t - t0) * g / (y2 - y1) / 2
        first

    shake: (target, x = 6, y = 0, repeat = 6, duration = 50) ->
        timer = target.game.time.create()
        timer.loop duration, ((tx, ty) ->
            if @i
                if x
                    target.x = tx + x * @i * (@i % 2 * 2 - 1) / repeat
                else if y
                    target.y = ty + y * @i * (@i % 2 * 2 - 1) / repeat
                --@i

            else
                if x
                    target.x = tx
                else if y
                    target.y = ty
                timer.destroy()), { i: repeat }, target.x, target.y
        timer.start()
