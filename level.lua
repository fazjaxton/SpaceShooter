Level = class ()
function Level:__init()
    self.name = "Level 1"
    self.enemy_order = { "drone", "drone", "drone", "seeker", "seeker" }
    self.enemy_timing = 1
    self.enemy_index = 1
    self.last_enemy_time = 0

    self.update = function (self, game_time)
        if (game_time - self.last_enemy_time >= self.enemy_timing) then
            if (self.enemy_index <= #self.enemy_order) then
                local enemy_type = self.enemy_order[self.enemy_index]
                local enemy = generate_enemy (enemy_type)

                enemies[enemy] = true
                self.enemy_index = self.enemy_index + 1
                self.last_enemy_time = game_time
            end
        end
    end
end

