local Mask = Class("Mask", Object)

function Mask:initialize(x, y, w, h, properties)
    Object.initialize(self, x, y, w, h, properties)
    self.name = "Mask"

    self.ID = properties.ID or 0

    self.image = love.graphics.newImage("assets/images/Misc/Village_PillarMask.png")
end

function Mask:update(dt)

end

function Mask:draw()
    love.graphics.draw(self.image, self.position.x, self.position.y)
end

function Mask:drawDebug(x, y)
    local propertyStrings = {
        "ID: " .. self.ID,
    }

    Object.drawDebug(self, x, y, propertyStrings)
end

return Mask
