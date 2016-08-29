local Wrench = Class("Wrench")

function Wrench:initialize(x, y, w, h)
    self.width, self.height = w, h
    self.position = Vector(x, y)

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

return Wrench
