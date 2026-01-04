local SceneManager = {}

SceneManager.sceneStack = {}

function SceneManager.pushScene(scene)
    if scene.init then scene.init() end
    table.insert(SceneManager.sceneStack, scene)
end

function SceneManager.removeScene(scene)
    for i, s in ipairs(SceneManager.sceneStack) do
        if s == scene then
            table.remove(SceneManager.sceneStack, i)
            break
        end
    end
end

function SceneManager.getCurrentScene()
    return SceneManager.sceneStack[#SceneManager.sceneStack]
end

function SceneManager.containsScene(scene)
    for _, s in ipairs(SceneManager.sceneStack) do
        if s == scene then
            return true
        end
    end
    return false
end

function SceneManager.drawScenes()
    for _, scene in ipairs(SceneManager.sceneStack) do
        if scene.draw then
            scene.draw()
        end
    end
end

return SceneManager