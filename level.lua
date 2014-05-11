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


function Level:__init()
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


Level1 = Level:extends ()
Level1.__name = "Level1"
function Level1:__init()
    Level1.super.__init(self)

    self.name = "Level 1"
    self.enemy_order = { { type = "missiledrone", powerup = "FastFire" },
                         { type = "missiledrone", powerup = "FastFire" }
                       }
    self.enemy_timing = 1
end

Level2 = Level:extends ()
Level2.__name = "Level2"
function Level2:__init()
    Level2.super.__init(self)

    self.name = "Level 2"
    self.enemy_order = { { type = "missiledrone" },
                         { type = "missiledrone" },
                         { type = "missiledrone" },
                         { type = "missiledrone" },
                         { type = "missiledrone" },
                         { type = "missiledrone" },
                         { type = "missiledrone" },
                         { type = "missiledrone" },
                         { type = "missiledrone" },
                         { type = "missiledrone" }
                       }
    self.enemy_timing = 0.25
end

game_levels = { Level1 (), Level2 ()}
