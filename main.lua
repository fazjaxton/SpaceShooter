class = require '30log'

require 'player'
require 'level'
require 'weapon'
require 'enemy'
require 'powerup'
require 'gamestate'


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


function love.load ()
    game = {}
    game.state = get_game_states ()

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


function love.draw ()
    game.state[current_state].draw ()
end

