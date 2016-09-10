local Augment = Class("Augment", Object)

function Augment:initialize(x, y, w, h, properties)
    Object.initialize(self, x, y, w, h, properties)
    self.name = "Augment"

    self.powerup = properties.powerup or "none"
end

function Augment:update(dt, world)
    local items, len = world:queryRect(self.position.x, self.position.y, self.width, self.height)

    for _, item in pairs(items) do
        if item.class and item:isInstanceOf(Player) then
            if self.powerup ~= "none" then
                item.augments[self.powerup] = true
            end
        end
    end
end

function Augment:draw()
    Object.draw(self)
end

function Augment:drawDebug()
    Object.drawDebug(self)
end

return Augment