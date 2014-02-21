function get_dist (o1, o2)
    return math.sqrt ((o2.x - o1.x) ^ 2 + (o2.y - o1.y) ^ 2)
end


function collide (o1, o2)
    return (get_dist (o1, o2) < o1.rad + o2.rad)
end


function fire ()
    local shot = {}

    shot.x = rocket.x + rocket.rad * math.cos (rocket.angle)
    shot.y = rocket.y + rocket.rad * math.sin (rocket.angle)
    shot.velocity = {}
    shot.velocity.angle = rocket.angle
    shot.velocity.speed = shot_speed
    shot.rad = shot_rad

    shots[shot] = true
end

function generate_enemy ()
    local enemy = {}
    
    enemy.x = win_width;
    enemy.y = math.random () * win_height

    enemy.velocity = {}
    enemy.velocity.speed = 100
    enemy.velocity.angle = math.random () * math.pi * 2
    enemy.rad = enemy_rad

    enemies[enemy] = true;
end

function love.load ()
    win_width = love.window.getWidth ()
    win_height = love.window.getHeight ()

    rocket = {}
    rocket_rad = 25
    spin_rps = 6

    shot_speed = 1000
    shot_rad = 4

    rocket.x = win_width / 2
    rocket.y = win_height / 2
    rocket.velocity = {}
    rocket.velocity.angle = math.pi / 8
    rocket.velocity.speed = 0

    rocket.angle = rocket.velocity.angle

    rocket.accel = 500
    rocket.max_speed = 500

    enemies = {}
    enemy_rad = 15
    generate_enemy ()
    generate_enemy ()
    generate_enemy ()

    shots = {}
end


function update_pos (object, dt)
    object.x = object.x + dt * object.velocity.speed * math.cos (object.velocity.angle)
    object.y = object.y + dt * object.velocity.speed * math.sin (object.velocity.angle)
end

function update_rocket_pos (dt)
    update_pos (rocket, dt)
end

function accelerate_rocket (dt)
    local dx, dy
    local vel_x, vel_y
    local dv_x, dv_y

    vel_x = rocket.velocity.speed * math.cos (rocket.velocity.angle)
    vel_y = rocket.velocity.speed * math.sin (rocket.velocity.angle)

    dv_x = rocket.accel * dt * math.cos (rocket.angle)
    dv_y = rocket.accel * dt * math.sin (rocket.angle)

    vel_x = vel_x + dv_x
    vel_y = vel_y + dv_y

    rocket.velocity.angle = math.atan2 (vel_y, vel_x)
    rocket.velocity.speed = math.sqrt (vel_x ^ 2 + vel_y ^ 2)
end


function love.keypressed (key)
    print (key)
    if (key == " ") then
        fire ()
    end
end


function handle_inputs (dt)
    if (love.keyboard.isDown ("a") or love.keyboard.isDown ("left")) then
        rocket.angle = rocket.angle - spin_rps * dt
    elseif (love.keyboard.isDown ("d") or love.keyboard.isDown ("right")) then
        rocket.angle = rocket.angle + spin_rps * dt
    end

    if (love.keyboard.isDown ("s") or love.keyboard.isDown ("down")) then
        accelerate_rocket (-dt)
    elseif (love.keyboard.isDown ("w") or love.keyboard.isDown ("up")) then
        accelerate_rocket (dt)
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
        for enemy in pairs(enemies) do
            if (collide (shot, enemy)) then
                enemies[enemy] = nil
                shots[shot] = nil
                break
            end
        end
    end
end

function check_limits ()
    wrap_edges (rocket)

    if (rocket.velocity.speed < 0) then
        rocket.velocity.speed = 0
    elseif (rocket.velocity.speed > rocket.max_speed) then
        rocket.velocity.speed = rocket.max_speed
    end
end


function update_enemies (dt)
    for enemy in pairs(enemies) do
        update_pos (enemy, dt)
        wrap_edges (enemy)
    end
end


function update_shots (dt)
    for shot in pairs(shots) do
        update_pos (shot, dt)
        if (shot.x < 0 or shot.x > win_width or
                shot.y < 0 or shot.y > win_height) then
            shots[shot] = nil
        end
    end
end

function love.update (dt)
    handle_inputs (dt)
    update_rocket_pos (dt)
    check_limits ()

    update_enemies (dt)
    update_shots (dt)

    check_collisions ()
end


function draw_rocket ()
    local rocket_polygon = {}

    love.graphics.setColor (255, 255, 255, 255)
    rocket_polygon[1] = rocket.x + rocket.rad * math.cos (rocket.angle + 0)
    rocket_polygon[2] = rocket.y + rocket.rad * math.sin (rocket.angle + 0)

    rocket_polygon[3] = rocket.x + rocket.rad * math.cos (rocket.angle + math.pi * 5 / 6)
    rocket_polygon[4] = rocket.y + rocket.rad * math.sin (rocket.angle + math.pi * 5 / 6)

    rocket_polygon[5] = rocket.x + rocket.rad * math.cos (rocket.angle + math.pi * 7 / 6)
    rocket_polygon[6] = rocket.y + rocket.rad * math.sin (rocket.angle + math.pi * 7 / 6)

    love.graphics.polygon ("fill", rocket_polygon)
end


function draw_enemies ()
    love.graphics.setColor (255, 150, 150, 255)
    for enemy in pairs(enemies) do
        love.graphics.circle ("fill", enemy.x, enemy.y, enemy.rad)
    end
end
        

function draw_shots ()
    love.graphics.setColor (0, 255, 0, 255)
    for shot in pairs(shots) do
        love.graphics.circle ("fill", shot.x, shot.y, shot.rad)
    end
end


function love.draw ()
    draw_rocket ()
    draw_enemies ()
    draw_shots ()
end

