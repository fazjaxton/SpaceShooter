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


local selected = 1
local key_wait_idx = 0

local function draw_title ()
    local x,y
    local myfont = font["title"]
    local text = "SpaceShooter"

    love.graphics.setFont (myfont)

    x = win_width / 2
    y = 75

    love.graphics.setColor (255, 255, 255, 255)
    local w, h = draw_text (text, x, y, myfont, "top", "center")
    draw_text ("Settings", x, y + h, font["large"], "top", "center")
end


local function update_key_text (idx)
    local item = settings_text[idx]

    if item.key then
        item.val = get_key_name (settings.controls[item.key])
    end
end


local function update_friction_text (idx)
    local item = settings_text[idx]

    item.val = settings.space_friction
end


local function draw_settings ()
    local font = font["med"]
    local left, right, y, w, h

    love.graphics.setColor (255, 255, 255, 255)

    left = 100
    right = win_width - 100
    y = 200

    for i = 1,#settings_text do
        local ltext = settings_text[i].name
        local rtext = settings_text[i].val

        if i == selected then
            rtext = "[ " .. rtext .. " ]"
            if settings_text[i].hint then
                draw_text (settings_text[i].hint, win_width / 2,
                        win_height - 50, font, "bottom", "center")
            end
        end

        if settings_text[i].spacing then
            y = y + settings_text[i].spacing
        end

        w,h = draw_text (ltext, left, y, font, "top", "left")
        draw_text (rtext, right, y, font, "top", "right")
        y = y + h * 1.3
    end
end


local function set_control_key (idx, key)
    local control = settings_text[idx].key

    -- Assign key to control
    settings.controls[control] = key

    -- Update settings screen control list
    settings_text[idx].update (idx)
end


local function settings_key_select (idx)
    settings_text[idx].val = "..."
    key_wait_idx = idx
end


local function settings_return (idx)
    set_state ("start")
end


local function settings_friction_inc (idx)
    settings.space_friction = settings.space_friction +
                                    settings.space_friction_step
    if settings.space_friction > 1.0 then
        settings.space_friction = 1.0
    end

    settings_text[idx].update (idx)
end


local function settings_friction_dec (idx)
    settings.space_friction = settings.space_friction -
                                    settings.space_friction_step
    if settings.space_friction < 0.05 then
        settings.space_friction = 0.0
    end

    settings_text[idx].update (idx)
end


settings_text = {
    {
        name = "Forward Thrust",
        key = "up",
        select = settings_key_select,
        update = update_key_text,
        hint = "Key to accelerate your ship forwards"
    },
    {
        name = "Reverse Thrust",
        key = "down",
        select = settings_key_select,
        update = update_key_text,
        hint = "Key to accelerate your ship backwards"
    },
    {
        name = "Spin Left",
        key = "left",
        select = settings_key_select,
        update = update_key_text,
        hint = "Key to rotate your ship left (counter-clockwise)"
    },
    {
        name = "Spin Right",
        key = "right",
        select = settings_key_select,
        update = update_key_text,
        hint = "Key to rotate your ship right (clockwise)"
    },
    {
        name = "Fire",
        key = "fire",
        select = settings_key_select,
        update = update_key_text,
        hint = "Key to fire your ship's weapons"
    },
    {
        name = "Space Friction",
        spacing = 25,
        inc = settings_friction_inc,
        dec = settings_friction_dec,
        update = update_friction_text,
        hint = "Rate at which your ship naturally slows over time"
    },
    {
        name = "",
        spacing = 40,
        val = "return",
        select = settings_return,
        hint = "Return to title screen"
    },
}

function settings_activate ()
    selected = 1

    for i,setting in pairs (settings_text) do
        if setting.update then
            setting.update (i)
        end
    end
end


function settings_draw (game_time, dt)
    draw_title ()
    draw_settings ()
end


function settings_key (key)
    local action

    -- If a control key is being assigned, accept this key press as the
    -- newly assigned key
    if (key_wait_idx > 0) then
        set_control_key (key_wait_idx, key)
        key_wait_idx = 0
        return
    end

    action = get_key_action (key)

    -- Always support up, down, left, right, enter on the settings screen.
    -- Also support whatever control keys the player has bound.
    if (key == "down" or action == "down") then
        selected = selected + 1
    elseif (key == "up" or action == "up") then
        selected = selected - 1
    elseif (key == "left" or action == "left") then
        if settings_text[selected].dec then
            settings_text[selected].dec (selected)
        end
    elseif (key == "right" or action == "right") then
        if settings_text[selected].inc then
            settings_text[selected].inc (selected)
        end
    elseif (key == "return" or action == "fire") then
        if settings_text[selected].select then
            settings_text[selected].select (selected)
        end
    end

    if (selected > #settings_text) then
        selected = #settings_text
    elseif (selected < 1) then
        selected = 1
    end
end


