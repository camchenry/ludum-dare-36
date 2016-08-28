local Spikes = Class("Spikes")

function Spikes:initialize(x, y, w, h)
    self.width = w
    self.height = h

    self.position = Vector(x, y)
end

return Spikes