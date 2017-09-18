local SkillBase = import("Game.Skill.NormalSkill.SkillBase")
local SkillTimeRevert = class("SkillTimeRevert", SkillBase)

--[[
FishGI.isCurTimehour = false
FishGI.timehourRemain = 0
FishGI.timehourGlodccount = 0
]]
function SkillTimeRevert:ctor(...)
    self:initListener()
    self.isCountingDown = false
    self.clicktime = 0
    self.buffers = {}
    
    FishGI.eventDispatcher:registerCustomListener("UpdateBufferLogo", self, function(valTab) self:UpdateBufferLogo(valTab) end);
end

function SkillTimeRevert:clickCallBack()
    log("")
    if os.time() - self.clicktime < self.cooldown then
        return
    end

    local dealed = self:doRevert()
    if dealed then
        return
    end

    self.useType = self:judgeUseType()
    if not self.useType then
        return
    end

    self:startCheck(self.useType)
end

-----------
function SkillTimeRevert:UpdateBufferLogo(valTab)
    log("SkillTimeRevert:UpdateBufferLogo")
    if valTab == nil then return end
    
    self.playerSelf = FishGI.gameScene.playerManager:getMyData()
    for k,v in pairs(valTab) do
        log("buffer player: ", v)
        if not self:isSelf(v) then
            self:addBuffer(v, 300)    
        end
    end
end
--------------

function SkillTimeRevert:startCheck(useType)
    local body = FishGF.getChByIndex(800000254) .. "\n" .. FishGF.getChByIndex(800000255)
    self:doCheck(nil, body, function ()
    
        if self.useType == 1 then
            log("self.useType: " .. self.useType)
            FishGMF.isSurePropData(self.playerSelf.playerInfo.playerId,FishCD.PROP_TAG_02, 1000, false)
        elseif self.useType == 0 then
            FishGMF.isSurePropData(self.playerSelf.playerInfo.playerId,FishCD.PROP_TAG_14, 1, false)
            --FishGMF.addTrueAndFlyProp(playerId,FishCD.PROP_TAG_14, 1, true)
        end

        self:requestForStart(useType)
        self:runTimer()
        self.clicktime = os.time()
    end)
end

function SkillTimeRevert:rechargeCheck(callbackcomfirm)
    if not self.isCountingDown then
        return false
    end
    
    local body1 = FishGF.getChByIndex(800000259) .. "\n"
    local body2 = FishGF.getChByIndex(800000257)
    local body = string.format(body2, tostring(self.nGoldCount))

    self:doCheck(nil, body1 .. body, function ()
        callbackcomfirm()
    end)

    return true
end

function SkillTimeRevert:stopCheck(comfirmCallback)
    if not self.isCountingDown then
        return false
    end

    local body1 = FishGF.getChByIndex(800000258) .. "\n"
    local body2 = FishGF.getChByIndex(800000257)
    local body = string.format(body2, tostring(self.nGoldCount))

    self:doCheck(nil, body1 .. body, function ()
        self:timeoutStop()
        self.stopCallback = comfirmCallback
    end)

    return true
end

function SkillTimeRevert:doRevert()
    log("SkillTimeRevert:doRevert")
    if not self.isCountingDown then
        return false
    end

    local dealed = self:revertCheck()
    if not dealed then
        return true
    end

    self:requestForStop(1)
    return true
end

function SkillTimeRevert:revertCheck()
    local coinCount = FishGMF.getPlayerPropData(self.playerSelf.playerInfo.playerId, FishCD.PROP_TAG_01)
    local coinall = coinCount.realCount - coinCount.flyingCount - coinCount.unSureCount
    if coinall <= self.nGoldCount then
        return true
    end

    local body1 = FishGF.getChByIndex(800000271) .. "\n"
    local body2 = FishGF.getChByIndex(800000257)
    local body = string.format(body2, tostring(self.nGoldCount))

    self:doCheck(nil, body1 .. body, function ()
        self:requestForStop(1)
        --self:runTimer()
    end)

    return false
end

function SkillTimeRevert:continueCheck()
    if not FishGI.isCurTimehour then
        return
    end

    self.nGoldCount = FishGI.timehourGlodCount   
    self.nTimeRemain = FishGI.timehourRemain

    log("SkillTimeRevert:continueCheck")
    local body1 = FishGF.getChByIndex(800000256) .. "\n"
    local body2 = FishGF.getChByIndex(800000257)
    local body = string.format(body2, tostring(self.nGoldCount))

    self:doCheck(nil, body1 .. body, function ()
        self:requestForContinue()
        FishGI.isCurTimehour = false
    end, function ()
        self:timeoutStop()
        FishGI.isCurTimehour = false
    end)
end

function SkillTimeRevert:doCheck(title, body, onSuccess, onfail)
    local function callback(sender)
        if sender:getTag() == 2 then 
            --log("")
            onSuccess()
        elseif onfail then
            onfail()
        end
    end

    FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,body,callback)
    return
end

-----------------------------------------------------------------------------------------------------
function SkillTimeRevert:initListener()
    FishGI.eventDispatcher:registerCustomListener("onStartHourGlass", self, function(valTab) self:onStart(valTab) end)
    FishGI.eventDispatcher:registerCustomListener("oStopHourGlass", self, function(valTab) self:oStop(valTab) end)
    FishGI.eventDispatcher:registerCustomListener("onTryGetHourGlass", self, function(valTab) self:onTryGet(valTab) end)
    FishGI.eventDispatcher:registerCustomListener("onContinueHourGlass", self, function(valTab) self:onContinue(valTab) end)
end

function SkillTimeRevert:onStart(valTab)
    log("SkillTimeRevert:onStart")
    for k,v in pairs(valTab) do
        log(k,v)
    end
    local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(valTab.playerID)
    if player == nil then
        return
    end

    self.playerSelf = FishGI.gameScene.playerManager:getMyData()
    if  not valTab.isSuccess then
        if self:isSelf(valTab.playerID) then
            FishGMF.isSurePropData(playerId,FishCD.PROP_TAG_02, 1000, true)
        end
        return
    end

    log("valTab.nTimeRemain: ", valTab.nTimeRemain)
    self:playStartAnimate(valTab.playerID, valTab.nTimeRemain, valTab.nFishIcon)
    if not self:isSelf(valTab.playerID) then
        return
    end

    self:showSkillingLogo()

    local playerId = self.playerSelf.playerInfo.playerId
    if self.useType == 1 then
        FishGMF.addTrueAndFlyProp(playerId,FishCD.PROP_TAG_02, -1000, false)
        FishGMF.isSurePropData(playerId,FishCD.PROP_TAG_02, 1000, true)
    elseif self.useType == 0 then
        FishGMF.addTrueAndFlyProp(playerId,FishCD.PROP_TAG_14, -1, false)
        FishGMF.isSurePropData(playerId,FishCD.PROP_TAG_14, 1, true)
    end

    self.nGoldCount = valTab.nFishIcon   
    self.nTimeRemain = valTab.nTimeRemain
    self.isCountingDown = true
end

function SkillTimeRevert:showSkillingLogo()
    self.btn.parentClasss:setState(2)
    if not self.initAnimate then
        self.initAnimate = true
    end
end

function SkillTimeRevert:hideSkillingLogo( ... )
    self.btn.parentClasss:setState(0)
end

function SkillTimeRevert:playStartAnimate(playerId, period, glodCount)
    log("period: ", period)
    local gameRect = cc.Director:getInstance():getWinSize()
    local startPos = self:getCannonPosByPlayerId(playerId)
    self:throwLamp(startPos, cc.p(gameRect.width/2, gameRect.height/2), function ( ... )
        self:addBuffer(playerId, period)
        if self:isSelf(playerId) then
            self:showBanner()
        end
    end, playerId)
end

function SkillTimeRevert:playStopAnimate(playerId, fishCoin)
    log("SkillTimeRevert:playStopAnimate")
end

function SkillTimeRevert:isSelf(playerId)
    return self.playerSelf.playerInfo.playerId == playerId
end

function SkillTimeRevert:timeoutStop()
    self:requestForStop(0)
end

function SkillTimeRevert:oStop(valTab)
    log("SkillTimeRevert:oStop")
    for k,v in pairs(valTab) do
        log(k,v)
    end

    local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(valTab.playerID)
    if player == nil then
        return
    end

    if not valTab.isSuccess then
        return
    end
    self.playerSelf = FishGI.gameScene.playerManager:getMyData()

    self:removeBuffer(valTab.playerID)
    
    if not self:isSelf(valTab.playerID) then
        return
    end

    self:hideSkillingLogo()
    self.neddStop = false
    if  self.stopCallback then
        self.stopCallback()
        self.stopCallback = nil
    end

    if valTab.useType == 0 then
    elseif valTab.useType == 1 then
        self:showRevert(valTab.nFishIcon)
        FishGMF.upDataByPropId(valTab.playerID, FishCD.PROP_TAG_01, valTab.nFishIcon, true)
    end

    self.isCountingDown = false
end

function SkillTimeRevert:onContinue(valTab)
    log("SkillTimeRevert:onContinue")
    local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(valTab.playerID)
    if player == nil then
        return
    end

    self.playerSelf = FishGI.gameScene.playerManager:getMyData()
    for k,v in pairs(valTab) do
        log(k,v)
    end
    if not valTab.isSuccess then return end

    self:addBuffer(valTab.playerID, valTab.nTimeRemain)

    if not self:isSelf(valTab.playerID) then return end

    self:showSkillingLogo()
    self.nTimeRemain = valTab.nTimeRemain
    self.nGoldCount = valTab.nFishIcon
    self.isCountingDown = true
end

function SkillTimeRevert:requestForStart(type)
    log("SkillTimeRevert:requestForStart")
    local valTab = {}
    valTab.useType = type
    FishGI.gameScene.net:sendToStartTimeHourglass(valTab)
end

function SkillTimeRevert:requestForStop(type)
    log("SkillTimeRevert:requestForStop")
    local valTab = {}
    valTab.useType = type

    FishGI.gameScene.net:sendToStopTimeHourglass(valTab)
end

function SkillTimeRevert:requestForContinue()
    log("SkillTimeRevert:requestForContinue")
    FishGI.gameScene.net:sendToContinueTimeHourglass({})
end

--开始位置 结束位置
function SkillTimeRevert:throwLamp(beginPos, endPos, callFunc, playerId)
    local totalTimes = 0;
    endPos = cc.p(endPos.x, endPos.y+10);
    local playerLayer = FishGI.gameScene.playerManager;

    local function addDarkCloud(callback)
        FishGF.print("appear cloud");
        local cloud1 = cc.Sprite:create("battle/effect/effect_lamp_clouds.png");
        cloud1:setOpacity(0);
        cloud1:setScale(0);
        cloud1:setPosition(endPos);
        local cloud2 = cc.Sprite:create("battle/effect/effect_lamp_clouds.png");
        cloud2:setRotation(180);
        cloud2:setOpacity(0);
        cloud2:setScale(0);
        cloud2:setPosition(cc.p(endPos.x, endPos.y-cloud1:getContentSize().height/2));

        local fadeAct1 = cc.Sequence:create(cc.FadeTo:create(0.6, 255), cc.FadeTo:create(0.6, 0))
        local scaleAct1 = cc.Sequence:create(cc.ScaleTo:create(1.2, 3), cc.RemoveSelf:create())
        local spaw1 = cc.Spawn:create(fadeAct1, scaleAct1);
        cloud1:runAction(spaw1);

        local fadeAct2 = cc.Sequence:create(cc.FadeTo:create(0.6, 255), cc.FadeTo:create(0.6, 0))
        local scaleAct2 = cc.Sequence:create(cc.ScaleTo:create(1.2, 3), cc.RemoveSelf:create())
        local spaw2 = cc.Spawn:create(fadeAct2, scaleAct2);
        local seq = cc.Sequence:create(cc.DelayTime:create(0.2), spaw2, cc.CallFunc:create(callback))
        cloud2:runAction(seq);
        endPos = cc.p(endPos.x, endPos.y-20);

        playerLayer:addChild(cloud1, 100);
        playerLayer:addChild(cloud2, 100);
    end

    local function firstCloud()
            addDarkCloud(function ( ... )
        end)
    end

    local function secondCloud()
        addDarkCloud(callFunc)
    end

    local function addLamp()
        local dis = cc.pDistanceSQ(beginPos, endPos);

        local rotateAct = cc.RotateBy:create(0.88, 360);
        local fadeAct = cc.Sequence:create(cc.FadeTo:create(0.12, 255), cc.DelayTime:create(0.76), cc.FadeTo:create(0.08, 0));
        local moveAct = cc.MoveTo:create(0.88, endPos);
        local enterCloudAct = cc.Sequence:create(cc.DelayTime:create(0.76), cc.CallFunc:create(firstCloud),cc.DelayTime:create(0.2), cc.CallFunc:create(secondCloud));
        local callFishAct = cc.Sequence:create(cc.DelayTime:create(1.16), cc.RemoveSelf:create());

        local lampSprite = cc.Sprite:create("common/prop/prop_014.png");
        lampSprite:setOpacity(255);
        lampSprite:setPosition(beginPos);
        lampSprite:runAction(rotateAct);
        lampSprite:runAction(fadeAct);
        lampSprite:runAction(moveAct);
        lampSprite:runAction(callFishAct);
        lampSprite:runAction(enterCloudAct);
        playerLayer:addChild(lampSprite, 99);
    end

    addLamp();
end

function SkillTimeRevert:addBuffer(playerId, delay)      
    if self.buffers[playerId] then
       self.buffers[playerId]:removeFromParent()
    end

    local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(playerId)

    self.buffers[playerId] = self:getBufferIcon(delay, playerId)
    self.buffers[playerId]:retain()
    local pos = self:getBufferPos(playerId)
    self.buffers[playerId]:setPosition(pos.x, pos.y)
    player:addChild(self.buffers[playerId],9)
end

function SkillTimeRevert:removeBuffer(playerId)
    if self.buffers[playerId] then
       self.buffers[playerId]:removeFromParent()
    end

    self.buffers[playerId] = nil
end

function SkillTimeRevert:getBufferPos(playerId)
    local chairId = FishGI.gameScene.playerManager:getPlayerChairId(playerId);

    local gameRect = cc.Director:getInstance():getWinSize()

    local marginX = 35*self.scaleMin_
    local marginY = 103*self.scaleMin_
    
    if chairId == FishCD.DIRECT.LEFT_DOWN then
        return cc.p(marginX, marginY)

    elseif chairId == FishCD.DIRECT.RIGHT_DOWN then
        return cc.p(gameRect.width - marginX, marginY)

    elseif chairId == FishCD.DIRECT.LEFT_UP then
        return cc.p(marginX, gameRect.height - marginY)

    elseif chairId == FishCD.DIRECT.RIGHT_UP then
        return cc.p(gameRect.width - marginX, gameRect.height - marginY)
    end

end
 
function SkillTimeRevert:getCannonPosByPlayerId(playerId)
    log("SkillTimeRevert:getCannonPosByPlayerId: " .. playerId)
    local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(playerId)

    local x,y = player.cannon:getPosition()

    return cc.p(x, y)
end

function SkillTimeRevert:showBanner()
    local playerLayer = FishGI.gameScene.playerManager

    local bg = self:getBanner()
    local display3second = self:displayPeriodAndRemove(5)
    
    bg:runAction(display3second)
    local gameRect = cc.Director:getInstance():getWinSize()
    bg:setPosition(gameRect.width/2, gameRect.height/2)

    playerLayer:addChild(bg)
end

function SkillTimeRevert:showRevert(count)
    local scene = cc.Director:getInstance():getRunningScene()
    local revert = self:getRevertAnimate(count)
    local gameRect = cc.Director:getInstance():getWinSize()

    revert:setPosition(gameRect.width/2, gameRect.height/2)
    scene:addChild(revert, FishCD.ORDER_LAYER_VIRTUAL)
end
---------------------------------------------------------------

function SkillTimeRevert:displayPeriodAndRemove(period)
    local sequence = {}
    sequence[#sequence + 1] = cc.DelayTime:create(period)
    sequence[#sequence + 1] = cc.RemoveSelf:create()

    return transition.sequence(sequence)
end

function SkillTimeRevert:getBufferIcon(delay, playerId)
    local nodeRet = cc.Sprite:create()
    local hg = self:getSkillLogo()
    
    if not self:isSelf(playerId) then
        nodeRet:addChild(hg)
        return nodeRet
    end

    local text = ccui.Text:create()
    text:setString(tostring(delay) .. "s")
    text:setPosition(0,33)
    text:setFontSize(20)

    local startTime = os.time()

    local bgr = self:getCountDownBgr()
    bgr:setPosition(0, 33)
    text:setTextColor(cc.c3b(0, 255, 0))

    local countdown = {}
    countdown[#countdown + 1] = cc.DelayTime:create(1)
    countdown[#countdown + 1] = cc.CallFunc:create(function ( ... )
        local cur = os.time()
        local delt = cur - startTime
        if delt > delay then
            self:timeoutStop()
            nodeRet:removeFromParent()
            return 
        end

        text:setString(tostring(delay - delt) .. "s")
    end)

    local cdseq = cc.RepeatForever:create(transition.sequence(countdown))

    nodeRet:addChild(bgr)
    nodeRet:addChild(text)
    nodeRet:addChild(hg)
    nodeRet:runAction(cdseq)

    return nodeRet
end

function SkillTimeRevert:getSkillLogo()
    local hg = cc.Sprite:create("battle/hourglass/hourglass_buff.png")

    local rotateAct = {}
    rotateAct[#rotateAct + 1] = cc.RotateBy:create(6, 360)
    --rotateAct[#rotateAct + 1] = cc.DelayTime:create(1.67)

    local act = cc.RepeatForever:create(transition.sequence(rotateAct))

    hg:runAction(act)
    return hg
end

function SkillTimeRevert:getCountDownBgr()
    local spr_prop_buff_data_bg = ccui.ImageView:create()
    spr_prop_buff_data_bg:ignoreContentAdaptWithSize(false)
    spr_prop_buff_data_bg:loadTexture("common/layerbg/com_bg_grxx.png",0)
    spr_prop_buff_data_bg:setScale9Enabled(true)
    spr_prop_buff_data_bg:setCapInsets({x = 13, y = 13, width = 14, height = 14})
    spr_prop_buff_data_bg:setLayoutComponentEnabled(true)
    spr_prop_buff_data_bg:setName("spr_prop_buff_data_bg")
    spr_prop_buff_data_bg:setTag(2163)
    spr_prop_buff_data_bg:setCascadeColorEnabled(true)
    spr_prop_buff_data_bg:setCascadeOpacityEnabled(true)
    spr_prop_buff_data_bg:setOpacity(204)
    spr_prop_buff_data_bg:setColor({r = 0, g = 0, b = 0})

    local layout = ccui.LayoutComponent:bindLayoutComponent(spr_prop_buff_data_bg)
    layout:setPositionPercentXEnabled(true)
    layout:setSize({width = 55.0000, height = 25.0000})
    layout:setLeftMargin(-20.0000)
    layout:setRightMargin(-20.0000)
    layout:setTopMargin(-12.5000)
    layout:setBottomMargin(-12.5000)

    return spr_prop_buff_data_bg
end

function SkillTimeRevert:getBanner()
    return require("Game/Skill/SkillUtil/TimehourBanner").create()
end

function SkillTimeRevert:getRevertAnimate(count)
    local data = {}
    data.score = 0
    data.delayTime = 0
    data.isShowScore = false
    FishGI.GameEffect:propMegaWin(data, "sound/congrat_01.mp3")

    local timehourEnd = require("Game/Skill/SkillUtil/TimehourEnd").create()
    local coinCount = FishGMF.getPlayerPropData(self.playerSelf.playerInfo.playerId, FishCD.PROP_TAG_01)
    local curCoin = coinCount.realCount - coinCount.flyingCount - coinCount.unSureCount

    timehourEnd:setRevertCoin(count, curCoin, function ( ... )
        local gameRect = cc.Director:getInstance():getWinSize()
        local playerId = self.playerSelf.playerInfo.playerId
        local chairId = FishGI.gameScene.playerManager:getPlayerChairId(playerId);
    
        FishGMF.showGainCoinEffect(playerId, chairId, 1, 12, 12, gameRect.width/2, gameRect.height/2, 0, 0, false)
    end)

    return timehourEnd
end

return SkillTimeRevert