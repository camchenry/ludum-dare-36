local LevelTransition = Class("LevelTransition")

function LevelTransition:initialize()
    -- this tells which state to work on
    self.workingState = game

    -- the loader to use for loading levels
    self.loader = LevelLoader:new()
end

function LevelTransition:update(dt)
    if self.transitioning then
        if Fade:isActive() then
            Signal.emit("levelEntered", self.toLevel)
            self.workingState.level = self.loader:load(self.toLevel)
            self.workingState.player = self.workingState.level.player
            Fade:unsubscribe("leveltransition")
            self.transitioning = false
        end
    end
end

function LevelTransition:to(level)
    self.toLevel = level 
    Fade:subscribe("leveltransition")
    self.transitioning = true
end

return LevelTransition
