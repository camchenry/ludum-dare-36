local Player = Class("Player")

function Player:initialize(x, y)
    self.width, self.height = 13, 35

    self.position = Vector(x, y)
    self.velocity = Vector(0, 0)
    self.acceleration = Vector(0, 0)

    self.gravity = 160
    self.velMax = 70
    self.moveVel = 60
    self.jumpAccel = 100
    self.jumpBurst = 8000

    self.jumpTime = 0.5
    self.jumpTimer = 0
    self.jumpState = false
    self.canJump = true
    self.startedJump = false

    self.touchingGround = false

    self.wrenchPower = false

    self.attackTimer = 0
    self.attackTime = 1

    self.facing = 1

    self.idleImage = love.graphics.newImage("assets/images/Hero/Hero_Idle.png")
    self.jumpImage = love.graphics.newImage("assets/images/Hero/Hero_Jump.png")

    self.imageOffset = Vector(-18, -10)
    self.runImageOffset = Vector(0, -3)
    self.attackImageOffset = Vector(0, 0)

    self.runImage = love.graphics.newImage("assets/images/Hero/Hero_Run.png")
    local g = Anim8.newGrid(48, 48, self.runImage:getWidth(), self.runImage:getHeight())
    self.runAnimation = Anim8.newAnimation(g('1-8', 1), 0.110)

    self.attackImage = love.graphics.newImage("assets/images/Hero/Hero_WrenchAttack.png")
    local g = Anim8.newGrid(45, 45, self.attackImage:getWidth(), self.attackImage:getHeight())
    self.attackAnimation = Anim8.newAnimation(g('1-5', 1), self.attackTime/5)
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
    end
end

function Player:update(dt)
    self.acceleration = Vector(0, self.gravity)

    if love.keyboard.isDown("w", "up", "space") and self.attackTimer == 0 then
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
            else
                -- note that this calculation is fighting against gravity, so it will offer diminishing returns in a way
                self.acceleration.y = self.acceleration.y - self.jumpAccel
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

    local isLeft, isRight = love.keyboard.isDown("a", "left"), love.keyboard.isDown("d", "right")

    if isLeft == isRight or self.attackTimer > 0 then
        self.velocity.x = 0
    elseif isLeft then
        if self.velocity.x == 0 then
            self.runAnimation:gotoFrame(1)
        end
        self.velocity.x = -self.moveVel
        self.facing = 1
    elseif isRight then
        if self.velocity.x == 0 then
            self.runAnimation:gotoFrame(1)
        end
        self.velocity.x = self.moveVel
        self.facing = -1
    end

    self.touchingGround = false

    self.velocity = self.velocity + self.acceleration * dt
    self.velocity.x = math.min(self.velMax, self.velocity.x)
    local actualX, actualY, cols, len = game.world:move(self, self.position.x + self.velocity.x*dt, self.position.y + self.velocity.y*dt, function(item, other)
        if other.class and other:isInstanceOf(Wrench) then
            return "cross"
        end
        if other.class and other:isInstanceOf(Enemy) then
            return "cross"
        end
        return "slide"
    end)

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
            end
        elseif other.class and other:isInstanceOf(Enemy) then
            -- return to last checkpoint
            -- revive any enemies that have died since the last checkpoint
            -- return any moving platforms and levers to their state before the last checkpoint
        else
            if col.normal.x == -1 or col.normal.x == 1 then
                self.velocity.x = 0
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
            end
        end
    end

    self.position = Vector(actualX, actualY)

    self.attackTimer = math.max(0, self.attackTimer - dt)
    self.attackAnimation:update(dt)
    self.runAnimation:update(dt)
end

function Player:draw()
    if DEBUG then
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle('line', math.floor(self.position.x+0.5+1), math.floor(self.position.y+0.5+1), self.width-1, self.height-1)
    end
    love.graphics.setColor(255, 255, 255)

    local offset = 0
    if self.facing == -1 then
        offset = 13
    end

    local image = self.idleImage

    if self.jumpTimer > 0 or not self.canJump then
        image = self.jumpImage
    end

    local x, y = math.floor(self.position.x + self.imageOffset.x*self.facing + offset + 0.5), math.floor(self.position.y + self.imageOffset.y + 0.5)

    if self.attackTimer > 0 then
        self.attackAnimation:draw(self.attackImage, x + self.attackImageOffset.x, y + self.attackImageOffset.y, 0, self.facing, 1)
    elseif self.velocity.x == 0 or not self.touchingGround then
        love.graphics.draw(image, x, y, 0, self.facing, 1)
    else
        self.runAnimation:draw(self.runImage, x + self.runImageOffset.x, y + self.runImageOffset.y, 0, self.facing, 1)
    end
end

return Player
