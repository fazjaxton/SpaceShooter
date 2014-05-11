require 'level'

local selected = 1
local menu_text = { "Start", game_levels[1].name}


local function draw_title ()
    local h,w,x,y
    local font = font["title"]
    local text = "SpaceShooter"

    love.graphics.setFont (font)

    w = font:getWidth (text);
    h = font:getHeight (text);

    x = (win_width - w) / 2
    y = 50

    love.graphics.setColor (255, 255, 255, 255)
    love.graphics.print (text, x, y, 0)
end


local function draw_menu ()
    local font = font["option"]
    local x,y,w

    love.graphics.setFont (font)
    love.graphics.setColor (255, 255, 255, 255)

    y = 200

    for i = 1,#menu_text do
        local text = menu_text[i]

        if i == selected then
            text = "[ " .. text .. " ]"
        end

        w = font:getWidth (text);
        x = (win_width - w) / 2

        love.graphics.print (text, x, y, 0)
        y = y + 50
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
    local sep_width = control_font:getWidth (separator)
    local y = win_height / 2 + 100

    love.graphics.setFont (control_font)

    for i,control in ipairs (controls) do
        local w = control_font:getWidth (control[1])
        local x = (win_width - sep_width) / 2 - w
        local line = control[1] .. separator .. control[2]

        love.graphics.print (line, x, y, 0)
        y = y + control_font:getHeight (line)
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


