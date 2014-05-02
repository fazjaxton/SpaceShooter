Explosion = class ()
Explosion.__name = "Explosion"
function Explosion:__init (x, y, rad)
    self.x = x
    self.y = y
    self.time = 0
    self.frame = 0
    self.length = 0.5
    self.total_frames = 16
    self.frame_time = self.length / self.total_frames
    self.angle = 0
    self.rad = rad * 1.5

    explosion_count = explosion_count + 1

    self.update = function (self, dt)
        self.time = self.time + dt
        self.frame = math.floor (self.time / self.frame_time)

        if self.frame >= self.total_frames then
            explosions[self] = nil
            explosion_count = explosion_count - 1
        end
    end

    self.draw = function (self)
        icon_draw (self, icons.explosion[self.frame + 1])
    end
end

