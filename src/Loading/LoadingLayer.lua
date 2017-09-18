local LoadingLayer = class("LoadingLayer", cc.load("mvc").ViewBase)

LoadingLayer.messageIndex      = 0
LoadingLayer.preloadData       = {}
LoadingLayer.AUTO_RESOLUTION   = true
LoadingLayer.RESOURCE_FILENAME = "ui/loading/uiLoadingLayer"
LoadingLayer.RESOURCE_BINDING  = {    
    ["node_fishact"]   = { ["varname"] = "node_fishact" }, 
    
    ["slider_loading"] = { ["varname"] = "slider_loading" },
    ["spr_bar_light"]  = { ["varname"] = "spr_bar_light" },
    
    ["text_message"]   = { ["varname"] = "text_message" },   
    
    ["fish"]           = { ["varname"] = "fish" },   

}

function LoadingLayer:ctor( )
    LoadingLayer.super.ctor(self)
    self.messageIndex = 0
    self.text_message:setString(FishGF.getChByIndex(800000059))
    
    self:openTouchEventListener()
    
    self:runAction(self.resourceNode_["animation"])
    self.resourceNode_["animation"]:play("fishjump", true)

    --self.slider_loading:setSwallowTouches(true)
    self.sliderScale = self.slider_loading:getScale()
    self:updataSliderLight()
    self.isloadEnd = true
end

function LoadingLayer:onCreate( ... )

end

function LoadingLayer:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function LoadingLayer:initMusic()
    -- self._MusicStatus = FishGI.AudioControl:getMusicVolume()
    -- FishGI.AudioControl:setMusicVolume(0.001)
    -- FishGI.AudioControl:pauseMusic()
    -- self._EffectStatus = FishGI.AudioControl:getEffectsVolume()
    -- FishGI.AudioControl:setEffectsVolume(0.001)
    -- FishGI.AudioControl:pauseAllEffects()

    self._MusicStatus = FishGI.AudioControl:getMusicStatus()
    self._EffectStatus = FishGI.AudioControl:getEffectStatus()
    FishGI.AudioControl:setEffectStatus(false)
    FishGI.AudioControl:setMusicStatus(false)
    FishGI.AudioControl:pauseMusic()
    FishGI.AudioControl:pauseAllEffects()
end

function LoadingLayer:resetSound()
    -- FishGI.AudioControl:setMusicVolume(self._MusicStatus)
    -- FishGI.AudioControl:setEffectsVolume(self._EffectStatus)
    FishGI.AudioControl:setEffectStatus(self._EffectStatus)
    FishGI.AudioControl:setMusicStatus(self._MusicStatus)
    FishGI.AudioControl:playLayerBgMusic()
    
end

function LoadingLayer:preloadRes(callBack)
    self:initMusic()

    self.index = 1
    self.messageIndex = 0
    if not FishGI.ISLOADING_END then
        self:preload(require("luaconfig/preloadData"))
    else
        self.preloadData = {};
        for i=1,100 do
            local data = {}
            data.loadtype = "nil"
            self.preloadData[i] = data
        end
    end
    print("-----------------------preloadRes--------------------")
    self:starPreload(callBack)
end

function LoadingLayer:preloadResNil(callBack)
    self:initMusic()

    self.index = 1
    self.messageIndex = 0
    self.preloadData = {};
    self:preload(require("luaconfig/preloadData"))
    local loadData = self.preloadData
    local proData = {}
    for i=1,#loadData do
        local value = loadData[i]
        if value.loadtype == "effect" then
            table.insert(proData,value)
        end
    end
    local count = #proData
    if count < 100 then
        for i=1,100 -count do
            local data = {}
            data.loadtype = "nil"
            table.insert(proData,data)
        end
    end

    self.preloadData = proData
    self:starPreload(callBack)
end

function LoadingLayer:preload( preloadData )
    local i = #self.preloadData + 1
    for key,value in pairs(preloadData) do
        if #self.preloadData == 0 then
            if value ~= nil then
                self.preloadData[i] = value
                 i = i + 1
            end           
        else
            local isflush = true
            for k,v in pairs(self.preloadData) do
                if v == value then
                    isflush = false
                     break
                end
            end
            if isflush then
                if value ~= nil then
                    self.preloadData[i] = value
                     i = i + 1
                end   
            end  
        end
    end

end

function LoadingLayer:starPreload( callBacl )
    self.isloadEnd = false
    self:closeAllSchedule()
    self.text_message:setString(FishGF.getChByIndex(800000059 + math.random(0,9)))

    local scheduler = cc.Director:getInstance():getScheduler()  
    self.noticeSchedulerID = scheduler:scheduleScriptFunc(function(dt)
       self.text_message:setString(FishGF.getChByIndex(800000059 + math.random(0,9)))
    end,2,false) 
 
    self.schedulerID = scheduler:scheduleScriptFunc(function(dt)
        local value = self.preloadData[self.index]
        if value ~= nil then
            if value.loadtype == "plist" then
                cc.SpriteFrameCache:getInstance():addSpriteFrames(value.prepath.."."..value.loadtype);
                self.index =  self.index +1
            elseif value.loadtype == "lua" then
                local nametable = FishGF.strSplit(value.prepath.."/","/")
                local tablename = nametable[#nametable]
                if FishGI[tablename] == nil  then
                    FishGI[tablename] = require(value.prepath).create();
                end
                self.index =  self.index +1
            elseif value.loadtype == "effect" then
                FishGI.AudioControl:preloadEffect(value.prepath)
                self.index =  self.index +1
            elseif value.loadtype == "music" then
                FishGI.AudioControl:preloadMusic(value.prepath)
                self.index =  self.index +1
            elseif value.loadtype == "playmp3" then
                print("---------------playmp3-----value.prepath="..value.prepath..".mp3")
                FishGI.AudioControl:playEffect(value.prepath..".mp3")
                self.index =  self.index +1
            elseif value.loadtype == "png" then
                cc.Director:getInstance():getTextureCache():addImage(value.prepath.."."..value.loadtype);
                self.index =  self.index +1
            elseif value.loadtype == "nil" then
                self.index =  self.index +1
            end
            local per = 100*( (self.index+FishGI.loading_index)/  ((#self.preloadData)+FishCD.LOADING_C_COUNT)  )
            self.slider_loading:setPercent(per)
            self:updataSliderLight()
        else
            if FishGI.isloadingEnd == false then
                FishGI.loading_index = FishGI.loading_index + FishGI.loading_sp*((FishCD.LOADING_C_COUNT - FishGI.loading_index) /(FishCD.LOADING_C_COUNT*2) )
            else
                FishGI.loading_index = FishGI.loading_index + FishGI.loading_sp
            end

            local per = 100*( (self.index+FishGI.loading_index)/  ((#self.preloadData)+FishCD.LOADING_C_COUNT)  )
            self.slider_loading:setPercent(per)
            self:updataSliderLight()
            if per >= 100 then
                FishGI.ISLOADING_END = true
                self.isloadEnd = true
                self:resetSound()
                self:closeAllSchedule()

                if FishGI.isloadingEnd then
                    self.slider_loading:setPercent(100)
                    self:updataSliderLight()
                    -- self:removeFromParent()
                    FishGI.GameEffect:hideEffect()
                    if type(callBacl) == "function" then
                        callBacl()
                    end

                    self:setVisible(false)
                else
                    self.slider_loading:setPercent(100)
                    self:updataSliderLight()
                    
                    local msg = FishGF.getChByIndex(800000170)
                    FishGF.createCloseSocketNotice(msg,"loading")
                    --FishGF.waitNetManager(false,nil,nil)
                end
            end
        end
    end,0.02,false)    
end

function LoadingLayer:updataSliderLight()
    local per = self.slider_loading:getPercent()
    local scaleY = self.sliderScale
    local scaleDis = 3
    if per > 100-scaleDis then
        scaleY = (100 - per)/scaleDis*scaleY
    end
    if per <= scaleDis then
        scaleY = per/scaleDis*scaleY
    end

    local size = self.slider_loading:getContentSize()
    self.spr_bar_light:setPositionX(size.width*per/100)
    self.spr_bar_light:setScale(scaleY)
end

function LoadingLayer:starRoomLoad( loadCount)
    FishGI.eventDispatcher:registerCustomListener("RoomLoadDispatcher", self, function() self:RoomLoadDispatcher() end);

    self.messageIndex = 0
    self.nextScene = nil
    self.index = 0
    self.loadCount = loadCount
end

function LoadingLayer:RoomLoadDispatcher( )
    self.index = self.index +1
    local per = 100*( self.index/self.loadCount )
    self.LB_bar:setPercent(per)

    if (self.messageIndex + 1)*30 <= per then
        self.messageIndex = self.messageIndex + 1
        self.Text_message:setString(FishGF.getChByIndex(800000059 + self.messageIndex))
    end

    if per >= 100 then
        self.LB_bar:setPercent(100)
        self:setVisible(false)
    end

end

function LoadingLayer:closeAllSchedule()
    if self.schedulerID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID )
        self.schedulerID = nil
        self:resetSound()
    end

    if self.noticeSchedulerID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.noticeSchedulerID )
        self.noticeSchedulerID = nil
    end
end




return LoadingLayer;