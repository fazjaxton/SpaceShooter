Shot = class ()
function Shot:__init(ship, target)
    self.dist = 0
    self.target = target
    self.accel = 0
    self.min_speed = 0

    self.velocity = {}

    if (target) then
        self.velocity.angle = angle_between (ship, target)
    else
        self.velocity.angle = ship.angle
    end

    self.x = ship.x + ship.rad * math.cos (self.velocity.angle)
    self.y = ship.y + ship.rad * math.sin (self.velocity.angle)

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
function CannonShot:__init (ship, target)
    CannonShot.super.__init(self, ship, target)

    self.velocity.speed = 100

    self.rad = shot_rad
    self.bounds = {}
    self.bounds.rad = shot_rad

    self.draw = function (self)
        love.graphics.setColor (0, 255, 0, 255)
        love.graphics.circle ("fill", self.x, self.y, self.rad)
    end
end

MissileShot = Shot:extends ()
function MissileShot:__init (ship, target)
    MissileShot.super.__init(self, ship, target)

    self.velocity.speed = 200
    self.accel = 300
    self.max_speed = 200

    self.rad = shot_rad
    self.bounds = {}
    self.bounds.rad = shot_rad

    self.update = function (self, dt)
        self.angle = angle_between (self, self.target)
        accelerate (self, dt)
        check_limits (self)
        update_pos (self, dt)
    end

    self.draw = function (self)
        love.graphics.setColor (255, 255, 0, 255)
        love.graphics.circle ("fill", self.x, self.y, self.rad)
    end
end

EnemyMissileShot = MissileShot:extends ()
function EnemyMissileShot:__init (ship, target)
    EnemyMissileShot.super.__init(self, ship, target)

    self.harms = {}
    self.harms[rocket] = true
end


PlayerCannonShot = CannonShot:extends ()
function PlayerCannonShot:__init (ship, target)
    PlayerCannonShot.super.__init(self, ship, target)

    self.velocity.speed = shot_speed

    self.harms = enemies
end


EnemyCannonShot = CannonShot:extends ()
function EnemyCannonShot:__init (ship, target)
    EnemyCannonShot.super.__init(self, ship, target)

    self.harms = {}
    self.harms[rocket] = true
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

        local shot = self.shoot (self.owner, self:get_target())

        shots[shot] = true
        self.fire_time = game_time
    end
end

Cannon = Weapon:extends ()
function Cannon:__init(owner)
    Cannon.super.__init(self, owner)
end

Missile = Weapon:extends ()
function Missile:__init(owner)
    Missile.super.__init(self, owner)
end

PlayerCannon = Cannon:extends ()
function PlayerCannon:__init(owner)
    PlayerCannon.super.__init(self, owner)
    self.shoot = PlayerCannonShot
    self.fire_rate = 5

    self.get_target = function (self)
        return nil
    end
end

EnemyCannon = Cannon:extends ()
function EnemyCannon:__init(owner)
    EnemyCannon.super.__init(self, owner)
    self.shoot = EnemyCannonShot
    self.fire_rate = 0.5

    self.get_target = function (self)
        return rocket
    end
end

EnemyMissile = Missile:extends ()
function EnemyMissile:__init(owner)
    EnemyMissile.super.__init(self, owner)
    self.shoot = EnemyMissileShot
    self.fire_rate = 0.25

    self.get_target = function (self)
        return rocket
    end
end
