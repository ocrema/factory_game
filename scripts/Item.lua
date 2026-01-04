local Item = {}

function Item.createItem(name, x, y, rotation, groupId)
    local item = {}
    item.name = name
    item.rotation = rotation
    item.x = x
    item.y = y
    item.groupId = groupId
    item.direction = 0
    return item
end

return Item
