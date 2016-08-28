game = {}

sti = require "libs.sti"

CANVAS_WIDTH = 240
CANVAS_HEIGHT = 160

function game:enter(from, ...)
    self:reset() 
end

function game:resetToCheckpoint()
    self.player:reset()
    for _, obj in ipairs(self.objects) do
        if obj.reset then
            obj:reset()
        end
    end
end

function game:reset()
    love.graphics.setBackgroundColor(99, 155, 133)

    self.map = sti("assets/levels/main_level.lua", {"bump"}) 
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

    self.player = add(Player:new(20, 560))

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
            self.console = Console:new(object.x, object.y)
        end

        if object.type == "Checkpoint" then
            add(Checkpoint:new(object.x, object.y, object.width, object.height))
        end
    end

    love.graphics.setLineStyle("rough")
end

function game:update(dt)
    self.map:update(dt)
    self.console:update(dt)

    for _, obj in ipairs(self.objects) do
        if obj.update then
            obj:update(dt, self.world)
        end
    end
    self.camera:lockX(math.floor(self.player.position.x + self.player.width/2 - CANVAS_WIDTH/2))
    self.camera:lockY(math.floor(self.player.position.y + self.player.height/2 - CANVAS_HEIGHT/2))
end

function game:keypressed(key, code)
    self.player:keypressed(key)
end

function game:mousepressed(x, y, mbutton)

end

function game:draw()
    self.canvas:renderTo(function()
        love.graphics.clear()  
        self.camera:draw(function()
            self.map:setDrawRange(math.floor(self.camera.x), math.floor(self.camera.y), CANVAS_WIDTH, CANVAS_HEIGHT)
            self.map:draw()
            self.console:draw()

            for _, obj in ipairs(self.objects) do
                if obj.draw then
                    obj:draw()
                end
            end

            self.player:draw()
        end)
    end)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.canvas, 0, 0, 0, SCALEX, SCALEY)
end
