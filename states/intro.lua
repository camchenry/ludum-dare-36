intro = {}

function intro:init()
    Signal.register('stateTransition', function(state)
        Flux.to(self.overlay, 1.5, {0, 0, 0, 255})
            :oncomplete(function()
                State.switch(_G[state])
                return
            end)
    end)
end

function intro:resume()

end

function intro:enter(prev, ...)
    self:reset()

    self.overlay = {0, 0, 0, 0}
end

function intro:reset()
    self.canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
    SCALEX = love.graphics.getWidth() / CANVAS_WIDTH
    SCALEY = love.graphics.getHeight() / CANVAS_HEIGHT

    self.levelLoader = LevelLoader:new()
    self.level = self.levelLoader:load("intro_level")
    self.map = self.level.map
    self.objects = self.level.objects
    self.world = self.level.world
    self.player = self.level.player

    self.camera = Camera()

    --self.soundManager = SoundManager:new()

    self.effects = {}
    self.effects.screenShake = ScreenShake:new()

    love.graphics.setLineStyle("rough")
end

function intro:update(dt)
    self.map:update(dt)

    -- Change this to an option for disabling screen shake
    local dx, dy = 0, 0
    if true then
        dx, dy = self.effects.screenShake:getOffset()
    end
    self.camera:lockX(math.floor(self.player.position.x + self.player.width/2 + dx))
    self.camera:lockY(math.floor(self.player.position.y + self.player.height/2 + dy))

    --self.soundManager:update(dt)
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
    self.camera:attach(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
    self.canvas:renderTo(function()
        love.graphics.clear()
        self.map:setDrawRange(math.floor(self.camera.x - CANVAS_WIDTH/2), math.floor(self.camera.y - CANVAS_HEIGHT/2), CANVAS_WIDTH, CANVAS_HEIGHT)
        self.map:draw()
    end)
    self.camera:detach()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.canvas, 0, 0, 0, SCALEX, SCALEY)

    love.graphics.setColor(self.overlay)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end
