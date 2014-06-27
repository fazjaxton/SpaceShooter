-- This file is part of SpaceShooter.
--
-- SpaceShooter is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- SpaceShooter is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with SpaceShooter.  If not, see <http://www.gnu.org/licenses/>.

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


local function volume_update (delta)
    settings.volume = settings.volume + delta
    if settings.volume < 0 then
        settings.volume = 0
    elseif settings.volume > 1 then
        settings.volume = 1
    end

    if settings.muted then
        love.audio.setVolume (0)
    else
        love.audio.setVolume (settings.volume)
    end
end


local function volume_down ()
    settings.muted = false
    volume_update (-settings.volume_step)
end


local function volume_up ()
    settings.muted = false
    volume_update (settings.volume_step)
end


local function volume_toggle_mute ()
    settings.muted = not settings.muted
    volume_update (0)
end


local function handle_global_keys (key)
    if key == "-" or key == "_" then
        volume_down ()
    elseif key == "+" or key == "=" then
        volume_up ()
    elseif key == "m" then
        volume_toggle_mute ()
    end
end


function love.keypressed (key)
    if handle_global_keys (key) then
        return
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
                if not target:is(Player) or not player.dead then
                    target:hit_with (shot)
                    shot:hit ()
                    break
                end
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


function get_powerup_chance_increment ()
    return game.difficulties[game.difficulty_idx].pci
end


function get_starting_shield_count ()
    return game.difficulties[game.difficulty_idx].shields
end


function love.load ()
    math.randomseed (os.time())

    game = {}
    game.state = get_game_states ()
    game.powerup_chance = 0

    game.version = "1.00"

    game.difficulty_idx = 1
    game.difficulties = {
        { name = "Easy",   pci = 0.05, shields = 2 },
        { name = "Normal", pci = 0.01, shields = 1 },
        { name = "Hard",   pci = 0.00, shields = 0 }
    }

    settings = {}
    settings.volume = 0.5
    settings.volume_step = 0.1
    settings.muted = false

    settings.space_friction = 0.0

    -- Set the initial volume
    volume_update (0)

    icons = {}
    icons.player = icon_load ("Assets/player.png")
    icons.shot = icon_load ("Assets/shot.png")
    icons.player_missile = icon_load ("Assets/missile-green.png")
    icons.enemy_missile = icon_load ("Assets/missile-red.png")

    icons.seeker = {}
    icons.seeker["purple"] = icon_load ("Assets/seeker-purple.png")
    icons.seeker["blue"]   = icon_load ("Assets/seeker-blue.png")
    icons.seeker["green"]  = icon_load ("Assets/seeker-green.png")
    icons.seeker["yellow"] = icon_load ("Assets/seeker-yellow.png")
    icons.seeker["orange"] = icon_load ("Assets/seeker-orange.png")
    icons.seeker["red"]    = icon_load ("Assets/seeker-red.png")

    icons.drone = {}
    icons.drone["purple"] = icon_load ("Assets/drone-purple.png")
    icons.drone["blue"]   = icon_load ("Assets/drone-blue.png")
    icons.drone["green"]  = icon_load ("Assets/drone-green.png")
    icons.drone["yellow"] = icon_load ("Assets/drone-yellow.png")
    icons.drone["orange"] = icon_load ("Assets/drone-orange.png")
    icons.drone["red"]    = icon_load ("Assets/drone-red.png")

    icons.powerups = {}
    icons.powerups["red"]    = icon_load ("Assets/powerup-red.png")
    icons.powerups["blue"]   = icon_load ("Assets/powerup-blue.png")
    icons.powerups["yellow"] = icon_load ("Assets/powerup-yellow.png")
    icons.powerups["green"]  = icon_load ("Assets/powerup-green.png")
    icons.powerups["purple"] = icon_load ("Assets/powerup-purple.png")
    icons.powerups["orange"] = icon_load ("Assets/powerup-orange.png")

    icons.explosion = {}
    for i = 1,16 do
        filename = string.format ("Assets/exp%02d.png", i)
        icons.explosion[i] = icon_load (filename)
    end

    font = {}
    font["small"] = love.graphics.newFont ("Assets/ROBOTECH_GP.ttf", 26);
    font["med"]   = love.graphics.newFont ("Assets/ROBOTECH_GP.ttf", 32);
    font["large"] = love.graphics.newFont ("Assets/ROBOTECH_GP.ttf", 45);
    font["title"] = love.graphics.newFont ("Assets/ROBOTECH_GP.ttf", 80);
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

    set_state ("start")
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

