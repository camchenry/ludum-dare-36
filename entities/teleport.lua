local Teleport = Class("Teleport", Object)

function Teleport:initialize(x, y, w, h, properties)
    Object.initialize(self, x, y, w, h, properties)
    self.name = "Teleport"

    self.ID         = properties.ID or 0
    self.activateID = properties.activateID or 0
    self.out        = properties.out or false

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
    for _, obj in pairs(game.level.objects) do
        if obj.class and obj:isInstanceOf(Teleport) and not obj.out and obj.ID == self.ID then
            item.position = Vector(obj.position.x + obj.width/2 - item.width/2, obj.position.y)
            game.level.world:update(item, item.position.x, item.position.y)
            item.teleportedTimer = item.teleportedTime
        end
    end
end

function Teleport:draw(debugOverride)
    Object.draw(self, debugOverride)
end

function Teleport:drawDebug(x, y)
    local propertyStrings = {
        "ID: " .. self.ID,
        "Activate ID: " .. self.activateID,
        "Activated: " .. (self.activated and "true" or "false"),
    }

    Object.drawDebug(self, x, y, propertyStrings)
end

return Teleport
