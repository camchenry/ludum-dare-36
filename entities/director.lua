Director = Class("Director", Object)

function Director:initialize(x, y, w, h, properties)
	Object.initialize(self, x, y, w, h, properties)
    self.name = "Director"

    self.activateID = properties.activateID or 0
    self.switchID   = properties.switchID or 0
    self.switchID2  = properties.switchID2 or 0
    self.direction  = properties.direction or 1
    self.oneTime    = properties.oneTime or false
    self.on         = properties.on or true
    
    self.activated = false

    Signal.register("activate", function(ID)
        if ID == self.activateID then
            --self.on = not self.on
        end
        if ID == self.switchID or ID == self.switchID2 then
            self.direction = self.direction * -1
        end
    end)
end

function Director:update(dt, world)
    if self.oneTime and self.activated then return end

    if self.on then
        local items, len = world:queryRect(self.position.x, self.position.y, self.width, self.height)

        for _, item in pairs(items) do
            if item.class and not item:isInstanceOf(Director) then
                if item.class and item.directionOverride then
                    item.direction = self.direction
                    self.activated = true
                end
            end
        end
    end
end

function Director:drawDebug(x, y)
    local propertyStrings = {
        "Activate ID: " .. self.activateID,
        "Switch ID: " .. self.switchID,
        "Direction: " .. self.direction,
        "One Time: " .. (self.oneTime and "true" or "false"),
        "On: " .. (self.on and "true" or "false"),
    }

    Object.drawDebug(self, x, y, propertyStrings)
end

return Director