Enemy = Class("Enemy")

function Enemy:initialize(x, y, direction, movement, right, jumping, jumpInterval, jumpAccel)
    self.width, self.height = 32, 16
    self.startPosition = Vector(x, y)
    self.position = Vector(x, y)

    self.direction    = tonumber(direction) or 1
    self.right        = tonumber(right) or 0
    self.jumpInterval = tonumber(jumpInterval) or 0
    self.jumpAccel    = tonumber(jumpAccel) or 0

    if movement and movement == "true" then
        self.movement = true
    else
        self.movement = false
    end
    if jumping and jumping == "true" then
        self.jumping = true
    else
        self.jumping = false
    end

    self.visible = true

    self.speed = 25
    self.gravity = 160
    self.acceleration = Vector(0, 0)
    self.velocity = Vector(0, 0)
    self.jumpTimer = self.jumpInterval

    self.image = love.graphics.newImage("assets/images/Enemy/Bug.png")
    self.imageOffset = Vector(-self.image:getWidth()/2 + 16, -self.image:getHeight()/2 - 16)
end

function Enemy:update(dt, world)
    self.acceleration = Vector(0, self.gravity)

    local newPos = Vector(self.position.x, self.position.y)

    if self.movement then
        if self.direction == -1 then
            local distance = self.startPosition.x + self.right - self.position.x
            if distance > 0 then
                newPos.x = math.min(self.startPosition.x + self.right, self.position.x + self.speed*dt)
            elseif distance <= 0 then
                self.direction = self.direction * -1
            end
        elseif self.direction == 1 then
            local distance = self.position.x - self.startPosition.x
            if distance > 0 then
                newPos.x = math.max(self.startPosition.x, self.position.x - self.speed*dt)
            elseif distance <= 0 then
                self.direction = self.direction * -1
            end
        end
    end

    if self.jumping then
        if self.jumpTimer <= 0 then
            self.jumpTimer = self.jumpInterval
            self.acceleration.y = -self.jumpAccel
        end

        self.jumpTimer = math.max(0, self.jumpTimer - dt)
    end

    self.velocity = self.velocity + self.acceleration*dt

    self.position = newPos + self.velocity*dt

    local actualX, actualY, cols, len = game.world:move(self, self.position.x, self.position.y, function(item, other)
        if other.class and other:isInstanceOf(Player) then
            return "cross"
        end
        if other.class and other:isInstanceOf(Enemy) then
            return nil
        end
        return "slide"
    end)

    for k, col in pairs(cols) do
        local other = col.other
        if other.class and other:isInstanceOf(Wrench) then

        else
            if col.normal.y == -1 then
                self.velocity.y = 0
            end
        end
    end

    self.position = Vector(actualX, actualY)
end

function Enemy:draw()
    love.graphics.setColor(255, 255, 255)

    if self.visible then
        love.graphics.draw(self.image, self.position.x + self.imageOffset.x, self.position.y + self.imageOffset.y)
    end

    if DEBUG then
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle('line', self.position.x + 0.5, self.position.y + 0.5, self.width - 0.5, self.height - 0.5)
    end

    love.graphics.setColor(255, 255, 255)
end

function Enemy:hit()
    -- keep the enemy loaded, just make them invisible
    -- they will need to be restored if you return to a checkpoint
    self.visible = false
end

return Enemy