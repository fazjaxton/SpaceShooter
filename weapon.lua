Weapon = class ()
function Weapon:__init(ship)
    self.x = ship.x + ship.rad * math.cos (ship.angle)
    self.y = ship.y + ship.rad * math.sin (ship.angle)
    self.velocity = {}
    self.velocity.angle = ship.angle
    self.velocity.speed = shot_speed
    self.rad = shot_rad
    self.bounds = {}
    self.bounds.rad = shot_rad
    self.dist = 0

    self.harms = enemies

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

    self.draw = function (self)
        love.graphics.setColor (0, 255, 0, 255)
        love.graphics.circle ("fill", self.x, self.y, self.rad)
    end
end
