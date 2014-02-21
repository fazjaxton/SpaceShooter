
function love.load ()
    win_width = love.window.getWidth ()
    win_height = love.window.getHeight ()

    rocket = {}
    rocket_rad = 25
    spin_rps = 6

    rocket.x = win_width / 2
    rocket.y = win_height / 2
    rocket.velocity = {}
    rocket.velocity.angle = math.pi / 8
    rocket.velocity.speed = 0

    rocket.angle = rocket.velocity.angle

    rocket.accel = 500
    rocket.max_speed = 500
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


function love.update (dt)
    rocket.x = rocket.x + dt * rocket.velocity.speed * math.cos (rocket.velocity.angle)
    rocket.y = rocket.y + dt * rocket.velocity.speed * math.sin (rocket.velocity.angle)

    if (rocket.x < 0) then
        rocket.x = rocket.x + win_width
    elseif (rocket.x > win_width) then
        rocket.x = rocket.x - win_width
    end

    if (rocket.y < 0) then
        rocket.y = rocket.y + win_height
    elseif (rocket.y > win_height) then
        rocket.y = rocket.y - win_height
    end

    if (love.keyboard.isDown ("a")) then
        rocket.angle = rocket.angle - spin_rps * dt
    elseif (love.keyboard.isDown ("d")) then
        rocket.angle = rocket.angle + spin_rps * dt
    end

    if (love.keyboard.isDown ("s")) then
        accelerate_rocket (-dt)
    elseif (love.keyboard.isDown ("w")) then
        accelerate_rocket (dt)
    end

    if (rocket.velocity.speed < 0) then
        rocket.velocity.speed = 0
    elseif (rocket.velocity.speed > rocket.max_speed) then
        rocket.velocity.speed = rocket.max_speed
    end
end

function love.draw ()
    local rocket_polygon = {}

    rocket_polygon[1] = rocket.x + rocket_rad * math.cos (rocket.angle + 0)
    rocket_polygon[2] = rocket.y + rocket_rad * math.sin (rocket.angle + 0)

    rocket_polygon[3] = rocket.x + rocket_rad * math.cos (rocket.angle + math.pi * 5 / 6)
    rocket_polygon[4] = rocket.y + rocket_rad * math.sin (rocket.angle + math.pi * 5 / 6)

    rocket_polygon[5] = rocket.x + rocket_rad * math.cos (rocket.angle + math.pi * 7 / 6)
    rocket_polygon[6] = rocket.y + rocket_rad * math.sin (rocket.angle + math.pi * 7 / 6)

    love.graphics.polygon ("fill", rocket_polygon)
end

