local ShowText = Class("ShowText")

function ShowText:initialize(x, y, w, h, properties)
    self.width = w
    self.height = h

    self.ID     = properties.ID or 0
    self.textID = properties.textID or 0

    self.showImage = false

    if self.textID == 1 then
        self.image = love.graphics.newImage("assets/images/Text/GateMonitor.png")
    elseif self.textID == 2 then
        self.image = love.graphics.newImage("assets/images/Text/1stSkeletonMonitor.png")
    elseif self.textID == 3 then
        self.image = love.graphics.newImage("assets/images/Text/2ndSkeletonMonitor.png")
    elseif self.textID == 4 then
        self.image = love.graphics.newImage("assets/images/Text/OldManIntro.png")
    elseif self.textID == 5 then
        self.image = love.graphics.newImage("assets/images/Text/CoreRoomMonitor1.png")
    elseif self.textID == 6 then
        self.image = love.graphics.newImage("assets/images/Text/CoreRoomMonitor2.png")
    elseif self.textID == 7 then
        self.image = love.graphics.newImage("assets/images/Text/CoreRoomMonitor3.png")
    elseif self.textID == 8 then
        self.image = love.graphics.newImage("assets/images/Text/CoreRoomMonitor4.png")
    elseif self.textID == 9 then
        self.image = love.graphics.newImage("assets/images/Text/CoreRoomMonitor5.png")
    end

    self.position = Vector(x+w/2, y+h/2)

    if self.image then
        self.position = Vector(self.position.x - self.image:getWidth()/2, self.position.y - self.image:getHeight()/2)
    end

    Signal.register("activate", function(ID)
        if ID == self.ID then
            self.showImage = not self.showImage
        end
    end)
end

function ShowText:update(dt, world)

end

function ShowText:draw()
    if self.showImage then
        if self.image then
            love.graphics.draw(self.image, self.position.x, self.position.y)
        end
    end
end

return ShowText
