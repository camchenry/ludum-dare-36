local SecretLayer = Class("SecretLayer")

function SecretLayer:initialize(x, y, w, h, properties)
    self.position = Vector(x, y)

    self.ID = properties.ID or 0

    self.image = love.graphics.newImage("assets/images/Misc/Room3_TopLayer.png")

    self.active = true
end

function SecretLayer:update(dt)
    local prevActive = self.active

    self.active = true

    for _, obj in pairs(game.objects) do
        if obj.class and obj:isInstanceOf(AreaTrigger) then
            if obj.active then
                self.active = false
            end
        end
    end
end

function SecretLayer:draw()
    if self.active then
        love.graphics.draw(self.image, self.position.x, self.position.y)
    end
end

return SecretLayer