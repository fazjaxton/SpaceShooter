local Enemy = class {}
Enemy.__name = "Enemy"
function Enemy:__init()
    self.x = win_width
    self.y = math.random () * win_height

    self.velocity = {}
    self.velocity.speed = 0
    self.velocity.angle = 0
    self.rad = enemy_rad

    self.angle = self.velocity.angle

    self.bounds = {}
    self.bounds.rad = enemy_rad
    self.max_speed = 100
    self.min_speed = 0
    self.drop = nil

    self.weapons = {}

    self.hit_with = function (self, shot)
        enemies[self] = nil
        enemy_count = enemy_count -1
    end

    self.update = function (self, dt)
        update_pos (self, dt)
        wrap_edges (self)
        for weapon in pairs (self.weapons) do
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

    self.draw = function (self)
        love.graphics.setColor (255, 150, 150, 255)
        love.graphics.circle ("fill", self.x, self.y, self.rad)
    end
end

Seeker = Enemy:extends()
Seeker.__name = "Seeker"
function Seeker:__init()
    Seeker.super.__init(self)
    self.velocity.speed = 100
    self.velocity.angle = angle_between (self, rocket)
    self.accel = 500

    self.update = function (self, dt)
        self.angle = angle_between (self, rocket)
        accelerate (self, dt)
        check_limits (self)
        update_pos (self, dt)
        wrap_edges (self)
    end

    self.draw = function (self)
        love.graphics.setColor (150, 150, 255, 255)
        love.graphics.circle ("fill", self.x, self.y, self.rad)
    end
end

CannonDrone = Drone:extends()
CannonDrone.__name = "CannonDrone"
function CannonDrone:__init()
    CannonDrone.super.__init(self)

    self.weapons[EnemyCannon (self)] = true
end

MissileDrone = Drone:extends()
MissileDrone.__name = "MissileDrone"
function MissileDrone:__init()
    MissileDrone.super.__init(self)

    self.weapons[EnemyMissile (self)] = true
end

local generator = {}
generator["drone"] = Drone
generator["seeker"] = Seeker
generator["cannondrone"] = CannonDrone
generator["missiledrone"] = MissileDrone

function generate_enemy (type)
    return generator[type] ()
end
