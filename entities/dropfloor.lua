local Dropfloor = Class("Dropfloor")

function Dropfloor:initialize(x, y, w, h)
    self.position = Vector(x, y)
    self.width = w
    self.height = h
end

return Dropfloor