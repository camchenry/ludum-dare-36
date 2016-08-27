Wrench = Class("Wrench")

function Wrench:initialize(x, y, w, h)
    self.width, self.height = w, h
    game.world:add(self, x, y, w, h)

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