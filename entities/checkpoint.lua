local Checkpoint = Class("Checkpoint")

function Checkpoint:initialize(x, y, w, h)
    self.position = Vector(x, y)
    self.width = w
    self.height = h
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
    if DEBUG then
        love.graphics.setColor(0, 255, 0)
        love.graphics.rectangle('line', self.position.x, self.position.y, self.width, self.height)
    end
    love.graphics.setColor(255, 255, 255)
end

return Checkpoint