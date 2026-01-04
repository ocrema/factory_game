
Button = {}

function Button.createButton(x, y, width, height, switchable, text)
    local button = {}
    button.x = x
    button.y = y
    button.width = width
    button.height = height
    button.switchable = switchable or false
    button.pressed = false
    button.alreadyClickedThisPress = false
    button.text = text or ""
    return button
end

function Button.updatePressed(button, mouseX, mouseY, mouseDown)
    local hovered = Button.isMouseOver(button, mouseX, mouseY)
    if button.switchable then
        if hovered and mouseDown then
            if not button.alreadyClickedThisPress then
                button.alreadyClickedThisPress = true
                button.pressed = not button.pressed
                return true
            end
        else
            button.alreadyClickedThisPress = false
        end
    else
        if hovered and mouseDown then
            if not button.alreadyClickedThisPress then
                button.alreadyClickedThisPress = true
                button.pressed = true
                return true
            end
        else
            button.alreadyClickedThisPress = false
            button.pressed = false
        end
    end
    return false
end

function Button.isMouseOver(button, mouseX, mouseY)
    return mouseX >= button.x and mouseX <= button.x + button.width and mouseY >= button.y and mouseY <= button.y + button.height
end

function Button.draw(button)
    if button.pressed then
        love.graphics.setColor(0.5, 0.5, 0.5)
    else
        love.graphics.setColor(0.8, 0.8, 0.8)
    end
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
    love.graphics.setColor(0, 0, 0)
    if button.text ~= "" then
        love.graphics.setFont(Assets.font)
        love.graphics.printf(button.text, button.x, button.y + button.height / 2 - 10, button.width, "center")
    end
end





return Button