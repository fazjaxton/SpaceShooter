class = require '30log'

require 'player'
require 'level'
require 'weapon'
require 'enemy'
require 'powerup'
require 'gamestate'
require 'explosion'


function angle_between (o1, o2)
    local dy, dx

    dy = o2.y - o1.y
    dx = o2.x - o1.x

    return math.atan2 (dy, dx)
end


-- Reduce an angle to the range -pi to +pi
function reduce_angle (angle)
    while (angle > math.pi) do
        angle = angle - (2 * math.pi)
    end
    while (angle < -math.pi) do
        angle = angle + (2 * math.pi)
    end

    return angle
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


function get_targets (shot)
    local targets = {}

    if shot.harms["enemies"] then
        for e in pairs(enemies) do
            targets[e] = true
        end
    end

    for s in pairs(shots) do
        if shot.harms["enemymissiles"] and s:is(EnemyMissileShot) then
            targets[s] = true
        elseif shot.harms["playermissiles"] and s:is(PlayerMissileShot) then
            targets[s] = true
        end
    end

    if shot.harms["player"] then
        targets[player] = true
    end

    return targets
end

function check_collisions ()
    for shot in pairs(shots) do
        local targets = get_targets (shot)
        for target in pairs(targets) do
            if (collide (shot, target)) then
                target:hit_with (shot)
                shot:hit ()
                break
            end
        end
        if not shots[shot] then
            break;
        end

        -- A shot collecting a powerup is the same as the player collecting it
        if shot.collects["powerups"] then
            for powerup in pairs(powerups) do
                if (collide (shot, powerup)) then
                    player:hit_with (powerup)
                    powerups[powerup] = nil
                    powerup_count = powerup_count - 1
                    shot:hit ()
                end
            end
        end
    end

    if not player.dead then
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


function update_explosions (dt)
    for explosion in pairs (explosions) do
        explosion:update (dt)
    end
end


function print_centered (text, sizedesc)
    local x,y

    if (not sizedesc) then
        sizedesc = "large"
    end

    local font = font[sizedesc]

    x = win_width / 2
    y = win_height / 2

    love.graphics.setColor (255, 255, 255, 255)
    draw_text (text, x, y, font, "center", "center")
end


function icon_draw (entity, icon)
    local aspect_w = entity.rad * 2 / icon.img:getWidth ()
    local aspect_h = entity.rad * 2 / icon.img:getHeight ()
    local aspect = aspect_w

    if (aspect_h < aspect) then
        aspect = aspect_h
    end

    love.graphics.setColor (255, 255, 255, 255)
    love.graphics.draw (icon.img, entity.x, entity.y, entity.angle, aspect, aspect, icon.w / 2, icon.h / 2)
end

function icon_load (filename)
    local icon = {}

    icon.img = love.graphics.newImage (filename)
    icon.w = icon.img:getWidth ()
    icon.h = icon.img:getHeight ()

    return icon
end


function setup_game ()
    set_state ("start")

    player = Player ()
    enemies = {}
    shots = {}
    powerups = {}
    explosions = {}
end


function play_explosion_sfx ()
    -- Find an audio source that is not playing and play it.
    for sound in pairs(explosion_sfx) do
        if not sound:isPlaying () then
            sound:play ()
            break
        end
    end
end


function make_explosion (x, y, rad)
    local explosion = Explosion (x, y, rad)
    explosions[explosion] = true
    play_explosion_sfx ()
end


function draw_text (text, x, y, font, yalign, xalign)
    local w, h

    w = font:getWidth(text)
    h = font:getHeight(text)

    -- This font has a lot of dead space above the top of the text.  This
    -- places text lower than intended and throws off height calculations.
    -- These factors correct for this, using a height that is close to the
    -- actual text height.
    y = y - h * 0.3
    h = h * 0.6

    if not xalign then
        xalign = "top"
    end

    if not yalign then
        yalign = "left"
    end

    if xalign == "center" then
        x = x - w / 2
    elseif xalign == "right" then
        x = x - w
    end

    if yalign == "center" then
        y = y - h / 2
    elseif yalign == "bottom" then
        y = y - h
    end

    love.graphics.setFont (font)
    love.graphics.print (text, x, y, 0)

    return w, h
end


function love.load ()
    game = {}
    game.state = get_game_states ()

    icons = {}
    icons.player = icon_load ("Assets/player.png")
    icons.shot = icon_load ("Assets/shot.png")
    icons.player_missile = icon_load ("Assets/missile-green.png")
    icons.enemy_missile = icon_load ("Assets/missile-red.png")
    icons.powerup = icon_load ("Assets/powerup-green.png")
    icons.enemy1 = icon_load ("Assets/enemy1.png")
    icons.enemy2 = icon_load ("Assets/enemy2.png")

    icons.explosion = {}
    for i = 1,16 do
        filename = string.format ("Assets/exp%02d.png", i)
        icons.explosion[i] = icon_load (filename)
    end

    font = {}
    font["small"] = love.graphics.newFont ("Assets/ROBOTECH GP.ttf", 26);
    font["med"]   = love.graphics.newFont ("Assets/ROBOTECH GP.ttf", 32);
    font["large"] = love.graphics.newFont ("Assets/ROBOTECH GP.ttf", 45);
    font["title"] = love.graphics.newFont ("Assets/ROBOTECH GP.ttf", 80);
    font["option"] = font["large"]

    menu_music = love.audio.newSource ("Assets/Space_Idea.mp3")
    game_music = love.audio.newSource ("Assets/Space_Circuit.mp3")
    menu_music:setLooping(true)
    game_music:setLooping(true)

    -- Load multiple copies to support overlapping sounds
    explosion_sfx = {}
    for i = 1,5 do
        local sound
        sound = love.audio.newSource ("Assets/explosion.ogg", "static")
        explosion_sfx[sound] = true;
    end

    powerup_sfx = love.audio.newSource ("Assets/powerup.ogg", "static")

    win_width = love.window.getWidth ()
    win_height = love.window.getHeight ()

    game_time = 0
    fire_time = 0

    shot_range = win_height

    setup_game ()
    selected_level_index = 1

    stars = {}

    for n = 1,100 do
        local star = {}
        star.x = math.random () * win_width
        star.y = math.random () * win_height
        star.rad = math.random () * 2
        star.color = math.random () * 127 + 128

        stars[star] = true
    end
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

