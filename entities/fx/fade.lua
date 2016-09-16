local Fade = Class("Fade")

function Fade:initialize()
    self.subscribers = {}
    self.color = {0, 0, 0, 0}
    self.tween = nil

    self.times = {
        fadeIn = 1,
        fadeOut = 1,
    }

    self.state = "inactive"

    Signal.register("fadeSubscribe", function(...)
        self:onSubscribe(...)
    end)
    Signal.register("fadeUnsubscribe", function(...)
        self:onUnsubscribe(...)
    end)
end

function Fade:update(dt)

end

function Fade:draw()
    love.graphics.push()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.pop()
end

function Fade:subscribe(source)
    self:onSubscribe(source)
end

function Fade:unsubscribe(source)
    self:onUnsubscribe(source)
end

function Fade:onSubscribe(source)
    table.insert(self.subscribers, source)

    if not self:isActive() then
        if self.tween then self.tween:stop() end
        self.tween = Flux.to(self.color, self.times.fadeOut, {0, 0, 0, 255})
            :onstart(function()
                self.state = "fadingOut"
            end)
            :oncomplete(function()
                self.state = "faded"
            end)
    end
end

function Fade:onUnsubscribe(source)
    for i, v in pairs(self.subscribers) do
        if v == source then
            table.remove(self.subscribers, i)
            break
        end
    end

    -- When there are no subscribers left, we remove the overlay
    if #self.subscribers == 0 then
        if self.tween then self.tween:stop() end
        self.tween = Flux.to(self.color, self.times.fadeIn, {0, 0, 0, 0}) 
            :onstart(function()
                self.state = "fadingIn"
            end)
            :oncomplete(function()
                self.state = "inactive"
            end)
    end
end

function Fade:isActive()
    return self.state == "faded"
end

function Fade:isInactive()
    return self.state == "inactive"
end

function Fade:isFadingOut()
    return self.state == "fadingOut"
end

function Fade:isFadingIn()
    return self.state == "fadingIn"
end

function Fade:isFading()
    return self:isFadingOut() or self:isFadingIn()
end

return Fade
