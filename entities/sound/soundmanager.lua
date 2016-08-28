local SoundManager = Class('SoundManager')

function SoundManager:initialize(directory)
	self.directory = directory or "assets/sounds/"

	function getFileName(url)
		return url:match("^.+/(.+)$")
	end

	function removeFileExtension(url)
		return url:gsub(".[^.]+$", "")
	end

	self.soundVolume = 1.0
	self.sounds = {}
	local files = love.filesystem.getDirectoryItems(self.directory)
	for i, file in pairs(files) do
		local path = self.directory .. file
		if love.filesystem.isFile(path) then
			local name = removeFileExtension(getFileName(path))
			self.sounds[name] = love.audio.newSource(path)
			self.sounds[name]:setVolume(self.soundVolume)
		end
	end

    self.sounds.startJump:setVolume(0.8)

    local signals = {
        'hitCeiling',
        'hitWall',
        'hitGround',
        'startJump',
        'playerDeath',
        'getWrench',
        'activate',
    }

    local function firstToUpper(str)
        return (str:gsub("^%l", string.upper))
    end

    for _, signal in ipairs(signals) do
        Signal.register(signal, function(...)
            self["on" .. firstToUpper(signal)](self, ...)
        end)
    end

    self.timers = {}
    for _, signal in ipairs(signals) do
        self.timers[signal] = 0
    end

    self.delays = {}
end

function SoundManager:playDelayed(delay, sound)
    Lume.push(self.delays, {sound=sound, delay=delay})
end

function SoundManager:playSequence(...)
    -- local t = 0
    -- for i, sound in ipairs(sounds) do
    --     self:playDelayed(t, sound)
    --     t = t + sound:tell()
    -- end
end

function SoundManager:update(dt)
    for signal, time in pairs(self.timers) do
        self.timers[signal] = math.max(0, time - dt)
    end

    for i=#self.delays, 1, -1 do
        local sound = self.delays[i]
        sound.delay = math.max(0, sound.delay - dt)

        if sound.delay == 0 then
            sound.sound:play()
            table.remove(self.delays, i)
        end
    end
end

function SoundManager:onHitCeiling()
    self.sounds.hitCeiling:play()
end

function SoundManager:onHitWall()
    if self.timers.hitWall == 0 then
        self.sounds.hitWall:play()
        self.timers.hitWall = 0.5
    end
end

function SoundManager:onStartJump()
    self.sounds.startJump:play()
end

function SoundManager:onHitGround()
    self.sounds.landing:play()
end

function SoundManager:onPlayerDeath()
    self.sounds.deathScream:play()

    self:playDelayed(0.175, self.sounds.respawn)
end

function SoundManager:onGetWrench()
    self.sounds.wrenchPickup:play() 
end

function SoundManager:onActivate()
    self.sounds.leverActivate:play()
end

return SoundManager
