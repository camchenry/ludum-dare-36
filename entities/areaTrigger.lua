local AreaTrigger = Class("AreaTrigger", Object)

function AreaTrigger:initialize(x, y, w, h, properties)
    Object.initialize(self, x, y, w, h, properties)
    self.name = "AreaTrigger"

    self.ID = properties.ID or 0
    self.ID2 = properties.ID2 or 0
    self.oneTime = properties.oneTime or false
    self.killBot = properties.killBot or false
    self.signalOff = properties.signalOff or false
    self.waitPlayerAndBot = properties.waitPlayerAndBot or false
    self.transition = properties.transition or false

    self.prevActive = false
    self.active = false
end

function AreaTrigger:update(dt, world)
    if self.oneTime and self.active then return end

    self.prevActive = self.active
    self.active = false

    local foundPlayer, foundBot = false, false

    local items, len = world:queryRect(self.position.x, self.position.y, self.width, self.height)

    for _, item in pairs(items) do
        if self.waitPlayerAndBot then
            if item.class and item:isInstanceOf(Player) then
                foundPlayer = true
            elseif item.class and item:isInstanceOf(Bot) then
                foundBot = true
            end
        else
            if item.class and (item:isInstanceOf(Player) or item:isInstanceOf(Bot)) then
                self.active = true
            end
            if item.class and item:isInstanceOf(Bot) then
                if self.killBot then
                    item:kill()
                end

                self.active = true
            end
        end
    end

    if self.waitPlayerAndBot then
        if foundPlayer and foundBot then
            self.active = true
        end
    end

    if self.active and self.transition then
        self.onTransition()
        return
    end

    if self.active and not self.prevActive then
        Signal.emit("activate", self.ID, self.ID2)
    end

    if not self.active and self.prevActive and self.signalOff then
        Signal.emit("activate", self.ID, self.ID2)
    end
end

function AreaTrigger:draw(debugOverride)
    Object.draw(self, debugOverride)
end

function AreaTrigger:drawDebug(x, y)
    local propertyStrings = {
        "ID: " .. self.ID,
        "ID2: " .. self.ID2,
        "One Time: " .. (self.oneTime and "true" or "false"),
        "Kill Bot: " .. (self.killBot and "true" or "false"),
        "Signal Off: " .. (self.signalOff and "true" or "false"),
        "WaitP&B: " .. (self.waitPlayerAndBot and "true" or "false"),
        "Transition: " .. (self.transition and "true" or "false"),
    }

    Object.drawDebug(self, x, y, propertyStrings)
end

return AreaTrigger
