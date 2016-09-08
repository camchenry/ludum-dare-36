Object = Class("Object")

function Object:initialize(x, y, w, h, properties)
    self.width = w
    self.height = h

    self.position = Vector(x, y)

    if properties then
        self.collidable = properties.collidable or false
        self.pushable = properties.pushable or false
    end

    self.name = "Object"
end

function Object:drawDebug(x, y, propertyStrings)
    love.graphics.setLineWidth(SCALEX)
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle('line', x - self.width*SCALEX, y, self.width*SCALEX, self.height*SCALEY)

    local spacing = 15

    local info = {
        "Name: " .. self.name,
        "X, Y: " .. Lume.round(self.position.x, .1) .. ", " .. Lume.round(self.position.y, .1),
        "W, H: " .. Lume.round(self.width, .1) .. ", " .. Lume.round(self.height, .1),
        "Collidable: " .. (self.collidable and "true" or "false"),
        "Pushable: " .. (self.pushable and "true" or "false"),
    }

    if propertyStrings then
        for i, text in ipairs(propertyStrings) do
            Lume.push(info, text)
        end
    end

    for i, text in ipairs(info) do
        love.graphics.print(text, x, y + (i-1)*spacing)
    end
end

return Object