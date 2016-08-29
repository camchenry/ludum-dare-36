VictoryCondition = Class("VictoryCondition")

function VictoryCondition:initialize()
    self.ID = tonumber(properties.ID) or 0
    self.ID2 = tonumber(properties.ID2) or 0

    self.condition1 = false
    self.condition2 = false

    Signal.register("activate", function(ID)
        if ID == self.ID then
            self.condition1 = true
        end
        if ID == self.ID2 then
            self.condition2 = true
        end
        self:check()
    end)
end

function VictoryCondition:check()
    if self.condition1 and self.condition2 then
        signal.emit("GameVictory")
    end
end

return VictoryCondition