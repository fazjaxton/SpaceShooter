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
        player.fire_multiplier = player.fire_multiplier * 1.5
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
        player.weapons[PlayerMissile (player, -pos, 0)] = true
        player.weapons[PlayerMissile (player, pos, 0)] = true
    end
end


local powerup_generator = {
    FastFire = FastFirePowerup,
    ExtraLife = ExtraLifePowerup,
    Shield = ShieldPowerup,
    Missile = MissilePowerup,
}

function generate_powerup (type)
    return powerup_generator[type] ()
end
