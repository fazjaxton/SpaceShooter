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

        self.weapons = {}
        self.weapons[PlayerCannon (self, 0, 0)] = true

        self.fire_multiplier = 1
    end

    self:set_start_pos ()
    self:set_defaults ()

    self.powerups = {}

    self.rad = 25

    self.spin_rps = 0

    self.bounds = {}
    self.bounds.rad = self.rad

    self.lives = 3

    self.powerup_count = 0

    self.update = function (self, dt)
        update_pos (self, dt)
        wrap_edges (self)
        check_limits (self)
    end

    self.draw = function (self)
        if not self.dead then
            icon_draw (self, icons.player)
        end
    end

    self.add_powerup = function (self, powerup)
        self.powerups[powerup] = true
        self.powerup_count = self.powerup_count + 1
        powerup:apply (self)
        print ("Powerup added")
    end

    self.remove_powerup = function (self, powerup)
        -- Remove powerup from ship
        self.powerups[powerup] = nil
        self.powerup_count = self.powerup_count - 1

        -- Restore ship to defaults
        self:set_defaults ()

        print ("Powerup removed")

        -- Apply all remaining powerups
        for p in pairs (self.powerups) do
            p:apply (self)
        end
    end

    self.hit_with = function (self, object)
        if (object:is (Shot) or object:is (Enemy)) then
            local lost = nil
            local count = 0

            if (self.powerup_count > 0) then
                local which = math.floor (math.random () * self.powerup_count)
                for powerup in pairs(self.powerups) do
                    if (count == which) then
                        self:remove_powerup (powerup)
                        break
                    end
                    count = count + 1
                end
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


