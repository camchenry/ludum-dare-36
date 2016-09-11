-- BUG: bots need a way to tell if a crusher is moving, or is in a state of waiting, whether from being off or from being in a waiting state

-- Specifications:

-- There are 2 ways a collision can occur:
-- it moves into something
-- something moves into it

-- Phase 1:
-- moves up and down
-- width and height do not change
-- cycles of movement that act as follows: outWait, outTime, inWait, inTime
-- once the end of each step is reached, excess time from that frame will carry over into the next step, only if the next step has a time greater than 0
-- excess time will not carry over for more than 1 step

-- Phase 2
-- activatable by trigger
-- triggers can either cause a single movement if auto is disabled
-- or start/stop continuous movement if auto
-- stopping a continuous movement should always ensure that it reaches the next stopping point, first

-- Phase 3:
-- if a player is on top of it, they are moved up with it, but still have the ability to jump
-- if a player is below it, they are pushed down
-- player being top or below may cause crushing
-- if the player is to the left or right, they should not be able to move into its

-- Phase 4:
-- bot should be able to be lifted by it
-- bot centered on it while it is moving
-- determines the direction of the bot after it is done moving

local NewCrusher = Class("NewCrusher", Object)

NewCrusher.static.images = {}
NewCrusher.static.images[1] = love.graphics.newImage("assets/images/Misc/Room_Gate_TrapDoor.png")
NewCrusher.static.images[2] = love.graphics.newImage("assets/images/Misc/Room4_Crusher.png")
NewCrusher.static.images[3] = love.graphics.newImage("assets/images/Misc/Room5_UpwardCrusher.png")
NewCrusher.static.images[4] = love.graphics.newImage("assets/images/Misc/Room6_Door.png")
NewCrusher.static.images[5] = love.graphics.newImage("assets/images/Misc/Room7_TrapDoor.png")

NewCrusher.static.images[6] = love.graphics.newImage("assets/images/Misc/Room9_LargeTrapDoor.png")
NewCrusher.static.images[7] = love.graphics.newImage("assets/images/Misc/Room9_SmallTrapDoor.png")
NewCrusher.static.images[8] = love.graphics.newImage("assets/images/Misc/Room10_Crushers.png")
NewCrusher.static.images[9] = love.graphics.newImage("assets/images/Misc/Room11_Door.png")
NewCrusher.static.images[10] = love.graphics.newImage("assets/images/Misc/puzzleRoom1_LargeElevator.png")

NewCrusher.static.images[11] = love.graphics.newImage("assets/images/Misc/PuzzleRoom1_SmallElevator_FirstPart.png")
NewCrusher.static.images[12] = love.graphics.newImage("assets/images/Misc/PuzzleRoom1_SmallElevator_SecondPart.png")
NewCrusher.static.images[13] = love.graphics.newImage("assets/images/Misc/PuzzleRoom1_TrapDoor_GoingLeft.png")
NewCrusher.static.images[14] = love.graphics.newImage("assets/images/Misc/PuzzleRoom1_TrapDoor_GoingRight.png")
NewCrusher.static.images[15] = love.graphics.newImage("assets/images/Misc/PuzzleRoom2_Crusher.png")

NewCrusher.static.images[16] = love.graphics.newImage("assets/images/Misc/PuzzleRoom2_ExitElevator.png")
NewCrusher.static.images[17] = love.graphics.newImage("assets/images/Misc/PuzzleRoom2_Gate.png")
NewCrusher.static.images[18] = love.graphics.newImage("assets/images/Misc/PuzzleRoom2_LongElevator.png")
NewCrusher.static.images[19] = love.graphics.newImage("assets/images/Misc/PuzzleRoom2_SmallElevator.png")
NewCrusher.static.images[20] = love.graphics.newImage("assets/images/Misc/PuzzleRoom2_SmallTrapDoor.png")

NewCrusher.static.images[21] = love.graphics.newImage("assets/images/Misc/RoomPuzzle3_Bridges.png")
NewCrusher.static.images[22] = love.graphics.newImage("assets/images/Misc/RoomPuzzle3_SmallDoors.png")
NewCrusher.static.images[23] = love.graphics.newImage("assets/images/Misc/RoomPuzzle3_Elevator.png")


function NewCrusher:initialize(x, y, w, h, properties)
    Object.initialize(self, x, y, w, h, properties)
    self.name = "NewCrusher"

    self.startPosition = Vector(x, y)
    self.startWidth, self.startHeight = w, h

    self.on           = properties.on or false
    self.auto         = properties.auto or false
    self.direction    = properties.direction or "up"
    self.ID           = properties.ID or 0
    self.augment      = properties.augment or "none"
    self.elevator     = properties.elevator or false
    self.clickable    = properties.clickable or false
    self.imgID        = properties.imgID or 0

    self.collidable = true

    self.horizontal = (self.direction == "left" or self.direction == "right")
    self.reverse = (self.direction == "up" or self.direction == "left")

    self.moving = false
    self.waiting = true
    self.finishedMovement = false

    self.image = nil
    if NewCrusher.images[self.imgID] then
        self.image = NewCrusher.images[self.imgID]
    end

    self.beginState = 1
    self.currentState = self.beginState
    self.currentStateTime = 0

    self.offset = 0

    self.stateTimes = {
        properties.outWait or 1,
        properties.outTime or 1,
        properties.inWait  or 1,
        properties.inTime  or 1,
    }
    assert(#self.stateTimes % 2 == 0, "Number of states must be even")

    self.lastMove = 0

    Signal.register("activate", function(ID, ID2)
        if ID == self.ID or ID2 == self.ID then
            self:activate()
        end
    end)
end

function NewCrusher:activate(clicked)
    if not clicked or self.clickable then
        self.on = not self.on
    end
end

function NewCrusher:getNextState()
    return self.currentState == #self.stateTimes and 1 or self.currentState + 1
end

function NewCrusher:advanceState(world)
    if self.auto or self.on or self.waiting then
        local spareTime = self.currentStateTime - self.stateTimes[self.currentState]

        if self.on or self.waiting then
            self.currentState = self:getNextState(self.currentState)
            self.currentStateTime = 0

            if not self.auto then
                self.on = false
            end

            self.moving = not self.moving
            self.waiting = not self.waiting
        end
    end
end

function NewCrusher:move(world, x, y, w, h)
    --if x ~= self.position.x or y ~= self.position.y then
        self.position.x, self.position.y = x, y
        self.width, self.height = w, h

        local extraCheck = 0

        local items, len = world:queryRect(self.position.x, self.position.y - extraCheck, self.width, self.height + extraCheck)

        for k, item in pairs(items) do
            if item.pushable then
                local crush = {}
                if self.horizontal then
                    if item.position.x <= self.position.x then
                        crush.right = true
                        item:move(world, x - item.width, item.position.y, true, crush, self)
                    else
                        crush.left = true
                        item:move(world, x + self.width, item.position.y, true, crush, self)
                    end
                else
                    if item.position.y <= self.position.y then
                        if not item.jumpControlTimer or item.jumpControlTimer <= 0 then
                            crush.bottom = true

                            local x = item.position.x
                            if item.controlled then
                                x = self.position.x + self.width/2 - item.width/2
                                item:move(world, x, self.position.y - item.height, false)
                            else
                                item:move(world, x, self.position.y - item.height, true, crush, self)
                            end

                            item.touchedNewCrusher = true
                            item.touchingGround = true
                        end
                    else
                        crush.top = true
                        item:move(world, item.position.x, self.position.y + self.height, true, crush)
                        
                        item.velocity.y = math.max(0, item.velocity.y)
                    end
                end
            end
        end

        world:update(self, self.position.x, self.position.y, math.max(1, self.width), math.max(1, self.height))
    --end
end

function NewCrusher:findGoal()
    local goal = 0

    if self.currentState == 1 or self.currentState == 4 then
        goal = 1
    end

    return goal, disp
end

function NewCrusher:getSpeed()
    local goal, disp = self:findGoal()

    if goal then
        local time = self.stateTimes[self.currentState]
        return disp / time
    end

    return 0
end

function NewCrusher:update(dt, world)
    self.finishedMovement = false

    local doMove = true

    self.currentStateTime = self.currentStateTime + dt

    if self.currentStateTime >= self.stateTimes[self.currentState] then
        self.finishedMovement = true
        self:advanceState(world)

        -- this ensures an offset fully reaches its end
        if self.offset > 0.5 then
            self.offset = 1
        else
            self.offset = 0
        end
    end

    self.lastMove = 0

    self.height = self.startHeight * (1 - self.offset)

    if doMove then
        local dy = 0

        if not self.waiting then
            local goal = 0

            if self.currentState == 1 or self.currentState == 4 then
                goal = 1
            end

            local time = self.stateTimes[self.currentState]
            local speed = 1 / time

            dy = speed * dt

            if self.currentState == 2 or self.currentState == 3 then
                dy = dy * -1
            end

            if self.reverse then
                dy = dy * -1
            end

            self.offset = self.offset + dy
            self.offset = math.max(0, math.min(1, self.offset))
        end

        self.lastMove = dy

        local x, y, width, height = self.startPosition.x, self.startPosition.y, self.startWidth, self.startHeight

        if self.elevator then
            if self.horizontal then
                width = width * (1 - self.offset)
            else
                height = height * (1 - self.offset)
            end
        end

        if not self.elevator or not self.reverse then
            if self.horizontal then
                x = x + self.offset * self.startWidth
            else
                y = y + self.offset * self.startHeight
            end
        end

        self:move(world, x, y, width, height)
    end
end

function NewCrusher:draw(debugOverride)
    love.graphics.setColor(255, 255, 255)
    if self.augment == "red" then
        love.graphics.setColor(255, 0, 0)
    elseif self.augment == "green" then
        love.graphics.setColor(0, 255, 0)
    elseif self.augment == "blue" then
        love.graphics.setColor(0, 0, 255)
    end
    
    love.graphics.rectangle('fill', self.position.x, self.position.y, self.width, self.height)

    if self.image then
        if self.elevator then
            local x1, y1 = game:cameraCoords(self.startPosition.x, self.startPosition.y)
            local x2, y2 = game:cameraCoords(self.startPosition.x + self.startWidth, self.startPosition.y + self.startHeight)
            local w, h = x2 - x1, y2 - y1
            love.graphics.setScissor(self.startPosition.x - game.camera.x + CANVAS_WIDTH/2, self.startPosition.y - game.camera.y + CANVAS_HEIGHT/2, self.startWidth, self.startHeight)
            LASTPOS = {x = self.startPosition.x - game.camera.x + CANVAS_WIDTH/2, y = self.startPosition.y - game.camera.y + CANVAS_HEIGHT/2}
        end

        love.graphics.draw(self.image, self.position.x - (self.startWidth - self.width), self.position.y - (self.startHeight - self.height))
    
        love.graphics.setScissor()
    end

    Object.draw(self, debugOverride)
end

function NewCrusher:drawDebug(x, y)
    local propertyStrings = {
        "Offset: " .. self.offset,
        "Current State: " .. self.currentState,
        "ID: " .. self.ID,
        "Direction: " .. self.direction,
        "Moving: " .. (self.moving and "true" or "false"),
        "Waiting: " .. (self.waiting and "true" or "false"),
        "Finished Movement: " .. (self.finishedMovement and "true" or "false"),
        "Auto: " .. (self.auto and "true" or "false"),
        "On: " .. (self.on and "true" or "false"),
    }

    Object.drawDebug(self, x, y, propertyStrings)
end

return NewCrusher
