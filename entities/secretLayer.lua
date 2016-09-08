local SecretLayer = Class("SecretLayer", Object)

function SecretLayer:initialize(x, y, w, h, properties)
    Object.initialize(self, x, y, w, h, properties)
    self.name = "SecretLayer"

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

function SecretLayer:drawDebug(x, y)
    local propertyStrings = {
        "ID: " .. self.ID,
        "Active: " .. (self.active and "true" or "false"),
    }

    Object.drawDebug(self, x, y, propertyStrings)
end

return SecretLayer