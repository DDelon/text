local AlmInfo = class("AlmInfo", cc.load("mvc").ViewBase)

AlmInfo.AUTO_RESOLUTION   = false
AlmInfo.RESOURCE_FILENAME = "ui/battle/uialminfo"
AlmInfo.RESOURCE_BINDING  = {    
    ["btn_bg"]          = { ["varname"] = "btn_bg" ,      ["events"]={["event"]="click",["method"]="onClickBack"}},
    ["spr_light"]       = { ["varname"] = "spr_light" },
    
    ["countdown"]       = { ["varname"] = "countdown" },
    ["text_word_time"]  = { ["varname"] = "text_word_time" },
    ["text_time"]       = { ["varname"] = "text_time" },
    
    ["text_clickcount"] = { ["varname"] = "text_clickcount" },
    ["text_notime"]     = { ["varname"] = "text_notime" },
}

function AlmInfo:onCreate( ... )
    self.text_word_time:setString(FishGF.getChByIndex(800000072))
    self.text_notime:setString(FishGF.getChByIndex(800000074))


    self.btn_bg:setTouchEnabled(false)
    self.leftCount = 0
    self.totalCount = 0
    self.schedulerID= nil
    self:setState(0)
    self.curTime = 0
    self.isSendEnd = false

    self.text_notime:setVisible(false)
    self.countdown:setVisible(false)
    self.text_clickcount:setVisible(false)
    self.btn_bg:setTouchEnabled(false)
    self.spr_light:setVisible(false)
    
    self.spr_light:runAction(cc.RepeatForever:create(cc.RotateBy:create(1,FishCD.LIGHT_SPEED)))

    self.animation = self.resourceNode_["animation"]
    self:runAction(self.animation)
    self.animation:play("gold", true);
    
    FishGI.eventDispatcher:registerCustomListener("AlmInfoing", self, function(valTab) self:AlmInfoing(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("ApplyAlmResult", self, function(valTab) self:ApplyAlmResult(valTab) end);
end

function AlmInfo:onClickBack( sender )
    FishGI.gameScene.net:sendApplyAlm()
    self.btn_bg:setTouchEnabled(false)
end

function AlmInfo:setState( state )
    self.text_notime:setVisible(false)
    self.countdown:setVisible(false)
    self.text_clickcount:setVisible(false)
    self.btn_bg:setTouchEnabled(false)
    self.spr_light:setVisible(false)

    local state = state
    if state == 1 then  --冷却时间
        self.countdown:setVisible(true)
    elseif state == 2 then     --剩余次数
        self.spr_light:setVisible(true)
        self.text_clickcount:setVisible(true)
        local str = FishGF.getChByIndex(800000073).."("..self.leftCount.."/"..self.totalCount..")"
        self.text_clickcount:setString(str)
        self.btn_bg:setTouchEnabled(true)
    elseif state == 3 then      --没次数
        self.text_notime:setVisible(true)
    end
end

function AlmInfo:AlmInfoing( valTab )
    print("AlmInfoing")
    if valTab ~= nil then
        self:setVisible(true)
    else
        print("--------------------AlmInfoing--- valTab ~= nil---------")
        return
    end
    
    self.leftCount = valTab.leftCount
    local cd = valTab.cd
    self.totalCount = valTab.totalCount

    if self.leftCount <= 0 then
        self:setState(3)
    else
        if self.schedulerID == nil then
            self.curTime = cd
            self:setState(1)
            self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)  
               self:upDataTime(dt)
            end,1,false)
            self:upDataTime(dt)
        end
    end
end

function AlmInfo:ApplyAlmResult( valTab )
    local success = valTab.success
    local selfId = FishGI.gameScene.playerManager.selfIndex

    if success == false and valTab.playerId == selfId then
        local strMsg = FishGF.getChByIndex(800000078)
        self:endCountTime()
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,strMsg,nil)
        return
    end 
    print("----AlmInfo:ApplyAlmResult---")
    --更新鱼币
    FishGMF.ApplyAlmResult(valTab.playerId,valTab.newFishIcon)

    if valTab.playerId ~= selfId then
        return
    end

    self.isSendEnd = false
    if valTab ~= nil then
        self:setVisible(false)
        self:setState(0)
    else
        print("--------------------ApplyAlmResult--- valTab ~= nil---------")
        return
    end

    local data = {}
    data.funName = "showGunUpEffect"
    data.playerId = selfId
    data.chairId = FishGI.gameScene.playerManager:getPlayerChairId(selfId)
    data.coinNum = 2

    local propData = FishGMF.getPlayerPropData(selfId,1)
    data.moneyCount = valTab.newFishIcon - propData.realCount

    self.lectCount = valTab.lectCount
    self.totalCount = valTab.totalCount

    data.showType = "almInfo"
    data.lectCount = valTab.lectCount
    data.totalCount = valTab.totalCount
    
    FishGI.GameEffect:playGunUpGrade(data)

end


function AlmInfo:upDataTime( dt )
    self.curTime = self.curTime - 1

    local time = FishGF.getFormatTimeBySeconds(self.curTime);
    self.text_time:setString(time)
    if self.curTime <= 0 then
        self:setState(2)
        if  self.schedulerID ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID )  
            self.schedulerID = nil
        end
    end
end

function AlmInfo:endCountTime( )
    if  self.schedulerID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID )  
        self.schedulerID = nil
    end
    self.isSendEnd = false
    self:setState(0)
    self:setVisible(false)
end

return AlmInfo;