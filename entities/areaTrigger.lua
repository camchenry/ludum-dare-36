local AreaTrigger = Class("AreaTrigger")

function AreaTrigger:initialize(x, y, w, h, properties)
    self.width = w
    self.height = h

    self.position = Vector(x, y)

    self.ID = tonumber(properties.ID) or 0
    self.oneTime = properties.oneTime
    self.killBot = properties.killBot
    self.signalOff = properties.signalOff
    self.transition = properties.transition

    self.prevActive = false
    self.active = false
end

function AreaTrigger:update(dt, world)
    if self.oneTime and self.active then return end

    self.prevActive = self.active
    self.active = false

    local items, len = world:queryRect(self.position.x, self.position.y, self.width, self.height)

    for _, item in pairs(items) do
        if item.class and item:isInstanceOf(Player) then
            self.active = true
        end
        if item.class and item:isInstanceOf(Bot) then
            if self.killBot then
                item:kill()
            end

            self.active = true
        end
    end

    if self.active and self.transition then
        State.switch(_G[self.transition])
        return
    end

    if self.active and not self.prevActive then
        Signal.emit("activate", self.ID)
    end

    if not self.active and self.prevActive and self.signalOff then
        Signal.emit("activate", self.ID)
    end
end

function AreaTrigger:draw()

end

return AreaTrigger
