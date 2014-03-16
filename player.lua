Player = class ()
function Player:__init()
    self.x = win_width / 2
    self.y = win_height / 2

    self.velocity = {}
    self.velocity.speed = 0
    self.velocity.angle = 0
    self.angle = self.velocity.angle

    self.accel = 500
    self.min_speed = 0
    self.max_speed = 500

    self.rad = rocket_rad

    self.spin_rps = 0
    self.spin_max = 6
    -- Radians per second per second
    self.spin_accel = 25

    self.bounds = {}
    self.bounds.rad = rocket_rad * 0.6

    self.weapons = {}
    self.weapons[PlayerCannon (self)] = true

    self.update = function (self, dt)
        if (not draw_player) then
            return
        end
        update_pos (self, dt)
        wrap_edges (self)
        check_limits (self)
    end

    self.draw = function (self)
        local polygon = {}

        love.graphics.setColor (255, 255, 255, 255)
        polygon[1] = rocket.x + rocket.rad * math.cos (rocket.angle + 0)
        polygon[2] = rocket.y + rocket.rad * math.sin (rocket.angle + 0)

        polygon[3] = rocket.x + rocket.rad * math.cos (rocket.angle + math.pi * 5 / 6)
        polygon[4] = rocket.y + rocket.rad * math.sin (rocket.angle + math.pi * 5 / 6)

        polygon[5] = rocket.x + rocket.rad * math.cos (rocket.angle + math.pi * 7 / 6)
        polygon[6] = rocket.y + rocket.rad * math.sin (rocket.angle + math.pi * 7 / 6)

        love.graphics.polygon ("fill", polygon)
        love.graphics.circle ("line", rocket.x, rocket.y, rocket.bounds.rad)
    end

    self.hit_with = function (self, shot)
    end

    self.accelerate = accelerate

    self.spin = function (self, dir, dt)
        self.spin_rps = self.spin_rps + self.spin_accel * dt
        if (self.spin_rps > self.spin_max) then
            self.spin_rps = self.spin_max
        end
        self.angle = self.angle + self.spin_rps * dir * dt
    end
end


