local MovingPlatform = Class("MovingPlatform")

function MovingPlatform:initialize(x, y, w, h, properties)
    self.position = Vector(x, y)
    self.width = w
    self.height = h
    self.image = nil
    self.color = {255, 255, 255, 255}

    self.leftMargin = properties.left or 3
    self.rightMargin = properties.right or 3
    self.topMargin = properties.top or 3
    self.bottomMargin = properties.bottom or 3

    self.startX = x
    self.startY = y
    self.minX = self.startX - w * self.leftMargin
    self.maxX = self.startX + w * self.rightMargin
    self.minY = self.startY - h * self.topMargin
    self.maxY = self.startY + h * self.bottomMargin

    self.speed = properties.speed or 50
    self.dirX = properties.dirX or 0
    self.dirY = properties.dirY or 0
end

function MovingPlatform:update(dt, world)
    if self.dirX ~= 0 then
        if self.position.x > self.maxX then
            self.dirX = -1
        end
        if self.position.x < self.minX then
            self.dirX = 1
        end
    end

    if self.dirY ~= 0 then
        if self.position.y > self.maxY then
            self.dirY = -1
        end

        if self.position.y < self.minY then
            self.dirY = 1
        end
    end

    local goalX = self.position.x + self.speed * dt * self.dirX
    local goalY = self.position.y + self.speed * dt * self.dirY

    -- do a check of what the platform would hit. move the player first if it would hit a player
    local actualX, actualY, collisions, len = world:check(self, goalX, goalY)

    -- now move the platform
    local actualX, actualY, collisions = world:move(self, goalX, goalY, function(item, other)
        if other.isInstanceOf and other:isInstanceOf(Player) then
            return "slide"
        end

        return "cross"
    end)

    self.position.x, self.position.y = actualX, actualY
end

function MovingPlatform:draw()
    love.graphics.setColor(255, 0, 255)
    love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height)
    -- love.graphics.draw(self.image, self.position.x, self.position.y, 0, self.width/32, self.height/32)
    love.graphics.setColor(255, 255, 255)
end

return MovingPlatform
