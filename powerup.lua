Powerup = class ()
Powerup.__name = "Powerup"
function Powerup:__init()
    self.color = {255, 255, 255, 255}
    self.rad = 5
    self.bounds = {}
    self.bounds.rad = self.rad

    self.apply = function (self, player)
        self.orig_value = player.value
        player[self.attribute] = self.value
    end

    self.update = function (self, dt)
        update_pos (self, dt)
        wrap_edges (self)
    end

    self.draw = function (self)
        love.graphics.setColor (unpack(self.color))
        love.graphics.circle ("fill", self.x, self.y, self.rad)
    end
end

FastFirePowerup = Powerup:extends()
FastFirePowerup.__name = "FastFirePowerup"
function FastFirePowerup:__init()
    FastFirePowerup.super.__init(self)

    self.apply = function (self, player)
        player.fire_multiplier = 2
    end
end

local powerup_generator = {
    FastFire = FastFirePowerup
}

function generate_powerup (type)
    return powerup_generator[type] ()
end
