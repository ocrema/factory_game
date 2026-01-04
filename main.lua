love = love

Assets = require("scripts.Assets")
Button = require("scripts.Button")
GameMenu = require("scripts.GameMenu")
GameScene = require("scripts.GameScene")
Globals = require("scripts.Globals")
Grid = require("scripts.Grid")
Input = require("scripts.Input")
Item = require("scripts.Item")
Levels = require("scripts.Levels")
LevelSelectScene = require("scripts.LevelSelectScene")
Log = require("scripts.Log")
PauseMenuScene = require("scripts.PauseMenuScene")
SceneManager = require("scripts.SceneManager")
Simulation = require("scripts.Simulation")
TitleScene = require("scripts.TitleScene")
Utils = require("scripts.Utils")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest", 1) 
    Globals.realScreenWidth, Globals.realScreenHeight = love.window.getDesktopDimensions()
    
    love.window.setMode(Globals.realScreenWidth, Globals.realScreenHeight, {fullscreen = true})
    --love.window.setMode(Globals.realScreenWidth / 2, Globals.realScreenHeight / 2, {fullscreen = false, resizable = true})
    love.window.setTitle("Factory Game")

    Assets.loadAssets()

    SceneManager.pushScene(TitleScene)
end

function love.update(dt)
    Globals.dt = dt
    Input.update()
    Log.update()

    --update screen dimensions
    Globals.realScreenWidth, Globals.realScreenHeight = love.window.getMode()

    if Globals.realScreenWidth / Globals.realScreenHeight < 16 / 9 then
        Globals.realScreenXOffset = 0
        Globals.realScreenYOffset = (Globals.realScreenHeight - (Globals.realScreenWidth * 9 / 16)) / 2
        Globals.realScreenInnerHeight = Globals.realScreenWidth * 9 / 16
        Globals.realScreenInnerWidth = Globals.realScreenWidth

    elseif Globals.realScreenWidth / Globals.realScreenHeight > 16 / 9 then
        Globals.realScreenXOffset = (Globals.realScreenWidth - Globals.realScreenHeight * 16 / 9) / 2
        Globals.realScreenYOffset = 0
        Globals.realScreenInnerWidth = Globals.realScreenHeight * 16 / 9
        Globals.realScreenInnerHeight = Globals.realScreenHeight
    else
        Globals.realScreenXOffset = 0
        Globals.realScreenYOffset = 0
        Globals.realScreenInnerWidth = Globals.realScreenWidth
        Globals.realScreenInnerHeight = Globals.realScreenHeight
    end

    Globals.screenScalar = Globals.screenWidth / Globals.realScreenInnerWidth

    --update mouse
    Globals.mouseX, Globals.mouseY = love.mouse.getPosition()
    Globals.mouseX = ((Globals.mouseX - Globals.realScreenXOffset) * Globals.screenScalar) or 0
    Globals.mouseY = ((Globals.mouseY - Globals.realScreenYOffset) * Globals.screenScalar) or 0

    if Input.keysClicked["escape"] then
        if SceneManager.sceneStack[#SceneManager.sceneStack] == PauseMenuScene then
            SceneManager.removeScene(PauseMenuScene)
        elseif not Utils.contains(SceneManager.sceneStack, PauseMenuScene) then
            SceneManager.pushScene(PauseMenuScene)
        end
    end
    --update scenes
    SceneManager.sceneStack[#SceneManager.sceneStack].update()
end

function love.draw()
    love.graphics.push()
    Globals.realScreenWidth, Globals.realScreenHeight = love.window.getMode()

    -- Draw animated background
    love.graphics.setColor(1, 1, 1, Globals.backgroundOpacity)
    local frameIndex = math.floor(love.timer.getTime() * 4) % 4 + 1
    local bgScale = math.max(Globals.realScreenWidth / 64, Globals.realScreenHeight / 64)
    local bgX = (Globals.realScreenWidth - 64 * bgScale) / 2
    local bgY = (Globals.realScreenHeight - 64 * bgScale) / 2
    love.graphics.draw(Assets.backgroundImage, Assets.backgroundFrames[frameIndex], bgX + bgScale * 64 * ((love.timer.getTime() / 256) % 1), bgY, 0, bgScale, bgScale)
    love.graphics.draw(Assets.backgroundImage, Assets.backgroundFrames[frameIndex], bgX + bgScale * 64 * ((love.timer.getTime() / 256) % 1) - bgScale * 64, bgY, 0, bgScale, bgScale)

    --love.graphics.setScissor(Globals.realScreenXOffset, Globals.realScreenYOffset, Globals.realScreenInnerWidth, Globals.realScreenInnerHeight)
    love.graphics.translate(Globals.realScreenXOffset, Globals.realScreenYOffset)
    love.graphics.scale(1 / Globals.screenScalar)

    love.graphics.setColor(1, 1, 1)
    for _, scene in ipairs(SceneManager.sceneStack) do
        scene.draw()
    end
    Log.draw()
    love.graphics.pop()
end

