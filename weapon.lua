Shot = class ()
function Shot:__init()
    self.dist = 0

    self.update = function (self, dt)
        update_pos (self, dt)
        if (self.dist > shot_range) then
            shots[self] = nil
        else
            wrap_edges (self)
        end
    end

    self.hit = function (self)
        shots[self] = nil
    end
end


CannonShot = Shot:extends ()
function CannonShot:__init (ship)
    CannonShot.super.__init(self)

    self.x = ship.x + ship.rad * math.cos (ship.angle)
    self.y = ship.y + ship.rad * math.sin (ship.angle)
    self.velocity = {}
    self.velocity.angle = ship.angle
    self.velocity.speed = shot_speed
    self.rad = shot_rad
    self.bounds = {}
    self.bounds.rad = shot_rad

    self.draw = function (self)
        love.graphics.setColor (0, 255, 0, 255)
        love.graphics.circle ("fill", self.x, self.y, self.rad)
    end
end

PlayerCannonShot = CannonShot:extends ()
function PlayerCannonShot:__init (ship)
    PlayerCannonShot.super.__init(self, ship)

    self.harms = enemies
end


Weapon = class ()
function Weapon:__init(owner)
    self.fire_time = game_time
    self.owner = owner

    self.fire = function ()
        -- Don't fire faster than max rate
        if (game_time < self.fire_time + 1 / self.fire_rate) then
            return
        end

        local shot = self.shoot (self.owner)

        shots[shot] = true
        self.fire_time = game_time
    end
end

Cannon = Weapon:extends ()
function Cannon:__init(owner)
    Cannon.super.__init(self, owner)
end

PlayerCannon = Cannon:extends ()
function PlayerCannon:__init(owner)
    PlayerCannon.super.__init(self, owner)
    self.shoot = PlayerCannonShot
    self.fire_rate = 5
end
