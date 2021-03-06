game = {}

function game:enter(from, ...)
    self:reset() 
    Signal.emit("gameEntered")
end

function game:resetToCheckpoint(override)
    for _, obj in ipairs(self.level.objects) do
        if obj.reset then
            if not obj:isInstanceOf(Bot) then
                obj:reset(self.level.world)
            end
        end
    end

    for _, obj in ipairs(self.level.objects) do
        if obj.reset then
            if obj:isInstanceOf(Bot) then
                obj:reset(self.level.world)
            end
        end
    end
end

function game:reset()
    -- Game canvas, rendered at a small resolution and scaled up
    self.canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
    SCALEX = love.graphics.getWidth() / CANVAS_WIDTH
    SCALEY = love.graphics.getHeight() / CANVAS_HEIGHT

    self.levelLoader = LevelLoader:new()
    self.level = self.levelLoader:load("intro_level")
    self.player = self.level.player

    RUNNING = true

    -- Game camera
    -- It is not zoomed, so it works with native resolution coords (!)
    self.camera = Camera()
    self.activeCamera = self.camera

    -- Audio and visual effects
    self.soundManager = SoundManager:new()

    self.effects = {}
    self.effects.screenShake = ScreenShake:new()
    self.shaders = {
        love.graphics.newShader("shaders/identity.glsl"),
        love.graphics.newShader("shaders/greyscale.frag"),
        love.graphics.newShader("shaders/posterize.frag"),
        love.graphics.newShader("shaders/distort.vert"),
        love.graphics.newShader("shaders/replace_color.glsl")
    }
    self.shaders[3]:send("num_bands", 3);
    self.currentShader = 1

    -- Debug stuff
    ACTIVE_ITEM = nil
    self.debugCamera = Camera()
    self.debugCameraSpeed = 4
    self.debugCameraOffset = Vector(0, 0)
    self.showDebugCamera = false
    self.dot = {x = 0, y = 0}
end

function game:update(dt)
    if RUNNING then
        self.level.map:update(dt)

        self.soundManager:update(dt)
        for _, effect in pairs(self.effects) do
            effect:update(dt)
        end
    end

    -- Change this to an option for disabling screen shake
    local dx, dy = 0, 0
    if true then
        dx, dy = self.effects.screenShake:getOffset()
    end
    self.camera:lockX(math.floor(self.player.position.x + self.player.width/2 + dx))
    self.camera:lockY(math.floor(self.player.position.y + self.player.height/2 + dy))

    if self.showDebugCamera then
        local dx, dy = 0, 0
        local isLeft, isRight = love.keyboard.isDown('a', 'left'), love.keyboard.isDown('d', 'right')
        local isUp, isDown = love.keyboard.isDown('w', 'up'), love.keyboard.isDown('s', 'down')

        if isLeft and isRight then
            dx = 0
        elseif isLeft then
            dx = -self.debugCameraSpeed
        elseif isRight then
            dx = self.debugCameraSpeed
        end

        if isUp and isDown then
            dy = 0
        elseif isUp then
            dy = -self.debugCameraSpeed
        elseif isDown then
            dy = self.debugCameraSpeed
        end

        if dx ~= 0 and dy ~= 0 then
            local mult = math.sin(math.pi/4)
            dx, dy = dx * mult, dy * mult
        end

        self.debugCameraOffset.x = self.debugCameraOffset.x + dx
        self.debugCameraOffset.y = self.debugCameraOffset.y + dy

        self.debugCamera:lockX(self.debugCameraOffset.x)
        self.debugCamera:lockY(self.debugCameraOffset.y)
    end
end

function game:keypressed(key, code)
    if DEBUG and key == "f3" then
        self.showDebugCamera = not self.showDebugCamera

        if self.showDebugCamera then
            self.activeCamera = self.debugCamera
            self.debugCameraOffset.x = self.camera.x
            self.debugCameraOffset.y = self.camera.y
        else
            self.activeCamera = self.camera
        end
    end

    if DEBUG and key == "f12" then
        self.player.wrenchPower = not self.player.wrenchPower
    end

    -- experiment shaders feature, remove this later
    if DEBUG and key == "f9" then
        self.currentShader = self.currentShader + 1

        if self.currentShader > #self.shaders then 
            self.currentShader = 1 
        end
    end

    self.player:keypressed(key)
end

function game:mousemoved(x, y, dx, dy)
    local bands = love.mouse.getX() / love.graphics.getWidth() * 16
    self.shaders[3]:send("num_bands", math.ceil(bands))
end

function game:mousepressed(x, y, mbutton)
    local worldX, worldY = self:worldCoords(x, y)
    self.dot.x = worldX 
    self.dot.y = worldY

    local items, len = self.level.world:queryPoint(worldX, worldY, function(item)
        if item.class then
            return item
        end

        return nil
    end)

    ACTIVE_ITEM = nil
    if len > 0 then
        ACTIVE_ITEM = items[1]
    end

    for i = 1, len do
        if items[i]:isInstanceOf(NewCrusher) then
            if self.player.augments[items[i].augment] or items[i].augment == "none" then
                items[i]:activate(true)
            end
        end
    end
end

function game:worldCoords(x, y)
    return self.activeCamera.x + x/SCALEX - CANVAS_WIDTH/2,
           self.activeCamera.y + y/SCALEY - CANVAS_HEIGHT/2
end

function game:cameraCoords(x, y)
    return (x - self.activeCamera.x + CANVAS_WIDTH/2)*SCALEX, 
           (y - self.activeCamera.y + CANVAS_HEIGHT/2)*SCALEY
end

function game:draw()
    love.graphics.setBackgroundColor(32, 65, 77)
    love.graphics.setLineWidth(1)
    love.graphics.setLineStyle("rough")

    local camera = self.activeCamera
    oldCameraX = camera.x
    oldCameraY = camera.y
    camera.x = math.floor(camera.x)
    camera.y = math.floor(camera.y)

    local translatedX = camera.x - CANVAS_WIDTH/2
    local translatedY = camera.y - CANVAS_HEIGHT/2

    camera:attach(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
    self.canvas:renderTo(function()
        love.graphics.clear()
        self.level.map:setDrawRange(translatedX, translatedY, CANVAS_WIDTH, CANVAS_HEIGHT)
        self.level.map:draw()
        if DEBUG then
            love.graphics.circle("fill", self.dot.x, self.dot.y, 5)
        end
    end)
    camera:detach()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setShader(self.shaders[self.currentShader])
    love.graphics.draw(self.canvas, 0, 0, 0, SCALEX, SCALEY)
    love.graphics.setShader()

    if DEBUG then
        for _, obj in ipairs(self.level.objects) do
            if obj.drawDebug and obj == ACTIVE_ITEM then
                local worldX = obj.position.x
                local worldY = obj.position.y
                local cameraX, cameraY = self:cameraCoords(worldX + 0.5, worldY + 0.5)

                cameraX = cameraX + obj.width * SCALEX
                cameraX = cameraX - cameraX % SCALEX
                cameraY = cameraY - cameraY % SCALEY

                obj:drawDebug(cameraX, cameraY)
            end
        end
    end

    camera.x = oldCameraX
    camera.y = oldCameraY
end
