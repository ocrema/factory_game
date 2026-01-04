local Grid = {}

function Grid.createGrid(level, xOffset, yOffset, xBounds, yBounds)
    local grid = {}
    local subList = {}
    local maxWidth = 0
    table.insert(grid, subList)
    for char in string.gmatch(level.layout, ".") do
        if char == "\n" then
            if #subList > maxWidth then
                maxWidth = #subList
            end
            subList = {}
            table.insert(grid, subList)
        else
            table.insert(subList, Utils.deepCopy(level[char]))
            subList[#subList].x = #subList
            subList[#subList].y = #grid
        end
    end
    for i = 1, #grid do
        while #grid[i] < maxWidth do
            table.insert(grid[i], Utils.deepCopy(level[" "]))
            grid[i][#grid[i]].x = #grid[i]
            grid[i][#grid[i]].y = i
        end
    end
    grid.width = #grid[1]
    grid.height = #grid
    grid.isSimulation = false
    grid.xOffset = xOffset
    grid.yOffset = yOffset
    grid.xBounds = xBounds
    grid.yBounds = yBounds
    grid.xInnerOffset = 0
    grid.yInnerOffset = 0
    grid.spriteScale = 1
    local boundsAspectRatio = grid.xBounds / grid.yBounds
    local gridAspectRatio = grid.width / grid.height
    if boundsAspectRatio > gridAspectRatio then
        grid.spriteScale = grid.yBounds / grid.height
        grid.xInnerOffset = (grid.xBounds - grid.width * grid.spriteScale) / 2
        grid.yInnerOffset = 0
    else
        grid.spriteScale = grid.xBounds / grid.width
        grid.yInnerOffset = (grid.yBounds - grid.height * grid.spriteScale) / 2
        grid.xInnerOffset = 0
    end
    return grid
end

function Grid.update(grid)
    
end

function Grid.draw(grid)
    love.graphics.setColor(1, 1, 1)
    --love.graphics.rectangle("line", grid.xOffset, grid.yOffset, grid.xBounds, grid.yBounds)

    --draw tiles of grid
    for y = 1, #grid do
        for x = 1, #grid[y] do
            local x2, y2 = (x - 1) * grid.spriteScale + grid.xInnerOffset + grid.xOffset,
                (y - 1) * grid.spriteScale + grid.yInnerOffset + grid.yOffset
            if not (grid[y][x].tile == "void") then
                Utils.drawTile("empty", x2, y2, 0, grid.spriteScale)
            end
            if grid[y][x].tile == "conveyer" or grid[y][x].tile == "input" then
                local function stencilFunction()
                    love.graphics.rectangle("fill", 0, 0, grid.spriteScale, grid.spriteScale)
                end

                love.graphics.push()
                love.graphics.translate(x2 + grid.spriteScale / 2, y2 + grid.spriteScale / 2)
                love.graphics.rotate((math.pi / 2) * grid[y][x].rotation)
                love.graphics.translate(-grid.spriteScale / 2, -grid.spriteScale / 2)

                -- Set up stencil
                love.graphics.stencil(stencilFunction, "replace", 1)
                love.graphics.setStencilTest("greater", 0)

                local conveyerOffset = (grid.progressToNextTick or 0) * grid.spriteScale
                love.graphics.translate(conveyerOffset - grid.spriteScale, 0)
                Utils.drawTile("conveyer1", 0, 0, 0, grid.spriteScale)
                Utils.drawTile("conveyer1", grid.spriteScale, 0, 0, grid.spriteScale)

                love.graphics.setStencilTest()
                love.graphics.pop()


                --Utils.drawTile("conveyer" .. math.floor(love.timer.getTime() * 10) % 8 + 1, x2, y2,
                --    grid[y][x].rotation, grid.spriteScale)
                if grid[y][x].tile == "input" then
                    love.graphics.setColor(.5, .5, 1, .8)
                    Utils.drawTile(grid[y][x].input, x2, y2, grid[y][x].rotation, grid.spriteScale)
                    love.graphics.setColor(1, 1, 1, 1)
                end
            elseif grid[y][x].tile == "wire" then
                local sprite, rotation = Grid.getWireToDraw(grid, x, y, function(grid2, x3, y3, direction2)
                    return (grid2[y3][x3].tile == "wire") or
                        ((grid2[y3][x3].tile == "piston" or grid2[y3][x3].tile == "sensor") and grid2[y3][x3].rotation ~= (direction2 + 2) % 4)
                end)
                Utils.drawTile(
                    "wire_" ..
                    sprite ..
                    "_" .. (grid.isSimulation and grid.signalNetworks[grid[y][x].signalNetwork] and "on" or "off"),
                    x2, y2, rotation, grid.spriteScale)
            elseif grid[y][x].tile == "output" then
                love.graphics.setColor(.5, 1, .5, .8)
                Utils.drawTile(grid[y][x].output, x2, y2, grid[y][x].rotation, grid.spriteScale)
                love.graphics.setColor(1, 1, 1, 1)
            end
        end
    end

    --draw welder beams
    local welderSpots = {}
    local welderSpotSet = {}
    for y = 1, #grid do
        for x = 1, #grid[y] do
            if grid[y][x].tile == "welder" then
                local xOffset, yOffset = Utils.directionToVector(grid[y][x].rotation)
                local x2, y2 = x + xOffset, y + yOffset
                if not Globals.solidTileSet[grid[y2][x2].tile] then
                    table.insert(welderSpots, { x = x2, y = y2 })
                    welderSpotSet[x2 .. "," .. y2] = true
                end
            end
        end
    end
    for i = 1, #welderSpots do
        local spot = welderSpots[i]
        local sprite, rotation = Grid.getWireToDraw(grid, spot.x, spot.y, function(grid2, x3, y3, direction2)
            return welderSpotSet[x3 .. "," .. y3] or
                (grid2[y3][x3].tile == "welder" and grid2[y3][x3].rotation == (direction2 + 2) % 4)
        end)
        Utils.drawTile("welder_" .. sprite, (spot.x - 1) * grid.spriteScale + grid.xInnerOffset + grid.xOffset,
            (spot.y - 1) * grid.spriteScale + grid.yInnerOffset + grid.yOffset, rotation, grid.spriteScale)
    end


    --draw items
    if grid.isSimulation then
        for y = 1, #grid do
            for x = 1, #grid[y] do
                local x2, y2 = (x - 1) * grid.spriteScale + grid.xInnerOffset + grid.xOffset,
                    (y - 1) * grid.spriteScale + grid.yInnerOffset + grid.yOffset
                if grid[y][x].item ~= nil then
                    local xMovingOffset, yMovingOffset = 0, 0
                    if grid[y][x].item ~= grid[y][x].nextItem then
                        xMovingOffset, yMovingOffset = Utils.directionToVector(grid[y][x].item.direction)
                        xMovingOffset = xMovingOffset * grid.spriteScale * grid.progressToNextTick
                        yMovingOffset = yMovingOffset * grid.spriteScale * grid.progressToNextTick
                    end
                    Utils.drawTile(grid[y][x].item.name, x2 + xMovingOffset, y2 + yMovingOffset, grid[y][x].item
                        .rotation, grid.spriteScale)
                end
                if Globals.drawFutureItems and grid[y][x].nextItem ~= nil and grid[y][x].item ~= grid[y][x].nextItem then
                    love.graphics.setColor(.5, 1, .5, .5)
                    Utils.drawTile(grid[y][x].nextItem.name, x2, y2, grid[y][x].nextItem.rotation, grid.spriteScale)
                    love.graphics.setColor(1, 1, 1, 1)
                end
            end
        end
    end

    --draw top of certain tiles

    for y = 1, #grid do
        for x = 1, #grid[y] do
            local x2, y2 = (x - 1) * grid.spriteScale + grid.xInnerOffset + grid.xOffset,
                (y - 1) * grid.spriteScale + grid.yInnerOffset + grid.yOffset
            if grid[y][x].tile == "piston" then
                if not grid.isSimulation then
                    Utils.drawTile("piston_head", x2, y2, grid[y][x].rotation, grid.spriteScale)
                    Utils.drawTile("piston_base_" .. (grid[y][x].on and "on" or "off"), x2, y2, grid[y][x].rotation,
                        grid.spriteScale)
                else
                    local startOfSpriteName = "piston_base_"
                    if (grid[y][x].item == nil and grid[y][x].nextItem == nil) or
                        (grid[y][x].item ~= nil and grid[y][x].nextItem == nil and grid.progressToNextTick > .5) or
                        (grid[y][x].item == nil and grid[y][x].nextItem ~= nil and grid.progressToNextTick < .5) then
                        startOfSpriteName = "piston_"
                    end
                    Utils.drawTile(startOfSpriteName .. (grid[y][x].on and "on" or "off"),
                        x2, y2, grid[y][x].rotation, grid.spriteScale)
                end
            elseif grid[y][x].tile == "sensor" then
                Utils.drawTile(
                    grid[y][x].tile ..
                    "_" .. (grid.isSimulation and grid.signalNetworks[grid[y][x].signalNetwork] and "on" or "off"),
                    x2, y2,
                    grid[y][x].rotation, grid.spriteScale)
            elseif Utils.contains({ "welder", "wall" }, grid[y][x].tile) then
                Utils.drawTile(grid[y][x].tile, x2, y2, grid[y][x].rotation, grid.spriteScale)
            end
        end
    end



    --draw tile at mouse
    if not grid.isSimulation then
        local tileAtMouse = Grid.getTileAtMouse(grid, Globals.mouseX, Globals.mouseY)
        if tileAtMouse and not tileAtMouse.locked then
            love.graphics.setColor(.7, .7, 1, .7)
            local x2, y2 = (tileAtMouse.x - 1) * grid.spriteScale + grid.xInnerOffset + grid.xOffset,
                (tileAtMouse.y - 1) * grid.spriteScale + grid.yInnerOffset + grid.yOffset
            local spriteName = Assets.iconMap[GameScene.heldTile]
            Utils.drawTile(spriteName, x2, y2, GameScene.heldTileRotation, grid.spriteScale)
        end
    end
end

function Grid.getTileAt(grid, x, y)
    if x < 1 or x > grid.width or y < 1 or y > grid.height then
        return nil
    end
    return grid[y][x]
end

function Grid.getTileAtMouse(grid, mouseX, mouseY)
    local x = math.floor((mouseX - grid.xOffset - grid.xInnerOffset) / grid.spriteScale) + 1
    local y = math.floor((mouseY - grid.yOffset - grid.yInnerOffset) / grid.spriteScale) + 1
    return Grid.getTileAt(grid, x, y)
end

function Grid.getWireToDraw(grid, x, y, callback)
    local connections = { false, false, false, false }
    local numberOfConnections = 0
    Utils.forEachDirection(function(direction, xOffset, yOffset)
        local x2 = x + xOffset
        local y2 = y + yOffset
        if callback(grid, x2, y2, direction) then
            connections[direction] = true
            numberOfConnections = numberOfConnections + 1
        end
    end)

    if numberOfConnections == 0 then
        return 4, 0
    elseif numberOfConnections == 1 then
        for i = 0, 3 do
            if connections[i] then
                return 0, (i - 2) % 4
            end
        end
    elseif numberOfConnections == 2 then
        if connections[0] and connections[2] then
            return 1, 0
        elseif connections[1] and connections[3] then
            return 1, 1
        elseif connections[2] and connections[3] then
            return 2, 0
        elseif connections[3] and connections[0] then
            return 2, 1
        elseif connections[0] and connections[1] then
            return 2, 2
        else
            return 2, 3
        end
    elseif numberOfConnections == 3 then
        for i = 0, 3 do
            if not connections[i] then
                return 3, (i - 1) % 4
            end
        end
    else
        return 4, 0
    end
end

return Grid
