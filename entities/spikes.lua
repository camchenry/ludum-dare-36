local Spikes = Class("Spikes", Object)

function Spikes:initialize(x, y, w, h, properties)
    Object.initialize(self, x, y, w, h, properties)
    self.name = "Spikes"
end

function Spikes:drawDebug(x, y)
    Object.drawDebug(self, x, y)
end

return Spikes