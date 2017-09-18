local AudioControl = class("AudioControl",nil)

AudioControl._MusicStatus = true
AudioControl._MusicVolume = 1.0
AudioControl._EffectStatus = true
AudioControl._EffectVolume = 1.0

function AudioControl.create()
    local data = AudioControl.new()
    data:init()
    return data
end

function AudioControl:init()
    if cc.UserDefault:getInstance():getBoolForKey("isXMLFileExist") then
        print("---isXMLFileExist-----")
        self._MusicStatus  = cc.UserDefault:getInstance():getBoolForKey("musicStatus",true)
        self._MusicVolume  = cc.UserDefault:getInstance():getFloatForKey("musicVolume",1.0)
        self._EffectStatus = cc.UserDefault:getInstance():getBoolForKey("effectStatus",true)
        self._EffectVolume = cc.UserDefault:getInstance():getFloatForKey("effectVolume",1.0)
    else
        self._MusicStatus  = true
        self._MusicVolume  = 1.0
        self._EffectStatus = true
        self._EffectVolume = 1.0
        cc.UserDefault:getInstance():setBoolForKey("isXMLFileExist", true)
    end

    if self._MusicVolume > 0 then
        self._MusicStatus = true
    end
    if self._EffectVolume > 0 then
        self._EffectStatus = true
    end
    
    self:setMusicStatus(self._MusicStatus)
    self:setMusicVolume(self._MusicVolume)
    self:setEffectStatus(self._EffectStatus)
    self:setEffectsVolume(self._EffectVolume)
    self.keyID = 0

end

-- function AudioControl:end()
--     AudioEngine:end()
-- end


--------------------------------------------------------------------------------
--------------------------------BackgroundMusic---------------------------------
--------------------------------------------------------------------------------

function AudioControl:playMusic( pszFilePath, bLoop)
    if self._MusicStatus then
        AudioEngine.playMusic(pszFilePath, bLoop)
    end
end

function AudioControl:stopMusic(releaseData)
    AudioEngine.stopMusic(releaseData)
end

function AudioControl:pauseMusic()
    AudioEngine.pauseMusic()
end

function AudioControl:resumeMusic()
    if self._MusicStatus then
        AudioEngine.resumeMusic()
    end
end

--循环播放
function AudioControl:rewindMusic()
    AudioEngine.rewindMusic()
end

-- function AudioControl:willPlayBackgroundMusic()
--     if self._MusicStatus then
--         return AudioEngine.willPlayBackgroundMusic();
--     else
--         return false;
--     end
-- end

function AudioControl:isMusicPlaying()
    if self._MusicStatus then
        return AudioEngine.isMusicPlaying()
    else
        return false;
    end
end

function AudioControl:preloadMusic(pszFilePath)
    if self._MusicStatus then
        AudioEngine.preloadMusic(pszFilePath)
    end
end

--------------------------------------------------------------------------------
-------------------------------------effect-------------------------------------
--------------------------------------------------------------------------------

function AudioControl:playEffect(pszFilePath, bLoop, pitch, pan, gain)
    if self._EffectStatus then
        return AudioEngine.playEffect(pszFilePath, bLoop, pitch, pan, gain)
    end
    return 0;
end

function AudioControl:stopAllEffects()
    AudioEngine.stopAllEffects()
end

function AudioControl:preloadEffect( pszFilePath)
    AudioEngine.preloadEffect(pszFilePath)
end

function AudioControl:stopEffect(nSoundId)
    AudioEngine.stopEffect(nSoundId)
end

function AudioControl:pauseEffect(nSoundId)
    AudioEngine.pauseEffect(nSoundId)
end

function AudioControl:resumeEffect(nSoundId)
    if self._EffectStatus then
        AudioEngine.resumeEffect(nSoundId)
    end
end

function AudioControl:pauseAllEffects()
    AudioEngine.pauseAllEffects()
end

function AudioControl:resumeAllEffects()
    if self._EffectStatus then
        AudioEngine.resumeAllEffects()
    end
end

function AudioControl:unloadEffect(filePath)
    AudioEngine.unloadEffect(filePath)
end

--------------------------------------------------------------------------------
--------------------------------volume interface--------------------------------
--------------------------------------------------------------------------------

function AudioControl:getMusicVolume()
    return self._MusicVolume
    --return AudioEngine.getBackgroundMusicVolume();
end

function AudioControl:setMusicVolume(volume)
    self._MusicVolume = volume;
    AudioEngine.setMusicVolume(volume)

    local dataTab = {}
    dataTab.funName = "AudioControl"
    dataTab.setType = 3
    dataTab.BackgroundMusicVolume = volume
    LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
end

function AudioControl:getEffectsVolume()
    return self._EffectVolume
    --return AudioEngine.getEffectsVolume();
end

function AudioControl:setEffectsVolume(volume)
    self._EffectVolume = volume
    AudioEngine.setEffectsVolume(volume)

    local dataTab = {}
    dataTab.funName = "AudioControl"
    dataTab.setType = 4
    dataTab.EffectVolume = volume
    LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
end

function AudioControl:setMusicStatus(status)
    self._MusicStatus = status

    local dataTab = {}
    dataTab.funName = "AudioControl"
    dataTab.setType = 1
    dataTab.MusicStatus = status
    LuaCppAdapter:getInstance():luaUseCppFun(dataTab)

end

function AudioControl:getMusicStatus()
    return self._MusicStatus
end

function AudioControl:setEffectStatus(status)
    self._EffectStatus = status

    local dataTab = {}
    dataTab.funName = "AudioControl"
    dataTab.setType = 2
    dataTab.EffectStatus = status
    LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
end

function AudioControl:getEffectStatus()
    return self._EffectStatus
end

function AudioControl:flushData()
    local effectStatus = self:getEffectStatus()
    cc.UserDefault:getInstance():setBoolForKey("effectStatus", effectStatus)  
    
     local musicStatus = self:getMusicStatus()
    cc.UserDefault:getInstance():setBoolForKey("musicStatus", musicStatus)

    local effectsVolume = self:getEffectsVolume()
    cc.UserDefault:getInstance():setFloatForKey("effectVolume", effectsVolume)

    local musicVolume = self:getMusicVolume()
    cc.UserDefault:getInstance():setFloatForKey("musicVolume", musicVolume)
    
    cc.UserDefault:getInstance():flush()

end

function AudioControl:playLayerBgMusic()
    print("-00000-FishGI.AudioControl:playLayerBgMusic()--")
    local musicName = nil
    local keyID = nil

    local curScene = cc.Director:getInstance():getRunningScene();
    local sceneName = curScene.sceneName
    if sceneName == "game" then
        keyID = FishGI.curGameRoomID + 910000000
        musicName = tostring(FishGI.GameConfig:getConfigData("room", tostring(keyID), "bg_music"))
    else
        keyID = 990000014
        musicName = tostring(FishGI.GameConfig:getConfigData("config",tostring(keyID), "data"));
    end

    if FishGI.isBossComing then
        keyID = 10000000
        musicName = "music_bosscome.mp3"
    end

    if self._MusicStatus then
        if not FishGI.AudioControl:isMusicPlaying() then
            self.keyID = keyID
            FishGI.AudioControl:playMusic("sound/"..musicName,true)
        else
            if keyID ~= self.keyID then
                print("-----keyID="..keyID.."----self.keyID="..self.keyID)
                self.keyID = keyID
                FishGI.AudioControl:playMusic("sound/"..musicName,true)
            end
        end
    else
        FishGI.AudioControl:pauseMusic()
    end
end

return AudioControl