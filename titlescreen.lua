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

require 'level'

local selected = 1
local menu_text = { "Start", "Level: 1", "Difficulty: Easy", "Quit"}


local function draw_title ()
    local x,y
    local font = font["title"]
    local text = "SpaceShooter"

    love.graphics.setFont (font)

    x = win_width / 2
    y = 75

    love.graphics.setColor (255, 255, 255, 255)
    draw_text (text, x, y, font, "top", "center")
end


local function draw_menu ()
    local font = font["option"]
    local x,y,w,h

    love.graphics.setColor (255, 255, 255, 255)

    y = 200

    for i = 1,#menu_text do
        local text = menu_text[i]

        if i == selected then
            text = "[ " .. text .. " ]"
        end

        x = win_width / 2

        w,h = draw_text (text, x, y, font, "top", "center")
        y = y + h * 1.3
    end
end


local function draw_controls ()
    local controls = { {"Up / W", "Forward Thrust" },
                       {"Down / S", "Reverse Thrust" },
                       {"Left / A", "Spin Left" },
                       {"Right / D", "Spin Right" },
                       {"Space", "Shoot" },
                     }
    local control_font = font["small"]
    local separator = " - "
    local half_sep_width = control_font:getWidth (separator) / 2
    local y = win_height / 2 + 120

    for i,control in ipairs (controls) do
        local x = win_width / 2
        local w,h
        local line = control[1] .. separator .. control[2]

        -- Center each line at the separator, with controls aligned
        -- on the left and actions aligned on the right.
        draw_text (control[1], x - half_sep_width, y,
                   control_font, "top", "right")
        draw_text (separator,  x, y,
                   control_font, "top", "center")
        w, h = draw_text (control[2], x + half_sep_width, y,
                   control_font, "top", "left")
        y = y + h * 1.2
    end
end


local function draw_version ()
    local version_font = font["small"]
    local x, y
    local border = 10
    local version = "Version " .. game.version

    x = win_width - border
    y = win_height - border

    draw_text (version, x, y, version_font, "bottom", "right")
end



function set_level (level)
    selected_level_index = level
    if selected_level_index < 1 then
        selected_level_index = 1
    elseif selected_level_index > #game_levels then
        selected_level_index = #game_levels
    end
    menu_text[2] = "Level: " .. selected_level_index
end


local function change_level (dir)
    local next_idx

    next_idx = selected_level_index + dir
    set_level (next_idx)
end


local function select_menu_item (idx)
    if (idx == 1) then
        game_level_index = selected_level_index
        setup_game ()
        start_level ()
    elseif (idx == 4) then
        os.exit ()
    end
end


local function increase_difficulty (inc)
    game.difficulty_idx = game.difficulty_idx + inc

    if (game.difficulty_idx > #game.difficulties) then
        game.difficulty_idx = #game.difficulties
    elseif (game.difficulty_idx < 1) then
        game.difficulty_idx = 1
    end

    menu_text[3] = "Difficulty: " .. game.difficulties[game.difficulty_idx].name
end


local function inc_menu_item (idx)
    if (idx == 2) then
        change_level (1)
    elseif (idx == 3) then
        increase_difficulty (1)
    end
end


local function dec_menu_item (idx)
    if (idx == 2) then
        change_level (-1)
    elseif (idx == 3) then
        increase_difficulty (-1)
    end
end


function start_screen_draw (game_time, dt)
    draw_title ()
    draw_menu ()
    draw_controls ()
    draw_version ()
end


function start_screen_key (key)
    if (key == "down") then
        selected = selected + 1
    elseif (key == "up") then
        selected = selected - 1
    elseif (key == "left") then
        dec_menu_item (selected)
    elseif (key == "right") then
        inc_menu_item (selected)
    elseif (key == " ") then
        select_menu_item (selected)
    end

    if (selected > #menu_text) then
        selected = #menu_text
    elseif (selected < 1) then
        selected = 1
    end
end


