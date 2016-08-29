local Lever = Class("Lever")

function Lever:initialize(x, y, properties)
    self.position = Vector(x, y)
    self.width = 16
    self.height = 16

    self.ID = tonumber(properties.ID) or 0
    self.active = false
    self.oneTime = properties.oneTime

    self.onImage = love.graphics.newImage("assets/images/Misc/Switch_On.png")
    self.offImage = love.graphics.newImage("assets/images/Misc/Switch_Off.png")

    self.imageOffset = Vector(-2, -1)
end

function Lever:draw()
    local image = self.offImage

    if self.active then
        image = self.onImage
    end

    love.graphics.draw(image, self.position.x + self.imageOffset.x, self.position.y + self.imageOffset.y)
end

function Lever:hit()
    if self.oneTime and self.active then return end
    Signal.emit("activate", self.ID)
    self.active = not self.active
    return true
end

return Lever
