game = {}

sti = require "libs.sti"

CANVAS_WIDTH = 240
CANVAS_HEIGHT = 160

function game:enter(from, ...)
    self:reset() 
end

function game:reset()
    self.map = sti("assets/levels/test_level.lua", {"bump"}) 
    self.canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
    SCALEX = love.graphics.getWidth() / CANVAS_WIDTH
    SCALEY = love.graphics.getHeight() / CANVAS_HEIGHT

    self.world = Bump.newWorld()
    self.map:bump_init(self.world)

    self.camera = Camera(0, 0)
end

function game:update(dt)
    self.map:update(dt)
end

function game:keypressed(key, code)

end

function game:mousepressed(x, y, mbutton)

end

function game:draw()
    self.canvas:renderTo(function()
        love.graphics.clear()  
        self.camera:attach()
        self.map:setDrawRange(self.camera.x, self.camera.y, CANVAS_WIDTH, CANVAS_HEIGHT)
        self.map:draw()
        love.graphics.setColor(255, 255, 255)
        love.graphics.circle("fill", 40, 40, 10)
        self.camera:detach()
    end)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.canvas, 0, 0, 0, SCALEX, SCALEY)
end
