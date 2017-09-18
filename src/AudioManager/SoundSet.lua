
local SoundSet = class("SoundSet", cc.load("mvc").ViewBase)

SoundSet.AUTO_RESOLUTION   = false
SoundSet.RESOURCE_FILENAME = "ui/common/uisoundset"
SoundSet.RESOURCE_BINDING  = {  
    ["panel"]         = { ["varname"] = "panel" },
    ["btn_close"]     = { ["varname"] = "btn_close" ,                 ["events"]={["event"]="click",["method"]="onClickclose"}},   
    
    ["slider_music"]  = { ["varname"] = "slider_music" }, 
    ["slider_effect"] = { ["varname"] = "slider_effect" },  
}

function SoundSet:onCreate(...)
    self.slider_music:setMaxPercent(120)
    self.slider_music:addEventListener(handler(self,self.sliderCallback))
    self.slider_effect:setMaxPercent(120)
    self.slider_effect:addEventListener(handler(self,self.sliderCallback))

    self:initData()

    self:openTouchEventListener()

    self.slider_music:setTag(1)
    self.slider_effect:setTag(2)

end

function SoundSet:initData(  )
    local musicvolume = FishGI.AudioControl:getMusicVolume()
    self.slider_music:setPercent(tonumber(musicvolume)*100+10)
    local effectsvolume = FishGI.AudioControl:getEffectsVolume()
    self.slider_effect:setPercent(tonumber(effectsvolume)*100+10)
end

function SoundSet:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function SoundSet:onClickclose( sender )
    self:hideLayer(true)
end

function SoundSet:sliderCallback(sender,eventType)
    local tag = sender:getTag()
    if eventType == ccui.SliderEventType.slideBallDown then
        local curPer = sender:getPercent()
        if curPer < 10 then
            curPer = 10
        elseif curPer > 110 then
            curPer = 110
        end
        sender:setPercent(curPer)
    elseif eventType == ccui.SliderEventType.percentChanged  then
        local curPer = sender:getPercent()
        if curPer < 10 then
            curPer = 10
        elseif curPer > 110 then
            curPer = 110
        end
        sender:setPercent(curPer)
        --self:setVolumeByPer(tag,curPer)
    elseif eventType == ccui.SliderEventType.slideBallUp then
        local curPer = sender:getPercent()
        if curPer < 10 then
            curPer = 10
        elseif curPer > 110 then
            curPer = 110
        end
        sender:setPercent(curPer)
        self:setVolumeByPer(tag,curPer)
        -- if tag == 1 then
        --     cc.UserDefault:getInstance():setStringForKey("musicvolume",tostring(curPer))
        -- elseif tag == 2 then
        --     cc.UserDefault:getInstance():setStringForKey("effectsvolume",tostring(curPer))
        -- end
        -- cc.UserDefault:getInstance():flush()

    elseif eventType == ccui.SliderEventType.slideBallCancel then
        local curPer = sender:getPercent()
        if curPer < 10 then
            curPer = 10
        elseif curPer > 110 then
            curPer = 110
        end
        sender:setPercent(curPer)
        self:setVolumeByPer(tag,curPer)
        -- if tag == 1 then
        --     cc.UserDefault:getInstance():setStringForKey("musicvolume",tostring(curPer))
        -- elseif tag == 2 then
        --     cc.UserDefault:getInstance():setStringForKey("effectsvolume",tostring(curPer))
        -- end
        -- cc.UserDefault:getInstance():flush()
    end
end

function SoundSet:setVolumeByPer(tag, curPer )
    local tag = tag
    FishGF.print("---setVolumeByPer---tag="..tag)
    if curPer == nil then
        curPer = 110
    end
    local volume = curPer -10
    print("--volume="..volume)

    if tag == 1 then
        FishGI.AudioControl:setMusicVolume(volume/100)
        if volume <= 0 then
            FishGI.AudioControl:setMusicStatus(false)
            FishGI.AudioControl:pauseMusic()
        else
            if not FishGI.AudioControl:getMusicStatus() then
                FishGI.AudioControl:setMusicStatus(true)
                FishGI.AudioControl:playLayerBgMusic()
            end
        end

        FishGI.AudioControl:flushData()

    elseif tag == 2 then
        FishGI.AudioControl:setEffectsVolume(volume/100)
        if volume <= 0 then
            FishGI.AudioControl:setEffectStatus(false)
            FishGI.AudioControl:stopAllEffects()
        else
            FishGI.AudioControl:setEffectStatus(true)
        end
        FishGI.AudioControl:flushData()

    end
end

return SoundSet;