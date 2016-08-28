Lever = Class("Lever")

function Lever:initialize(x, y, properties)
    self.position = Vector(x, y)
    self.width = 16
    self.height = 16

    self.ID = tonumber(properties.ID) or 0
end

function Lever:draw()

end

function Lever:hit()
    Signal.emit("activate", self.ID)
end

return Lever