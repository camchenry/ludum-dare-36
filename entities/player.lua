local Player = Class("Player")

function Player:initialize(x, y)
    self.width, self.height = 13, 35
    game.world:add(self, x, y, self.width, self.height)

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

    self.wrenchPower = false

    self.facing = 1

    self.idleImage = love.graphics.newImage("assets/images/Hero/Hero_Idle.png")
    self.jumpImage = love.graphics.newImage("assets/images/Hero/Hero_Jump.png")

    self.imageOffset = Vector(-18, -10)
end

function Player:keypressed(key)
    if key == "z" or "return" then
        self:doAction()
    end
end

function Player:doAction()
    -- check if the player is colliding with a lever
end

function Player:update(dt)
    self.acceleration = Vector(0, self.gravity)

    if love.keyboard.isDown("w", "up", "space") then
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

    if love.keyboard.isDown("a", "left") then
        self.velocity.x = -self.moveVel
        self.facing = 1
    elseif love.keyboard.isDown("d", "right") then
        self.velocity.x = self.moveVel
        self.facing = -1
    else
        self.velocity.x = 0
    end

    self.velocity = self.velocity + self.acceleration * dt
    self.velocity.x = math.min(self.velMax, self.velocity.x)
    local actualX, actualY, cols, len = game.world:move(self, self.position.x + self.velocity.x*dt, self.position.y + self.velocity.y*dt, function(item, other)
        if other.type == "Wrench" then
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

        if other.type == "Wrench" then
            if not self.wrenchPower then
                self.wrenchPower = true
            end
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
            end
        end
    end

    self.position = Vector(actualX, actualY)
end

function Player:draw()
    love.graphics.rectangle('fill', self.position.x, self.position.y, self.width, self.height)
    local offset = 0
    if self.facing == -1 then
        offset = 13
    end

    local image = self.idleImage

    if self.jumpTimer > 0 or not self.canJump then
        image = self.jumpImage
    end

    love.graphics.draw(image, self.position.x + self.imageOffset.x*self.facing + offset, self.position.y + self.imageOffset.y, 0, self.facing, 1)
end

return Player
