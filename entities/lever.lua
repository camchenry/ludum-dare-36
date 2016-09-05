local Lever = Class("Lever")

Lever.static.onImage = love.graphics.newImage("assets/images/Misc/Switch_On.png")
Lever.static.offImage = love.graphics.newImage("assets/images/Misc/Switch_Off.png")

function Lever:initialize(x, y, properties)
    self.position = Vector(x, y)
    self.width = 16
    self.height = 16

    self.ID      = properties.ID or 0
    self.oneTime = properties.oneTime or false

    self.active = false

    self.imageOffset = Vector(-2, -1)
end

function Lever:reset()
    self.active = false
end

function Lever:draw()
    local image = Lever.offImage

    if self.active then
        image = Lever.onImage
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
