require 'titlescreen'

GameState = class ()
GameState.__name = "GameState"
function GameState:__init(update, draw, key, mouse)
    self.update = update
    self.draw = draw
    self.keypressed = key
    self.mousepressed = mouse
end


-- Start Screen functions --
function start_next_level ()
    game_level_index = game_level_index + 1
    if (game_level_index > #game_levels) then
        current_state = "win"
    else
        level = game_levels[game_level_index] ()
        current_state = "level"
    end
end


function restart_level ()
    level = game_levels[game_level_index] ()
    current_state = "level"
end


-- Level Start functions --
local function level_start_update (game_time, dt)
    if (not level_name_display_start) then
        level_name_display_start = game_time
    elseif (game_time - level_name_display_start >= level_name_display) then
        level_name_display_start = nil
        current_state = "playing"
    end
end


local function level_start_draw ()
    print_centered (level.name)
end


-- Playing Game functions --
local function playing_key (key)
    if (key == " ") then
        for weapon in pairs (player.weapons) do
            weapon.fire ()
        end
    end
end


local function handle_inputs (dt)
    if (love.keyboard.isDown ("a") or love.keyboard.isDown ("left")) then
        player:spin (-1, dt)
    elseif (love.keyboard.isDown ("d") or love.keyboard.isDown ("right")) then
        player:spin (1, dt)
    else
        player.spin_rps = 0
    end

    if (love.keyboard.isDown ("s") or love.keyboard.isDown ("down")) then
        player:accelerate (-dt)
    elseif (love.keyboard.isDown ("w") or love.keyboard.isDown ("up")) then
        player:accelerate (dt)
    end

    if (love.keyboard.isDown (" ")) then
        playing_key (" ")
    end
end


local function playing_update (game_time, dt)
    level:update (game_time)

    handle_inputs (dt)
    update_player_pos (dt)

    update_enemies (dt)
    update_shots (dt)
    update_powerups (dt)
    update_explosions (dt)

    check_collisions ()

    if level:failed () then
        restart_level ()
    elseif level:complete () then
        start_next_level ()
    end
end


local function draw_stars ()
    for star in pairs(stars) do
        love.graphics.setColor (star.color, star.color, star.color, 255)
        love.graphics.circle ("fill", star.x, star.y, star.rad)
    end
end

local function draw_player ()
    player:draw ()
end


local function draw_enemies ()
    for enemy in pairs (enemies) do
        enemy:draw ()
    end
end


local function draw_shots ()
    for shot in pairs(shots) do
        shot:draw ()
    end
end


local function draw_powerups ()
    for powerup in pairs (powerups) do
        powerup:draw ()
    end
end


local function draw_explosions ()
    for explosion in pairs (explosions) do
        explosion:draw ()
    end
end


local function playing_draw ()
    draw_stars ()
    draw_player ()
    draw_enemies ()
    draw_shots ()
    draw_powerups ()
    draw_explosions ()
end


-- Win screen functions --
local function win_draw ()
    print_centered ("You Win!")
end


function get_game_states ()
    local states = {}

    states["start"]     = GameState (nil,
                                     start_screen_draw,
                                     start_screen_key)
    states["level"]     = GameState (level_start_update,
                                     level_start_draw,
                                     nil)
    states["playing"]   = GameState (playing_update,
                                     playing_draw,
                                     playing_key)
    states["win"]       = GameState (nil,
                                     win_draw,
                                     nil)

    return states
end
