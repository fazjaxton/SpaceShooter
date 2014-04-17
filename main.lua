class = require '30log'

require 'player'
require 'level'
require 'weapon'
require 'enemy'
require 'powerup'


function angle_between (o1, o2)
    local dy, dx

    dy = o2.y - o1.y
    dx = o2.x - o1.x

    return math.atan2 (dy, dx)
end


function get_dist (o1, o2)
    return math.sqrt ((o2.x - o1.x) ^ 2 + (o2.y - o1.y) ^ 2)
end


function collide (o1, o2)
    return (get_dist (o1, o2) < o1.bounds.rad + o2.bounds.rad)
end


function check_limits (object)
    if (object.velocity.speed < object.min_speed) then
        object.velocity.speed = object.min_speed
    elseif (object.velocity.speed > object.max_speed) then
        object.velocity.speed = object.max_speed
    end
end


function update_pos (object, dt)
    local dist

    dist = dt * object.velocity.speed

    object.x = object.x + dist * math.cos (object.velocity.angle)
    object.y = object.y + dist * math.sin (object.velocity.angle)

    if (object.dist) then
        object.dist = object.dist + dist
    end
end


function accelerate (self, dt)
    local dx, dy
    local vel_x, vel_y
    local dv_x, dv_y

    vel_x = self.velocity.speed * math.cos (self.velocity.angle)
    vel_y = self.velocity.speed * math.sin (self.velocity.angle)

    dv_x = self.accel * dt * math.cos (self.angle)
    dv_y = self.accel * dt * math.sin (self.angle)

    vel_x = vel_x + dv_x
    vel_y = vel_y + dv_y

    self.velocity.angle = math.atan2 (vel_y, vel_x)
    self.velocity.speed = math.sqrt (vel_x ^ 2 + vel_y ^ 2)
end


GameState = class ()
GameState.__name = "GameState"
function GameState:__init(update, draw, key, mouse)
    self.update = update
    self.draw = draw
    self.keypressed = key
    self.mousepressed = mouse
end

function start_screen_key (key)
    start_next_level ()
end

function playing_key (key)
    if (key == " ") then
        for weapon in pairs (player.weapons) do
            weapon.fire ()
        end
    end
end

function love.keypressed (key)
    if (key == "?") then
    end

    if (game.state[current_state].keypressed) then
        game.state[current_state].keypressed (key)
    end
end

function love.mousepressed (x, y, button)
    if (game.state[current_state].mousepressed) then
        game.state[current_state].mousepressed (x, y. button)
    end
end

function handle_inputs (dt)
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


function wrap_edges (object)
    if (object.x < 0) then
        object.x = object.x + win_width
    elseif (object.x > win_width) then
        object.x = object.x - win_width
    end

    if (object.y < 0) then
        object.y = object.y + win_height
    elseif (object.y > win_height) then
        object.y = object.y - win_height
    end
end


function check_collisions ()
    for shot in pairs(shots) do
        for target in pairs(shot.harms) do
            if (collide (shot, target)) then
                target:hit_with (shot)
                shot:hit ()
            end
        end
    end

    for powerup in pairs(powerups) do
        if (collide (player, powerup)) then
            player:hit_with (powerup)
            powerups[powerup] = nil
            powerup_count = powerup_count - 1
        end
    end

    for enemy in pairs(enemies) do
        if (collide (player, enemy)) then
            player:hit_with (enemy)
            enemy:hit_with (player)
        end
    end
end


function update_player_pos (dt)
    player:update (dt)
end


function update_enemies (dt)
    for enemy in pairs(enemies) do
        enemy:update (dt)
    end
end


function update_shots (dt)
    for shot in pairs(shots) do
        shot:update (dt)
    end
end


function update_powerups (dt)
    for powerup in pairs (powerups) do
        powerup:update (dt)
    end
end


function print_centered (text, sizedesc)
    local h,w,x,y

    if (not sizedesc) then
        sizedesc = "large"
    end

    local font = font[sizedesc]
    love.graphics.setFont (font)

    w = font:getWidth (text);
    h = font:getHeight (text);

    x = (win_width - w) / 2
    y = (win_height - h) / 2

    love.graphics.setColor (255, 255, 255, 255)
    love.graphics.print (text, x, y, 0)
end


function start_screen_draw (game_time, dt)
    print_centered ("Press a key to Start")
end


function level_start_draw ()
    print_centered (level.name)
end


function level_start_update (game_time, dt)
    if (not level_name_display_start) then
        level_name_display_start = game_time
    elseif (game_time - level_name_display_start >= level_name_display) then
        level_name_display_start = nil
        current_state = "playing"
    end
end


function start_next_level ()
    game_level_index = game_level_index + 1
    if (game_level_index > #game_levels) then
        current_state = "win"
    else
        level = game_levels[game_level_index] ()
        current_state = "level"
    end
end

function playing_update (game_time, dt)
    level:update (game_time)

    handle_inputs (dt)
    update_player_pos (dt)

    update_enemies (dt)
    update_shots (dt)
    update_powerups (dt)

    check_collisions ()

    if (level:complete ()) then
        start_next_level ()
    end
end


function win_draw ()
    print_centered ("You Win!")
end


function love.load ()
    game = {}
    game.state = {}

    game.state["start"] = GameState (nil, start_screen_draw, start_screen_key)
    game.state["level"] = GameState (level_start_update, level_start_draw)
    game.state["playing"] = GameState (playing_update, playing_draw, playing_key)
    game.state["win"] = GameState (nil, win_draw)

    font = {}
    font["small"] = love.graphics.newFont ("DejaVuSans.ttf", 20);
    font["med"]   = love.graphics.newFont ("DejaVuSans.ttf", 32);
    font["large"] = love.graphics.newFont ("DejaVuSans.ttf", 45);

    level_name_display = 3
    current_state = "start"

    win_width = love.window.getWidth ()
    win_height = love.window.getHeight ()

    game_time = 0
    fire_time = 0

    which_enemy = 1
    shot_range = win_height

    player = Player ()

    -- Index incremented to 1 in start_next_level
    game_level_index = 0

    enemies = {}
    shots = {}
    powerups = {}
end


function love.update (dt)
    game_time = game_time + dt

    if (game.state[current_state].update) then
        game.state[current_state].update (game_time, dt)
    end
end


function draw_player ()
    player:draw ()
end


function draw_enemies ()
    for enemy in pairs (enemies) do
        enemy:draw ()
    end
end


function draw_shots ()
    for shot in pairs(shots) do
        shot:draw ()
    end
end


function draw_powerups ()
    for powerup in pairs (powerups) do
        powerup:draw ()
    end
end


function playing_draw ()
    draw_player ()
    draw_enemies ()
    draw_shots ()
    draw_powerups ()
end

function love.draw ()
    game.state[current_state].draw ()
end

