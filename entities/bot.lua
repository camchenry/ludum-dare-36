-- BUG: bot gets crushed after it should be centered on a crusher

local Bot = Class("Bot", Object)

Bot.static.image = love.graphics.newImage("assets/images/Misc/Bot.png")

function Bot:initialize(x, y, w, h, properties)
    Object.initialize(self, x, y, w, h, properties)
    self.name = "Bot"

    self.velocity = Vector(0, 0)
    self.acceleration = Vector(0, 0)

    self.resetPosition = Vector(x, y)

    self.direction         = properties.direction or 1
    self.controlled        = properties.controlled or true
    self.acceptCheckpoint  = properties.acceptCheckpoint or true
    self.directionOverride = properties.directionOverride or true
    self.resettable        = properties.resettable or true

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

function Bot:move(world, tryX, tryY, checkCrush, crush, reference)
    if reference then
        self.newCrusherReference = reference
    end

    if x ~= self.position.x or y ~= self.position.y then
        if checkCrush then
            w, h = self.width, self.height
            local crushed = {}
            if crush then
                crushed.top = crush.top
                crushed.bottom = crush.bottom
                crushed.left = crush.left
                crushed.right = crush.right
            end
            local crushers = {top = "", bottom = "", left = "", right = ""}

            local x, y = tryX, tryY
            if reference then 
                if reference.horizontal then
                    y = self.position.y
                else
                    x = self.position.x
                end
            end

            if not crush or crush.bottom then
                local itemsTop, lenTop = world:querySegment(x, y, x+w, y, function(item)
                    if not item.class or item.collidable then
                        return true
                    end

                    return false
                end)

                crushed.top = lenTop > 0
                crushers.top = itemsTop[1]
            end

            if not crush or crush.top then
                --if crush and crush.top then error(Inspect(crush)..'\n'..Inspect(crushed)..'\n'..Inspect(thing)) end
                local itemsBottom, lenBottom = world:querySegment(x, y+h, x+w, y+h, function(item)
                    if not item.class or item.collidable then
                        return true
                    end

                    return false
                end)

                crushed.bottom = lenBottom > 0
                crushers.bottom = itemsBottom[1]
            end

            if not crush or crush.right then
                local itemsLeft, lenLeft = world:querySegment(x, y, x, y+h, function(item)
                    if not item.class or item.collidable then
                        return true
                    end

                    return false
                end)

                crushed.left = lenLeft > 0
                crushers.left = itemsLeft[1]
            end
            
            if not crush or crush.left then
                local itemsRight, lenRight = world:querySegment(x+w, y, x+w, y+h, function(item)
                    if not item.class or item.collidable then
                        return true
                    end

                    return false
                end)

                crushed.right = lenRight > 0
                crushers.right = itemsRight[1]
            end

            -- potential issue here. if the postion x y has already been chosen by bump, then they are coordinates for a location already safe from crushing
            -- this evaluates collisions between the current position and the desired position
            local actualX, actualY, cols = world:check(self, tryX, tryY, function(item, other)
                if not other.class or other.collidable then
                    return "slide"
                end

                return false
            end)


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
            self.position.x, self.position.y = tryX, tryY
            world:update(self, self.position.x, self.position.y)
        end
    end
end

function Bot:kill()
    self.dead = true
end

function Bot:reset(world)
    if self.resettable then
        self.position = Vector(self.resetPosition.x, self.resetPosition.y)
        game.world:update(self, self.resetPosition.x, self.resetPosition.y)
        self.startTimer = 5
        self.acceleration = Vector(0, 0)
        self.velocity = Vector(0, 0)
    end
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

    local changePos = true

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
            changePos = false
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

    local prevPosition = Vector(self.position.x, self.position.y)

    if changePos then
        self:move(world, actualX, actualY)
    end

    if self.startTimer <= 0 and (self.position - prevPosition):len() > (newPos - prevPosition):len() then
        -- GET CRUSHED!
        game:resetToCheckpoint()
        Signal.emit("botDeath")
    end

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
            if not item.finishedMovement and item.moving and not item.horizontal then
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
        self.animation:draw(Bot.image, math.floor(self.position.x), math.floor(self.position.y-1+0.5))
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