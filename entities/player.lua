local Player = Class("Player", Object)

function Player:initialize(x, y, w, h, properties)
    self.width, self.height = 13, 31

    Object.initialize(self, x, y, self.width, self.height, properties)
    self.name = "Player"

    self.position = Vector(x, y)
    self.resetPosition = Vector(x, y)
    self.velocity = Vector(0, 0)
    self.acceleration = Vector(0, 0)

    self.prevX = x

    self.gravity = 600
    self.velMax = 75
    self.moveVel = 65
    self.jumpAccel = 300
    self.jumpBurst = 250
    self.jumpHoldGravityReduction = 0.5

    self.jumpTime = 0.2
    self.jumpTimer = 0
    self.jumpState = false
    self.canJump = true
    self.startedJump = false

    self.touchingGround = false
    self.onPlatform = false

    self.prevGround = false
    self.prevCeil = false
    self.prevWall = false

    self.wrenchPower = false

    self.attackTimer = 0
    self.attackTime = 0.5

    self.crusherTouchTimer = 0
    self.crusherTouchTime = 0.2

    self.lastJumpTimer = 0
    self.lastJumpTime = 0.4

    self.foundTimer = 0
    self.foundTime = 1.2

    self.footstepTimer = 0

    self.touchedNewCrusher = false
    self.prevTouchedNewCrusher = false
    self.jumpControlTime = 0.3
    self.jumpControlTimer = 0

    self.newCrusherReference = nil

    self.actionDelay = 0.0

    self.facing = -1

    self.teleportedTime = 1
    self.teleportedTimer = 0

    self.idleImage = love.graphics.newImage("assets/images/Hero/Hero_Idle.png")
    self.jumpImage = love.graphics.newImage("assets/images/Hero/Hero_Jump.png")

    self.imageOffset = Vector(-18, -14)
    self.runImageOffset = Vector(0, -3)
    self.attackImageOffset = Vector(0, 0)

    self.runImage = love.graphics.newImage("assets/images/Hero/Hero_Run.png")
    local g = Anim8.newGrid(48, 48, self.runImage:getWidth(), self.runImage:getHeight())
    self.runAnimation = Anim8.newAnimation(g('1-8', 1), 0.110)

    self.attackImage = love.graphics.newImage("assets/images/Hero/Hero_WrenchAttack.png")
    local g = Anim8.newGrid(45, 45, self.attackImage:getWidth(), self.attackImage:getHeight())
    self.attackAnimation = Anim8.newAnimation(g('1-5', 1), self.attackTime/5)

    self.foundImage = love.graphics.newImage("assets/images/Hero/Hero_FoundWrench.png")
    local g = Anim8.newGrid(45, 45, self.foundImage:getWidth(), self.foundImage:getHeight())
    self.foundAnimation = Anim8.newAnimation(g('1-10', 1), self.foundTime/10)

    self.attackBoxOffset = Vector(20, 5)
    self.attackBoxSize = Vector(20, 25)

    self.lastCrush = {}
    self.lastNormals = {}

    self.collidable = false
    self.pushable = true
    self.acceptCheckpoint = true

    self.augments = {red = false, green = false, blue = false}
end

function Player:reset(world)
    self.position = Vector(self.resetPosition.x, self.resetPosition.y)
    world:update(self, self.resetPosition.x, self.resetPosition.y)
    self.acceleration = Vector(0, 0)
    self.velocity = Vector(0, 0)
    self.jumpTimer = 0
    self.crusherReference = nil
    self.lastCrusherReference = nil
    self.crusherTouchTimer = 0
    self.jumpState = false
    self.canJump = false
    self.startedJump = false
    self.touchingGround = false
end

function Player:keypressed(key)
    if key == "z" or key == "return" then
        self:doAction()
    end
end

function Player:doAction()
    -- check if the player is colliding with a lever

    if self.wrenchPower and self.touchingGround and self.attackTimer == 0 and self.foundTimer == 0 then
        self.attackTimer = self.attackTime
        self.attackAnimation:gotoFrame(1)


        Flux.to(self, self.actionDelay, {}):oncomplete(function()
            local offset = 0
            if self.facing == -1 then
                offset = -8
            end
            local x, y = math.floor(self.position.x-self.attackBoxOffset.x*self.facing+offset+1), math.floor(self.position.y+0.5+1+self.attackBoxOffset.y)
            local items, len = self.world:queryRect(x, y, self.attackBoxSize.x, self.attackBoxSize.y)
            local didHit = false
            for k, item in pairs(items) do
                if item.class and item:isInstanceOf(Enemy) then
                    didHit = item:hit()
                end
                if item.class and item:isInstanceOf(Lever) then
                    didHit = item:hit()
                end
            end
            if not didHit then
                Signal.emit('wrenchSwing')
            end
        end)
    end

end

function Player:move(world, tryX, tryY, checkCrush, crush, reference)
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
                    Signal.emit("playerDeath")
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

function Player:updateJump(isUp, isDown, dt)
    if self.touchedNewCrusher or self.newCrusherReference or self.prevNewCrusherReference then
        self.canJump = true
    end

    if (isUp and not isDown) and self.attackTimer == 0 and self.foundTimer == 0 then
        if not self.jumpState then
            self.jumpTimer = math.min(self.jumpTime, self.jumpTimer + dt)
            -- gravity is reduced while holding a jump
            -- this makes jumps higher if you hold longer
            self.acceleration.y = self.acceleration.y * self.jumpHoldGravityReduction
        else
            self.jumpTimer = math.max(0, self.jumpTimer - dt)
        end

        if self.jumpTimer > 0 and self.canJump then
            -- add an initial large jump acceleration on the first frame
            -- add a smaller amount for subsequent frames
            -- even a small jump will give a large jump, but it can still be held for a bigger jump
            if not self.startedJump then
                self.velocity.y = -self.jumpBurst
                self.lastJumpTimer = self.lastJumpTime
                Signal.emit("startJump")
                self.jumpControlTimer = self.jumpControlTime
            end

            -- we jumped, we are no longer on a platform
            if self.onPlatform then
                self.onPlatform = false
                self.attachedPlatform = nil
            end
        end

        self.startedJump = true
    else
        self.jumpState = false
        self.canJump = false
        self.startedJump = false
    end

    if self.jumpTimer >= self.jumpTime then
        self.jumpState = true
        self.canJump = false
    elseif self.jumpTimer == 0 then
        self.jumpState = false
    end
end

function Player:update(dt, world)
    self.world = world
    self.acceleration = Vector(0, self.gravity)

    local isLeft, isRight = love.keyboard.isDown("a", "left"), love.keyboard.isDown("d", "right")
    local isUp, isDown    = love.keyboard.isDown("w", "up", "space"), love.keyboard.isDown("s", "down")

    self:updateJump(isUp, isDown, dt)
    
    self.canMove = (not isLeft == isRight) and self.attackTimer == 0 and self.foundTimer == 0

    if isLeft == isRight or self.attackTimer > 0 or self.foundTimer > 0 then
        self.velocity.x = 0
    elseif isLeft then
        if self.velocity.x == 0 then
            self.runAnimation:gotoFrame(1)
            Signal.emit("beginRun")
        end
        self.velocity.x = -self.moveVel
        self.facing = 1
        self.onPlatform = false
    elseif isRight then
        if self.velocity.x == 0 then
            self.runAnimation:gotoFrame(1)
            Signal.emit("beginRun")
        end
        self.velocity.x = self.moveVel
        self.facing = -1
        self.onPlatform = false
    end

    if self.onPlatform then
        self.velocity.x = self.attachedPlatform.velocity.x
    end

    self.velocity = self.velocity + self.acceleration*dt
    local newPos = self.position + self.velocity * dt 

    local changePos = true
    self.touchingGround = false

    local hitGround, hitCeil, hitWall = false, false, false

    local crushed = {}

    if self.newCrusherReference and self.jumpControlTimer <= 0 and not self.newCrusherReference.horizontal then
        newPos.y = self.newCrusherReference.position.y - self.height
        self.velocity.y = 0
        self.touchingGround = true
    end

    local actualX, actualY, cols, len = self.world:check(self, newPos.x, newPos.y, function(item, other)
        if other.class and other:isInstanceOf(Wrench) then
            return "cross"
        end
        if other.class and other:isInstanceOf(Enemy) then
            return "cross"
        end
        if other.class and other:isInstanceOf(Gate) then
            if other.width > 2 and other.height > 2 then
                return "slide"
            else
                return false
            end
        end

        if other.class and other:isInstanceOf(Spikes) then
            return "cross"
        end

        local offset = 0
        if item.velocity.y > 0 then
            offset = -5
        elseif item.velocity.y < 0 then
            offset = 5
        end

        if other.class and other:isInstanceOf(Dropfloor) and ((isUp and isDown) or (item.position.y + item.height + offset > other.position.y) or (item.velocity.y > 0 and item.position.y + item.height > other.position.y)) then
            return false
        end

        if not other.class or other.collidable then
            return "slide"
        end

        return false
    end)

    -- stop player from moving if they hit a wall
    -- horizontal collisions will stop horizontal velocity
    -- vertical collisions will stop vertical velocity
    for k, col in pairs(cols) do
        local other = col.other

        if other.class and other:isInstanceOf(Wrench) then
            if not self.wrenchPower then
                self.wrenchPower = true
                other:activate()
                Signal.emit("getWrench")
                self.foundAnimation:gotoFrame(1)
                self.foundTimer = self.foundTime
            end
        elseif other.class and other:isInstanceOf(Enemy) then
            if other.visible and other.alive then
                -- return to last checkpoint
                -- revive any enemies that have died since the last checkpoint
                -- return any moving platforms and levers to their state before the last checkpoint
                game:resetToCheckpoint()
                changePos = false
                Signal.emit("playerDeath")
            end
        elseif other.class and other:isInstanceOf(MovingPlatform) then
            if col.normal.y == -1 then
                self.onPlatform = true
                self.attachedPlatform = other
                self.jumpTimer = 0
                self.jumpState = false
                self.canJump = true
                self.touchingGround = true
                self.velocity.y = 0
            end
        elseif other.class and other:isInstanceOf(Spikes) then
            game:resetToCheckpoint()
            changePos = false
            Signal.emit("playerDeath")
        elseif other.class and other:isInstanceOf(NewCrusher) then
            if col.normal.y == -1 or col.normal.y == 1 then
                if self.position.y <= other.position.y + other.height/2 then
                    Signal.emit("hitGround")
                else
                    -- hitting the crusher from underneath
                    -- if velocity is negavitive, make it 0. otherwise keep the current velocity
                    -- this is intended to make the player begin to fall as soon as they hit a crusher from underneath
                    self.velocity.y = math.max(0, self.velocity.y)

                    self.jumpTimer = 0
                    self.canJump = false
                    self.jumpState = false
                    Signal.emit("hitCeiling")
                end
            end
            if col.normal.x == -1 or col.normal.x == 1 then
                self.velocity.x = 0
                if not self.prevWall then
                    self.prevWall = true
                    Signal.emit("hitWall")
                end
                hitWall = true
            end
        else
            if col.normal.x == -1 or col.normal.x == 1 then
                self.velocity.x = 0
                if not self.prevWall then
                    self.prevWall = true
                    Signal.emit("hitWall")
                end
                hitWall = true
            end
            if col.normal.y == -1 or col.normal.y == 1 then
                self.velocity.y = 0
            end
            if col.normal.y == -1 then
                -- allow the player to jump again once they hit the ground
                self.jumpTimer = 0
                self.jumpState = false
                self.canJump = true
                self.touchingGround = true
                hitGround = true
            end
            if col.normal.y == 1 then
                if not self.prevCeil then
                    self.prevCeil = true
                    Signal.emit("hitCeiling")
                end
                hitCeil = true
            end
        end
    end

    if hitGround and not self.prevGround then
        Signal.emit("hitGround")
    end

    self.prevGround = hitGround
    self.prevCeil = hitCeil
    self.prevWall = hitWall

    self.prevX = self.position.x
    local prevPosition = Vector(self.position.x, self.position.y)

    if changePos then
        self:move(world, actualX, actualY)
    end

    if self.teleportedTimer <= 0 and (self.position - prevPosition):len() > (newPos - prevPosition):len() then
        -- GET CRUSHED!
        game:resetToCheckpoint()
        Signal.emit("playerDeath")
    end

    self.attackTimer = math.max(0, self.attackTimer - dt)
    self.crusherTouchTimer = math.max(0, self.crusherTouchTimer - dt)
    self.lastJumpTimer = math.max(0, self.lastJumpTimer - dt)
    self.foundTimer = math.max(0, self.foundTimer - dt)
    self.teleportedTimer = math.max(0, self.teleportedTimer - dt)
    self.jumpControlTimer = math.max(0, self.jumpControlTimer - dt)

    self.attackAnimation:update(dt)
    self.foundAnimation:update(dt)

    if self.canMove and not hitWall and self.jumpTimer == 0 and self.touchingGround then
        self.footstepTimer = (self.footstepTimer + dt)
    end

    -- Only emit footstep signal if we are running and in the right frame
    if self.footstepTimer >= 0.4 then
        self.footstepTimer = 0
        Signal.emit("playerFootstep")
    end

    self.prevTouchedNewCrusher = self.touchedNewCrusher
    self.touchedNewCrusher = false


    self.prevNewCrusherReference = self.newCrusherReference
    self.newCrusherReference = nil

    self:checkFootBox(world)

    -- Don't update the run animation if we aren't actually able to run
    if self.touchingGround then
        self.runAnimation:update(dt)
    else
        self.runAnimation:gotoFrame(1)
    end
end

function Player:checkFootBox(world)
    local items, len = world:queryRect(self.position.x, self.position.y+self.height, self.width, 1, function(item)
        if not item.class or (item.class and not item:isInstanceOf(Player) and item.collidable) then
            return true
        end
        return false
    end)

    for k, item in pairs(items) do
        if item.class and item:isInstanceOf(NewCrusher) then
            if self.jumpControlTimer <= 0 then
                if len == 1 then
                    local y = item.position.y - self.height
                    self:move(world, self.position.x, y, false)
                end
                self.newCrusherReference = item
                self.velocity.y = 0
                self.touchingGround = true
                self.jumpTimer = 0
            end
        end
    end

    self.lastLen = len
end

function Player:draw()
    Object.draw(self, 0.5, 0.5)
    
    if DEBUG and DRAW_ATTACKBOX then
        love.graphics.setColor(0, 0, 255)
        local offset = 0
        if self.facing == -1 then
            offset = -8
        end
        love.graphics.setLineWidth(1)
        love.graphics.rectangle('line', math.floor(self.position.x+0.5+1-self.attackBoxOffset.x*self.facing+offset), math.floor(self.position.y+0.5+1+self.attackBoxOffset.y), self.attackBoxSize.x, self.attackBoxSize.y)
    end
    love.graphics.setColor(255, 255, 255)

    local offset = 0
    if self.facing == -1 then
        offset = 13
    end

    local image = self.idleImage

    if (self.jumpTimer > 0 or not self.canJump) and self.crusherTouchTimer <= 0 and not self.crusherReference and not self.prevTouchedNewCrusher and not self.prevNewCrusherReference and not self.touchingGround and not self.newCrusherReference then
        image = self.jumpImage
    end

    local x, y = math.floor(self.position.x + self.imageOffset.x*self.facing + offset + 0.5), math.floor(self.position.y + self.imageOffset.y + 0.5)

    if self.foundTimer > 0 then
        self.foundAnimation:draw(self.foundImage, x + self.attackImageOffset.x, y + self.attackImageOffset.y, 0, self.facing, 1)
    elseif self.attackTimer > 0 then
        self.attackAnimation:draw(self.attackImage, x + self.attackImageOffset.x, y + self.attackImageOffset.y, 0, self.facing, 1)
    elseif self.velocity.x == 0 or not self.touchingGround and not self.prevNewCrusherReference then
        love.graphics.draw(image, x, y, 0, self.facing, 1)
    else
        self.runAnimation:draw(self.runImage, x + self.runImageOffset.x, y + self.runImageOffset.y, 0, self.facing, 1)
    end

    -- love.graphics.setLineWidth(1)

    -- local f = 5
    -- local sep = 5
    -- local s = 5

    -- local x, y = self.position.x + self.width/2 + 0.5, self.position.y - f - s/2 + 0.5
    -- if self.augments.red then
    --     love.graphics.setColor(255, 0, 0)
    --     love.graphics.rectangle('fill', x-s/2, y-s/2, s, s)
    -- end
    -- love.graphics.setColor(255, 255, 255)
    -- love.graphics.rectangle('line', x-s/2, y-s/2, s, s)

    -- if self.augments.green then
    --     love.graphics.setColor(0, 255, 0)
    --     love.graphics.rectangle('fill', x-s*3/2-sep, y-s/2, s, s)
    -- end
    -- love.graphics.setColor(255, 255, 255)
    -- love.graphics.rectangle('line', x-s*3/2-sep, y-s/2, s, s)

    -- if self.augments.blue then
    --     love.graphics.setColor(0, 0, 255)
    --     love.graphics.rectangle('fill', x+s/2+sep, y-s/2, s, s)
    -- end
    -- love.graphics.setColor(255, 255, 255)
    -- love.graphics.rectangle('line', x+s/2+sep, y-s/2, s, s)
end

function Player:drawDebug(x, y)
    local propertyStrings = {
        "Last len: " .. self.lastLen,
        "Found Timer: " .. self.foundTimer,
    }

    Object.drawDebug(self, x, y, propertyStrings)
end

return Player
