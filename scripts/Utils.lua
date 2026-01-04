local Utils = {}


function Utils.drawTile(sprite, x, y, r, scale)
    if Assets.sprites[sprite] == nil then
        Log.error("Sprite " .. sprite .. " not found in assets")
    else
        love.graphics.draw(Assets.spritesheet, Assets.sprites[sprite], x + scale/2, y + scale/2, (r or 0) * math.pi/2, scale/32, scale/32, 16, 16)
    end
end

function Utils.deepCopy(table)
    if type(table) ~= "table" then
        return table
    end
    local copy = {}
    for k, v in pairs(table) do
        copy[k] = Utils.deepCopy(v)
    end
    return copy
end

function Utils.contains(table, value)
    for i = 1, #table do
        if table[i] == value then
            return true
        end
    end
    return false
end

function Utils.directionToVector(direction)
    if direction == 0 then
        return 1, 0
    elseif direction == 1 then
        return 0, 1
    elseif direction == 2 then
        return -1, 0
    elseif direction == 3 then
        return 0, -1
    end
end

function Utils.forEachDirection(callback)
    callback(0, 1, 0)
    callback(2, -1, 0)
    callback(1, 0, 1)
    callback(3, 0, -1)
end

function Utils.fitRectWithinBounds(rect, bounds)
    local result = {}
    local rectAspect = rect.width / rect.height
    local boundsAspect = bounds.width / bounds.height
    if rectAspect > boundsAspect then
        local scale = bounds.width / rect.width
        result.width = rect.width * scale
        result.height = rect.height * scale
        result.xOffset = bounds.xOffset
        result.yOffset = bounds.yOffset + (bounds.height - result.height) / 2
    else
        local scale = bounds.height / rect.height
        result.width = rect.width * scale
        result.height = rect.height * scale
        result.xOffset = bounds.xOffset + (bounds.width - result.width) / 2
        result.yOffset = bounds.yOffset
    end
    return result
end

return Utils