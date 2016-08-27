local Wrench = Class("Wrench")

function Wrench:initialize(x, y)
    self.width, self.height = 16, 16
    self.position = Vector(x, y)

    self.visible = true
end

function Wrench:draw()
    if self.visible then
        love.graphics.rectangle('fill', self.position.x, self.position.y, self.width, self.height)
    end
end

return Wrench
