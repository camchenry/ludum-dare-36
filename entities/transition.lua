local Transition = Class("Transition")

function Transition:initialize()
    self.toState = nil
end

function Transition:update(dt)
    if self.transitioning then
        if Fade:isActive() then
            State.switch(self.toState)
            Fade:unsubscribe("transition")
            self.transitioning = false
        end
    end
end

function Transition:to(state)
    if type(state) == "string" then
        state = _G[state] 
    end
    self.toState = state 

    Fade:subscribe("transition")
    self.transitioning = true
end

return Transition
