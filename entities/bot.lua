-- BUG: bot gets crushed after it should be centered on a crusher

local Bot = Class("Bot", Object)

Bot.static.image = love.graphics.newImage("assets/images/Misc/Bot.png")

function Bot:initialize(x, y, w, h, properties)
    Object.initialize(self, x, y, w, h, properties)
    self.name = "Bot"

    self.velocity = Vector(0, 0)
    self.acceleration = Vector(0, 0)

    self.resetPosition = Vector(x, y)

    self.direction = properties.direction or 1
    self.controlled = properties.controlled or true
    self.acceptCheckpoint = properties.acceptCheckpoint or true
    self.directionOverride = properties.directionOverride or true

    self.animationTime = 0.3

    self.prevX = x

    local g = Anim8.newGrid(16, 16, Bot.image:getWidth(), Bot.image:getHeight())
    self.animation = Anim8.newAnimation(g('1-2', 1), self.animationTime)

    self.gravity = 160
    self.speed = 15

    self.pushable = true

    self.movement = true
    self.dead = false

    self.crusherReference = nil
    self.crusherTimer = 0
    self.crusherTime = 0.3

    self.startTimer = 5
end

function Bot:move(world, x, y, checkCrush, crush, reference)
    if reference then
        self.newCrusherReference = reference
    end

    if x ~= self.position.x or y ~= self.position.y then
        if checkCrush then
            -- potential issue here. if the postion x y has already been chosen by bump, then they are coordinates for a location already safe from crushing
            -- this evaluates collisions between the current position and the desired position
            local actualX, actualY, cols = world:check(self, x, y, function(item, other)
                if not other.class or other.collidable then
                    return "slide"
                end

                return false
            end)

            local crushed = crush or {}
            local crushers = {top = "", bottom = "", left = "", right = ""}

            for k, col in pairs(cols) do
                local other = col.other
                
                if not other.class or other.collidable then
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

    if self.newCrusherReference and not self.newCrusherReference.horizontal then
        newPos.y = self.newCrusherReference.position.y - self.height
        self.velocity.y = 0
        self.touchingGround = true
    end

    local actualX, actualY, cols, len = world:check(self, newPos.x, newPos.y, function(item, other)
        if other.class and other:isInstanceOf(Spikes) then
            return "cross"
        end

        if not other.class or other.collidable then
            return "slide"
        end

        return false
    end)

    for k, col in pairs(cols) do
        local other = col.other
        if other.class and other:isInstanceOf(Spikes) then
            if self.startTimer <= 0 then
                game:resetToCheckpoint()
            else
                self:reset(world)
            end
        elseif other.class and other:isInstanceOf(NewCrusher) then
            if col.normal.y == -1 or col.normal.y == 1 then

                if self.position.y <= other.position.y + other.height/2 then
                else
                    -- hitting the crusher from underneath
                    -- if velocity is negavitive, make it 0. otherwise keep the current velocity
                    -- this is intended to make the player begin to fall as soon as they hit a crusher from underneath
                    self.velocity.y = math.max(0, self.velocity.y)
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

    self.crusherTimer = math.max(0, self.crusherTimer - dt)
    self.startTimer = math.max(0, self.startTimer - dt)

    self.animation:update(dt)

    self.prevNewCrusherReference = self.newCrusherReference
    self.newCrusherReference = nil

    self:checkFootBox(world)
end

function Bot:checkFootBox(world)
    local items, len = world:queryRect(self.position.x, self.position.y+self.height, self.width, 1)
    for k, item in pairs(items) do
        if item.class and item:isInstanceOf(NewCrusher) then
            self.newCrusherReference = item
            local x = self.position.x
            local y = item.position.y - self.height

            -- center the bot on the crusher
            if not item.finishedMovement and item.moving then
                x = item.position.x + item.width/2 - self.width/2
            end

            self:move(world, x, y, true)
            self.velocity.y = 0
            self.touchingGround = true
        end
    end
end

function Bot:draw(debugOverride)
    Object.draw(self, debugOverride)
    
    love.graphics.setColor(255, 255, 255)

    if not self.dead then
        self.animation:draw(Bot.image, math.floor(self.position.x), math.floor(self.position.y-1))
    end
end

function Bot:drawDebug(x, y)
    local propertyStrings = {
        "Direction: " .. self.direction,
        "Controlled: " .. (self.controlled and "true" or "false"),
        "Accept Checkpoint: " .. (self.acceptCheckpoint and "true" or "false"),
        "Direction Override: " .. (self.directionOverride and "true" or "false"),
    }

    Object.drawDebug(self, x, y, propertyStrings)
end

return Bot