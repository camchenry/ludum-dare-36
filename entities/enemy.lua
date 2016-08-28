Enemy = Class("Enemy")

function Enemy:initialize(x, y, properties)
    self.width, self.height = 32, 16
    self.startPosition = Vector(x, y)
    self.position = Vector(x, y)
    self.color = {255, 255, 255, 255}

    self.direction    = tonumber(properties.direction) or 1
    self.right        = tonumber(properties.right) or 0
    self.jumpInterval = tonumber(properties.jumpInterval) or 0
    self.jumpAccel    = tonumber(properties.jumpAccel) or 0

    self.startDirection = self.direction

    if properties.movement and properties.movement == "true" then
        self.movement = true
    else
        self.movement = false
    end
    if properties.jumping and properties.jumping == "true" then
        self.jumping = true
    else
        self.jumping = false
    end

    self.visible = true
    self.dead = false

    self.hitColorTime = 0.1
    self.fallAmount = 500
    self.fallTime = 2

    self.speed = 25
    self.gravity = 160
    self.acceleration = Vector(0, 0)
    self.velocity = Vector(0, 0)
    self.jumpTimer = self.jumpInterval
    self.fallOffset = 0

    self.image = love.graphics.newImage("assets/images/Enemy/Bug.png")
    self.imageOffset = Vector(16, -self.image:getHeight()/2 - 16)
end

function Enemy:reset()
    self.position = Vector(self.startPosition.x, self.startPosition.y)
    game.world:update(self, self.position.x, self.position.y)
    self.direction = self.startDirection
    self.visible = true
    self.dead = false
    self.fallOffset = 0
    self.acceleration = Vector(0, 0)
    self.velocity = Vector(0, 0)
    self.jumpTimer = self.jumpInterval
end

function Enemy:update(dt, world)
    self.acceleration = Vector(0, self.gravity)

    local newPos = Vector(self.position.x, self.position.y)

    if self.movement and not self.dead then
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

    if self.jumping and not self.dead then
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
            return nil
        end
        if other.class and other:isInstanceOf(Enemy) then
            return nil
        end
        if other.class and other:isInstanceOf(Console) then
            return nil
        end
        return "slide"
    end)

    for k, col in pairs(cols) do
        local other = col.other
        if other.class and other:isInstanceOf(Wrench) then

        else
            if math.abs(col.normal.x) == 1 then
                self.direction = self.direction * -1
            elseif col.normal.y == -1 then
                self.velocity.y = 0
            end
        end
    end

    self.position = Vector(actualX, actualY)
end

function Enemy:draw()
    love.graphics.setColor(255, 255, 255)

    if self.visible then
        love.graphics.setColor(self.color)
        love.graphics.draw(self.image, math.floor(self.position.x + self.imageOffset.x), math.floor(self.position.y + self.imageOffset.y + self.fallOffset), 0, self.direction, 1, self.image:getWidth()/2, 0)
    end

    if DEBUG then
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle('line', math.floor(self.position.x + 0.5), math.floor(self.position.y + 0.5), self.width - 0.5, self.height - 0.5)
    end

    love.graphics.setColor(255, 255, 255)
end

function Enemy:hit()
    -- keep the enemy loaded, just make them invisible
    -- they will need to be restored if you return to a checkpoint
    self.fallOffset = 0
    self.dead = true

    Flux.to(self.color, self.hitColorTime, {255, 0, 0})
        :after(self.hitColorTime, {255, 255, 255})
            :after(self, self.fallTime, {fallOffset = self.fallAmount})
                :oncomplete(function()
                    self.visible = false
                end)
end

return Enemy