local Checkpoint = Class("Checkpoint")

function Checkpoint:initialize(x, y, w, h)
    self.position = Vector(x, y)
    self.width = w
    self.height = h
end

function Checkpoint:draw()
    if DEBUG then
        love.graphics.setColor(0, 255, 0)
        love.graphics.rectangle('line', self.position.x, self.position.y, self.width, self.height)
    end
    love.graphics.setColor(255, 255, 255)
end

return Checkpoint