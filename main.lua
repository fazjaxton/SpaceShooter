class = require '30log'

local Enemy = class {}
function Enemy:__init()
    self.x = win_width
    self.y = math.random () * win_height

    self.velocity = {}
    self.velocity.speed = 0
    self.velocity.angle = 0
    self.rad = enemy_rad
    self.min_speed = 0

    self.update = function (self, dt)
        update_pos (self, dt)
        wrap_edges (self)
    end
end

local Drone = Enemy:extends()
function Drone:__init()
    self.super.__init(self)
    self.velocity.speed = 100
    self.velocity.angle = math.random () * math.pi * 2

    self.draw = function (self)
        love.graphics.setColor (255, 150, 150, 255)
        for enemy in pairs(enemies) do
            love.graphics.circle ("fill", enemy.x, enemy.y, enemy.rad)
        end
    end
end

local Player = class ()
function Player:__init()
    self.x = win_width / 2
    self.y = win_height / 2

    self.velocity = {}
    self.velocity.speed = 0
    self.velocity.angle = 0
    self.angle = self.velocity.angle

    self.accel = 500
    self.min_speed = 0
    self.max_speed = 500

    self.rad = rocket_rad

    self.update = function (self, dt)
        update_pos (self, dt)
        wrap_edges (self)
        check_limits (self)
    end

    self.draw = function (self)
        local polygon = {}

        love.graphics.setColor (255, 255, 255, 255)
        polygon[1] = rocket.x + rocket.rad * math.cos (rocket.angle + 0)
        polygon[2] = rocket.y + rocket.rad * math.sin (rocket.angle + 0)

        polygon[3] = rocket.x + rocket.rad * math.cos (rocket.angle + math.pi * 5 / 6)
        polygon[4] = rocket.y + rocket.rad * math.sin (rocket.angle + math.pi * 5 / 6)

        polygon[5] = rocket.x + rocket.rad * math.cos (rocket.angle + math.pi * 7 / 6)
        polygon[6] = rocket.y + rocket.rad * math.sin (rocket.angle + math.pi * 7 / 6)

        love.graphics.polygon ("fill", polygon)
    end
end


local Weapon = class ()
function Weapon:__init(ship)
    self.x = ship.x + ship.rad * math.cos (ship.angle)
    self.y = ship.y + ship.rad * math.sin (ship.angle)
    self.velocity = {}
    self.velocity.angle = ship.angle
    self.velocity.speed = shot_speed
    self.rad = shot_rad
    self.dist = 0

    self.update = function (self, dt)
        update_pos (self, dt)
        if (self.dist > shot_range) then
            shots[self] = nil
        else
            wrap_edges (self)
        end
    end

    self.draw = function (self)
        love.graphics.setColor (0, 255, 0, 255)
        love.graphics.circle ("fill", self.x, self.y, self.rad)
    end
end


function get_dist (o1, o2)
    return math.sqrt ((o2.x - o1.x) ^ 2 + (o2.y - o1.y) ^ 2)
end


function collide (o1, o2)
    return (get_dist (o1, o2) < o1.rad + o2.rad)
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

function generate_enemy ()
    local enemy = Drone ()
    enemies[enemy] = true;
end

function love.load ()
    win_width = love.window.getWidth ()
    win_height = love.window.getHeight ()

    rocket_rad = 25
    spin_rps = 6

    shot_speed = 1000
    shot_rad = 4
    enemy_rad = 15

    game_time = 0
    fire_time = 0

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

function love.update (dt)
    if (math.floor ((game_time + dt) / enemy_interval) > math.floor (game_time / enemy_interval)) then
        generate_enemy ()
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

