Wrench = Class("Wrench")

function Wrench:initialize(x, y)
    self.width, self.height = 16, 16
    game.world:add(self, x, y, self.width, self.height)

    self.x = x
    self.y = y

    self.visible = true
end

function Wrench:draw()
    if self.visible then
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    end
end

return Wrench