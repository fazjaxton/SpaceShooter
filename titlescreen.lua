require 'level'

local selected = 1
local menu_text = { "Start", game_levels[1].name}


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
        y = y + h * 1.5
    end
end


local function draw_controls ()
    local text
    local controls = { {"Up / W", "Forward Thrust" },
                       {"Down / S", "Reverse Thrust" },
                       {"Left / A", "Spin Left" },
                       {"Right / D", "Spin Rigth" },
                       {"Space", "Shoot" },
                     }
    local control_font = font["small"]
    local separator = " - "
    local half_sep_width = control_font:getWidth (separator) / 2
    local y = win_height / 2 + 100

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


local function change_level (dir)
    selected_level_index = selected_level_index + dir
    if selected_level_index < 1 then
        selected_level_index = 1
    elseif selected_level_index > #game_levels then
        selected_level_index = #game_levels
    end
    menu_text[2] = game_levels[selected_level_index].name
end


local function select_menu_item (idx)
    if (idx == 1) then
        game_level_index = selected_level_index
        start_level ()
    elseif (idx == 2) then
        change_level (1)
    end
end


function start_screen_draw (game_time, dt)
    draw_title ()
    draw_menu ()
    draw_controls ()
end


function start_screen_key (key)
    if (key == "down") then
        selected = selected + 1
    elseif (key == "up") then
        selected = selected - 1
    elseif (key == "left" and selected == 2) then
        change_level (-1)
    elseif (key == "right" and selected == 2) then
        change_level (1)
    elseif (key == " ") then
        select_menu_item (selected)
    end

    if (selected > #menu_text) then
        selected = 1
    elseif (selected < 1) then
        selected = #menu_text
    end
end


