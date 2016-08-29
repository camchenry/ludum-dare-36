local Player = Class("Player")

function Player:initialize(x, y)
    self.width, self.height = 13, 31

    self.position = Vector(x, y)
    self.resetPosition = Vector(x, y)
    self.velocity = Vector(0, 0)
    self.acceleration = Vector(0, 0)

    self.prevX = x

    self.gravity = 600
    self.velMax = 75
    self.moveVel = 65
    self.jumpAccel = 300
    self.jumpBurst = 13500

    self.jumpTime = 0.3
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
    self.attackTime = 1

    self.crusherTouchTimer = 0
    self.crusherTouchTime = 0.2

    self.lastJumpTimer = 0
    self.lastJumpTime = 0.4

    self.footstepTimer = 0

    self.crusherReference = nil

    self.actionDelay = 0.7

    self.facing = -1

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

    self.attackBoxOffset = Vector(20, 5)
    self.attackBoxSize = Vector(20, 25)

    self.lastCrush = {}
end

function Player:reset(world)
    self.position = Vector(self.resetPosition.x, self.resetPosition.y)
    world:update(self, self.resetPosition.x, self.resetPosition.y)
    self.acceleration = Vector(0, 0)
    self.velocity = Vector(0, 0)
    self.jumpTimer = 0
end

function Player:keypressed(key)
    if key == "z" or key == "return" then
        self:doAction()
    end
end

function Player:doAction()
    -- check if the player is colliding with a lever

    if self.wrenchPower and self.touchingGround and self.attackTimer == 0 then
        self.attackTimer = self.attackTime
        self.attackAnimation:gotoFrame(1)

        Flux.to(self, self.actionDelay, {}):oncomplete(function()
            local offset = 0
            if self.facing == -1 then
                offset = -8
            end
            local x, y = math.floor(self.position.x-self.attackBoxOffset.x*self.facing+offset+1), math.floor(self.position.y+0.5+1+self.attackBoxOffset.y)
            local items, len = game.world:queryRect(x, y, self.attackBoxSize.x, self.attackBoxSize.y)
            for k, item in pairs(items) do
                if item.class and item:isInstanceOf(Enemy) then
                    item:hit()
                end
                if item.class and item:isInstanceOf(Lever) then
                    item:hit()
                end
            end
        end)
    end
end

function Player:update(dt, world)
    self.acceleration = Vector(0, self.gravity)

    local isLeft, isRight = love.keyboard.isDown("a", "left"), love.keyboard.isDown("d", "right")
    local isUp, isDown    = love.keyboard.isDown("w", "up", "space"), love.keyboard.isDown("s", "down")

    if self.crusherTouchTimer > 0 then
        if self.lastJumpTimer == 0 then
            self.canJump = true
        end
    end

    if (isUp and not isDown) and self.attackTimer == 0 then
        if not self.jumpState then
            self.jumpTimer = math.min(self.jumpTime, self.jumpTimer + dt)
        else
            self.jumpTimer = math.max(0, self.jumpTimer - dt)
        end

        if self.jumpTimer > 0 and self.canJump then
            -- add an initial large jump acceleration on the first frame
            -- add a smaller amount for subsequent frames
            -- even a small jump will give a large jump, but it can still be held for a bigger jump
            if not self.startedJump then
                self.acceleration.y = -self.jumpBurst
                self.lastJumpTimer = self.lastJumpTime
                Signal.emit("startJump")
            else
                -- note that this calculation is fighting against gravity, so it will offer diminishing returns in a way
                self.acceleration.y = self.acceleration.y - self.jumpAccel
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

    self.canMove = (not isLeft == isRight) and self.attackTimer == 0

    if isLeft == isRight or self.attackTimer > 0 then
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

    self.touchingGround = false

    self.velocity = self.velocity + self.acceleration*dt
    self.velocity.x = math.min(self.velMax, self.velocity.x)


    local newPos = self.position + self.velocity * dt 

    local changePos = true

    if self.crusherReference then
        if not self.crusherReference.hasMoved then
            -- move crusher first
            self.crusherReference:update(dt, world, true)

            newPos.y = self.crusherReference.position.y - self.height

            if self.crusherReference.direction == "up" then
                newPos.y = self.crusherReference.position.y + self.crusherReference.height + self.velocity.y * dt + 5
            end

            if math.abs(newPos.y - self.position.y) > self.height/2 or math.abs(self.prevX - self.position.x) > self.width/2 then
                -- death by crushed
                game:resetToCheckpoint()
                changePos = false
                Signal.emit("playerDeath")
                self.attackTimer = 0
            end

            world:update(self, self.position.x, newPos.y)
            self.position.y = newPos.y

        end
        -- move the player to crusher y position
    end


    local hitGround, hitCeil, hitWall = false, false, false

    local crushed = {}

    local actualX, actualY, cols, len = game.world:check(self, newPos.x, newPos.y, function(item, other)
        if other.class and other:isInstanceOf(Wrench) then
            return "cross"
        end
        if other.class and other:isInstanceOf(Enemy) then
            return "cross"
        end
        if other.class and other:isInstanceOf(Checkpoint) then
            return "cross"
        end
        if other.class and other:isInstanceOf(Lever) then
            return false
        end
        if other.class and other:isInstanceOf(Crusher) then
            return "slide"
        end
        if other.class and other:isInstanceOf(Gate) then
            if other.width > 2 and other.height > 2 then
                return "slide"
            else
                return false
            end
        end
        if other.class and other:isInstanceOf(Bot) then
            return "cross"
        end
        if other.class and other:isInstanceOf(Spikes) then
            return "cross"
        end
        if other.class and other:isInstanceOf(AreaTrigger) then
            return false
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
        return "slide"
    end)

    local additionalX, additionalY = 0, 0

    if self.crusherReference then
        self.crusherReference = nil
    end

    -- stop player from moving if they hit a wall
    -- horizontal collisions will stop horizontal velocity
    -- vertical collisions will stop vertical velocity
    for k, col in pairs(cols) do
        local other = col.other
        --if other.class and other:isInstanceOf(Pickup) then
            --do thing
        --end

        if other.class and other:isInstanceOf(Wrench) then
            if not self.wrenchPower then
                self.wrenchPower = true
                other.visible = false
                Signal.emit("getWrench")
            end
        elseif other.class and other:isInstanceOf(Enemy) then
            if other.visible and not other.dead then
                -- return to last checkpoint
                -- revive any enemies that have died since the last checkpoint
                -- return any moving platforms and levers to their state before the last checkpoint
                game:resetToCheckpoint()
                changePos = false
                Signal.emit("playerDeath")
            end
        elseif other.class and other:isInstanceOf(Checkpoint) then
            self.resetPosition = Vector(other.position.x + other.width/2 - self.width/2, other.position.y)
        elseif other.class and other:isInstanceOf(Crusher) then
            if col.normal.y == -1 then
                self.jumpTimer = 0
                self.jumpState = false
                self.canJump = true
                self.touchingGround = true
                self.velocity.y = 0
                self.crusherTouchTimer = self.crusherTouchTime
                self.crusherReference = other
            elseif col.normal.y == 1 then
                self.velocity.y = 0
                if not self.prevCeil then
                    self.prevCeil = true
                    Signal.emit("hitCeiling")
                end
                hitCeil = true
                self.crusherReference = other
            end
        elseif other.class and other:isInstanceOf(Bot) then
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
            self:reset(world)
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
                if not self.prevGround then
                    self.prevGround = true
                    Signal.emit("hitGround")
                end
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

        if not other.class or (other.class and not (other:isInstanceOf(Checkpoint) or other:isInstanceOf(Wrench) or other:isInstanceOf(Enemy) or other:isInstanceOf(Lever) or other:isInstanceOf(Console) or other:isInstanceOf(Bot))) then
            local fine = true

            
            if fine then
                if col.normal.y == 1 then
                    crushed.top = true
                end
                if col.normal.y == -1 then
                    crushed.bottom = true
                end
                if col.normal.x == 1 and self.prevGround then
                    crushed.left = true
                end
                if col.normal.x == -1 and self.prevGround then
                    crushed.right = true
                end
            end
        end
    end

    if math.abs(actualX - self.position.x) > self.width/2 then
        -- death by crushed
        game:resetToCheckpoint()
        changePos = false
        Signal.emit("playerDeath")
    end

    if not hitGround then
        self.prevGround = false
    end
    if not hitCeil then
        self.prevCeil = false
    end
    if not hitWall then
        self.prevWall = false
    end

    if (crushed.top and crushed.bottom) or (crushed.left and crushed.right) then
        -- death by crushed
        game:resetToCheckpoint()
        changePos = false
        Signal.emit("playerDeath")
    end

    self.lastCrush = crushed

    self.prevX = self.position.x

    if changePos then
        --if math.abs(actualY - self.position.y) < self.height then
            self.position = Vector(actualX, actualY)
        --else
        --    self.position = Vector(actualX, self.position.y)
        --end

        world:update(self, self.position.x, self.position.y)
    end

    --self:tryMove(additionalX, additionalY, world) -- not sure why multiplying dt works here
    --self.position.y = self.position.y+1
    --world:update(self, self.position.x, self.position.y)

    self.attackTimer = math.max(0, self.attackTimer - dt)
    self.crusherTouchTimer = math.max(0, self.crusherTouchTimer - dt)
    self.lastJumpTimer = math.max(0, self.lastJumpTimer - dt)

    self.attackAnimation:update(dt)
    -- Don't update the run animation if we aren't actually able to run
    if self.canMove and self.jumpTimer == 0 then
        self.runAnimation:update(dt)
    else
        self.runAnimation:gotoFrame(1)
    end

    
    if self.canMove and self.jumpTimer == 0 and self.touchingGround then
        self.footstepTimer = (self.footstepTimer + dt)
    end

    -- Only emit footstep signal if we are running and in the right frame
    if self.footstepTimer >= 0.4 then
        self.footstepTimer = 0
        Signal.emit("playerFootstep")
    end
end

function Player:tryMove(dx, dy, world, limit)
    local actualX, actualY, collisions = world:move(self, self.position.x + dx, self.position.y + dy, function(item, other)
        if other.class and other:isInstanceOf(Wrench) then
            return "cross"
        end
        if other.class and other:isInstanceOf(Enemy) then
            return "cross"
        end
        if other.class and other:isInstanceOf(Checkpoint) then
            return "cross"
        end
        if other.class and other:isInstanceOf(Lever) then
            return false
        end
        if other.class and other:isInstanceOf(Crusher) then
            return "slide"
        end

        if other.class and other:isInstanceOf(Gate) then
            if other.width == 0 or other.height == 0 then
                return "touch"
            else
                return "touch"
            end
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
        return "slide"
    end)
    if math.abs(actualY - self.position.y) < self.height then
        self.position.x, self.position.y = actualX, actualY
    else
        self.position.x = actualX
    end

    world:update(self, self.position.x, self.position.y)
end

function Player:draw()
    if DEBUG then
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle('line', math.floor(self.position.x+0.5+1), math.floor(self.position.y+0.5+1), self.width-1, self.height-1)

        love.graphics.setColor(0, 0, 255)
        local offset = 0
        if self.facing == -1 then
            offset = -8
        end
        love.graphics.rectangle('line', math.floor(self.position.x+0.5+1-self.attackBoxOffset.x*self.facing+offset), math.floor(self.position.y+0.5+1+self.attackBoxOffset.y), self.attackBoxSize.x, self.attackBoxSize.y)
    end
    love.graphics.setColor(255, 255, 255)

    if DEBUG and self.crusherTouchTimer > 0 then
        love.graphics.setColor(255, 0, 255)
    end

    local offset = 0
    if self.facing == -1 then
        offset = 13
    end

    local image = self.idleImage

    if self.jumpTimer > 0 or not self.canJump and self.crusherTouchTimer == 0 then
        image = self.jumpImage
    end

    local x, y = math.floor(self.position.x + self.imageOffset.x*self.facing + offset + 0.5), math.floor(self.position.y + self.imageOffset.y + 0.5)

    if self.attackTimer > 0 then
        self.attackAnimation:draw(self.attackImage, x + self.attackImageOffset.x, y + self.attackImageOffset.y, 0, self.facing, 1)
    elseif self.velocity.x == 0 or ((not self.touchingGround or self.onPlatform) and self.crusherTouchTimer == 0) then
        love.graphics.draw(image, x, y, 0, self.facing, 1)
    else
        self.runAnimation:draw(self.runImage, x + self.runImageOffset.x, y + self.runImageOffset.y, 0, self.facing, 1)
    end
end

return Player
