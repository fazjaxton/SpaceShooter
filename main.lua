class = require '30log'

require 'player'
require 'weapon'
require 'enemy'


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


function fire ()
    -- Don't fire faster than max rate
    if (game_time < fire_time + 1 / fire_rate) then
        return
    end

    local shot = Weapon (rocket)

    shots[shot] = true
    fire_time = game_time
end


function love.load ()
    game_running = true
    draw_player = true

    win_width = love.window.getWidth ()
    win_height = love.window.getHeight ()

    rocket_rad = 25

    shot_speed = 1000
    shot_rad = 4
    enemy_rad = 15

    game_time = 0
    fire_time = 0

    which_enemy = 1
    enemy_interval = 2
    fire_rate = 5
    shot_range = win_height

    rocket = Player ()

    enemies = {}
    shots = {}
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


function love.keypressed (key)
    if (key == " ") then
        fire ()
    end
end


function handle_inputs (dt)
    if (love.keyboard.isDown ("a") or love.keyboard.isDown ("left")) then
        rocket:spin (-dt)
    elseif (love.keyboard.isDown ("d") or love.keyboard.isDown ("right")) then
        rocket:spin (dt)
    end

    if (love.keyboard.isDown ("s") or love.keyboard.isDown ("down")) then
        rocket:accelerate (-dt)
    elseif (love.keyboard.isDown ("w") or love.keyboard.isDown ("up")) then
        rocket:accelerate (dt)
    end

    if (love.keyboard.isDown (" ")) then
        fire ()
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
    for enemy in pairs(enemies) do
        for shot in pairs(shots) do
            if (collide (shot, enemy)) then
                enemies[enemy] = nil
                shots[shot] = nil
                break
            end
        end

        if (collide (rocket, enemy)) then
            game_running = false
            draw_player = false
        end
    end
end


function update_rocket_pos (dt)
    rocket:update (dt)
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


enemy_order = {"drone", "seeker"}
function love.update (dt)
    if (not game_running) then
        return
    end

    if (math.floor ((game_time + dt) / enemy_interval) > math.floor (game_time / enemy_interval)) then
        local enemy
        local enemy_type

        enemy_type = enemy_order[which_enemy];
        which_enemy = which_enemy + 1
        if (which_enemy > 2) then
            which_enemy = 1
        end

        enemy = generate_enemy (enemy_type)
        enemies[enemy] = true;
    end
    game_time = game_time + dt

    handle_inputs (dt)
    update_rocket_pos (dt)

    update_enemies (dt)
    update_shots (dt)

    check_collisions ()
end


function draw_rocket ()
    rocket:draw ()
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


function love.draw ()
    draw_rocket ()
    draw_enemies ()
    draw_shots ()
end

