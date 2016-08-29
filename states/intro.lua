intro = {}

sti = require "libs.sti"

CANVAS_WIDTH = 240
CANVAS_HEIGHT = 160

function intro:init()

end

function intro:resume()

end

function intro:enter(prev, ...)
    self:reset()
    self.camera:lookAt(30*16, 17*16)
end

function intro:reset()
    self.map = sti("assets/levels/intro_level.lua", {"bump"}) 
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

    self.camera = Camera()

    for i, object in pairs(self.map.objects) do
        if object.type == "Spawn" then
            self.player = add(Player:new(object.x, object.y))
        end
    end

    self.soundManager = SoundManager:new()

    self.effects = {}
    self.effects.screenShake = ScreenShake:new()

    love.graphics.setLineStyle("rough")
end

function intro:update(dt)
    self.map:update(dt)

    for _, obj in ipairs(self.objects) do
        if obj.update then
            obj:update(dt, self.world)
        end
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

function intro:keyreleased(key, code)
    self.player:keypressed(key)
end

function intro:mousepressed(x, y, mbutton)

end

function intro:draw()
    self.canvas:renderTo(function()
        love.graphics.clear()  
        self.camera:draw(function()
            self.map:setDrawRange(math.floor(self.camera.x), math.floor(self.camera.y), CANVAS_WIDTH, CANVAS_HEIGHT)
            self.map:draw()

            for _, obj in ipairs(self.objects) do
                if obj.draw then
                    if obj == self.player and State.current() ~= intro then

                    else
                        obj:draw()
                    end
                end
            end
        end)
    end)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.canvas, 0, 0, 0, SCALEX, SCALEY)
end
