game = {}

sti = require "libs.sti"

CANVAS_WIDTH = 240
CANVAS_HEIGHT = 160

function game:enter(from, ...)
    self:reset() 
    Signal.emit("gameEntered")
end

function game:resetToCheckpoint(override)
    if not override then
        self.player:reset(self.world)
    end

    for _, obj in ipairs(self.objects) do
        if obj.reset then
            if not obj:isInstanceOf(Bot) and not obj:isInstanceOf(Player) then
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
    -- self.map = sti("assets/levels/main_level.lua", {"bump"}) 
    self.canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
    SCALEX = love.graphics.getWidth() / CANVAS_WIDTH
    SCALEY = love.graphics.getHeight() / CANVAS_HEIGHT

    self.objects = {}
    self.world = Bump.newWorld()
    self.map:bump_init(self.world)

    local function add(obj)
        table.insert(self.objects, obj)
        self.world:add(obj, obj.position.x, obj.position.y, obj.width, obj.height)
        return obj
    end

    loads = loads + 1

    self.camera = Camera()
    -- self.camera.smoother = Camera.smooth.damped(7)

    --self.player = add(Player:new(20, 1550))
    --self.player = add(Player:new(1200, 1169))

    self.textItems = {}

    for i, object in pairs(self.map.objects) do
        if object.type == "Wrench" then
            self.wrench = add(Wrench:new(object.x, object.y, object.width, object.height))
        end

        if object.type == "Enemy" then
            add(Enemy:new(object.x, object.y, object.properties))
        end

        if object.type == "MovingPlatform" then
            local platform = add(MovingPlatform:new(object.x, object.y, object.width, object.height, object.properties))
        end
        
        if object.type == "Console" then
            self.console = Console:new(object.x, object.y, object.width, object.height, object.properties)
        end

        if object.type == "Checkpoint" then
            add(Checkpoint:new(object.x, object.y, object.width, object.height))
        end

        if object.type == "Dropfloor" then
            add(Dropfloor:new(object.x, object.y, object.width, object.height))
        end

        if object.type == "Lever" then
            add(Lever:new(object.x, object.y, object.properties))
        end

        if object.type == "Gate" then
            add(Gate:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "Crusher" then
            add(Crusher:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "Bot" then
            add(Bot:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "Spikes" then
            add(Spikes:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "AreaTrigger" then
            add(AreaTrigger:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "SecretLayer" then
            self.secretLayer = SecretLayer:new(object.x, object.y, object.width, object.height, object.properties)
        end

        if object.type == "ShowText" then
            table.insert(self.textItems, ShowText:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "Teleport" then
            add(Teleport:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "VictoryCondition" then
            self.victoryCondition = VictoryCondition:new(object.x, object.y, object.width, object.height, object.properties)
        end

        if object.type == "Spawn" then
            self.player = add(Player:new(object.x, object.y))
        end

        if object.type == "NewCrusher" then
            add(NewCrusher:new(object.x, object.y, object.width, object.height, object.properties))
        end
    end

    --self.soundManager = SoundManager:new()

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
        if obj.update then
            if obj.class and not obj:isInstanceOf(NewCrusher) then
                obj:update(dt, self.world)
            end
        end
    end

    for _, obj in ipairs(self.objects) do
        if obj.class and obj:isInstanceOf(NewCrusher) then
            obj:update(dt, self.world)
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

    --self.soundManager:update(dt)
    for _, effect in pairs(self.effects) do
        effect:update(dt)
    end
end

function game:keypressed(key, code)
    self.player:keypressed(key)
end

function game:mousepressed(x, y, mbutton)

end

function game:draw()
    love.graphics.setBackgroundColor(32, 65, 77)

    self.canvas:renderTo(function()
        love.graphics.clear()  
        self.camera:draw(function()
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
        end)
    end)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.canvas, 0, 0, 0, SCALEX, SCALEY)
end
