local Enemy = class {}
function Enemy:__init()
    self.x = win_width
    self.y = math.random () * win_height

    self.velocity = {}
    self.velocity.speed = 0
    self.velocity.angle = 0
    self.rad = enemy_rad

    self.bounds = {}
    self.bounds.rad = enemy_rad
    self.min_speed = 0
    self.drop = nil

    self.update = function (self, dt)
        update_pos (self, dt)
        wrap_edges (self)
    end
end

Drone = Enemy:extends()
function Drone:__init()
    self.super.__init(self)
    self.velocity.speed = 100
    self.velocity.angle = math.random () * math.pi * 2

    self.draw = function (self)
        love.graphics.setColor (255, 150, 150, 255)
        love.graphics.circle ("fill", self.x, self.y, self.rad)
    end
end

Seeker = Enemy:extends()
function Seeker:__init()
    self.super.__init(self)
    self.velocity.speed = 100
    self.velocity.angle = angle_between (self, rocket)

    self.update = function (self, dt)
        self.velocity.angle = angle_between (self, rocket)
        update_pos (self, dt)
        wrap_edges (self)
    end

    self.draw = function (self)
        love.graphics.setColor (150, 150, 255, 255)
        love.graphics.circle ("fill", self.x, self.y, self.rad)
    end
end

local generator = {}
generator["drone"] = Drone
generator["seeker"] = Seeker

function generate_enemy (type)
    return generator[type] ()
end
