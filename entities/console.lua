local Console = Class("Console")

function Console:initialize(x, y, w, h, properties)
    self.position = Vector(x, y)

    self.interval = 3

    self.ID = tonumber(properties.ID) or 0
    self.ID2 = tonumber(properties.ID2) or 0

    self.closedImage = love.graphics.newImage("assets/images/Misc/Room_Gate_GateClosed.png")
    local g = Anim8.newGrid(208, 128, self.closedImage:getWidth(), self.closedImage:getHeight())
    self.closedAnimation = Anim8.newAnimation(g('1-2', 1), self.interval/2)

    self.halfImage = love.graphics.newImage("assets/images/Misc/Room_Gate_HalfOpened.png")
    local g = Anim8.newGrid(208, 128, self.halfImage:getWidth(), self.halfImage:getHeight())
    self.halfAnimation = Anim8.newAnimation(g('1-2', 1), self.interval/2)

    self.openImage = love.graphics.newImage("assets/images/Misc/Room_Gate_Opened.png")

    self.progress = 0

    Signal.register("activate", function(ID)
        if ID == self.ID then
            self.progress = 1
        end
        
        if ID == self.ID2 then
            self.progress = 2
        end
    end)
end

function Console:update(dt)
    self.closedAnimation:update(dt)
    self.halfAnimation:update(dt)
end

function Console:draw()
    if self.progress == 0 then
        self.closedAnimation:draw(self.closedImage, self.position.x, self.position.y)
    elseif self.progress == 1 then
        self.halfAnimation:draw(self.halfImage, self.position.x, self.position.y)
    elseif self.progress == 2 then
        love.graphics.draw(self.openImage, self.position.x, self.position.y)
    end
end

return Console