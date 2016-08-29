local Crusher = Class("Crusher")

function Crusher:initialize(x, y, w, h, properties)
    self.position = Vector(x, y)
    self.width = w
    self.height = h

    self.prevHeight = h

    self.startPosition = Vector(x, y)
    self.startHeight = h

    self.direction = properties.dir or "up"
    self.ID = tonumber(properties.ID) or 0
    self.botDir = tonumber(properties.botDir) or 0
    self.imgID = tonumber(properties.img) or 0

    if self.imgID == 2 then
        self.image = love.graphics.newImage("assets/images/Misc/Room4_Crusher.png")
    elseif self.imgID == 3 then
        self.image = love.graphics.newImage("assets/images/Misc/Room5_UpwardCrusher.png")
    elseif self.imgID == 8 then
        self.image = love.graphics.newImage("assets/images/Misc/Room10_Crushers.png")
    elseif self.imgID == 10 then
        self.image = love.graphics.newImage("assets/images/Misc/puzzleRoom1_LargeElevator.png")
    elseif self.imgID == 11 then
        self.image = love.graphics.newImage("assets/images/Misc/PuzzleRoom1_SmallElevator_FirstPart.png")
    elseif self.imgID == 12 then
        self.image = love.graphics.newImage("assets/images/Misc/PuzzleRoom1_SmallElevator_SecondPart.png")
    end

    if properties.canClose and properties.canClose == "false" then
        self.canClose = false
    else
        self.canClose = true
    end

    if properties.auto and properties.auto == "false" then
        self.auto = false
    else
        self.auto = true
    end

    if properties.waitTwo and properties.waitTwo == "true" then
        self.waitTwo = true
    else
        self.waitTwo = false
    end

    self.interval = 5
    
    self.crushing = false

    self.hasMoved = false

    self.open = true

    Signal.register("activate", function(ID)
        if ID == self.ID then
            if not self.activating then
                self:activate()
            end
        end
    end)
end

function Crusher:activate()
    if not self.crushing and not self.auto then
        if self.open then
            Flux.to(self, self.interval/2, {height = 0}):ease("linear"):oncomplete(function()
                self.crushing = false
            end)
        elseif self.canClose then
            Flux.to(self, self.interval/2, {height = self.startHeight}):ease("linear"):oncomplete(function()
                self.crushing = false
            end)
        end

        self.crushing = true
        self.open = not self.open
    end
end

function Crusher:update(dt, world, override)
    local dy = 0

    -- crusher won't activate until both the Bot and Player are touching it
    if self.waitTwo then
        local yOffset = 10
        local items, len = game.world:queryRect(self.position.x, self.position.y - yOffset, self.width, yOffset)
        local foundBot, foundPlayer = false, false

        for k, item in pairs(items) do
            if item.class and item:isInstanceOf(Bot) then
                foundBot = true
            elseif item.class and item:isInstanceOf(Player) then
                foundPlayer = true
            end
        end

        if foundBot and foundPlayer then
            self:activate()
        end
    end

    if not self.hasMoved then
        if not self.crushing and self.auto then
            self.crushing = true

            Flux.to(self, self.interval/2, {height = 0}):ease("linear"):after(self.interval/2, {height = self.startHeight}):ease("linear"):oncomplete(function()
                self.crushing = false
            end)
        end

        if self.direction == "down" then
            local goal = self.startHeight - self.height
            local moveAmount = self.startPosition.y + goal - self.position.y
            
            -- now move the platform
            local actualX, actualY, collisions = world:move(self, self.position.x, self.position.y + moveAmount, function(item, other)
                if other.class and other:isInstanceOf(Player) then
                    if override then
                        return false
                    else
                        return "cross"
                    end
                end

                if other.class and other:isInstanceOf(Bot) then
                    if self.botDir ~= 0 then
                        --other.direction = self.botDir
                    end
                    if override then
                        return false
                    else
                        return "cross"
                    end
                end

                return "cross"
            end)

            dy = self.position.y - actualY

            self.position.x, self.position.y = actualX, actualY
        end

        world:update(self, self.position.x, self.position.y, math.max(1, self.width), math.max(1, self.height))

        self.prevHeight = self.height
    end

    self.hasMoved = true

    return dy
end

function Crusher:draw()
    love.graphics.setColor(255, 255, 255)

    -- use a scissor
    if self.image then
        local height = math.max(2, self.height)

        if self.direction == "up" then
            love.graphics.setScissor(self.position.x - game.camera.x, self.position.y - game.camera.y, self.width, height + 2)
            love.graphics.draw(self.image, math.floor(self.position.x), math.floor(self.position.y - (self.startHeight - height)))
            love.graphics.setScissor()
        elseif self.direction == "down" then
            love.graphics.setScissor(self.position.x - game.camera.x, self.startPosition.y - game.camera.y, self.width, self.startHeight)

            --local y = math.min(self.position.y, self.startPosition.y + self.startHeight-2)

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

return Crusher