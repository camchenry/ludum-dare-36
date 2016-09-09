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

function Object:draw(dx, dy)
    if DEBUG and DRAW_HITBOXES or ACTIVE_ITEM == self then
        dx, dy = dx or 0, dy or 0

        love.graphics.setLineWidth(1)
        love.graphics.setColor(127, 127, 127)
        love.graphics.rectangle('line', math.floor(self.position.x + 1 + dx), math.floor(self.position.y + 1 + dy), self.width - 1, self.height - 1)
        love.graphics.setColor(255, 255, 255)
    end
end

function Object:drawDebug(x, y, propertyStrings)
    local spacing = 15
    local margin = 5

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

    local maxWidth = 5
    local currentFont = love.graphics.getFont()
    for _, text in pairs(info) do
        local textWidth = currentFont:getWidth(text)
        if textWidth > maxWidth then
            maxWidth = textWidth
        end
    end

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", x + 1*SCALEX - margin, y - margin, maxWidth + margin*2, spacing * #info + margin*2)

    for i, text in ipairs(info) do
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(text, x + 1*SCALEX, y + (i-1)*spacing)
    end
end

return Object