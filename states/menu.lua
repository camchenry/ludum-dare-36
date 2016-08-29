menu = {}

function menu:init()
    self.titleImage = love.graphics.newImage("assets/images/title.png")

    self.startKey = "space"
    self.startText = "< Press " .. self.startKey .. " to start >"
    self.startFont = Fonts.regular[40]

    love.graphics.setBackgroundColor(99, 155, 133)

    self.timer = 0
end

function menu:enter(prev, ...)
    self.prev = prev
end

function menu:update(dt)
    self.timer = (self.timer + dt) % 1
end

function menu:keyreleased(key, code)
    if key == self.startKey then
        State.pop()
    end
end

function menu:mousepressed(x, y, mbutton)

end

function menu:draw()
    if self.prev then
        self.prev:draw()
    end
    love.graphics.setColor(255, 255, 255)
    
    love.graphics.draw(self.titleImage, love.graphics.getWidth()/2 - self.titleImage:getWidth()/2, 100)

    if self.timer <= 0.5 then
        love.graphics.setFont(self.startFont)
        love.graphics.printf(self.startText, 0, love.graphics.getHeight()/2 - self.startFont:getHeight(self.startText)/2, love.graphics.getWidth(), "center")
    end
end
