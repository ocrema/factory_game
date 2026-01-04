
local Log = {}
Log.logs = {}
Log.maxLogs = 20
Log.timeSinceLastLog = 0
function Log.log(message, r, g, b)
    if not Globals.loggerActive then return end
    r = r or 0
    g = g or 0
    b = b or 0
    Log.timeSinceLastLog = 0
    for m in message:gmatch("[^\r\n]+") do
        table.insert(Log.logs, {message = m, r = r, g = g, b = b})
    end
    while #Log.logs > Log.maxLogs do
        table.remove(Log.logs, 1)
    end
end
function Log.error(message)
    Log.log(message, 1, 0, 0)
end
function Log.warning(message)
    Log.log(message, 1, 1, 0)
end
function Log.success(message)
    Log.log(message, 0, 1, 0)
end
function Log.info(message)
    Log.log(message, 0, 0, 1)
end
function Log.draw()
    if not Globals.loggerActive then return end
    love.graphics.setFont(Assets.font)
    for i = 1, #Log.logs do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 10, 16 + (i - 1) * (Assets.font:getHeight() + 2), Assets.font:getWidth(Log.logs[i].message) + 1, Assets.font:getHeight() + 2)
        love.graphics.setColor(Log.logs[i].r, Log.logs[i].g, Log.logs[i].b, 1)
        love.graphics.print(Log.logs[i].message, 11, 16 + (i - 1) * (Assets.font:getHeight() + 2) + 1)
    end
end
function Log.clear()
    Log.logs = {}
end
function Log.update()
    if not Globals.loggerActive then return end
    Log.timeSinceLastLog = Log.timeSinceLastLog + Globals.dt
    if Log.timeSinceLastLog > 5 then
        Log.clear()
    end
end
return Log