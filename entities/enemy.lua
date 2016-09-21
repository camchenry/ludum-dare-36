local Enemy = Class("Enemy", Object)

Enemy.static.idleImage = love.graphics.newImage("assets/images/Enemy/Bug_Idle.png")
Enemy.static.jumpImage = love.graphics.newImage("assets/images/Enemy/Bug_Jump.png")
Enemy.static.walkImage = love.graphics.newImage("assets/images/Enemy/Bug_Walk.png")

function Enemy:initialize(x, y, w, h, properties)
    Object.initialize(self, x, y, w, h, properties)
    self.width = 32
    self.height = 16
    self.name = "Enemy"

    self.startPosition = Vector(x, y)
    self.color = {255, 255, 255, 255}

    self.direction    = properties.direction or 1
    self.jumpInterval = properties.jumpInterval or 3.0
    self.jumpAccel    = properties.jumpAccel or 1000.0
    self.ID           = properties.ID or 0
    self.movement     = properties.movement or false
    self.jumping      = properties.jumping or false
    if properties.limits then
        local limits = loadstring("return {" .. properties.limits .. "}")()
        self.limits = {}
        self.limits.left = limits[1] * TILE_WIDTH
        self.limits.right = limits[2] * TILE_WIDTH
    end

    self.startDirection = self.direction    

    self.visible = true
    self.alive = true

    self.fallAmount = 500
    self.fallTime = 2
    self.colorFlash = false
    self.colorFlashTime = 4/60

    self.speed = 25
    self.gravity = 160
    self.acceleration = Vector(0, 0)
    self.velocity = Vector(0, 0)
    self.jumpTimer = self.jumpInterval
    self.fallOffset = 0

    local g = Anim8.newGrid(64, 64, Enemy.walkImage:getWidth(), Enemy.walkImage:getHeight())
    self.walkAnimation = Anim8.newAnimation(g('1-5', 1), 0.110)

    self.imageOffset = Vector(16, -48)

    Signal.register("activate", function(ID)
        if ID == self.ID then
            self:reset(game.level.world)
        end
    end)
end

function Enemy:reset(world)
    if self.deathTween then
        self.deathTween:stop()
        self.deathTween = nil
    end

    self.position = self.startPosition:clone()
    world:update(self, self.position.x, self.position.y)
    self.direction = self.startDirection

    self.visible = true
    self.alive = true
    self.fallOffset = 0
    self.acceleration = Vector(0, 0)
    self.velocity = Vector(0, 0)
    self.jumpTimer = self.jumpInterval
end

function Enemy:update(dt, world)
    self.acceleration = Vector(0, self.gravity)

    if self.movement and self.alive then
        self.velocity.x = self.speed * self.direction
    end

    if self.jumping and self.alive then
        if self.jumpTimer <= 0 then
            self.jumpTimer = self.jumpInterval
            self.velocity.y = -self.jumpAccel
        end

        self.jumpTimer = math.max(0, self.jumpTimer - dt)
    end

    if self.limits then
        -- too far left of boundary
        if self.direction == -1 and self.position.x <= self.limits.left then
            self.direction = self.direction * -1
        end

        -- too far right of boundary
        if self.direction == 1 and self.position.x >= self.limits.right then
            self.direction = self.direction * -1
        end
    end

    self.velocity = self.velocity + self.acceleration * dt
    self.position = self.position + self.velocity * dt

    local filter = function(item, other)
        return (not other.class or other.collidable) and "slide" or false
    end

    self.position.x, self.position.y, cols = world:move(self, self.position.x, self.position.y, filter)

    for k, col in pairs(cols) do
        if math.abs(col.normal.x) == 1 then
            self.direction = self.direction * -1
        end
        if col.normal.y == -1 then
            self.velocity.y = 0
        end
    end

    self.walkAnimation:update(dt)
end

function Enemy:draw(debugOverride)
    Object.draw(self, debugOverride)
    
    love.graphics.setColor(255, 255, 255)

    if self.visible then
        love.graphics.setColor(self.color)

        if not self.alive then
            love.graphics.setColor(181, 220, 161)
            love.graphics.setShader(game.shaders[5])
        end

        local image = Enemy.idleImage

        if self.movement then
            self.walkAnimation:draw(
                Enemy.walkImage, 
                math.floor(self.position.x + self.imageOffset.x), 
                math.floor(self.position.y + self.imageOffset.y + self.fallOffset), 
                0, 
                -self.direction, 
                1, 
                Enemy.idleImage:getWidth()/2, 
                0
            )
        else
            if self.position.y < self.startPosition.y then
                image = Enemy.jumpImage
            end

            love.graphics.draw(
                image, 
                math.floor(self.position.x + self.imageOffset.x),
                math.floor(self.position.y + self.imageOffset.y + self.fallOffset),
                0, 
                -self.direction, 
                1, 
                image:getWidth()/2, 
                0
            )
        end

        love.graphics.setShader()
    end

    love.graphics.setColor(255, 255, 255)
end

function Enemy:drawDebug(x, y)
    local propertyStrings = {
        "ID: " .. self.ID,
        "Direction: " .. self.direction,
        "Jump Interval: " .. self.jumpInterval,
        "Jump Accel: " .. self.jumpAccel,
        "Movement: " .. (self.movement and "true" or "false"),
        "Jumping: " .. (self.jumping and "true" or "false"),
        "Alive: " .. (self.alive and "true" or "false"),
        --"Limits: " .. (self.limits and ("%d, %d"):format(self.limits[1], self.limits[2]) or "nil"),
    }

    Object.drawDebug(self, x, y, propertyStrings)
end

function Enemy:hit()
    if self.alive then
        -- keep the enemy loaded, just make them invisible
        -- they will need to be restored if you return to a checkpoint
        self.fallOffset = 0
        self.alive = false

        Signal.emit("enemyDeath")

        self.deathTween = Flux.to(self, self.fallTime, {fallOffset = self.fallAmount})
            :oncomplete(function()
                self.visible = false
                self.deathTween = nil
            end)

        return true
    end
end

return Enemy
