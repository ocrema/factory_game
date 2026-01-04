
GameMenu = {}

function GameMenu.createGameMenu(xOffset, yOffset, width, height)
    local gameMenu = {}
    gameMenu.xOffset = xOffset
    gameMenu.yOffset = yOffset
    gameMenu.width = width
    gameMenu.height = height
    gameMenu.placeableButtonSize = width * .25
    gameMenu.placeableButtonSpacing = (width - 2 * gameMenu.placeableButtonSize) / 3
    local tempPlaceables = {"conveyer", "wall", "piston", "welder", "sensor", "wire"}
    gameMenu.placeables = {}
    for i = 1, #tempPlaceables do
        local x, y = 0, 0
        if i % 2 == 1 then
            x = gameMenu.xOffset + gameMenu.placeableButtonSpacing
            y = gameMenu.yOffset + gameMenu.placeableButtonSpacing + (i - 1) / 2 * (gameMenu.placeableButtonSize + gameMenu.placeableButtonSpacing)
        else
            x = gameMenu.xOffset + gameMenu.placeableButtonSpacing + gameMenu.placeableButtonSize + gameMenu.placeableButtonSpacing
            y = gameMenu.yOffset + gameMenu.placeableButtonSpacing + (i - 2) / 2 * (gameMenu.placeableButtonSize + gameMenu.placeableButtonSpacing)
        end
        gameMenu.placeables[i] = Button.createButton(x, y, gameMenu.placeableButtonSize, gameMenu.placeableButtonSize, false)
        gameMenu.placeables[i].placeable = tempPlaceables[i]
    end
    return gameMenu
end

function GameMenu.update(gameMenu)
    for i = 1, #gameMenu.placeables do
        if Button.updatePressed(gameMenu.placeables[i], Globals.mouseX, Globals.mouseY, love.mouse.isDown(1)) then
            GameScene.heldTile = gameMenu.placeables[i].placeable
            Log.log("Held tile: " .. GameScene.heldTile)
            for j = 1, #gameMenu.placeables do
                gameMenu.placeables[j].pressed = false
            end
            break
        end
    end

    if Input.keysClicked["r"] then
        GameScene.heldTileRotation = (GameScene.heldTileRotation + 1) % 4
        Log.log("Held tile rotation: " .. GameScene.heldTileRotation)
    end
end

function GameMenu.draw(gameMenu)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", gameMenu.xOffset, gameMenu.yOffset, gameMenu.width, gameMenu.height, gameMenu.width / 10)
    for i = 1, #gameMenu.placeables do
        if GameScene.heldTile == gameMenu.placeables[i].placeable then
            love.graphics.setColor(.5, .5, 1, 1)
            love.graphics.setLineWidth(gameMenu.placeableButtonSize / 10)
            love.graphics.rectangle("line", gameMenu.placeables[i].x - gameMenu.placeableButtonSize / 10, gameMenu.placeables[i].y - gameMenu.placeableButtonSize / 10, gameMenu.placeableButtonSize + gameMenu.placeableButtonSize / 5, gameMenu.placeableButtonSize + gameMenu.placeableButtonSize / 5)
        end
        -- Convert icon name to sprite name
        local spriteName = Assets.iconMap[gameMenu.placeables[i].placeable] or gameMenu.placeables[i].placeable
        love.graphics.setColor(1, 1, 1)
        Utils.drawTile(spriteName, gameMenu.placeables[i].x, gameMenu.placeables[i].y, Globals.heldTileRotation, gameMenu.placeableButtonSize)
    end
    love.graphics.setColor(1, 1, 1)
end
return GameMenu