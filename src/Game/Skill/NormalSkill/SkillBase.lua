local SkillBase = class("SkillBase",cc.load("mvc").ViewBase)

function SkillBase:ctor(...)

end

function SkillBase.create()
    local SkillBase = SkillBase.new();
    SkillBase:init();
    return SkillBase;
end

function SkillBase:init()
    FishGI.GameTableData:initSkillTable()
end

--按键按下的处理
function SkillBase:clickCallBack( )
    --子类要覆盖重写
end

--
function SkillBase:getSkillData( propId,key )
    local SkillTab = FishGI.GameTableData:getSkillTable()
    if SkillTab == nil or SkillTab[tonumber(propId)] == nil then
        FishGI.GameTableData:initSkillTable()
    end
    return SkillTab[tonumber(propId)][key]
end

--初始化
function SkillBase:initDataByPropId(key, propId,btn,propCount)
    self.scaleX_,self.scaleY_,self.scaleMin_  = FishGF.getCurScale()
    self.btn = btn
    self.btn:setTouchEnabled(true)
    self.propId = propId
    self.keyID = key

    local cooltime = self:getSkillData(propId,"cool_down")
    self["cooldown"] = cooltime
    self.btn.parentClasss:initProgressTimer()

    local val = {}
    val.propId = self.propId
    if propCount == nil  then
        propCount = 0
    end
    val.propCount = propCount
    local propData = FishGI.GameTableData:getItemTable(propId)
    val.priceId = propData.priceId
    val.price = propData.priceCount
    self.price = val.price
    self:setPricce(val)
    self:setSkillByTag(val)

end

--设置道具价格
function SkillBase:setPricce( val )
    self.btn.parentClasss:setPricce(val)
end

--设置道具个数
function SkillBase:setSkillByTag( val )
    self.btn.parentClasss:setSkillByTag(val)
end

--判断使用方式  0，个数     1，水晶      核弹数据不存缓存
function SkillBase:judgeUseType()
    local count = self.btn.parentClasss:getFntCount()
    local price = self.btn.parentClasss:getFntPrice()
    
    local useType = nil
    if count > 0 then
        useType = 0
    else
        --判断VIP多少购买
        local requireVip = tonumber(FishGI.GameTableData:getItemTable(self.propId).require_vip)
        self.playerSelf = FishGI.gameScene.playerManager:getMyData()
        local playerInfo = self.playerSelf.playerInfo;

        local curVip = playerInfo.vip_level;
        FishGF.print("curVip:"..curVip.." requireVip:"..requireVip);
        if curVip < requireVip then
            local function callback(sender)
                local tag = sender:getTag()
                if tag == 2 then
                    FishGI.gameScene.uiShopLayer:showLayer()
                    FishGI.gameScene.uiShopLayer:setShopType(1)
                end
            end
            local str = FishGF.getChByIndex(800000111)..requireVip..FishGF.getChByIndex(800000112);
            FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,str,callback);
            return
        end

        local myWinCrystal = self.playerSelf.cannon:getDiamonds()
        if myWinCrystal < self.price then
            --提示钻石不够
            log("--提示钻石不够购买--")
            local function callback(sender)
                local tag = sender:getTag()
                if tag == 2 then
                    FishGI.gameScene.uiShopLayer:showLayer() 
                    FishGI.gameScene.uiShopLayer:setShopType(2)
                end
            end
            FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,FishGF.getChByIndex(800000093),callback)
            return
        end
        useType = 1
    end
    return useType

end

--发送消息
function SkillBase:sendNetMessage(data)
    local tag = self.propId
    
    if tag == FishCD.SKILL_TAG_FREEZE then     --冰冻
        FishGI.gameScene.net:sendFreezeStart(data.useType)
    elseif tag == FishCD.SKILL_TAG_LOCK then --锁定
        if data.sendType == "start" then
            FishGI.gameScene.net:sendlockFish(data.timelineId,data.fishArrayId,data.useType)
        elseif data.sendType == "change" then
            local tab = {}
            tab.bullets = data.bullets
            tab.timelineId = data.timelineId
            tab.fishArrayId = data.fishArrayId
            FishGI.gameScene.net:sendBulletTargetChange(tab)
        end
    elseif tag == FishCD.SKILL_TAG_CALLFISH then --神灯
        FishGI.gameScene.net:sendCallFish(FishGI.callFishCount, data.useType);
        FishGI.callFishCount = FishGI.callFishCount+1;
    elseif tag == FishCD.SKILL_TAG_BOMB or tag == FishCD.SKILL_TAG_MISSILE or tag == FishCD.SKILL_TAG_SUPERBOMB then --核弹 导弹 氢弹
        if data.sendType == "sendNBomb" then
            FishGI.eventDispatcher:dispatch("setNewUsedPropId", data.nPropID)
            FishGI.gameScene.net:sendNBomb(data.nPropID, data.touchBeginPos, data.useType);
        elseif data.sendType == "sendNBombBalst" then
            FishGI.gameScene.net:sendNBombBalst(data.nBombId, data.fishesTab);
        end
    elseif tag == FishCD.SKILL_TAG_VIOLENT then --狂暴
        FishGI.gameScene.net:sendUseViolent(data.useType);
    end
   
end

--使用中，数据进入缓存
function SkillBase:pushDataToPool(useType)
    self.myPlayerId = FishGI.gameScene.playerManager.selfIndex
    local propCount = 0
    local propId = 0
    if useType == 0 then
        propCount = 1
        propId = self.propId
    else
        propCount = self.price
        propId = FishCD.PROP_TAG_02
    end
    --c++方面缓存未确定数据
    FishGMF.isSurePropData(self.myPlayerId,propId,propCount,false)
end

--使用失败，清除缓存数据    默认自动更新界面
function SkillBase:clearDataFromPool(useType)
    self.myPlayerId = FishGI.gameScene.playerManager.selfIndex
    local propCount = 0
    local propId = 0
    if useType == 0 then
        propCount = 1
        propId = self.propId
    else
        propCount = self.price
        propId = FishCD.PROP_TAG_02
    end

    --c++方面清除未确定数据
    FishGMF.isSurePropData(self.myPlayerId,propId,propCount,true)

end

function SkillBase:getPlusParam( ... )
    local vip_level = tonumber(FishGI.gameScene.playerManager:getMyData().playerInfo.vip_level)
    local skillplus = FishGI.GameConfig:getConfigData("vip",tostring(840000000+vip_level),"skill_plus")
    local skillpluses = string.split(skillplus, ";")
    local plus = 1
    for k,v in pairs(skillpluses) do
        local plus_para = string.split(v, ",")
        if tonumber(plus_para[1]) == self.keyID then
            plus = tonumber(plus_para[2])/100
        end
    end

    return plus
end

--CD进度条
function SkillBase:runTimer(callback)
    if self.propId == nil then
        return;
    end
    local callbackAct = cc.CallFunc:create(function (  )  
        self:stopTimer()
        if callback ~= nil then
            callback()
        end
    end)
    self.btn.parentClasss:runTimer(self["cooldown"],0,callbackAct)
    self.CDStartTime = os.time()

end

--刷新CD时间
function SkillBase:upDateTimer(callback)
    if self.CDStartTime == nil then
        return
    end
    local endTime = os.time()
    local disTime = endTime - self.CDStartTime

    local cooldownTime = self["cooldown"]
    if disTime >= cooldownTime then
        self:stopTimer()
        return
    end

    local per= disTime/cooldownTime*100
    local times = cooldownTime - disTime
    local callbackAct = cc.CallFunc:create(function (  )  
        self:stopTimer()
        if callback ~= nil then
            callback()
        end
    end)
    self.btn.parentClasss:runTimer(times,100 - per,callbackAct)

end

--停止CD进度条
function SkillBase:stopTimer()
    self.CDStartTime = nil
    self.btn.parentClasss:stopTimer()
end

function SkillBase:closeSchedule()
    if  self.schedulerID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID )  
        self.schedulerID = nil
    end
end

return SkillBase;