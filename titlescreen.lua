
local selected = 1
local menu_text = { "Start", "Credits" }


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


local function select_menu_item (idx)
    if (idx == 1) then
        start_next_level ()
    end
end


function start_screen_draw (game_time, dt)
    draw_title ()
    draw_menu ()
end


function start_screen_key (key)
    if (key == "down") then
        selected = selected + 1
    elseif (key == "up") then
        selected = selected - 1
    elseif (key == " ") then
        select_menu_item (selected)
    end

    if (selected > #menu_text) then
        selected = 1
    elseif (selected < 1) then
        selected = #menu_text
    end
end


