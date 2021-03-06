local Lever = Class("Lever", Object)

Lever.static.onImage = love.graphics.newImage("assets/images/Misc/Switch_On.png")
Lever.static.offImage = love.graphics.newImage("assets/images/Misc/Switch_Off.png")

function Lever:initialize(x, y, w, h, properties)
    self.width = 16
    self.height = 16

    Object.initialize(self, x, y, self.width, self.height, properties)
    self.name = "Lever"

    self.ID         = properties.ID or 0
    self.oneTime    = properties.oneTime or false
    self.resettable = properties.resettable or false

    -- Levers should be drawn behind enemies, the bot, etc
    self.zindex = properties.zindex or -99

    self.active = false

    self.imageOffset = Vector(-2, -1)
end

function Lever:reset()
    if self.resettable then
        self.active = false
    end
end

function Lever:draw(debugOverride)
    love.graphics.setColor(255, 255, 255)

    Object.draw(self, debugOverride)
    
    local image = Lever.offImage

    if self.active then
        image = Lever.onImage
    end

    love.graphics.draw(image, self.position.x + self.imageOffset.x, self.position.y + self.imageOffset.y)
end

function Lever:drawDebug(x, y)
    local propertyStrings = {
        "ID: " .. self.ID,
        "One Time: " .. (self.oneTime and "true" or "false"),
        "Active: " .. (self.active and "true" or "false"),
    }

    Object.drawDebug(self, x, y, propertyStrings)
end

function Lever:hit()
    if self.oneTime and self.active then return end
    Signal.emit("activate", self.ID)
    Signal.emit("leverActivate")
    self.active = not self.active
    return true
end

return Lever
