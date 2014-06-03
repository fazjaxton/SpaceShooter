-- This file is part of SpaceShooter.
--
-- SpaceShooter is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- SpaceShooter is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with SpaceShooter.  If not, see <http://www.gnu.org/licenses/>.

Powerup = class ()
Powerup.__name = "Powerup"
function Powerup:__init()
    self.color = {255, 255, 255, 255}
    self.rad = 15
    self.bounds = {}
    self.bounds.rad = self.rad

    self.dist = 0
    self.max_dist = 1000

    self.apply = function (self, player)
        self.orig_value = player.value
        player[self.attribute] = self.value
    end

    self.destroy = function (self)
        powerups[self] = nil
        powerup_count = powerup_count - 1
    end

    self.drop_from = function (self, carrier)
        self.x = carrier.x
        self.y = carrier.y
        self.velocity = {}
        self.velocity.speed = carrier.velocity.speed
        self.velocity.angle = carrier.velocity.angle
        powerups[self] = true
        powerup_count = powerup_count + 1
    end

    self.update = function (self, dt)
        if (self.max_dist and self.dist > self.max_dist) then
            self:destroy ()
        end

        update_pos (self, dt)
        wrap_edges (self)
    end

    self.draw = function (self)
        icon_draw (self, self.icon)
    end
end

FastFirePowerup = Powerup:extends()
FastFirePowerup.__name = "FastFirePowerup"
function FastFirePowerup:__init()
    FastFirePowerup.super.__init(self)
    self.type = "persistent"

    self.icon = icons.powerups["orange"]

    self.apply = function (self, player)
        player.cannon_fire_mult = player.cannon_fire_mult * 1.5
    end
end

ExtraLifePowerup = Powerup:extends()
ExtraLifePowerup.__name = "ExtraLifePowerup"
function ExtraLifePowerup:__init()
    ExtraLifePowerup.super.__init(self)
    self.type = "instantaneous"

    self.icon = icons.powerups["green"]

    self.apply = function (self, player)
        player.lives = player.lives + 1
    end
end

ShieldPowerup = Powerup:extends()
ShieldPowerup.__name = "ShieldPowerup"
function ShieldPowerup:__init()
    ShieldPowerup.super.__init(self)
    self.type = "persistent"

    self.icon = icons.powerups["blue"]

    self.apply = function (self, player)
        player.shield_count = player.shield_count + 1
    end
end

MissilePowerup = Powerup:extends()
MissilePowerup.__name = "MissilePowerup"
function MissilePowerup:__init()
    MissilePowerup.super.__init(self)
    self.type = "persistent"

    self.icon = icons.powerups["red"]

    self.apply = function (self, player)
        local pos = 0.78
        local has_missile = false

        for w in pairs (player.weapons) do
            if w:is(Missile) then
                has_missile = true
                break
            end
        end

        -- If player doesn't have missiles already, this adds missiles.
        -- Otherwise it increases the missile fire rate.
        if has_missile then
            player.missile_fire_mult = player.missile_fire_mult * 1.5
        else
            player.weapons[PlayerMissile (player, -pos, 0)] = true
            player.weapons[PlayerMissile (player, pos, 0)] = true
        end
    end
end


local powerup_generator = {
    FastFire = FastFirePowerup,
    ExtraLife = ExtraLifePowerup,
    Shield = ShieldPowerup,
    Missile = MissilePowerup,
}

local powerup_array = {
    FastFirePowerup,
    ExtraLifePowerup,
    ShieldPowerup,
    MissilePowerup,
}


function powerup_drop_random (carrier)
    local rand = math.random ()
    local which = math.ceil (rand * #powerup_array)

    local powerup = powerup_array[which]()

    powerup:drop_from (carrier)
    powerups[powerup] = true
end


function powerup_roulette (increment)
    local rand = math.random ()
    local drop = false
    game.powerup_chance = game.powerup_chance + get_powerup_chance_increment ()

    if (rand < game.powerup_chance) then
        game.powerup_chance = 0
        drop = true
    end

    return drop
end


function generate_powerup (type)
    return powerup_generator[type] ()
end
