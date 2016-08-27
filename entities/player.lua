local Player = Class("Player")

function Player:initialize(x, y)
    self.width, self.height = 16, 16
    game.world:add(self, x, y, self.width, self.height)

    self.position = Vector(x, y)
    self.velocity = Vector(0, 0)
    self.acceleration = Vector(0, 0)

    self.gravity = 160
    self.velMax = 20
    self.moveAccel = 60
    self.jumpAccel = 20
end

function Player:update(dt)
    self.acceleration = Vector(0, self.gravity)

    if love.keyboard.isDown("w", "up") then
        self.acceleration.y = self.acceleration.y - self.jumpAccel
    end

    if love.keyboard.isDown("a", "left") then
        self.acceleration.x = -self.moveAccel
    elseif love.keyboard.isDown("d", "right") then
        self.acceleration.x = self.moveAccel
    end

    self.velocity = self.velocity + self.acceleration * dt
    local actualX, actualY, cols, len = game.world:move(self, self.position.x + self.velocity.x*dt, self.position.y + self.velocity.y*dt)

    -- stop player from moving if they hit a wall
    -- horizontal collisions will stop horizontal velocity
    -- vertical collisions will stop vertical velocity
    for k, col in pairs(cols) do
        local other = col.other
        --if other.class and other:isInstanceOf(Pickup) then
            --do thing
        --end
        
        if col.normal.x == -1 or col.normal.x == 1 then
            self.velocity.x = 0
        end
        if col.normal.y == -1 or col.normal.y == 1 then
            self.velocity.y = 0
        end
    end

    self.position = Vector(actualX, actualY)
end

function Player:draw()
    love.graphics.rectangle('fill', self.position.x, self.position.y, self.width, self.height)
end

return Player
