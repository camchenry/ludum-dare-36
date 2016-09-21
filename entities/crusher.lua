local Crusher = Class("Crusher", Object)

function Crusher:initialize(x, y, w, h, properties)
	Object.initialize(self, x, y, w, h, properties)
    self.name = "Crusher"

    self.prevHeight = h

    self.startPosition = Vector(x, y)
    self.startHeight = h

    self.direction    = properties.dir or "up"
    self.ID           = properties.ID or 0
    self.botDir       = properties.botDir or 0
    self.imgID        = properties.img or 0
    self.retractTime  = properties.retractTime or 1.0
    self.crushTime    = properties.crushTime or 1.0
    self.waitTime     = properties.waitTime or 1.0
    self.activateOnce = properties.activateOnce or false
    self.auto         = properties.auto or true
    self.waitPlayer   = properties.waitPlayer or false
    self.waitBot      = properties.waitBot or false
    self.resetItem    = properties.reset or true
    self.startOpen    = properties.startOpen or false
	
	self.name = "Crusher"

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
    elseif self.imgID == 15 then
        self.image = love.graphics.newImage("assets/images/Misc/PuzzleRoom2_Crusher.png")
    elseif self.imgID == 16 then
        self.image = love.graphics.newImage("assets/images/Misc/PuzzleRoom2_ExitElevator.png")
    elseif self.imgID == 18 then
        self.image = love.graphics.newImage("assets/images/Misc/PuzzleRoom2_LongElevator.png")
    elseif self.imgID == 19 then
        self.image = love.graphics.newImage("assets/images/Misc/PuzzleRoom2_SmallElevator.png")
    elseif self.imgID == 22 then
        self.image = love.graphics.newImage("assets/images/Misc/RoomPuzzle3_SmallDoors.png")
    elseif self.imgID == 23 then
        self.image = love.graphics.newImage("assets/images/Misc/RoomPuzzle3_Elevator.png")
    end

    self.hasBeenActivated = false
    self.hasMoved = false
    self.crushing = true

    if self.startOpen then
        --self.crushing = true
        --self.hasMoved = true
        self.open = false

        if self.direction == "up" then
            self.height = 1
        elseif self.direction == "down" then
            self.height = 1
        elseif self.direction == "left" then
            self.width = 1
        elseif self.direction == "right" then
            self.width = 1
        end
    else
        self.open = true
    end

    if self.waitTween then
        self.waitTween:stop()
        self.waitTween = nil
    end

    self.waitTween = Flux.to(self, self.waitTime, {}):oncomplete(function()
        self.crushing = false
        self.waitTween = nil
    end)

    Signal.register("activate", function(ID)
        if ID == self.ID then
            if not self.activating then
                self:activate()
            end
        end
    end)
end

function Crusher:reset()
    if self.resetItem then
        if self.moveTween then
            self.moveTween:stop()
            self.moveTween = nil
        end

        self.height = self.startHeight
        self.prevHeight = self.startHeight

        self.position = Vector(self.startPosition.x, self.startPosition.y)
        game.world:update(self, self.position.x, self.position.y, math.max(1, self.width), math.max(1, self.height))

        if self.startOpen then
            self.open = false
            if self.direction == "up" then
                self.height = 1
            elseif self.direction == "down" then
                self.height = 1
            elseif self.direction == "left" then
                self.width = 1
            elseif self.direction == "right" then
                self.width = 1
            end
        else
            self.open = true
        end

        self.hasBeenActivated = false
        self.hasMoved = false
        self.crushing = true

        if self.waitTween then
            self.waitTween:stop()
            self.waitTween = nil
        end

        if game.world:hasItem(self) then
            game.world:update(self, self.position.x, self.position.y, math.max(1, self.width), math.max(1, self.height))
        end

        self.waitTween = Flux.to(self, self.waitTime, {}):oncomplete(function()
            self.crushing = false
            self.waitTween = nil
        end)
    end
end

function Crusher:activate()
    if not self.crushing and not self.auto and not self.moveTween and not self.hasBeenActivated and not self.waitTween then
        if self.open then
            if self.moveTween then
                self.moveTween:stop()
                self.moveTween = nil
            end

            self.moveTween = Flux.to(self, self.retractTime, {height = 0}):ease("linear"):oncomplete(function()
                self.moveTween = nil
                self.crushing = false
            end)
        else
            if self.moveTween then
                self.moveTween:stop()
                self.moveTween = nil
            end

            self.moveTween = Flux.to(self, self.crushTime, {height = self.startHeight}):ease("linear"):oncomplete(function()
                self.moveTween = nil
                self.crushing = false
            end)
        end

        self.crushing = true
        self.open = not self.open
    end

    self.hasBeenActivated = true
end

function Crusher:update(dt, world, override)
    local dy = 0

    -- crusher won't activate until both the Bot and Player are touching it
    if self.waitPlayer or self.waitBot then
        local yOffset = 4
        local items, len = game.world:queryRect(self.position.x, self.position.y - yOffset, self.width, yOffset)
        local foundBot, foundPlayer = false, false

        for k, item in pairs(items) do
            if item.class and item:isInstanceOf(Bot) then
                foundBot = true
            elseif item.class and item:isInstanceOf(Player) then
                foundPlayer = true
            end
        end

        if ( (not self.waitPlayer) or (self.waitPlayer and foundPlayer) ) and ( (not self.waitBot or (self.waitBot and foundBot) ) ) then
            self:activate()
        end
    end

    if not self.hasMoved then
        if not self.moveTween then
            if not self.crushing and (self.auto or (self.waitPlayer and game.player.position.y > self.position.y + 20)) then
                self.crushing = true

                self.moveTween = Flux.to(self, self.retractTime, {height = 0}):ease("linear"):after(self.crushTime, {height = self.startHeight}):ease("linear"):oncomplete(function()
                    self.crushing = false
                    self.moveTween = nil
                end)
            end
        end

        if self.direction == "down" then
            local goal = self.startHeight - self.height
            local moveAmount = self.startPosition.y + goal - self.position.y
            
            -- now move the platform
            local actualX, actualY, collisions = world:check(self, self.position.x, self.position.y + moveAmount, function(item, other)
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

            self.position.y = self.position.y + moveAmount
        end

        if self.moveTween then
            world:update(self, self.position.x, self.position.y, math.max(1, self.width), math.max(1, self.height))
            self.prevHeight = self.height
        end
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

function Crusher:drawDebug(x, y)
	Object.drawDebug(self, x, y, propertyStrings)
end

return Crusher