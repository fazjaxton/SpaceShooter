Level = class ()

function release_enemy (self, game_time)
    if (game_time - self.last_enemy_time >= self.enemy_timing) then
        if (self.enemy_index <= #self.enemy_order) then
            local enemy_type = self.enemy_order[self.enemy_index]
            local enemy = generate_enemy (enemy_type)

            enemies[enemy] = true
            enemy_count = enemy_count + 1
            self.enemy_index = self.enemy_index + 1
            self.last_enemy_time = game_time
        end
    end
end


function Level:__init()
    self.enemy_index = 1
    self.last_enemy_time = game_time
    enemy_count = 0

    self.update = release_enemy

    self.complete = function (self)
        -- All enemies have appeared and been destroyed
        return (self.enemy_index > #self.enemy_order and
                enemy_count == 0)
    end
end


Level1 = Level:extends ()
function Level1:__init()
    Level1.super.__init(self)

    self.name = "Level 1"
    self.enemy_order = { "drone" }
    self.enemy_timing = 1
end

Level2 = Level:extends ()
function Level2:__init()
    Level2.super.__init(self)

    self.name = "Level 2"
    self.enemy_order = { "drone", "drone", "drone", "drone", "drone", "drone", "drone", "drone", "drone" }
    self.enemy_timing = 0.25
end

game_levels = { Level1, Level2 }
