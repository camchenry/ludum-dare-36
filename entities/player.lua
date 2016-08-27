local Player = Class("Player")

function Player:initialize(x, y)
    self.width, self.height = 16, 16
    game.world:add(self, x, y, self.width, self.height)

    self.position = vector(x, y)
    self.velocity = vector(0, 0)
    self.acceleration = vector(0, -9.8)

    self.velMax = 20
    self.accel = 2
end

function Player:update(dt)
    if love.keyboard.isDown("a", "left") then
        self.acceleration.x = -self.accel
    elseif love.keyboard.isDown("d", "right") then
        self.acceleration.x = self.accel
    end

    self.velocity = self.velocty + self.acceleration * dt
    local actualX, actualY, cols, len = gameworld:move(self, self.position.x + self.velocty.x*dt, self.position.y + self.velocity.y*dt)

    self.position = vector(actualX, actualY)
end

function Player:draw()
    love.graphics.rectangle('fill', self.position.x, self.position.y, self.width, self.height)
end

return Player
