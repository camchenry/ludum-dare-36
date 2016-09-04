local Bot = Class("Bot")

function Bot:initialize(x, y, w, h, properties)
    self.width, self.height = 15, 15

    self.position = Vector(x, y)
    self.velocity = Vector(0, 0)
    self.acceleration = Vector(0, 0)

    self.resetPosition = Vector(x, y)

    self.noCheckpoint = properties.noCheckpoint

    self.animationTime = 0.3

    self.prevX = x

    self.image = love.graphics.newImage("assets/images/Misc/Bot.png")
    local g = Anim8.newGrid(16, 16, self.image:getWidth(), self.image:getHeight())
    self.animation = Anim8.newAnimation(g('1-2', 1), self.animationTime)

    self.gravity = 160
    self.direction = 1
    self.speed = 15

    self.movement = true
    self.dead = false

    self.crusherReference = nil
    self.crusherTimer = 0
    self.crusherTime = 0.3

    self.startTimer = 5
end

function Bot:move(world, x, y, checkCrush, crush, reference)
    if x ~= self.position.x or y ~= self.position.y then
        if checkCrush then
            -- potential issue here. if the postion x y has already been chosen by bump, then they are coordinates for a location already safe from crushing
            -- this evaluates collisions between the current position and the desired position
            local actualX, actualY, cols = world:check(self, x, y)

            local crushed = crush or {}
            local crushers = {top = "", bottom = "", left = "", right = ""}

            for k, col in pairs(cols) do
                local other = col.other
                
                if not other.class or (other.class and not (other:isInstanceOf(Checkpoint) or other:isInstanceOf(Wrench) or other:isInstanceOf(Enemy) or other:isInstanceOf(Lever) or other:isInstanceOf(Console) or other:isInstanceOf(Bot))) then
                    if col.normal.y == 1 then
                        crushed.top = true
                        crushers.top = other
                    end
                    if col.normal.y == -1 then
                        crushed.bottom = true
                        crushers.bottom = other
                    end
                    if col.normal.x == 1 and self.prevGround then
                        crushed.left = true
                        crushers.left = other
                    end
                    if col.normal.x == -1 and self.prevGround then
                        crushed.right = true
                        crushers.right = other
                    end
                end
            end

            if (crushed.top and crushed.bottom) or (crushed.left and crushed.right) then
                if crushers[1] ~= crushers[2] or (not crushers[1] and not crushers[2]) then
                    -- death by crushed
                    game:resetToCheckpoint()
                    changePos = false
                    Signal.emit("botDeath")
                end
            else
                self.position.x, self.position.y = actualX, actualY
                world:update(self, self.position.x, self.position.y)
            end

            self.lastCrush = crushed
        else
            self.position.x, self.position.y = x, y
            world:update(self, self.position.x, self.position.y)
        end
    end
end

function Bot:kill()
    self.dead = true
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

    local newPos = newPos + self.velocity * dt 

    local actualX, actualY, cols, len = world:check(self, newPos.x, newPos.y, function(item, other)
        if other.class and other:isInstanceOf(Player) then
            return false
        end
        if other.class and other:isInstanceOf(Spikes) then
            return "cross"
        end
        if other.class and other:isInstanceOf(AreaTrigger) then
            return false
        end
        if other.class and other:isInstanceOf(Checkpoint) then
            if not self.noCheckpoint then
                self.resetPosition = Vector(other.position.x + other.width/2, other.position.y)
            end
            return false
        end
        return "slide"
    end)

    for k, col in pairs(cols) do
        local other = col.other
        if other.class and other:isInstanceOf(Spikes) then
            --self:reset(world)
            --game:resetToCheckpoint(true)
            if self.startTimer <= 0 then
                game:resetToCheckpoint()
            else
                self:reset(world)
            end
        elseif other.class and other:isInstanceOf(Checkpoint) then
            self.resetPosition = Vector(other.position.x + other.width/2, other.position.y)
        elseif other.class and other:isInstanceOf(NewCrusher) then
            if col.normal.y == -1 or col.normal.y == 1 then

                if self.position.y <= other.position.y + other.height/2 then
                    -- player is above
                    -- allow the player to jump again once they hit the ground
                    self.jumpTimer = 0
                    self.jumpState = false
                    self.canJump = true
                    self.touchingGround = true
                    if not self.prevGround then
                        self.prevGround = true
                        Signal.emit("hitGround")
                    end
                    hitGround = true

                    self.touchedNewCrusher = true
                    self.touchingGround = true
                    self.velocity.y = 0
                else
                    -- hitting the crusher from underneath
                    -- if velocity is negavitive, make it 0. otherwise keep the current velocity
                    -- this is intended to make the player begin to fall as soon as they hit a crusher from underneath
                    self.velocity.y = math.max(0, self.velocity.y)

                    self.jumpTimer = 0
                    self.canJump = false
                    self.jumpState = false
                end
            end
        end

        if math.abs(col.normal.x) == 1 then
            self.direction = self.direction * -1
        elseif col.normal.y == -1 then
            self.velocity.y = 0
        end
    end

    self:move(world, actualX, actualY)

--[[
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
    ]]

    self.crusherTimer = math.max(0, self.crusherTimer - dt)
    self.startTimer = math.max(0, self.startTimer - dt)

    self.animation:update(dt)
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

    if not self.dead then
        self.animation:draw(self.image, math.floor(self.position.x), math.floor(self.position.y-1))
    end
end

return Bot