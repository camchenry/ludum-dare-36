local Lever = Class("Lever")

function Lever:initialize(x, y, properties)
    self.position = Vector(x, y)
    self.width = 16
    self.height = 16

    self.ID = tonumber(properties.ID) or 0
    self.active = false
    self.oneTime = properties.oneTime
end

function Lever:draw()

end

function Lever:hit()
    if self.oneTime and self.active then return end
    Signal.emit("activate", self.ID)
    self.active = not self.active
    return true
end

return Lever
