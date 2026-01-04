local Assets = {}
Assets.spritesheetMap = {
    "empty",
    "wall",
    "red_block",
    "green_block",
    "blue_block",
    "conveyer1",
    "conveyer2",
    "conveyer3",
    "conveyer4",
    "conveyer5",
    "conveyer6",
    "conveyer7",
    "conveyer8",
    "piston_off",
    "piston_on",
    "piston_base_off",
    "piston_base_on",
    "piston_head",
    "piston",
    "welder",
    "welder_0",
    "welder_1",
    "welder_2",
    "welder_3",
    "welder_4",
    "sensor_off",
    "sensor_on",
    "wire_0_off",
    "wire_0_on",
    "wire_1_off",
    "wire_1_on",
    "wire_2_off",
    "wire_2_on",
    "wire_3_off",
    "wire_3_on",
    "wire_4_off",
    "wire_4_on",
    "couch_left",
    "couch_middle",
    "couch_right",
}
Assets.iconMap = {
    conveyer = "conveyer1",
    wall = "wall",
    piston = "piston",
    welder = "welder",
    sensor = "sensor_on",
    wire = "wire_4_on"
}

function Assets.loadAssets()
    -- Load background animation
    Assets.backgroundImage = love.graphics.newImage("sprites/background.png")
    Assets.backgroundFrames = {}
    local frameWidth = 64
    local frameHeight = 64
    for i = 0, 3 do
        Assets.backgroundFrames[i + 1] = love.graphics.newQuad(
            i * frameWidth, 0, frameWidth, frameHeight,
            Assets.backgroundImage:getWidth(), Assets.backgroundImage:getHeight()
        )
    end
    
    Assets.spritesheet = love.graphics.newImage("sprites/spritesheet.png")
    local spriteSize = 32
    local spriteSheetWidth = Assets.spritesheet:getWidth() / spriteSize
    local spriteSheetHeight = Assets.spritesheet:getHeight() / spriteSize
    Assets.sprites = {}
    for y = 0, spriteSheetHeight - 1 do
        for x = 0, spriteSheetWidth - 1 do
            if not Assets.spritesheetMap[y * spriteSheetWidth + x + 1] then break end
            local quad = love.graphics.newQuad(x * spriteSize, y * spriteSize, spriteSize, spriteSize, Assets.spritesheet:getWidth(), Assets.spritesheet:getHeight())
            Assets.sprites[Assets.spritesheetMap[y * spriteSheetWidth + x + 1]] = quad
        end
    end
    Assets.icons = {}
    for key, value in pairs(Assets.iconMap) do
        Assets.icons[key] = Assets.sprites[value]
    end

    Assets.font = love.graphics.newFont("fonts/font.ttf", 16)
    Assets.largeFont = love.graphics.newFont("fonts/font.ttf", 32)
    Assets.hugeFont = love.graphics.newFont("fonts/font.ttf", 64)
    Assets.titleFont = love.graphics.newFont("fonts/font.ttf", 100)
end
return Assets