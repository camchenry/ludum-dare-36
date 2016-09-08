game = {}

CANVAS_WIDTH = 240
CANVAS_HEIGHT = 160

function game:enter(from, ...)
    self:reset() 
    Signal.emit("gameEntered")
end

function game:resetToCheckpoint(override)
    for _, obj in ipairs(self.objects) do
        if obj.reset then
            if not obj:isInstanceOf(Bot) then
                obj:reset(self.world)
            end
        end
    end

    for _, obj in ipairs(self.objects) do
        if obj.reset then
            if obj:isInstanceOf(Bot) then
                obj:reset(self.world)
            end
        end
    end
end

function game:reset()
    self.canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
    SCALEX = love.graphics.getWidth() / CANVAS_WIDTH
    SCALEY = love.graphics.getHeight() / CANVAS_HEIGHT

    self.levelLoader = LevelLoader:new()
    self.textItems = {} -- TODO refactor this out
    self.level = self.levelLoader:load("playground_level")
    self.map = self.level.map
    self.objects = self.level.objects
    self.world = self.level.world

    self.activeItem = nil

    local function add(obj)
        table.insert(self.objects, obj)
        self.world:add(obj, obj.position.x, obj.position.y, obj.width, obj.height)
        return obj
    end

    self.camera = Camera()

    self.debugCamera = Camera()
    self.debugCameraSpeed = 4
    self.debugCameraOffset = Vector(0, 0)
    self.showDebugCamera = false

    self.activeCamera = self.camera

    self.pause = false

    self.soundManager = SoundManager:new()

    self.effects = {}
    self.effects.screenShake = ScreenShake:new()

    love.graphics.setLineStyle("rough")
end

function game:update(dt)
    if not self.pause then
        self.map:update(dt)

        if self.console then
            self.console:update(dt)
        end

        for _, obj in ipairs(self.objects) do
            if obj.class and obj:isInstanceOf(Crusher) then
                obj.hasMoved = false
            end
        end

        for _, obj in ipairs(self.objects) do
            if obj.class and obj:isInstanceOf(NewCrusher) then
                obj:update(dt, self.world)
            end
        end

        for _, obj in ipairs(self.objects) do
            if obj.update then
                if obj.class and not obj:isInstanceOf(NewCrusher) then
                    obj:update(dt, self.world)
                end
            end
        end

        if self.secretLayer then
            self.secretLayer:update(dt)
        end
    end

    -- Change this to an option for disabling screen shake
    local dx, dy = 0, 0
    if true then
        dx, dy = self.effects.screenShake:getOffset()
    end
    self.camera:lockX(self.player.position.x + self.player.width/2 - CANVAS_WIDTH/2 + dx)
    self.camera:lockY(self.player.position.y + self.player.height/2 - CANVAS_HEIGHT/2 + dy)

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

    self.soundManager:update(dt)
    for _, effect in pairs(self.effects) do
        effect:update(dt)
    end
end

function game:keypressed(key, code)
    if key == "f2" then
        self.pause = not self.pause
    end
    if key == "f3" then
        self.showDebugCamera = not self.showDebugCamera

        if self.showDebugCamera then
            self.activeCamera = self.debugCamera
            self.debugCameraOffset.x = self.camera.x
            self.debugCameraOffset.y = self.camera.y
        else
            self.activeCamera = self.camera
        end
    end

    self.player:keypressed(key)
end

function game:mousepressed(x, y, mbutton)
    local worldX, worldY = self:worldCoords(x, y)

    local items, len = self.world:queryPoint(worldX, worldY, function(item)
        if item.class then
            return item
        end

        return nil
    end)

    self.activeItem = nil
    if len > 0 then
        self.activeItem = items[1]
    end
end

function game:worldCoords(x, y)
    return self.activeCamera.x + x/SCALEX, self.activeCamera.y + y/SCALEY
end

function game:cameraCoords(x, y)
    return (x - self.activeCamera.x)*SCALEX, (y - self.activeCamera.y)*SCALEY
end

function game:draw()
    love.graphics.setBackgroundColor(32, 65, 77)

    local camera = self.activeCamera
    oldCameraX, oldCameraY = camera.x, camera.y
    camera.x, camera.y = math.floor(camera.x), math.floor(camera.y)

    self.canvas:renderTo(function()
        love.graphics.clear()

        camera:draw(function()
            love.graphics.setLineWidth(1)
            self.map:setDrawRange(math.floor(camera.x), math.floor(camera.y), CANVAS_WIDTH, CANVAS_HEIGHT)
            self.map:draw()

            if self.console then
                self.console:draw(self.activeItem == self.console)
            end

            for _, obj in ipairs(self.objects) do
                if obj.draw then
                    obj:draw(self.activeItem == obj)
                end
            end

            for _, textItem in pairs(self.textItems) do
                textItem:draw(self.activeItem == textItem)
            end

            self.player:draw(self.activeItem == self.player)

            if self.secretLayer then
                self.secretLayer:draw(self.activeItem == self.secretLayer)
            end
        end)
    end)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.canvas, 0, 0, 0, SCALEX, SCALEY)

    if DEBUG then
        for _, obj in ipairs(self.objects) do
            if obj.drawDebug and obj == self.activeItem then
                local worldX, worldY = obj.position.x, obj.position.y
                local cameraX, cameraY = self:cameraCoords(worldX + 0.5, worldY + 0.5)

                cameraX = cameraX + obj.width * SCALEX
                cameraX, cameraY = cameraX - cameraX % SCALEX, cameraY - cameraY % SCALEY

                obj:drawDebug(cameraX, cameraY)
            end
        end
    end

    camera.x, camera.y = oldCameraX, oldCameraY
end
