local PauseMenuScene = {}

function PauseMenuScene.init()
    PauseMenuScene.buttonWidth = 200
    PauseMenuScene.buttonHeight = 50
    PauseMenuScene.buttonSpacing = 20
    PauseMenuScene.buttonNames = {}
    if SceneManager.containsScene(GameScene) then
        table.insert(PauseMenuScene.buttonNames, "Level Select")
    end
    table.insert(PauseMenuScene.buttonNames, "Quit Game")
    PauseMenuScene.width = PauseMenuScene.buttonWidth + 100
    PauseMenuScene.height = (#PauseMenuScene.buttonNames) * (PauseMenuScene.buttonHeight + PauseMenuScene.buttonSpacing) + 100
    PauseMenuScene.x = (Globals.screenWidth - PauseMenuScene.width) / 2
    PauseMenuScene.y = (Globals.screenHeight - PauseMenuScene.height) / 2
    PauseMenuScene.name = "PauseMenuScene"
    PauseMenuScene.buttons = {}
    for _, name in ipairs(PauseMenuScene.buttonNames) do
        local buttonX = PauseMenuScene.x + (PauseMenuScene.width - PauseMenuScene.buttonWidth) / 2
        local buttonY = PauseMenuScene.y + 80 + (#PauseMenuScene.buttons) * (PauseMenuScene.buttonHeight + PauseMenuScene.buttonSpacing)
        local button = Button.createButton(buttonX, buttonY, PauseMenuScene.buttonWidth, PauseMenuScene.buttonHeight, false, name)
        table.insert(PauseMenuScene.buttons, button)
    end
end

function PauseMenuScene.update()
    for _, button in ipairs(PauseMenuScene.buttons) do
        if Button.updatePressed(button, Globals.mouseX, Globals.mouseY, Input.mouseClicked[1]) then
            if button.text == "Quit Game" then
                love.event.quit()
            elseif button.text == "Level Select" then
                SceneManager.removeScene(PauseMenuScene)
                SceneManager.removeScene(GameScene)
                SceneManager.pushScene(LevelSelectScene)
            end
        end
    end
end


function PauseMenuScene.draw()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, Globals.screenWidth, Globals.screenHeight)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", PauseMenuScene.x, PauseMenuScene.y, PauseMenuScene.width, PauseMenuScene.height, 10)

    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(Assets.largeFont)
    love.graphics.printf("Paused", PauseMenuScene.x, PauseMenuScene.y + 20, PauseMenuScene.width, "center")
    --love.graphics.setFont(Assets.font)
    --love.graphics.printf("Press ESC to resume", PauseMenuScene.x, PauseMenuScene.y + PauseMenuScene.height / 2 - 10, PauseMenuScene.width, "center")
    for _, button in ipairs(PauseMenuScene.buttons) do
        Button.draw(button)
    end
end

return PauseMenuScene