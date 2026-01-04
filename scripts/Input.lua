Input = {}
local keysToListenFor = {'r', 'escape', 'space'}
Input.keysDown = {}
Input.keysClicked = {}
Input.mouseDown = {}
Input.mouseClicked = {}

function Input.update()

    for i = 1, #keysToListenFor do
        if love.keyboard.isDown(keysToListenFor[i]) then
            if not Input.keysDown[keysToListenFor[i]] then
                Input.keysDown[keysToListenFor[i]] = true
                Input.keysClicked[keysToListenFor[i]] = true
            else
                Input.keysClicked[keysToListenFor[i]] = false
            end
        else
            Input.keysClicked[keysToListenFor[i]] = false
            Input.keysDown[keysToListenFor[i]] = false
        end
    end

    if love.mouse.isDown(1) then
        if not Input.mouseClicked[1] then
            Input.mouseDown[1] = true
            Input.mouseClicked[1] = true
        else
            Input.mouseClicked[1] = false
        end
    else
        Input.mouseDown[1] = false
        Input.mouseClicked[1] = false
    end

    if love.mouse.isDown(2) then
        if not Input.mouseClicked[2] then
            Input.mouseDown[2] = true
            Input.mouseClicked[2] = true
        else
            Input.mouseClicked[2] = false
        end
    else
        Input.mouseDown[2] = false
        Input.mouseClicked[2] = false
    end
end

return Input