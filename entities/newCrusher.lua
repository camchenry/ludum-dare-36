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

local NewCrusher = Class("NewCrusher")

function NewCrusher:initialize(x, y, w, h, properties)
    self.width = w
    self.height = h

    self.position = Vector(x, y)
    self.startPosition = Vector(x, y)

    self.on = true
    self.auto = properties.auto or false
    self.direction = properties.dir or "up"
    self.ID = 0

    self.beginState = "outWait"

    self.stateTimes = {
        outWait = 1,
        outTime = 2,
        inWait  = 3,
        inTime  = 4,
    }

    self.nextState = {
      ["outWait"] = "outTime",
      ["outTime"] = "inWait",
      ["inWait"] = "inTime",
      ["inTime"] = "outWait",
    }

    self.currentState = self.beginState
    self.currentStateTime = 0

    self.lastMove = 0

    Signal.register("activate", function(ID)
        if ID == self.ID then
            self.on = not self.on
        end
    end)
end

function NewCrusher:advanceState(world)
    if self.auto or self.on or self.currentState == "outWait" or self.currentState == "inWait" then
        local spareTime = self.currentStateTime - self.stateTimes[self.currentState]

        if self.on or self.currentState == "outWait" or self.currentState == "inWait" then
            self.currentState = self.nextState[self.currentState]
            self.currentStateTime = 0

            world:update(self, self.position.x, self.position.y)

            if not self.auto then
                self.on = false
            end
        end
    end
end

function NewCrusher:move(world, x, y)
    if x ~= self.position.x or y ~= self.position.y then
        self.position.x, self.position.y = x, y

        local extraCheck = 5

        local items, len = world:queryRect(self.position.x, self.position.y - extraCheck, self.width, self.height + extraCheck)

        for k, item in pairs(items) do
            if item.class and item:isInstanceOf(Player) then
                if item.jumpControlTimer <= 0 then
                    local crush = {}
                    if item.position.y <= self.position.y then
                        crush.bottom = true
                        item:move(world, item.position.x, math.floor(self.position.y - item.height), true, crush)
                    else
                        if self.lastMove > 0 then
                            crush.top = true
                            item:move(world, item.position.x, math.floor(self.position.y + self.height), true, crush)
                            
                            item.velocity.y = math.max(0, item.velocity.y)
                        end
                    end
                    
                    item.touchedNewCrusher = true
                    item.touchingGround = true
                end
            end
        end

        world:update(self, self.position.x, self.position.y)
    end
end

function NewCrusher:findGoal()
    local goal = false
    local disp = 0

    -- account for reverse crushers
    if (self.direction == "up" and self.currentState == "outTime") then
        goal = self.startPosition.y + self.height
        disp = self.height
    elseif (self.direction == "up" and self.currentState == "inTime") then
        goal = self.startPosition.y
        disp = -self.height
    elseif (self.direction == "down" and self.currentState == "outTime") then
        goal = self.startPosition.y - self.height
        disp = -self.height
    elseif (self.direction == "down" and self.currentState == "inTime") then
        goal = self.startPosition.y
        disp = self.height
    end

    return goal, disp
end

function NewCrusher:update(dt, world)
    local doMove = true

    self.currentStateTime = self.currentStateTime + dt

    if self.currentStateTime >= self.stateTimes[self.currentState] then
        local goal, disp = self:findGoal()
        if goal then
            self:move(world, self.startPosition.x, goal)
        end
        self:advanceState(world)
        doMove = false
    end

    self.lastMove = 0

    if doMove then
        local dy = 0

        if self.currentState == "outWait" or self.currentState == "inWait" then
            -- do nothing
        elseif self.currentState == "outTime" or self.currentState == "inTime" then
            -- speed = dist / time
            local goal, disp = self:findGoal()

            if goal then
                local time = self.stateTimes[self.currentState]
                local speed = disp / time

                dy = speed * dt
            end
        end

        self.lastMove = dy

        self:move(world, self.position.x, self.position.y + dy)
    end
end

function NewCrusher:draw()
    love.graphics.rectangle('line', self.position.x, math.floor(self.position.y), self.width, self.height)
end

return NewCrusher