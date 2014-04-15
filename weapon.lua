Shot = class ()
Shot.__name = "Shot"
function Shot:__init(weapon)
    self.dist = 0
    self.accel = 0
    self.min_speed = 0

    self.velocity = {}

    self.velocity.angle = weapon.owner.angle + weapon.angle

    local pos = weapon.owner.angle + weapon.mount_pos

    self.x = weapon.owner.x + weapon.owner.rad * math.cos (pos)
    self.y = weapon.owner.y + weapon.owner.rad * math.sin (pos)

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
CannonShot.__name = "CannonShot"
function CannonShot:__init (weapon)
    CannonShot.super.__init(self, weapon)

    self.velocity.speed = 100

    self.rad = shot_rad
    self.bounds = {}
    self.bounds.rad = shot_rad

    self.draw = function (self)
        love.graphics.setColor (0, 255, 0, 255)
        love.graphics.circle ("fill", self.x, self.y, self.rad)
    end
end

function update_target (shot)
    local best_dist
    local target

    for harms in pairs(shot.harms) do
        local dist = get_dist (shot, harms)
        if (not best_dist or dist < best_dist) then
            best_dist = dist
            target = harms
        end
    end

    return target
end

MissileShot = Shot:extends ()
MissileShot.__name = "MissileShot"
function MissileShot:__init (weapon)
    MissileShot.super.__init(self, weapon)

    self.velocity.speed = 200
    self.accel = 300
    self.max_speed = 200
    self.guidance_dist = 50
    self.weapon = weapon

    self.rad = shot_rad
    self.bounds = {}
    self.bounds.rad = shot_rad

    self.destroy = function (self, dt)
        shots[self] = nil
    end

    self.update = function (self, dt)
        if (self.max_dist and self.dist > self.max_dist) then
            self:destroy ()
        elseif (self.dist > self.guidance_dist) then
            self.target = update_target (self)
            if (not self.target) then
                self:destroy ()
            else
                self.angle = angle_between (self, self.target)
                accelerate (self, dt)
            end
        end
        check_limits (self)
        update_pos (self, dt)
    end

    self.draw = function (self)
        love.graphics.setColor (255, 255, 0, 255)
        love.graphics.circle ("fill", self.x, self.y, self.rad)
    end
end

PlayerMissileShot = MissileShot:extends ()
PlayerMissileShot.__name = "PlayerMissileShot"
function PlayerMissileShot:__init (weapon)
    PlayerMissileShot.super.__init(self, weapon)

    self.harms = enemies

    self.max_dist = 600
end


EnemyMissileShot = MissileShot:extends ()
EnemyMissileShot.__name = "EnemyMissileShot"
function EnemyMissileShot:__init (weapon)
    EnemyMissileShot.super.__init(self, weapon)

    self.harms = {}
    self.harms[player] = true

    self.max_dist = 600
end


PlayerCannonShot = CannonShot:extends ()
PlayerCannonShot.__name = "PlayerCannonShot"
function PlayerCannonShot:__init (weapon)
    PlayerCannonShot.super.__init(self, weapon)

    self.velocity.speed = shot_speed

    self.harms = enemies
end


EnemyCannonShot = CannonShot:extends ()
EnemyCannonShot.__name = "EnemyCannonShot"
function EnemyCannonShot:__init (weapon)
    EnemyCannonShot.super.__init(self, weapon)

    self.harms = {}
    self.harms[player] = true
end


Weapon = class ()
Weapon.__name = "Weapon"
function Weapon:__init(owner)
    self.fire_time = game_time
    self.owner = owner
    self.angle = owner.angle
    self.mount_pos = owner.angle

    self.fire = function ()
        local rate = self.fire_rate * owner.fire_multiplier

        -- Don't fire faster than max rate
        if (game_time < self.fire_time + 1 / rate) then
            return
        end

        local shot = self.shoot (self)

        shots[shot] = true
        self.fire_time = game_time
    end
end

Cannon = Weapon:extends ()
Cannon.__name = "Cannon"
function Cannon:__init(owner)
    Cannon.super.__init(self, owner)
end

Missile = Weapon:extends ()
Missile.__name = "Missile"
function Missile:__init(owner)
    Missile.super.__init(self, owner)
end

PlayerCannon = Cannon:extends ()
PlayerCannon.__name = "PlayerCannon"
function PlayerCannon:__init(owner, pos, angle)
    PlayerCannon.super.__init(self, owner)
    self.shoot = PlayerCannonShot
    self.fire_rate = 5
    self.angle = angle
    self.mount_pos = pos
end

PlayerMissile = Missile:extends ()
PlayerMissile.__name = "PlayerMissile"
function PlayerMissile:__init(owner, pos, angle)
    PlayerMissile.super.__init(self, owner)
    self.shoot = PlayerMissileShot
    self.fire_rate = 0.75
    self.angle = angle
    self.mount_pos = pos
end

EnemyCannon = Cannon:extends ()
EnemyCannon.__name = "EnemyCannon"
function EnemyCannon:__init(owner)
    EnemyCannon.super.__init(self, owner)
    self.shoot = EnemyCannonShot
    self.fire_rate = 0.5
end

EnemyMissile = Missile:extends ()
EnemyMissile.__name = "EnemyMissile"
function EnemyMissile:__init(owner)
    EnemyMissile.super.__init(self, owner)
    self.shoot = EnemyMissileShot
    self.fire_rate = 0.25
end
