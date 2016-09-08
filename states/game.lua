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

    local function add(obj)
        table.insert(self.objects, obj)
        self.world:add(obj, obj.position.x, obj.position.y, obj.width, obj.height)
        return obj
    end

    self.camera = Camera()

    self.dot = {x = 0, y = 0}
    self.soundManager = SoundManager:new()

    self.effects = {}
    self.effects.screenShake = ScreenShake:new()

    love.graphics.setLineStyle("rough")
end

function game:update(dt)
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

    -- Change this to an option for disabling screen shake
    local dx, dy = 0, 0
    if true then
        dx, dy = self.effects.screenShake:getOffset()
    end
    self.camera:lockX(math.floor(self.player.position.x + self.player.width/2 - CANVAS_WIDTH/2 + dx))
    self.camera:lockY(math.floor(self.player.position.y + self.player.height/2 - CANVAS_HEIGHT/2 + dy))

    self.soundManager:update(dt)
    for _, effect in pairs(self.effects) do
        effect:update(dt)
    end
end

function game:keypressed(key, code)
    self.player:keypressed(key)
end

function game:mousepressed(x, y, mbutton)
    self.dot.x, self.dot.y = self.camera.x + x/SCALEX, self.camera.y + y/SCALEY
end

function game:worldCoords(x, y)
    return self.camera.x + x/SCALEX, self.camera.y + y/SCALEY
end

function game:cameraCoords(x, y)
    return (x - self.camera.x)*SCALEX, (y - self.camera.y)*SCALEY
end

function game:draw()
    love.graphics.setBackgroundColor(32, 65, 77)

    self.canvas:renderTo(function()
        love.graphics.clear()  
        self.camera:draw(function()
            love.graphics.setLineWidth(1)
            self.map:setDrawRange(math.floor(self.camera.x), math.floor(self.camera.y), CANVAS_WIDTH, CANVAS_HEIGHT)
            self.map:draw()

            if self.console then
                self.console:draw()
            end

            for _, obj in ipairs(self.objects) do
                if obj.draw then
                    obj:draw()
                end
            end

            for _, textItem in pairs(self.textItems) do
                textItem:draw()
            end

            self.player:draw()

            if self.secretLayer then
                self.secretLayer:draw()
            end


            love.graphics.setColor(255, 0, 0)
            love.graphics.circle('fill', self.dot.x, self.dot.y, 5)
        end)
    end)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.canvas, 0, 0, 0, SCALEX, SCALEY)

    for _, obj in ipairs(self.objects) do
        if obj.drawDebug then
            local worldX, worldY = obj.position.x, obj.position.y
            local cameraX, cameraY = self:cameraCoords(worldX, worldY)

            cameraX = cameraX + obj.width * SCALEX
            cameraX, cameraY = cameraX - cameraX % SCALEX, cameraY - cameraY % SCALEY

            obj:drawDebug(cameraX, cameraY)
        end
    end
end
