Director = Class("Director")

function Director:initialize(x, y, w, h, properties)
    self.width = w
    self.height = h

    self.position = Vector(x, y)

    self.activateID = properties.activateID or 0
    self.switchID   = properties.switchID or 0
    self.switchID2  = properties.switchID2 or 0
    self.oneTime    = properties.oneTime or false
    self.collidable = properties.collidable or false
    self.pushable   = properties.pushable or false
    self.direction  = properties.direction or 1
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

function Director:draw()
    if DEBUG then
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle('line', math.floor(self.position.x + 0.5), math.floor(self.position.y + 0.5), self.width - 0.5, self.height - 0.5)
        love.graphics.setFont(Fonts.mono[12])
        love.graphics.print("DRTR", self.position.x + self.width, self.position.y)
    end
end

return Director