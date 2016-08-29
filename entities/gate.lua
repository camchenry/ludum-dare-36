local Gate = Class("Gate")

function Gate:initialize(x, y, w, h, properties)
    self.position = Vector(x, y)
    self.width = w
    self.height = h

    self.startX = x
    self.startWidth = w
    self.startHeight = h

    self.direction = properties.dir or "up"
    self.ID = tonumber(properties.ID) or 0
    self.ID2 = tonumber(properties.ID2) or 0
    self.imgID = tonumber(properties.img) or 0

    if self.imgID == 1 then
        self.image = love.graphics.newImage("assets/images/Misc/Room_Gate_TrapDoor.png")
    elseif self.imgID == 4 then
        self.image = love.graphics.newImage("assets/images/Misc/Room6_Door.png")
    elseif self.imgID == 5 then
        self.image = love.graphics.newImage("assets/images/Misc/Room7_TrapDoor.png")
    elseif self.imgID == 6 then
        self.image = love.graphics.newImage("assets/images/Misc/Room9_LargeTrapDoor.png")
    elseif self.imgID == 7 then
        self.image = love.graphics.newImage("assets/images/Misc/Room9_SmallTrapDoor.png")
    elseif self.imgID == 9 then
        self.image = love.graphics.newImage("assets/images/Misc/Room11_Door.png")
    elseif self.imgID == 13 then
        self.image = love.graphics.newImage("assets/images/Misc/PuzzleRoom1_TrapDoor_GoingLeft.png")
    elseif self.imgID == 14 then
        self.image = love.graphics.newImage("assets/images/Misc/PuzzleRoom1_TrapDoor_GoingRight.png")
    end

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
        elseif self.direction == "right" then
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
    elseif self.direction == "right" then
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
    if self.direction == "right" then
        local goal = self.startX + self.startWidth - self.width
        world:update(self, goal, self.position.y, math.max(1, self.width), math.max(1, self.height))
        self.position.x = goal
    else
        world:update(self, self.position.x, self.position.y, math.max(1, self.width), math.max(1, self.height))
    end
end

function Gate:draw()
    love.graphics.setColor(255, 255, 255)

    -- use a scissor
    if self.image then
        love.graphics.draw(self.image, self.position.x, self.position.y)
    end

    if DEBUG then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('line', self.position.x, self.position.y, self.width, self.height)
    end

    love.graphics.setColor(255, 255, 255)
end

return Gate