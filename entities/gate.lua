local Gate = Class("Gate")

function Gate:initialize(x, y, w, h, properties)
    self.position = Vector(x, y)
    self.width = w
    self.height = h

    self.startWidth = w
    self.startHeight = h

    self.direction = properties.dir or "up"
    self.ID = tonumber(properties.ID) or 0
    self.ID2 = tonumber(properties.ID2) or 0

    if properties.canClose and properties.canClose == "false" then
        self.canClose = false
    else
        self.canClose = true
    end

    self.activateTime = 2
    self.activating = false

    if properties.open and properties.open == "true" then
        self.activeOn = false
        if self.direction == "up" then
            self.height = 1
        elseif self.direction == "left" then
            self.width = 1
        end
    else
        self.activeOn = true
    end

    Signal.register("activate", function(ID)
        if ID == self.ID or ID == self.ID2 then
            if not self.activating then
                self:activate()
            end
        end
    end)
end

function Gate:activate()
    if self.direction == "up" then
        self:activateUp()
    elseif self.direction == "left" then
        self:activateLeft()
    end

    self.activating = true
    self.activeOn = not self.activeOn
end

function Gate:activateUp()
    if self.activeOn then
        -- it is time to open
        Flux.to(self, self.activateTime, {height = 1}):oncomplete(function()
            self.activating = false
        end)
    elseif self.canClose then
        -- it is time to close
        Flux.to(self, self.activateTime, {height = self.startHeight}):oncomplete(function()
            self.activating = false
        end)
    end
end

function Gate:activateLeft()
    if self.activeOn then
        -- it is time to open
        Flux.to(self, self.activateTime, {width = 1}):oncomplete(function()
            self.activating = false
        end)
    elseif self.canClose then
        -- it is time to close
        Flux.to(self, self.activateTime, {width = self.startWidth}):oncomplete(function()
            self.activating = false
        end)
    end
end

function Gate:update(dt, world)
    world:update(self, self.position.x, self.position.y, math.max(1, self.width), math.max(1, self.height))
end

function Gate:draw()
    --if DEBUG then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('line', self.position.x, self.position.y, self.width, self.height)
    --end

    if self.width > 1 and self.height > 1 then
        -- draw image
        -- image may need to use a scissor
    end

    love.graphics.setColor(255, 255, 255)
end

return Gate