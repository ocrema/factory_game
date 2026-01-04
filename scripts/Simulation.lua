local Simulation = {}


function Simulation.createSimulation(grid)
    local simulation = Utils.deepCopy(grid)
    simulation.isSimulation = true
    simulation.progressToNextTick = 1
    simulation.solidCoordSet = {}
    simulation.nextItemGroupId = 1
    simulation.pistons = {}
    simulation.welders = {}
    simulation.conveyers = {}
    simulation.sensors = {}
    simulation.inputs = {}
    simulation.outputs = {}
    simulation.inputGroups = {}
    simulation.outputGroups = {}
    simulation.signalNetworks = {}

    for y = 1, #simulation do
        for x = 1, #simulation[y] do
            simulation[y][x].item = nil
            simulation[y][x].nextItem = nil
            if simulation[y][x].tile == "piston" then
                Simulation.addNewItem(simulation, "piston_head", x, y, simulation[y][x].rotation)
                table.insert(simulation.pistons, {x = x, y = y})
            elseif simulation[y][x].tile == "welder" then
                table.insert(simulation.welders, {x = x, y = y})
            elseif simulation[y][x].tile == "conveyer" then
                table.insert(simulation.conveyers, {x = x, y = y})
            elseif simulation[y][x].tile == "input" then
                table.insert(simulation.inputs, {x = x, y = y})
                if simulation[y][x].groupId == nil then
                    table.insert(simulation.inputGroups, {})
                    Simulation.propagateGroupId(simulation, "input", x, y, #simulation.inputGroups, simulation.inputGroups[#simulation.inputGroups])
                end
            elseif simulation[y][x].tile == "output" then
                table.insert(simulation.outputs, {x = x, y = y})
                if simulation[y][x].groupId == nil then
                    table.insert(simulation.outputGroups, {})
                    Simulation.propagateGroupId(simulation, "output", x, y, #simulation.outputGroups, simulation.outputGroups[#simulation.outputGroups])
                end
            elseif simulation[y][x].tile == "sensor" then
                table.insert(simulation.sensors, {x = x, y = y})
                table.insert(simulation.signalNetworks, false)
                simulation[y][x].signalNetwork = #simulation.signalNetworks
                Utils.forEachDirection(function (direction, xOffset, yOffset)
                    if simulation[y + yOffset][x + xOffset].tile == "wire" and simulation[y + yOffset][x + xOffset].signalNetwork == nil then
                        table.insert(simulation.signalNetworks, false)
                        Simulation.setConnectedWireSignalNetwork(simulation, x + xOffset, y + yOffset, #simulation.signalNetworks)
                    end
                end)
            end
            if Globals.solidTileSet[simulation[y][x].tile] then
                simulation.solidCoordSet[x .. "," .. y] = true
            end
        end
    end
    return simulation
end

function Simulation.addNewItem(simulation, itemName, x, y, rotation, itemGroupId)
    if itemGroupId == nil then
        itemGroupId = simulation.nextItemGroupId
        simulation.nextItemGroupId = simulation.nextItemGroupId + 1
    end
    local item = Item.createItem(itemName, x, y, rotation, itemGroupId)
    simulation[y][x].item = item
    simulation[y][x].nextItem = item
end

function Simulation.propagateGroupId(simulation, name, x, y, groupId, group)
    simulation[y][x].groupId = groupId
    if group then
        table.insert(group, {x = x, y = y})
    end
    Utils.forEachDirection(function (direction, xOffset, yOffset)
        if simulation[y + yOffset][x + xOffset].tile == name and simulation[y + yOffset][x + xOffset].groupId == nil then
            Simulation.propagateGroupId(simulation, name, x + xOffset, y + yOffset, groupId, group)
        end
    end)
end

function Simulation.update(simulation)
    simulation.progressToNextTick = simulation.progressToNextTick + Globals.dt
    if simulation.progressToNextTick < 1 then
        return
    end
    simulation.progressToNextTick = simulation.progressToNextTick - 1
    Simulation.finishMovement(simulation)
    Simulation.updateWelders(simulation)
    Simulation.updateOutputs(simulation)
    Simulation.updateInputs(simulation)
    Simulation.updateSensors(simulation)
    Simulation.updatePistons(simulation)
    Simulation.updateConveyers(simulation)
end

function Simulation.finishMovement(simulation)
    for y = 1, #simulation do
        for x = 1, #simulation[y] do
            simulation[y][x].item = simulation[y][x].nextItem
            if simulation[y][x].item ~= nil then
                simulation[y][x].item.x = x
                simulation[y][x].item.y = y
            end
        end
    end
end

function Simulation.updateWelders(simulation)
    local weldableItems = {}
    for _, coord in ipairs(simulation.welders) do
        local xOffset, yOffset = Utils.directionToVector(simulation[coord.y][coord.x].rotation)
        local x, y = coord.x + xOffset, coord.y + yOffset
        if not simulation.solidCoordSet[x .. "," .. y] and 
            simulation[y][x].item and 
            simulation[y][x].item.name ~= "piston_head" then

            for _, item in ipairs(weldableItems) do
                local xDist = math.abs(item.x - x)
                local yDist = math.abs(item.y - y)
                if (xDist == 0 and yDist == 1) or (yDist == 0 and xDist == 1) and item.groupId ~= simulation[y][x].item.groupId then
                    local oldId = simulation[y][x].item.groupId
                    local newId = item.groupId
                    local function propagateWeld(x2, y2)
                        simulation[y2][x2].item.groupId = newId
                        Utils.forEachDirection(function (direction2, xOffset2, yOffset2)
                            if simulation[y2 + yOffset2][x2 + xOffset2].item and simulation[y2 + yOffset2][x2 + xOffset2].item.groupId == oldId then
                                propagateWeld(x2 + xOffset2, y2 + yOffset2)
                            end
                        end)
                    end
                    propagateWeld(x, y)
                end
            end
            table.insert(weldableItems, simulation[y][x].item)
        end
    end
end

function Simulation.updateOutputs(simulation)
    for _, group in ipairs(simulation.outputGroups) do
        local acceptOutput = true
        for _, coord in ipairs(group) do
            local x, y = coord.x, coord.y
            if (simulation[y][x].item == nil) or
            (simulation[y][x].item.name ~= simulation[y][x].output) or 
            (simulation[y][x].validRotations ~= nil and not Utils.contains(simulation[y][x].validRotations, simulation[y][x].item.rotation)) or 
            (simulation[y][x].invalidRotations ~= nil and Utils.contains(simulation[y][x].invalidRotations, simulation[y][x].item.rotation)) then
                acceptOutput = false
                break
            end
            for _, helper in ipairs(Globals.allRotations) do
                local x2, y2 = x + helper.xOffset, y + helper.yOffset
                if (simulation[y2][x2].tile ~= "output" and simulation[y2][x2].item and simulation[y2][x2].item.groupId == simulation[y][x].item.groupId) or
                (simulation[y2][x2].tile == "output" and (simulation[y2][x2].item == nil or simulation[y2][x2].item.groupId ~= simulation[y][x].item.groupId)) then
                    acceptOutput = false
                    break
                end
            end
            if not acceptOutput then break end
        end
        if acceptOutput then
            group.numberOfOutputs = (group.numberOfOutputs or 0) + 1
            for _, coord in ipairs(group) do
                local x, y = coord.x, coord.y
                simulation[y][x].item = nil
                simulation[y][x].nextItem = nil
            end
        end
    end
end

function Simulation.updateInputs(simulation)
    for _, group in ipairs(simulation.inputGroups) do
        if group.timeUntilNextInput == 0 or group.timeUntilNextInput == nil then
            local addInput = true
            for _, coord in ipairs(group) do
                local x, y = coord.x, coord.y
                if simulation[y][x].item ~= nil then
                    addInput = false
                    break
                end
            end
            if addInput then
                local itemGroupId = simulation.nextItemGroupId
                simulation.nextItemGroupId = simulation.nextItemGroupId + 1
                for _, coord in ipairs(group) do
                    local x, y = coord.x, coord.y
                    Simulation.addNewItem(simulation, simulation[y][x].input, x, y, simulation[y][x].inputRotation or 0, itemGroupId)
                    if simulation[y][x].timeBetweenInputs ~= nil then
                        group.timeUntilNextInput = simulation[y][x].timeBetweenInputs
                    end
                end
            end
        end
        if group.timeUntilNextInput > 0 then
            group.timeUntilNextInput = group.timeUntilNextInput - 1
        end
    end

end

function Simulation.updateSensors(simulation)
    for i = 1, #simulation.signalNetworks do
        simulation.signalNetworks[i] = false
    end
    for _, coord in ipairs(simulation.sensors) do
        local x, y = coord.x, coord.y
        local xOffset, yOffset = Utils.directionToVector(simulation[y][x].rotation)
        local on = (not not simulation[y + yOffset][x + xOffset].item) and simulation[y + yOffset][x + xOffset].item.name ~= "piston_head"
        simulation.signalNetworks[simulation[y][x].signalNetwork] = on

        if on then
            Utils.forEachDirection(function (direction, xOffset2, yOffset2)
                if direction == simulation[y][x].rotation then return end
                local x2 = x + xOffset2
                local y2 = y + yOffset2
                if simulation[y2][x2].tile == "wire" then
                    simulation.signalNetworks[simulation[y2][x2].signalNetwork] = true
                end
            end)
        end
    end
end

function Simulation.setConnectedWireSignalNetwork(simulation, x, y, networkNumber)
    simulation[y][x].signalNetwork = networkNumber
    Utils.forEachDirection(function (direction, xOffset, yOffset)
        if simulation[y + yOffset][x + xOffset].tile == "wire" and simulation[y + yOffset][x + xOffset].signalNetwork == nil then
            Simulation.setConnectedWireSignalNetwork(simulation, x + xOffset, y + yOffset, networkNumber)
        end
    end)
end

function Simulation.updatePistons(simulation)
    for _, coord in ipairs(simulation.pistons) do
        local x, y = coord.x, coord.y
        local xOffset, yOffset = Utils.directionToVector(simulation[y][x].rotation)
        simulation[y][x].on = false
        Utils.forEachDirection(function (direction2, xOffset2, yOffset2)
            if direction2 == simulation[y][x].rotation then return end
            local x2 = x + xOffset2
            local y2 = y + yOffset2
            if simulation[y2][x2].signalNetwork and simulation.signalNetworks[simulation[y2][x2].signalNetwork] then
                simulation[y][x].on = true
            end
        end)
        
        if not simulation[y][x].on and not simulation[y][x].item then
            simulation[y][x].nextItem = simulation[y + yOffset][x + xOffset].item
            simulation[y + yOffset][x + xOffset].nextItem = nil
            simulation[y][x].nextItem.direction = (simulation[y][x].rotation + 2) % 4
        end
    end
    for _, coord in ipairs(simulation.pistons) do
        local x, y = coord.x, coord.y
        local xOffset, yOffset = Utils.directionToVector(simulation[y][x].rotation)
        if simulation[y][x].on and simulation[y][x].item then
            local pushed = Simulation.attemptPushItem(simulation, x + xOffset, y + yOffset, simulation[y][x].rotation)
            if pushed then
                simulation[y + yOffset][x + xOffset].nextItem = simulation[y][x].item
                simulation[y][x].nextItem = nil
                simulation[y][x].item.direction = simulation[y][x].rotation
            end
        end
    end
end


function Simulation.updateConveyers(simulation)
    Utils.forEachDirection(function(direction)
        for _, coord in ipairs(simulation.conveyers) do
            local x, y = coord.x, coord.y
            if simulation[y][x].rotation == direction and simulation[y][x].item ~= nil and simulation[y][x].item.name ~= "piston_head" then
                Simulation.attemptPushItem(simulation, x, y, direction)
            end
        end
        for _, coord in ipairs(simulation.inputs) do
            local x, y = coord.x, coord.y
            if simulation[y][x].rotation == direction and simulation[y][x].item ~= nil and simulation[y][x].item.name ~= "piston_head" then
                Simulation.attemptPushItem(simulation, x, y, direction)
            end
        end
    end)
end

function Simulation.canIMoveIntoThisSpot(simulation, x, y, direction, itemsToMoveSet)
    if itemsToMoveSet[simulation[y][x].item] then return true end
    if simulation.solidCoordSet[x .. "," .. y] then return false end
    if simulation[y][x].item == nil and simulation[y][x].nextItem == nil then return true end
    if simulation[y][x].item ~= nil and simulation[y][x].nextItem == nil then
        if simulation[y][x].item.direction == direction then return true else return false end
    end
    if simulation[y][x].item == nil and simulation[y][x].nextItem ~= nil then return false end
    if simulation[y][x].item ~= nil and simulation[y][x].nextItem ~= nil then
        if simulation[y][x].item ~= simulation[y][x].nextItem then return false end
        if simulation[y][x].item.name == "piston_head" then return false end
        itemsToMoveSet[simulation[y][x].item] = true
        local result = true
        Utils.forEachDirection(function (direction2, xOffset, yOffset)
            if not result then return end
            local x2 = x + xOffset
            local y2 = y + yOffset
            if direction == direction2 or (simulation[y2][x2].item and simulation[y][x].item.groupId == simulation[y2][x2].item.groupId) then 
                result = Simulation.canIMoveIntoThisSpot(simulation, x2, y2, direction, itemsToMoveSet)
            end
        end)
        return result
    end
end

function Simulation.moveItemSet(simulation, direction, itemsToMoveSet)
    local xOffset, yOffset = Utils.directionToVector(direction)
    for item, _ in pairs(itemsToMoveSet) do
        local x, y = item.x, item.y
        if simulation[y][x].item == simulation[y][x].nextItem then
            simulation[y][x].nextItem = nil
        end
        simulation[y + yOffset][x + xOffset].nextItem = item
        item.direction = direction
    end
end

function Simulation.attemptPushItem(simulation, x, y, direction)
    local itemsToMoveSet = {}
    local result = Simulation.canIMoveIntoThisSpot(simulation, x, y, direction, itemsToMoveSet)
    if result then
        Simulation.moveItemSet(simulation, direction, itemsToMoveSet)
    end
    return result
end



return Simulation