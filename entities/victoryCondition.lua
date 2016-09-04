VictoryCondition = Class("VictoryCondition")

function VictoryCondition:initialize(x, y, w, h, properties)
    self.ID  = properties.ID or 0
    self.ID2 = properties.ID2 or 0

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
        Signal.emit("GameVictory")
    end
end

return VictoryCondition