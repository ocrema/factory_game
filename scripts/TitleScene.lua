local TitleScene = {}


function TitleScene.init()
    TitleScene.name = "TitleScene"
    TitleScene.progress = 0
    TitleScene.speed = .15
    TitleScene.backgroundFadeInStart = 0
    TitleScene.backgroundFadeInEnd = .5
    TitleScene.backgroundOpacity = 0
    TitleScene.titleFadeInStart = .6
    TitleScene.titleFadeInEnd = .9
    TitleScene.titleOpacity = 0
    TitleScene.subTitleFadeInStart = .8
    TitleScene.subTitleFadeInEnd = 1.0
    TitleScene.subTitleOpacity = 0
    TitleScene.titleText = "Factory Game"
    TitleScene.subTitleText = "Press Space to Start"
end

function TitleScene.update()
    TitleScene.progress = math.min(TitleScene.progress + TitleScene.speed * Globals.dt, 1)
    TitleScene.backgroundOpacity = (math.min(math.max(TitleScene.backgroundFadeInStart, TitleScene.progress), TitleScene.backgroundFadeInEnd) - TitleScene.backgroundFadeInStart) / (TitleScene.backgroundFadeInEnd - TitleScene.backgroundFadeInStart)
    Globals.backgroundOpacity = TitleScene.backgroundOpacity
    TitleScene.titleOpacity = (math.min(math.max(TitleScene.titleFadeInStart, TitleScene.progress), TitleScene.titleFadeInEnd) - TitleScene.titleFadeInStart) / (TitleScene.titleFadeInEnd - TitleScene.titleFadeInStart)
    TitleScene.subTitleOpacity = (math.min(math.max(TitleScene.subTitleFadeInStart, TitleScene.progress), TitleScene.subTitleFadeInEnd) - TitleScene.subTitleFadeInStart) / (TitleScene.subTitleFadeInEnd - TitleScene.subTitleFadeInStart)
    if Input.keysClicked["space"] then
        Globals.backgroundOpacity = 1
        SceneManager.removeScene(TitleScene)
        SceneManager.pushScene(LevelSelectScene)
        return
    end
end

function TitleScene.draw()
    love.graphics.setFont(Assets.titleFont)
    love.graphics.setColor(1, 1, 1, TitleScene.titleOpacity)
    love.graphics.printf("Factory Game", 0, Globals.screenHeight / 2 - 100, Globals.screenWidth, "center")
    love.graphics.setFont(Assets.largeFont)
    love.graphics.setColor(1, 1, 1, TitleScene.subTitleOpacity)
    love.graphics.printf("Press Space to Start", 0, Globals.screenHeight / 2 + 30, Globals.screenWidth, "center")
end

return TitleScene