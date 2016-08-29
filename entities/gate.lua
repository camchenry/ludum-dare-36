local Gate = Class("Gate")

function Gate:initialize(x, y, w, h, properties)
    self.position = Vector(x, y)
    self.width = w
    self.height = h

    self.startPosition = Vector(x, y)

    self.startX = x
    self.startWidth = w
    self.startHeight = h

    self.direction = properties.dir or "up"
    self.ID = tonumber(properties.ID) or 0
    self.ID2 = tonumber(properties.ID2) or 0
    self.imgID = tonumber(properties.img) or 0
    self.retractTime = tonumber(properties.retractTime) or 0
    self.crushTime = tonumber(properties.crushTime) or 0

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
    elseif self.imgID == 17 then
        self.image = love.graphics.newImage("assets/images/Misc/PuzzleRoom2_Gate.png")
    elseif self.imgID == 20 then
        self.image = love.graphics.newImage("assets/images/Misc/PuzzleRoom2_SmallTrapDoor.png")
    end

    if properties.canClose and properties.canClose == "false" then
        self.canClose = false
    else
        self.canClose = true
    end

    self.activateTime = 2
    self.activating = false

    self.dontReset = properties.dontReset

    if properties.open and properties.open == "true" then
        self.startOpen = true
        self.activeOn = false
        if self.direction == "up" then
            self.height = 1
        elseif self.direction == "left" then
            self.width = 1
        elseif self.direction == "right" then
            self.width = 1
        end
    else
        self.startOpen = false
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

function Gate:reset()
    if not self.dontReset then
        if self.moveTween then
            self.moveTween:stop()
            self.moveTween = nil
        end

        self.width = self.startWidth
        self.height = self.startHeight

        self.position = Vector(self.startPosition.x, self.startPosition.y)

        if self.startOpen then
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

        self.activating = false

        self.waitTimer = self.waitTime
    end
end

function Gate:activate()
    if not self.moveTween then
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
end

function Gate:activateUp()
    if self.activeOn then
        -- it is time to open
        self.moveTween = Flux.to(self, self.retractTime, {height = 1}):oncomplete(function()
            self.moveTween = nil
            self.activating = false
        end)
    elseif self.canClose then
        -- it is time to close
        self.moveTween = Flux.to(self, self.crushTime, {height = self.startHeight}):oncomplete(function()
            self.moveTween = nil
            self.activating = false
        end)
    end
end

function Gate:activateLeft()
    if self.activeOn then
        -- it is time to open
        self.moveTween = Flux.to(self, self.retractTime, {width = 1}):oncomplete(function()
            self.moveTween = nil
            self.activating = false
        end)
    elseif self.canClose then
        -- it is time to close
        self.moveTween = Flux.to(self, self.crushTime, {width = self.startWidth}):oncomplete(function()
            self.moveTween = nil
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
        local width = math.max(2, self.width)
        local height = math.max(2, self.height)

        if self.direction == "up" then
            love.graphics.setScissor(self.position.x - game.camera.x, self.position.y - game.camera.y, self.width, height + 2)
            love.graphics.draw(self.image, math.floor(self.position.x), math.floor(self.position.y - (self.startHeight - height)))
            love.graphics.setScissor()
        elseif self.direction == "down" then
            love.graphics.setScissor(self.position.x - game.camera.x, self.position.y - game.camera.y - 40, self.width, height + 40)

            --local y = math.min(self.position.y, self.startPosition.y + self.startHeight-2)

            love.graphics.draw(self.image, math.floor(self.position.x), math.floor(self.position.y))
            love.graphics.setScissor()
        elseif self.direction == "left" then
            love.graphics.setScissor(self.position.x - game.camera.x, self.position.y - game.camera.y, width + 2, self.height)
            love.graphics.draw(self.image, math.floor(self.position.x - (self.startWidth - width)), math.floor(self.position.y))
            love.graphics.setScissor()
        elseif self.direction == "right" then
            love.graphics.setScissor(self.startPosition.x - game.camera.x, self.position.y - game.camera.y, self.startWidth, self.height)
            love.graphics.draw(self.image, math.floor(self.position.x), math.floor(self.position.y))
            love.graphics.setScissor()
        end
    end

    if DEBUG then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('line', self.position.x, self.position.y, self.width, self.height)
    end

    love.graphics.setColor(255, 255, 255)
end

return Gate