local Checkpoint = Class("Checkpoint", Object)

function Checkpoint:initialize(x, y, w, h, properties)
    Object.initialize(self, x, y, w, h, properties)
    self.name = "Checkpoint"
end

function Checkpoint:update(dt, world)
    local items, len = world:queryRect(self.position.x, self.position.y, self.width, self.height)

    for _, item in pairs(items) do
        if item.class and item.acceptCheckpoint then
            item.resetPosition = Vector(self.position.x + self.width/2 - item.width/2, self.position.y + self.height/2 - item.height/2)
        end
    end

    if self.active and self.transition then
        self.onTransition()
        return
    end

    if self.active and not self.prevActive then
        Signal.emit("activate", self.ID)
    end

    if not self.active and self.prevActive and self.signalOff then
        Signal.emit("activate", self.ID)
    end
end

function Checkpoint:draw()

end

function Checkpoint:drawDebug(x, y)
    Object.drawDebug(self, x, y)
end

return Checkpoint