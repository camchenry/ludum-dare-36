local Dropfloor = Class("Dropfloor", Object)

function Dropfloor:initialize(x, y, w, h, properties)
    Object.initialize(self, x, y, w, h, properties)
    self.name = "Dropfloor"

    self.collidable = true
end

function Dropfloor:drawDebug(x, y)
    Object.drawDebug(self, x, y)
end

return Dropfloor