local LevelSelectScene = {}


function LevelSelectScene.init()
    LevelSelectScene.name = "LevelSelectScene"
    LevelSelectScene.buttons = {}
    
    local numLevels = #Levels
    local buttonWidth = 200
    local buttonHeight = 100
    local buttonPadding = 20
    local buttonsPerRow = math.floor((Globals.screenWidth - buttonPadding) / (buttonWidth + buttonPadding))
    
    for i = 1, numLevels do
        local row = math.floor((i - 1) / buttonsPerRow)
        local col = (i - 1) % buttonsPerRow
        
        local x = buttonPadding + col * (buttonWidth + buttonPadding)
        local y = buttonPadding + row * (buttonHeight + buttonPadding)
        
        local button = Button.createButton(x, y, buttonWidth, buttonHeight)
        button.levelIndex = i
        table.insert(LevelSelectScene.buttons, button)
    end
end

function LevelSelectScene.update()
    local mouseDown = Input.mouseClicked[1]
    
    for _, button in ipairs(LevelSelectScene.buttons) do
        if Button.updatePressed(button, Globals.mouseX, Globals.mouseY, mouseDown) then
            Globals.selectedLevel = Levels[button.levelIndex]
            SceneManager.removeScene(LevelSelectScene)
            SceneManager.pushScene(GameScene)
            return
        end
    end
    
end

function LevelSelectScene.draw()
    love.graphics.setFont(Assets.largeFont)
    
    for _, button in ipairs(LevelSelectScene.buttons) do
        Button.draw(button)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(Levels[button.levelIndex].name, button.x, button.y + button.height / 2 - 10, button.width, "center")
    end
end

return LevelSelectScene
