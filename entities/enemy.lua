Enemy = Class("Enemy")

function Enemy:initialize(x, y, direction, movement, right)
    self.width, self.height = 32, 16
    self.startPosition = Vector(x, y)
    self.position = Vector(x, y)

    self.direction = direction or 1
    self.movement = movement or false
    self.right = right or 0

    self.visible = true

    self.speed = 50

    self.image = love.graphics.newImage("assets/images/Enemy/Bug.png")
    self.imageOffset = Vector(-self.image:getWidth()/2 + 16, -self.image:getHeight()/2 - 16)
end

function Enemy:update(dt, world)
    if self.direction == -1 then
        local distance = self.startPosition.x + self.right - self.position.x
        if distance > 0 then
            self.position.x = math.min(self.startPosition.x + self.right, self.position.x + self.speed*dt)
        elseif distance <= 0 then

        end
    end
end

function Enemy:draw()
    love.graphics.setColor(255, 255, 255)

    if self.visible then
        love.graphics.draw(self.image, self.position.x + self.imageOffset.x, self.position.y + self.imageOffset.y)
    end

    if DEBUG then
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle('line', self.position.x + 0.5, self.position.y + 0.5, self.width - 0.5, self.height - 0.5)
    end

    love.graphics.setColor(255, 255, 255)
end

function Enemy:hit()
    -- keep the enemy loaded, just make them invisible
    -- they will need to be restored if you return to a checkpoint
    self.visible = false
end

return Enemy