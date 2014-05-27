require 'titlescreen'

GameState = class ()
GameState.__name = "GameState"
function GameState:__init(update, draw, key, activate)
    self.update = update
    self.draw = draw
    self.keypressed = key
    self.activate = activate
end


function set_state (state)
    current_state = state
    if game.state[state].activate then
        game.state[state].activate ()
    end
end


local function return_to_title ()
    setup_game ()
end


local function set_gameover ()
    set_level (game_level_index)
    transition_start ("Game Over", 3, return_to_title)
end


local function set_win ()
    set_level (1)
    transition_start ("You Win!", 5, return_to_title)
end


local function set_playing ()
    set_state ("playing")
end


local function set_complete ()
    transition_start ("Level Complete!", 3, start_next_level)
end


-- Start Screen functions --
local function start_level_transition ()
    transition_start (level.name, 3, set_playing, draw_player_lives)
end


function start_next_level ()
    game_level_index = game_level_index + 1
    if (game_level_index > #game_levels) then
        set_win ()
    else
        level = game_levels[game_level_index]
        level.start ()
        start_level_transition ()
    end
end


function start_level ()
    level = game_levels[game_level_index]
    level.start ()
    start_level_transition ()
end


-- Level Start functions --
local function transition_update (gametime, dt)
    if (not transition_start_time) then
        transition_start_time = game_time
    else
        local time = game_time - transition_start_time
        if (time > transition_min and time > transition_time) then
            transition_end_action ()
        end
    end
end


function draw_player_lives ()
    local fake_player = {}
    local y = win_height / 2 + 75
    local x
    local life_font
    local text

    life_font = font["med"]
    love.graphics.setFont (life_font)
    text = "  x " .. player.lives
    x = (win_width - player.rad - life_font:getWidth (text)) / 2

    fake_player.x = x + player.rad / 2
    fake_player.y = y
    fake_player.rad = player.rad
    fake_player.angle = -math.pi / 2

    icon_draw (fake_player, icons.player)

    x = x + player.rad

    love.graphics.setColor (255, 255, 255, 255)
    draw_text (text, x, y, life_font, "center", "left")
end


local function transition_draw ()
    print_centered (transition_text)
    if (transition_draw_extra) then
        transition_draw_extra ()
    end
end


local function transition_key ()
    -- Set transition time to zero to cancel transition immediately
    transition_time = 0
end


function transition_start (text, time, end_action, draw)
    transition_text = text
    transition_time = time
    transition_end_action = end_action
    transition_start_time = nil
    transition_draw_extra = draw

    -- Allow at least one second for transitions so that if the player
    -- is still mashing buttons, the screen doesn't clear
    transition_min = 1

    set_state ("transition")
end


-- Playing Game functions --
local function playing_key (key)
    if (key == " ") then
        for weapon in pairs (player.weapons) do
            weapon.fire ()
        end
    elseif (key == "escape") then
        return_to_title ()
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
        player.lives = player.lives - 1
        if player.lives == 0 then
            set_gameover ()
        else
            start_level ()
        end
    elseif level:complete () then
        set_complete ()
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


local function draw_status ()
    local status_font
    local powerup_spacing = 10
    local border = 10
    local x,y,w,h
    local powerup_y

    status_font = font["med"]

    powerup_text = "Powerups: "
    lives_text = "Lives: " .. player.lives
    y = win_height - border
    x = border

    love.graphics.setColor (255, 255, 255, 255)
    w,h = draw_text (powerup_text, x, y, status_font, "bottom", "left")

    x = x + w

    for powerup in pairs(player.powerups) do
        powerup_y = y - (h + powerup.icon.h) / 2
        love.graphics.draw (powerup.icon.img, x, powerup_y, 0)
        x = x + powerup.icon.w + powerup_spacing
    end

    x = win_width / 2
    draw_text (lives_text, x, y, status_font, "bottom", "left")
end


local function playing_draw ()
    draw_stars ()
    draw_player ()
    draw_enemies ()
    draw_shots ()
    draw_powerups ()
    draw_explosions ()
    draw_status ()
end


local function start_screen_activate ()
    -- Pause all other audio
    love.audio.pause ()

    menu_music:rewind ()
    menu_music:play ()

    -- Rewind game music so it starts over each game
    game_music:rewind ()
end


local function transition_activate ()
    menu_music:pause ()
    game_music:play ()
end


function get_game_states ()
    local states = {}

    states["start"]     = GameState (nil,
                                     start_screen_draw,
                                     start_screen_key,
                                     start_screen_activate)
    states["playing"]   = GameState (playing_update,
                                     playing_draw,
                                     playing_key)
    states["transition"] = GameState(transition_update,
                                     transition_draw,
                                     transition_key,
                                     transition_activate)

    return states
end
