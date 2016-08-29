local Teleport = Class("Teleport")

function Teleport:initialize(x, y, w, h, properties)
    self.width = w
    self.height = h

    self.position = Vector(x, y)

    self.ID = tonumber(properties.ID) or 0
    self.activateID = tonumber(properties.activateID) or 0
    self.out = properties.out

    self.activated = false

    Signal.register("activate", function(ID)
        if ID == self.activateID then
            self.activated = true
        end
    end)
end

function Teleport:update(dt, world)
    if self.out and self.activated then
        local items, len = world:queryRect(self.position.x, self.position.y, self.width, self.height)

        for _, item in pairs(items) do
            if item.class and item:isInstanceOf(Player) then
                self:teleportEntity(item)
            end
        end
    end
end

function Teleport:teleportEntity(item)
    for _, obj in pairs(game.objects) do
        if obj.class and obj:isInstanceOf(Teleport) and not obj.out and obj.ID == self.ID then
            item.position = Vector(obj.position.x + obj.width/2 - item.width/2, obj.position.x + obj.height/2)
        end
    end
end

return Teleport