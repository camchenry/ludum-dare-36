Enemy = Class("Enemy")

function Enemy:initialize(x, y)
    self.width, self.height = 32, 16
    self.position = Vector(x, y)

    self.visible = true

    self.image = love.graphics.newImage("assets/images/Enemy/Bug.png")
    self.imageOffset = Vector(-self.image:getWidth()/2 + 16, -self.image:getHeight()/2 - 16)
end

function Enemy:draw()
    love.graphics.setColor(255, 255, 255)

    love.graphics.draw(self.image, self.position.x + self.imageOffset.x, self.position.y + self.imageOffset.y)

    if DEBUG then
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle('line', self.position.x + 0.5, self.position.y + 0.5, self.width - 0.5, self.height - 0.5)
    end

    love.graphics.setColor(255, 255, 255)
end

return Enemy