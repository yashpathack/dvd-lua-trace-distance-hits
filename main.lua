


local screenWidth, screenHeight = love.graphics.getDimensions()
local dvdIcon = love.graphics.newImage("dvd.png")

local dvdWidth, dvdHeight = dvdIcon:getDimensions()
local distanceTraveled = 0
local edgeCollisions = 0

local x = 100
local y = 100
local speed = 500
local xDirection = 1
local yDirection = 1
local collisionSound

local minSize = 50


local function playCollisionSound()
    if lastCollisionSound then
        lastCollisionSound:stop()  -- Stop the last collision sound
    end
    lastCollisionSound = love.audio.newSource("bubble.mp3", "static")
    lastCollisionSound:play()
end

local function pickColor()
    local r = math.random(0, 254)
    local g = math.random(0, 254)
    local b = math.random(0, 254)

    return {r / 255, g / 255, b / 255}
end

local currentColor = pickColor()
local path = {}
local pathWidth = 5
local drawPath = true  -- Controls the visibility of the path

local toggleButton = {
    x = 10,
    y = 10,
    width = 100,
    height = 30
}

local speedSlider = {
    x = 10,
    y = 50,
    width = 100,
    height = 20,
    minValue = 100,
    maxValue = 5000,
    value = speed,
    knobRadius = 10,
    knobColor = {1, 0, 0}
}

function love.load()
    x = math.random(0, screenWidth - dvdWidth)
    y = math.random(0, screenHeight - dvdHeight)
    

end

function love.update(dt)
    x = x + speed * xDirection * dt
    y = y + speed * yDirection * dt

    local dx = speed * xDirection * dt
    local dy = speed * yDirection * dt
    local distance = math.sqrt(dx * dx + dy * dy)
    

    if x <= 0 then
        x = 0
        xDirection = 1
        currentColor = pickColor()
        playCollisionSound()
    elseif x + dvdWidth >= screenWidth then
        x = screenWidth - dvdWidth
        xDirection = -1
        currentColor = pickColor()
        playCollisionSound()
    end

    if y <= 0 then
        y = 0
        yDirection = 1
        currentColor = pickColor()
        playCollisionSound()
    elseif y + dvdHeight >= screenHeight then
        y = screenHeight - dvdHeight
        yDirection = -1
        currentColor = pickColor()
        playCollisionSound()
    end

    local aspectRatio = dvdWidth / dvdHeight
    local targetWidth = math.max(minSize, screenWidth / 5)
    local targetHeight = targetWidth / aspectRatio
    dvdWidth = targetWidth
    dvdHeight = targetHeight

    -- Add current position to path
    if drawPath then
        table.insert(path, {x = x + dvdWidth / 2, y = y + dvdHeight / 2, color = {currentColor[1], currentColor[2], currentColor[3], 0.5}})
    end

    distanceTraveled = distanceTraveled + distance

    if x <= 0 or x + dvdWidth >= screenWidth or y <= 0 or y + dvdHeight >= screenHeight then
        edgeCollisions = edgeCollisions + 1
        -- collisionSound:play()
    end

    speed = speedSlider.value
end

function love.draw()
    -- Draw the path
    if drawPath then
        love.graphics.setLineWidth(pathWidth)
        for i = 2, #path do
            local prev = path[i - 1]
            local curr = path[i]
            love.graphics.setColor(curr.color)
            love.graphics.line(prev.x, prev.y, curr.x, curr.y)
        end
    end

    -- Draw the DVD logo
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(dvdIcon, x, y, 0, dvdWidth / dvdIcon:getWidth(), dvdHeight / dvdIcon:getHeight())

    -- Draw the toggle button
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", toggleButton.x, toggleButton.y, toggleButton.width, toggleButton.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Toggle Path", toggleButton.x + 10, toggleButton.y + 5)

    -- Draw the speed slider
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", speedSlider.x, speedSlider.y, speedSlider.width, speedSlider.height)
    local knobX = speedSlider.x + (speedSlider.value - speedSlider.minValue) / (speedSlider.maxValue - speedSlider.minValue) * (speedSlider.width - 2 * speedSlider.knobRadius) + speedSlider.knobRadius
    love.graphics.setColor(speedSlider.knobColor)
    love.graphics.circle("fill", knobX, speedSlider.y + speedSlider.height / 2, speedSlider.knobRadius)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Speed: " .. speedSlider.value, speedSlider.x + speedSlider.width + 10, speedSlider.y + 5) -- Display current speed value
    
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", screenWidth - 120, 10, 110, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Distance: " .. math.floor(distanceTraveled), screenWidth - 115, 15)

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", screenWidth - 120, screenHeight - 40, 110, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Collisions: " .. edgeCollisions, screenWidth - 115, screenHeight - 35)
end

function love.mousepressed(mx, my, button, istouch, presses)
    if button == 1 and mx >= toggleButton.x and mx <= toggleButton.x + toggleButton.width and my >= toggleButton.y and my <= toggleButton.y + toggleButton.height then
        drawPath = not drawPath  -- Toggle the visibility of the path
    elseif button == 1 and mx >= speedSlider.x and mx <= speedSlider.x + speedSlider.width and my >= speedSlider.y and my <= speedSlider.y + speedSlider.height then
        local knobX = mx - speedSlider.x
        speedSlider.value = math.min(speedSlider.maxValue, math.max(speedSlider.minValue, speedSlider.minValue + knobX / (speedSlider.width - 2 * speedSlider.knobRadius) * (speedSlider.maxValue - speedSlider.minValue)))    
    end
end
