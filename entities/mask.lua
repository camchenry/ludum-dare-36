local Mask = Class("Mask")

function Mask:initialize(x, y, w, h, properties)
    self.position = Vector(x, y)

    self.ID = tonumber(properties.ID) or 0

    self.image = love.graphics.newImage("assets/images/Misc/Village_PillarMask.png")
end

function Mask:update(dt)

end

function Mask:draw()
    love.graphics.draw(self.image, self.position.x, self.position.y)
end

return Mask
