Console = Class("Console")

function Console:initialize(x, y)
    self.position = Vector(x, y)

    self.interval = 3

    self.closedImage = love.graphics.newImage("assets/images/Backgrounds/Room_Gate_GateClosed.png")
    local g = Anim8.newGrid(208, 128, self.closedImage:getWidth(), self.closedImage:getHeight())
    self.closedAnimation = Anim8.newAnimation(g('1-2', 1), self.interval/2)
end

function Console:update(dt)
    self.closedAnimation:update(dt)
end

function Console:draw()
    self.closedAnimation:draw(self.closedImage, self.position.x, self.position.y)
end

return Console