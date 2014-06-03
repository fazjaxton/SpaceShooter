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

Level = class ()
Level.__name = "Level"

function release_enemy (self, game_time)
    if (game_time - self.last_enemy_time >= self.enemy_timing) then
        if (self.enemy_index <= #self.enemy_order) then
            local next_enemy = self.enemy_order[self.enemy_index]
            local enemy = generate_enemy (next_enemy.type)

            if (next_enemy.powerup) then
                enemy.powerup = generate_powerup (next_enemy.powerup)
            end

            enemies[enemy] = true
            enemy_count = enemy_count + 1
            self.enemy_index = self.enemy_index + 1
            self.last_enemy_time = game_time
        end
    end
end


function Level:__init(order, timing)
    self.enemy_order = order
    self.enemy_timing = timing

    self.start = function ()
        self.enemy_index = 1
        self.last_enemy_time = game_time
        enemy_count = 0
        powerup_count = 0
        explosion_count = 0

        -- Clear any existing shots
        shots = {}
        enemies = {}
        powerups = {}

        player:set_start_pos ()
    end

    self.update = release_enemy

    self.complete = function (self)
        -- All enemies have appeared and been destroyed
        return (self.enemy_index > #self.enemy_order and
                enemy_count == 0 and
                powerup_count == 0 and
                explosion_count == 0 and
                not player.dead)
    end

    self.failed = function (self)
        return (player.dead and
                explosion_count == 0)
    end
end


--Level1 = Level:extends ()
--Level1.__name = "Level1"
--function Level1:__init()
    --Level1.super.__init(self)


game_levels = {
    Level ( {
        { type = "drone", powerup = "Missile" },
        { type = "drone", powerup = "Shield" },
        { type = "drone", powerup = "Shield" },
        { type = "drone", powerup = "Shield" },
        { type = "drone", powerup = "Shield" },
        },
        3
    ),
    Level ( {
        { type = "seeker" },
        { type = "seeker" },
        { type = "seeker" },
        { type = "seeker" },
        { type = "seeker" },
        },
        3
    ),
    Level ( {
        { type = "missiledrone" },
        { type = "seeker" },
        { type = "missiledrone" },
        { type = "seeker" },
        { type = "missiledrone" },
        },
        3
    ),
    Level ( {
        { type = "missileseeker" },
        { type = "missileseeker" },
        { type = "missileseeker" },
        { type = "missileseeker" },
        { type = "missileseeker" },
        },
        3
    ),
    Level ( {
        { type = "drone" },
        { type = "drone" },
        { type = "drone" },
        { type = "drone" },
        { type = "seeker"},
        { type = "drone" },
        { type = "drone" },
        { type = "drone" },
        { type = "drone" },
        { type = "seeker", powerup = "ExtraLife" },
        },
        1
    ),
    Level ( {
        { type = "cannondrone" },
        { type = "seeker" },
        { type = "cannondrone" },
        { type = "seeker" },
        { type = "cannondrone", powerup = "FastFire" },
        },
        3
    ),
    Level ( {
        { type = "cannondrone" },
        { type = "cannondrone" },
        { type = "cannondrone" },
        { type = "cannondrone" },
        { type = "cannondrone" },
        },
        3
    ),
    Level ( {
        { type = "cannondrone" },
        { type = "cannonseeker" },
        { type = "cannondrone" },
        { type = "cannonseeker" },
        { type = "cannondrone" },
        { type = "cannonseeker" },
        },
        2
    ),
    Level ( {
        { type = "cannondrone" },
        { type = "missiledrone" },
        { type = "cannondrone" },
        { type = "missiledrone" },
        { type = "cannondrone" },
        { type = "missiledrone" },
        { type = "cannondrone" },
        { type = "missiledrone" },
        { type = "cannondrone" },
        { type = "missiledrone" },
        },
        1
    ),
}
