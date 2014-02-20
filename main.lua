
function love.load ()
    win_width = love.window.getWidth ()
    win_height = love.window.getHeight ()

    rocket = {}
    rocket_rad = 25
    spin_rps = 6

    rocket.x = win_width / 2
    rocket.y = win_height / 2
    rocket.angle = math.pi / 8
    rocket.speed = 0
    rocket.accel = 500
    rocket.max_speed = 500
end

function love.update (dt)
    rocket.x = rocket.x + dt * rocket.speed * math.cos (rocket.angle)
    rocket.y = rocket.y + dt * rocket.speed * math.sin (rocket.angle)

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
        rocket.speed = rocket.speed - rocket.accel * dt
    elseif (love.keyboard.isDown ("w")) then
        rocket.speed = rocket.speed + rocket.accel * dt
    end

    if (rocket.speed < 0) then
        rocket.speed = 0
    elseif (rocket.speed > rocket.max_speed) then
        rocket.speed = rocket.max_speed
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

