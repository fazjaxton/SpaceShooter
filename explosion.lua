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

