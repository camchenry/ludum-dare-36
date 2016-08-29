local ShowText = Class("ShowText")

function ShowText:initialize(x, y, w, h, properties)
    self.width = w
    self.height = h

    self.ID = tonumber(properties.ID) or 0
    self.imgID = tonumber(properties.img) or 0

    self.showImage = false

    if self.imgID == 1 then
        --self.image = love.graphics.newImage("assets/images/Misc/Room_Gate_TrapDoor.png")
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
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", self.position.x, self.position.y, 20, 20)
    end
end

return ShowText