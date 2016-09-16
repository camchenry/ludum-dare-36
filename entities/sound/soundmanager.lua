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

    self.sounds.startJump:setVolume(0.5)
    self.sounds.startJump:setPitch(0.9)
    self.sounds.bugDeath:setVolume(0.9)
    self.sounds.hitCeiling:setVolume(0.85)
    self.sounds.wrenchSwing:setPitch(0.9)
    self.sounds.wrenchSwing:setVolume(0.75)

	self.musicVolume = 0.75
    self.currentMusicVolume = 0.75
    self.music = {
        boom = "assets/music/boom.wav",
        ambient1 = "assets/music/ambient1.mp3",
    }
	for name, music in pairs(self.music) do
        self.music[name] = love.audio.newSource(music)
        self.music[name]:setVolume(self.musicVolume)
        self.music[name]:setLooping(true)
	end

    self.music.boom:setLooping(false)

    local signals = {
        'hitCeiling',
        'hitWall',
        'hitGround',
        'startJump',
        'playerDeath',
        'enemyDeath',
        'getWrench',
        -- 'activate',
        'playerFootstep',
        'gameEntered',
        'levelEntered',
        'textActivate',
        'leverActivate',
        'wrenchSwing',
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

    self.lastFootstep = 1
end

function SoundManager:playDelayed(delay, sound)
    Lume.push(self.delays, {sound=sound, delay=delay})
end

function SoundManager:playSequence(...)

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

    if self.currentMusic and self.currentMusic:isPlaying() then
        self.currentMusic:setVolume(self.currentMusicVolume)
    end
end

function SoundManager:onHitCeiling()
    self.sounds.hitCeiling:play()
end

function SoundManager:onHitWall()
    if self.timers.hitWall == 0 then
        self.sounds.hitWall:play()
        self.timers.hitWall = 0.1
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

function SoundManager:onEnemyDeath()
    self.sounds.bugDeath:play()
end

function SoundManager:onGetWrench()
    self.sounds.wrenchPickup:play() 
end

function SoundManager:onWrenchSwing()
    self:playDelayed(0.05, self.sounds.wrenchSwing)
end

function SoundManager:onLeverActivate()
    self.sounds.leverActivate:play()
end

function SoundManager:onTextActivate()
    self.sounds.textActivate:play()
end

function SoundManager:onPlayerFootstep()
    local s = self.sounds["footstep" .. self.lastFootstep]
    s:setVolume(0.10)
    s:setPitch(love.math.random(90, 110)/100)
    s:play()
end

function SoundManager:onGameEntered()

end

function SoundManager:onLevelEntered(level)
    if level == "main_level" then
        self.music.boom:play()

        self.currentMusic = self.music.ambient1
        self.currentMusic:play()
    end
end

return SoundManager
