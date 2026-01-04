local GameScene = {}


function GameScene.update()
    --update game
    Grid.update(GameScene.grid)
    GameMenu.update(GameScene.gameMenu)

    if GameScene.simulation then
        if Input.keysClicked["space"] then
            GameScene.simulation = nil
            Log.info("Simulation destroyed")
        else
            Simulation.update(GameScene.simulation)
        end
    else
        if Input.keysClicked["space"] then
            GameScene.simulation = Simulation.createSimulation(GameScene.grid)
            Log.info("Simulation created")
        end
    end

    --update hovered tile
    local hoveredTile = Grid.getTileAtMouse(GameScene.grid, Globals.mouseX, Globals.mouseY)
    if love.mouse.isDown(1) and hoveredTile and not hoveredTile.locked then
        hoveredTile.tile = GameScene.heldTile
        hoveredTile.rotation = GameScene.heldTileRotation
    elseif love.mouse.isDown(2) and hoveredTile and not hoveredTile.locked then
        hoveredTile.tile = "empty"
        hoveredTile.rotation = 0
    end
end

function GameScene.draw()
    if GameScene.simulation then
        Grid.draw(GameScene.simulation)
    else
        Grid.draw(GameScene.grid)
    end
    GameMenu.draw(GameScene.gameMenu)

end

function GameScene.init()
    GameScene.name = "GameScene"
    GameScene.grid = Grid.createGrid(Globals.selectedLevel, Globals.screenWidth * .45, Globals.screenHeight * .05, Globals.screenWidth * .5, Globals.screenHeight * .9)
    GameScene.gameMenu = GameMenu.createGameMenu(Globals.screenWidth * .05, Globals.screenHeight * .05, Globals.screenWidth * .25, Globals.screenHeight * .9)
    GameScene.simulation = nil
    GameScene.heldTile = "conveyer"
    GameScene.heldTileRotation = 0
end

return GameScene