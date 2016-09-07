local LevelLoader = Class("LevelLoader")

function LevelLoader:initialize(directory)
    self.directory = directory or "assets/levels/"
end

-- TODO refactor out references to the game state
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

    for i, object in pairs(map.objects) do
        if object.type == "Wrench" then
            game.wrench = add(Wrench:new(object.x, object.y, object.width, object.height))
        end

        if object.type == "Enemy" then
            add(Enemy:new(object.x, object.y, object.properties))
        end

        if object.type == "MovingPlatform" then
            local platform = add(MovingPlatform:new(object.x, object.y, object.width, object.height, object.properties))
        end
        
        if object.type == "Console" then
            game.console = Console:new(object.x, object.y, object.width, object.height, object.properties)
        end

        if object.type == "Checkpoint" then
            add(Checkpoint:new(object.x, object.y, object.width, object.height))
        end

        if object.type == "Dropfloor" then
            add(Dropfloor:new(object.x, object.y, object.width, object.height))
        end

        if object.type == "Lever" then
            add(Lever:new(object.x, object.y, object.properties))
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
            table.insert(game.textItems, ShowText:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "Teleport" then
            add(Teleport:new(object.x, object.y, object.width, object.height, object.properties))
        end

        if object.type == "VictoryCondition" then
            game.victoryCondition = VictoryCondition:new(object.x, object.y, object.width, object.height, object.properties)
        end
    end

    return {
        map = map,
        world = world,
        objects = objects,
    }
end

return LevelLoader
