local Bot = Class("Bot")

function Bot:initialize(x, y)
    self.width, self.height = 15, 15

    self.position = Vector(x, y)
    self.velocity = Vector(0, 0)
    self.acceleration = Vector(0, 0)

    self.resetPosition = Vector(x, y)

    self.prevX = x

    self.image = love.graphics.newImage("assets/images/Misc/Bot.png")

    self.gravity = 160
    self.direction = 1
    self.speed = 15

    self.movement = true
    self.dead = false

    self.crusherReference = nil
    self.crusherTimer = 0
    self.crusherTime = 0.3
end

function Bot:reset(world)
    self.position = Vector(self.resetPosition.x, self.resetPosition.y)
    world:update(self, self.position.x, self.position.y)
end

function Bot:update(dt, world)
    self.acceleration = Vector(0, self.gravity)

    local newPos = Vector(self.position.x, self.position.y)

    if self.movement and not self.dead then
        if self.direction == -1 then
            newPos.x = self.position.x + self.speed*dt
        elseif self.direction == 1 then
            newPos.x = self.position.x - self.speed*dt
        end
    end

    self.velocity = self.velocity + self.acceleration*dt

    self.position = newPos + self.velocity*dt

    local actualX, actualY, cols, len = game.world:check(self, self.position.x, self.position.y, function(item, other)
        if other.class and other:isInstanceOf(Player) then
            return false
        end
        if other.class and other:isInstanceOf(Spikes) then
            return "cross"
        end
        if other.class and other:isInstanceOf(Checkpoint) then
            self.resetPosition = Vector(other.position.x + other.width/2, other.position.y)
            return false
        end
        return "slide"
    end)

    if self.crusherReference then
        if self.crusherReference.botDir ~= 0 then
            --self.direction = self.crusherReference.botDir
        end

        if self.crusherTimer == 0 then
            self.crusherReference = nil
        end
    end

    for k, col in pairs(cols) do
        local other = col.other
        if other.class and other:isInstanceOf(Crusher) then
            if col.normal.y == -1 then
                self.touchingGround = true
                self.velocity.y = 0
                self.crusherReference = other
                self.crusherTimer = self.crusherTime
            elseif col.normal.y == 1 then
                self.velocity.y = 0
                self.crusherReference = other
            end
            if other.botDir ~= 0 then
                --self.direction = other.botDir
            end
        elseif other.class and other:isInstanceOf(Spikes) then
            self:reset(world)
        elseif other.class and other:isInstanceOf(Checkpoint) then
            self.resetPosition = Vector(other.position.x + other.width/2, other.position.y)
        end

        if math.abs(col.normal.x) == 1 then
            self.direction = self.direction * -1
        elseif col.normal.y == -1 then
            self.velocity.y = 0
        end
    end

    if self.crusherReference and self.crusherReference.crushing and (not self.crusherReference.open or (self.crusherReference.open and self.crusherReference.canClose)) then
        if not self.crusherReference.hasMoved then
            -- move crusher first
            self.crusherReference:update(dt, world, true)
        end

        newPos.x = self.crusherReference.position.x + self.crusherReference.width/2 - self.width/2
        newPos.y = self.crusherReference.position.y - self.height

        if self.crusherReference.direction == "up" then
            newPos.y = self.crusherReference.position.y + self.crusherReference.height + self.velocity.y * dt + 5
        end

        --if math.abs(newPos.y - self.position.y) > self.height/2 or math.abs(self.prevX - self.position.x) > self.width/2 then
        --    -- death by crushed
        --    game:resetToCheckpoint()
        --    changePos = false
        --    error('botDeath')
        --end

        self.prevX = self.position.x

        world:update(self, newPos.x, newPos.y)
        self.position = Vector(newPos.x, newPos.y)
    else

        local actualX, actualY, cols, len = game.world:move(self, self.position.x, self.position.y, function(item, other)
            if other.class and other:isInstanceOf(Player) then
                return "cross"
            end
            if other.class and other:isInstanceOf(Enemy) then
                return nil
            end
            if other.class and other:isInstanceOf(Console) then
                return nil
            end
            if other.class and other:isInstanceOf(Spikes) then
                return false
            end
            if other.class and other:isInstanceOf(Checkpoint) then
                return false
            end
                return "slide"
            end)

        self.prevX = self.position.x

        self.position = Vector(actualX, actualY)
    end

    self.crusherTimer = math.max(0, self.crusherTimer - dt)
end

function Bot:draw()
    if DEBUG then
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle('line', self.position.x, self.position.y, self.width, self.height)
    end
    love.graphics.setColor(255, 255, 255)

    if DEBUG and self.crusherReference then
        love.graphics.setColor(0, 255, 255)
    end

    love.graphics.draw(self.image, math.floor(self.position.x), math.floor(self.position.y-1))
end

return Bot