local LevelLoader = Class("LevelLoader")

function LevelLoader:initialize(directory)
    self.directory = directory or "assets/levels/"
end

function LevelLoader:load(level)
    local map = STI(self.directory .. level .. ".lua", {"bump"})
    local objects = {}
    local world = Bump.newWorld()
    map:bump_init(world)

    local function add(obj)
        table.insert(objects, obj)
        world:add(obj, obj.position.x, obj.position.y, obj.width, obj.height)
        return obj
    end

    local objectsLayer = map:addCustomLayer("Objects layer")

    objectsLayer.objects = objects

    function objectsLayer:update(dt)
        for _, obj in ipairs(self.objects) do
            if obj.class and obj:isInstanceOf(Crusher) then
                obj.hasMoved = false
            end
        end

        for _, obj in ipairs(self.objects) do
            if obj.update then
                if obj.class and obj:isInstanceOf(NewCrusher) then
                    obj:update(dt, world)
                end
            end
        end

        for _, obj in ipairs(self.objects) do
            if obj.update then
                if obj.class and not obj:isInstanceOf(NewCrusher) and not obj:isInstanceOf(Player) then
                    obj:update(dt, world)
                end
            end
        end
    end

    function objectsLayer:draw()
        for _, obj in ipairs(self.objects) do
            if obj.draw then
                obj:draw()
            end
        end
    end

    local consoleLayer = map:addCustomLayer("Console layer")

    consoleLayer.console = nil

    function consoleLayer:update(dt)
        if self.console then
            self.console:update(dt)
        end
    end

    function consoleLayer:draw()
        if self.console then
            self.console:draw()
        end
    end

    local textLayer = map:addCustomLayer("Text layer")

    textLayer.items = {}
    
    function textLayer:draw()
        for _, item in pairs(self.items) do
            item:draw()
        end
    end

    local playerLayer = map:addCustomLayer("Player layer")

    playerLayer.player = nil

    function playerLayer:update(dt)
        self.player:update(dt, world)
    end

    function playerLayer:draw()
        self.player:draw()
    end

    for i, object in pairs(map.objects) do
        if object.type == "Wrench" then
            add(Wrench:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "Enemy" then
            add(Enemy:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "MovingPlatform" then
            add(MovingPlatform:new(object.x, object.y, object.width, object.height, object.properties))
        end
        
        if object.type == "Console" then
            consoleLayer.console = Console:new(object.x, object.y, object.width, object.height, object.properties)
        end

        if object.type == "Checkpoint" then
            add(Checkpoint:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "Dropfloor" then
            add(Dropfloor:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "Lever" then
            add(Lever:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "Gate" then
            add(Gate:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "Crusher" then
            add(Crusher:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "Bot" then
            add(Bot:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "Spikes" then
            add(Spikes:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "AreaTrigger" then
            add(AreaTrigger:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "SecretLayer" then
            game.secretLayer = SecretLayer:new(object.x, object.y, object.width, object.height, object.properties)
        end

        if object.type == "ShowText" then
            table.insert(textLayer.items, ShowText:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "Teleport" then
            add(Teleport:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "VictoryCondition" then
            game.victoryCondition = VictoryCondition:new(object.x, object.y, object.width, object.height, object.properties)
        end

        if object.type == "Spawn" then
            playerLayer.player = add(Player:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "NewCrusher" then
            add(NewCrusher:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "Director" then
            add(Director:new(object.x, object.y, object.width, object.height, object.properties))
        end
    end

    return {
        map = map,
        world = world,
        objects = map.objects,
        player = playerLayer.player,
    }
end

return LevelLoader
