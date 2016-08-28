Crusher = Class("Crusher")

function Crusher:initialize(x, y, w, h, properties)
    self.position = Vector(x-1, y-1)
    self.width = w+1
    self.height = h+1

    self.prevHeight = h+1

    self.startPosition = Vector(x-1, y-1)
    self.startHeight = h+1

    self.direction = properties.dir or "up"

    self.interval = 5
    
    self.crushing = false
end

function Crusher:update(dt, world)
    if not self.crushing then
        self.crushing = true

        Flux.to(self, self.interval/2, {height = 0}):ease("linear"):after(self.interval/2, {height = self.startHeight}):ease("linear"):oncomplete(function()
            self.crushing = false
        end)
    end

    if self.direction == "down" then
        local goal = self.startHeight - self.height
        local moveAmount = self.startPosition.y + goal - self.position.y

        -- do a check of what the platform would hit. move the player first if it would hit a player
        local actualX, actualY, cols, len = world:check(self, self.position.x, self.position.y + moveAmount, function(item, other)
            if other.class and other:isInstanceOf(Player) then
                return "cross"
            end

            return "slide"
        end)

        for k, col in pairs(cols) do
            local other = col.other
            if other.class and other:isInstanceOf(Player) then -- if the platform would move into a player 
                other:tryMove(0, (goal-other.position.y)*dt, world) -- not sure why multiplying dt works here
            end
        end

        -- now move the platform
        local actualX, actualY, collisions = world:move(self, self.position.x, self.position.y + moveAmount, function(item, other)
            if other.class and other:isInstanceOf(Player) then
                return "cross"
            end

            return "cross"
        end)

        self.position.x, self.position.y = actualX, actualY
    end

    world:update(self, self.position.x, self.position.y, math.max(1, self.width), math.max(1, self.height))

    self.prevHeight = self.height
end

function Crusher:draw()
    if DEBUG then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('line', self.position.x+1, self.position.y+1, self.width-1, self.height-1)
    end

    if self.width > 0 and self.height > 0 then
        -- draw image
        -- image may need to use a scissor
    end

    love.graphics.setColor(255, 255, 255)
end

return Crusher