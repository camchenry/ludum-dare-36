local LevelTransition = Class("LevelTransition")

function LevelTransition:initialize(state)
    -- this tells which state to work on
    self.workingState = game

    -- the loader to use for loading levels
    self.loader = LevelLoader:new()
end

function LevelTransition:update(dt)
    if self.transitioning then
        if Fade:isActive() then
            -- TODO level transition knows too much about loading the level?
            local level = self.loader:load(self.toLevel)
            self.workingState.level = level
            self.workingState.map = level.map
            self.workingState.objects = level.objects
            self.workingState.world = level.world
            self.workingState.player = level.player
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
