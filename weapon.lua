-- Pivot a weapon within its range to point at a target
local function target_weapon (weapon, target)
    local angle
    local limit = 0.78  -- Pi / 4

    angle = angle_between (weapon.owner, target)
    angle = angle - weapon.owner.angle
    angle = reduce_angle (angle)
    if (angle > limit) then
        angle = limit
    elseif (angle < -limit) then
        angle = -limit
    end

    weapon.angle = angle
end


Shot = class ()
Shot.__name = "Shot"
function Shot:__init(weapon)
    self.dist = 0
    self.accel = 0
    self.min_speed = 0

    self.velocity = {}
    self.harms = {}
    self.collects = {}

    self.angle = weapon.owner.angle
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

    self.rad = 8
    self.bounds = {}
    self.bounds.rad = self.rad

    self.draw = function (self)
        icon_draw (self, icons.shot)
    end
end

function update_target (shot)
    local best_dist
    local options
    local target

    options = get_targets (shot)

    for option in pairs(options) do
        local dist = get_dist (shot, option)
        if (not best_dist or dist < best_dist) then
            best_dist = dist
            target = option
        end
    end

    return target
end

MissileShot = Shot:extends ()
MissileShot.__name = "MissileShot"
function MissileShot:__init (weapon)
    MissileShot.super.__init(self, weapon)

    self.velocity.speed = 200
    self.accel = 600
    self.max_speed = 150
    self.guidance_dist = 50
    self.weapon = weapon

    self.rad = 12
    self.bounds = {}
    self.bounds.rad = 10

    self.destroy = function (self, dt)
        shots[self] = nil
    end

    self.hit_with = function (self, object)
        shots[self] = nil
        make_explosion (self.x, self.y, self.rad)
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
        icon_draw (self, self.icon)
    end
end

PlayerMissileShot = MissileShot:extends ()
PlayerMissileShot.__name = "PlayerMissileShot"
function PlayerMissileShot:__init (weapon)
    PlayerMissileShot.super.__init(self, weapon)

    self.harms["enemies"] = true
    self.icon = icons.player_missile

    self.max_dist = 600
end


EnemyMissileShot = MissileShot:extends ()
EnemyMissileShot.__name = "EnemyMissileShot"
function EnemyMissileShot:__init (weapon)
    EnemyMissileShot.super.__init(self, weapon)

    self.harms["player"] = true

    self.icon = icons.enemy_missile

    self.max_dist = 600
end


PlayerCannonShot = CannonShot:extends ()
PlayerCannonShot.__name = "PlayerCannonShot"
function PlayerCannonShot:__init (weapon)
    PlayerCannonShot.super.__init(self, weapon)

    self.velocity.speed = 1000

    self.harms["enemies"] = true
    self.harms["enemymissiles"] = true
    self.collects["powerups"] = true
end


EnemyCannonShot = CannonShot:extends ()
EnemyCannonShot.__name = "EnemyCannonShot"
function EnemyCannonShot:__init (weapon)
    EnemyCannonShot.super.__init(self, weapon)

    self.velocity.speed = 250

    self.harms["player"] = true
    self.harms["playermissiles"] = true
end


Weapon = class ()
Weapon.__name = "Weapon"
function Weapon:__init(owner, rate)
    self.fire_rate = rate
    self.next_fire = game_time + (1 / (rate * 2))

    -- Ship that owns the weapon
    self.owner = owner

    -- Angle which the weapon points
    self.angle = 0

    -- Max angle that weapon can pivot to
    self.angle_limit = 0

    -- Angle at which the weapon is mounted on the ship (determines initial
    -- shot position)
    self.mount_pos = 0

    self.fire = function ()
        local rate = self.fire_rate * owner.fire_multiplier

        -- Don't fire faster than max rate
        if (game_time < self.next_fire) then
            return
        end

        local shot = self.shoot (self)

        shots[shot] = true
        self.next_fire = game_time + (1 / rate)
    end
end

Cannon = Weapon:extends ()
Cannon.__name = "Cannon"
function Cannon:__init(owner, rate)
    Cannon.super.__init(self, owner, rate)
end

Missile = Weapon:extends ()
Missile.__name = "Missile"
function Missile:__init(owner, rate)
    Missile.super.__init(self, owner, rate)
end

PlayerCannon = Cannon:extends ()
PlayerCannon.__name = "PlayerCannon"
function PlayerCannon:__init(owner, pos, angle)
    PlayerCannon.super.__init(self, owner, 5)
    self.shoot = PlayerCannonShot
    self.angle = angle
    self.mount_pos = pos
end

PlayerMissile = Missile:extends ()
PlayerMissile.__name = "PlayerMissile"
function PlayerMissile:__init(owner, pos, angle)
    PlayerMissile.super.__init(self, owner, 0.75)
    self.shoot = PlayerMissileShot
    self.angle = angle
    self.mount_pos = pos
end

EnemyCannon = Cannon:extends ()
EnemyCannon.__name = "EnemyCannon"
function EnemyCannon:__init(owner)
    EnemyCannon.super.__init(self, owner, 0.5)
    self.shoot = EnemyCannonShot
    self.angle_limit = 0.78  -- Pi / 4

    self.update = function (self)
        target_weapon (self, player)
    end
end

EnemyMissile = Missile:extends ()
EnemyMissile.__name = "EnemyMissile"
function EnemyMissile:__init(owner)
    EnemyMissile.super.__init(self, owner, 0.25)
    self.shoot = EnemyMissileShot
end
