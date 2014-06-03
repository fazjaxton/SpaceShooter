Player = class ()
Player.__name = "Player"
function Player:__init()
    self.set_start_pos = function (self)
        self.x = win_width / 2
        self.y = win_height / 2

        self.velocity = {}
        self.velocity.speed = 0
        self.velocity.angle = 0
        self.angle = self.velocity.angle

        self.dead = false
    end

    self.set_defaults = function (self)
        self.accel = 500
        self.min_speed = 0
        self.max_speed = 500

        self.spin_max = 6
        -- Radians per second per second
        self.spin_accel = 25

        self.shield_count = get_starting_shield_count ()

        self.weapons = {}
        self.weapons[PlayerCannon (self, 0, 0)] = true

        self.cannon_fire_mult = 1
        self.missile_fire_mult = 1
    end

    self.reset = function (self)
        self:set_start_pos ()
        self:set_defaults ()

        self.powerups = {}
        self.powerup_count = 0
    end

    self:reset ()

    self.rad = 25

    self.spin_rps = 0

    self.bounds = {}
    self.bounds.rad = self.rad

    self.lives = 3

    self.update = function (self, dt)
        update_pos (self, dt)
        wrap_edges (self)
        check_limits (self)
    end

    self.draw = function (self)
        if not self.dead then
            love.graphics.setColor (0, 0, 255, 255)
            for i = 1,self.shield_count do
                local rad = self.rad + i
                love.graphics.circle ("line", self.x, self.y, rad)
            end
            icon_draw (self, icons.player)
        end
    end

    self.add_powerup = function (self, powerup)
        if (powerup:is(ShieldPowerup)) then
            self.shield_count = self.shield_count + 1
        else
            if powerup.type == "persistent" then
                self.powerup_count = self.powerup_count + 1
                self.powerups[self.powerup_count] = powerup
            end
            powerup:apply (self)
        end
    end

    self.hit_with = function (self, object)
        if (object:is (Shot) or object:is (Enemy)) then
            local count = 0

            if (self.shield_count > 0) then
                self.shield_count = self.shield_count - 1
            else
                make_explosion (self.x, self.y, self.rad)
                self.dead = true
            end

            if (object:is (Shot)) then
                make_explosion (object.x, object.y, object.rad)
            end
        elseif (object:is (Powerup)) then
            self:add_powerup (object)
            powerup_sfx:play ()
        end
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


