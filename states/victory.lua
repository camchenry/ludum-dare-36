victory = {}

function victory:init()
    self.titleImage = love.graphics.newImage("assets/images/title.png")

    love.graphics.setBackgroundColor(99, 155, 133)
    
    self.text = [[
Thanks for playing!

Made by:
Robert "Nuthen" Piepsney
<robert.piepsney2 at gmail.com>

Simon Ando Chim
(simonmakesgames.com)

Cameron "Ikroth" McHenry
(camchenry.com)
]]
end

function victory:enter(prev, ...)

end

function victory:update(dt)

end

function victory:keyreleased(key, code)

end

function victory:mousepressed(x, y, mbutton)

end

function victory:draw()
    love.graphics.setColor(255, 255, 255)

    love.graphics.draw(self.titleImage, love.graphics.getWidth()/2 - self.titleImage:getWidth()/2, 50)
    
    love.graphics.setFont(Fonts.regular[36])
    local width = love.graphics.getWidth()*0.9
    love.graphics.printf(self.text, love.graphics.getWidth()/2 - width/2, 75 + self.titleImage:getHeight(), width, "center")
end
