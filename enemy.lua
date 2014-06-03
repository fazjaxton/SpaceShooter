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

Enemy = class {}
Enemy.__name = "Enemy"
function Enemy:__init()
    local edge = math.random () * 4

    if (edge < 2) then          -- left or right
        self.y = math.random () * win_height
        if (edge < 1) then      -- left
            self.x = 0
        else                    -- right
            self.x = win_width
        end
    else                        -- top or bottom
        self.x = math.random () * win_width
        if (edge < 3) then      -- top
            self.y = 0
        else                    -- bottom
            self.y = win_height
        end
    end

    self.velocity = {}
    self.velocity.speed = 0
    self.velocity.angle = 0
    self.rad = 15

    self.angle = self.velocity.angle

    self.bounds = {}
    self.bounds.rad = self.rad
    self.max_speed = 100
    self.min_speed = 0
    self.drop = nil

    self.weapons = {}

    self.cannon_fire_mult = 1
    self.missile_fire_mult = 1

    self.destroyed = function (self)
        make_explosion (self.x, self.y, self.rad)

        enemies[self] = nil
        enemy_count = enemy_count -1

        if powerup_roulette (game.powerup_chance_inc) then
            powerup_drop_random (self)
        end
    end

    self.hit_with = function (self, object)
        if (object:is (Player) or object:is (Shot)) then
            self:destroyed ()
        end
    end

    self.update = function (self, dt)
        update_pos (self, dt)
        wrap_edges (self)
        for weapon in pairs (self.weapons) do
            if (weapon.update) then
                weapon:update ()
            end
            weapon.fire ()
        end
    end
end

Drone = Enemy:extends()
Drone.__name = "Drone"
function Drone:__init()
    Drone.super.__init(self)
    self.velocity.speed = 100
    self.velocity.angle = math.random () * math.pi * 2
    self.angle = self.velocity.angle

    self.icon = icons.drone["green"]

    self.draw = function (self)
        icon_draw (self, self.icon)
    end
end

Seeker = Enemy:extends()
Seeker.__name = "Seeker"
function Seeker:__init()
    Seeker.super.__init(self)
    self.velocity.speed = 100
    self.velocity.angle = angle_between (self, player)
    self.accel = 500

    self.icon = icons.seeker["green"]

    self.update = function (self, dt)
        self.angle = angle_between (self, player)
        accelerate (self, dt)
        check_limits (self)
        update_pos (self, dt)
        wrap_edges (self)
        for weapon in pairs (self.weapons) do
            weapon.fire ()
        end
    end

    self.draw = function (self)
        icon_draw (self, self.icon)
    end
end

CannonDrone = Drone:extends()
CannonDrone.__name = "CannonDrone"
function CannonDrone:__init()
    CannonDrone.super.__init(self)

    self.icon = icons.drone["orange"]
    self.weapons[EnemyCannon (self)] = true
end

MissileDrone = Drone:extends()
MissileDrone.__name = "MissileDrone"
function MissileDrone:__init()
    MissileDrone.super.__init(self)

    self.icon = icons.drone["red"]
    self.weapons[EnemyMissile (self)] = true
end

CannonSeeker = Seeker:extends()
CannonSeeker.__name = "CannonSeeker"
function CannonSeeker:__init()
    CannonSeeker.super.__init(self)

    self.icon = icons.seeker["orange"]
    self.weapons[EnemyCannon (self)] = true
end

MissileSeeker = Seeker:extends()
MissileSeeker.__name = "MissileSeeker"
function MissileSeeker:__init()
    MissileSeeker.super.__init(self)

    self.icon = icons.seeker["red"]
    self.weapons[EnemyMissile (self)] = true
end


local enemy_generator = {}
enemy_generator["drone"] = Drone
enemy_generator["seeker"] = Seeker
enemy_generator["cannondrone"] = CannonDrone
enemy_generator["missiledrone"] = MissileDrone
enemy_generator["cannonseeker"] = CannonSeeker
enemy_generator["missileseeker"] = MissileSeeker

function generate_enemy (type)
    return enemy_generator[type] ()
end
