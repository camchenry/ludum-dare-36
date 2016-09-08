local Wrench = Class("Wrench", Object)

function Wrench:initialize(x, y, w, h, properties)
    Object.initialize(self, x, y, w, h, properties)

    self.activated = false

    self.image = love.graphics.newImage("assets/images/Misc/Room6_SkeletonLayer.png")

    self.imageOffset = Vector(-26, -2)
end

function Wrench:activate()
    self.activated = true
end

function Wrench:draw()
    if self.activated then
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(self.image, self.position.x + self.imageOffset.x, self.position.y + self.imageOffset.y)
    end
end

function Wrench:drawDebug(x, y)
    local propertyStrings = {
        "Activated: " .. (self.activated and "true" or "false"),
    }

    Object.drawDebug(self, x, y, propertyStrings)
end

return Wrench
