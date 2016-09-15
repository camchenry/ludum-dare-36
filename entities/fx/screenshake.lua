local ScreenShake = Class('ScreenShake')

function ScreenShake:initialize()
    self.time = 0
    self.timeMax = 2
    self.strength = 0
    self.velocity = Vector(0, 0)
    self.angle = 0

    Signal.register('doorActivate', function(id)
        self:shake(1.5, 2, true) 
    end)
end

function ScreenShake:update(dt)
    self.time = math.max(0, self.time - dt)
end

function ScreenShake:shake(time, strength, dampen)
    self.strength = strength
    self.time = time
    self.dampen = dampen or true

    self.angle = love.math.random(0, math.pi)
    self.velocity = Vector(math.cos(self.angle), math.sin(self.angle))
end

function ScreenShake:getOffset()
    local dx, dy = 0, 0
    if self.time > 0 then
        local dampening = 1

        if self.dampen then
            dampening = math.sqrt(self.time / self.timeMax)
        end

        dx = (love.math.random() - 0.5) * 2 * self.strength * dampening
        dy = (love.math.random() - 0.5) * 2 * self.strength * dampening
    end

    return dx, dy
end
return ScreenShake
