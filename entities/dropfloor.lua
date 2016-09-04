local Dropfloor = Class("Dropfloor")

function Dropfloor:initialize(x, y, w, h, properties)
    self.position = Vector(x, y)
    self.width = w
    self.height = h

    self.collidable = properties.collidable or true
end

return Dropfloor