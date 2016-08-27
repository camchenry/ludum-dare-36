MovingPlatform = class("MovingPlatform", GameObject)

function MovingPlatform:initialize(x, y, w, h, properties)
	GameObject.initialize(self)
    self.position = vector(x, y)
	self.width = w
	self.height = h
    self.image = love.graphics.newImage("assets/img/movingPlatform.png")
	self.color = {255, 255, 255, 255}
	
	self.leftMargin = properties.left or 3
	self.rightMargin = properties.right or 3
	self.topMargin = properties.top or 3
	self.bottomMargin = properties.bottom or 3

	self.velocity = vector(0, 0)

	self.startX = x
	self.startY = y
	self.minX = self.startX - w * self.leftMargin
	self.maxX = self.startX + w * self.rightMargin
	self.minY = self.startY - h * self.topMargin
	self.maxY = self.startY + h * self.bottomMargin

	self.speed = properties.speed or 50
	self.dirX = properties.dirX or 0
	self.dirY = properties.dirY or 0
end

function MovingPlatform:update(dt, world)
    GameObject.update(self, dt)

    if self.dirX ~= 0 then
	    if self.position.x > self.maxX then
	    	self.dirX = -1
	   	end
	   	if self.position.x < self.minX then
	    	self.dirX = 1
	   	end
	end

	if self.dirY ~= 0 then
	   	if self.position.y > self.maxY then
	    	self.dirY = -1
	   	end

	   	if self.position.y < self.minY then
	    	self.dirY = 1
	   	end
	end

   	local goalX, goalY = self.position.x + self.speed * dt * self.dirX, self.position.y + self.speed * dt * self.dirY

   	-- do a check of what the platform would hit. move the player first if it would hit a player
   	local actualX, actualY, collisions, len = world:check(self, goalX, goalY)

   	if collisions then
        for i=1, #collisions do
        	col = collisions[i]
        	obj = collisions[i].other
           	if obj:isInstanceOf(Player) then -- if the platform would move into a player 
           		obj:tryMove(0, (obj.position.y - col.touch.y) * dt, world) -- not sure why multiplying dt works here
           	end
        end
    end

    -- now move the platform
    local actualX, actualY, collisions = world:move(self, goalX, goalY, function(item, other)
   		if other:isInstanceOf(Player) then
   			return "slide"
    	end

    	return "cross"
    end)

   	self.position.x, self.position.y = actualX, actualY
end

function MovingPlatform:draw()
    GameObject.draw(self)
	love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.image, self.position.x, self.position.y, 0, self.width/32, self.height/32)
end
