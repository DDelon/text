local SkillBase = import("Game.Skill.NormalSkill.SkillBase")
local SkillLock = class("SkillLock",SkillBase)

SkillLock.touchDisTime  = 0.5  --手动切换目标间隔
SkillLock.chainCount  = 8  --锁链点个数
function SkillLock:ctor(...)

    self:initListener()
    self:initLock()
    self:openTouchEventListener()

    FishGI.isLock = false
    self.tem_timelineId = 0
    self.tem_fishArrayId = 0

end

--初始化监听器
function SkillLock:initListener()
    FishGI.eventDispatcher:registerCustomListener("startMyLock", self, function(valTab) self:startMyLock(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("startOtherLock", self, function(valTab) self:startOtherLock(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("bulletTargetChange", self, function(valTab) self:bulletTargetChange(valTab) end);

end

--初始化锁定
function SkillLock:initLock()
    self.aimFish = nil
    self.playerSelf = nil
    self.startTime = 0
    self.touchStartTime = 0

    self.lockNode = cc.Node:create()
    self:addChild(self.lockNode,1)

    --锁定目标的环
    self.lockLoop = cc.Sprite:create("battle/effect/effect_lock_0.png")
    self.lockNode:addChild(self.lockLoop)

    --锁定的箭头
    self.lockArrow = cc.Sprite:create("battle/effect/effect_lock_1.png")
    self.lockNode:addChild(self.lockArrow)
    self.lockNode:setVisible(false)

    --锁链
    self.chain = {}
    for i=self.chainCount,1,-1 do
        self.chain[i] = cc.Sprite:create("battle/effect/effect_lock_2.png")
        self:addChild(self.chain[i],0)
        self.chain[i]:setVisible(false)
    end

    self:initLockAct()

end

--设置锁链是否可见
function SkillLock:setLockSpr( isShow)
    self.lockNode:setVisible(isShow)
    for i=1,self.chainCount do
        self.chain[i]:setVisible(isShow)
    end
end

--初始化锁链环运动
function SkillLock:initLockAct()
    --锁定目标的环运动
    self.lockLoop:stopAllActions()
    self.lockLoop:runAction(cc.RepeatForever:create(cc.RotateBy:create(4,360)))

    --锁定的箭头运动
    self.lockArrow:stopAllActions()
    local seq = cc.Sequence:create(cc.ScaleTo:create(0.13,0.8),cc.ScaleTo:create(0.87,1))
    self.lockArrow:runAction(cc.RepeatForever:create(seq))

end

--设置锁链转换目标效果 
function SkillLock:playLockChangeAim( )
    print("------SkillLock:playLockChangeAim---------")

    --锁定目标的箭头运动
    self.lockArrow:stopAllActions()

    self.lockArrow:setScale(1.8)
    self.lockArrow:setOpacity(255*0.3)

    local scaleAct1 = cc.ScaleTo:create(0.13,0.9)
    local OpacityAct1 = cc.FadeTo:create(0.13,255)
    local spawnAct1 = cc.Spawn:create(scaleAct1,OpacityAct1)

    local act2 = cc.ScaleTo:create(0.03,1)
    local rotate = cc.RotateBy:create(0.16,80)

    local endAct = cc.CallFunc:create(function ( ... )
        self:initLockAct()
    end)
    self.lockArrow:runAction(rotate)
    self.lockArrow:runAction(cc.Sequence:create(spawnAct1,act2,endAct))


    --锁定目标的环运动
    --self.lockLoop:stopAllActions()
    self.lockArrow:setScale(1.2)   
    local LoopSeq = cc.Sequence:create(cc.ScaleTo:create(0.13,0.8),cc.ScaleTo:create(0.03,1))
    self.lockLoop:runAction(LoopSeq)


end

--锁链移动
function SkillLock:upDataLockSprAct(aimPosX,aimPosY) 
    if aimPosX <= 0 or aimPosY <= 0 or FishGI.isLock == false then
        self:setLockSpr(false)
        return 
    end
    self:setLockSpr(true)

    local curPosInNode = self:convertToNodeSpace(cc.p(aimPosX,aimPosY))
    self.lockNode:setPosition(cc.p(curPosInNode.x,curPosInNode.y))
    local chairId  = FishGI.gameScene.playerManager:getMyChairId()
    local startPosX = FishCD.aimPosTab[chairId].x*self.scaleX_
    local startPosY = FishCD.aimPosTab[chairId].y*self.scaleY_
    for i=1,self.chainCount do
        local posX = startPosX + (aimPosX - startPosX)/(self.chainCount + 2)*(i+1)
        local posY = startPosY + (aimPosY - startPosY)/(self.chainCount + 2)*(i+1)
        local curPosInNode = self:convertToNodeSpace(cc.p(posX,posY))
        self.chain[i]:setPosition(curPosInNode)
    end

end

--结束锁定
function SkillLock:endLock( )
    print("over lock")
    FishGI.isLock = false
    self:setLockSpr(false)

    self.playerSelf = FishGI.gameScene.playerManager:getMyData()
    if self.playerSelf ~= nil then
        self.playerSelf:endShoot();
    end 
    self.touchStartTime = 0
    self.btn.parentClasss:setState(1)
    --self:stopTimer()
    self.playerSelf:setMyAimFish(0,0)
end

function SkillLock:onTouchBegan(touch, event) 
    if FishGI.isLock == true then
        if self.touchStartTime ~= 0 and (os.time() -self.touchStartTime < self.touchDisTime) then
            return
        end
        self.touchStartTime = os.time()

        local isTouchBtn = self:getParent():getParent():isTouchBtn(touch)
        if isTouchBtn then
            return true
        end

        local curPos = touch:getLocation()
        self.playerSelf = FishGI.gameScene.playerManager:getMyData()
        local myPlayerId = FishGI.gameScene.playerManager.selfIndex

        local timelineId,fishArrayId = self:getLockFishByPos(curPos)

        if timelineId == nil or (timelineId == 0 and  fishArrayId == 0)  then
            return true
        end

        self:setCppAimFish(myPlayerId,timelineId,fishArrayId)
        self:setMyAimFish(timelineId,fishArrayId)

        --锁定目标变换
        self:sendChangeAimFish()

        return true
    end

    return false

end

function SkillLock:onTouchCancelled(touch, event) 

end

--按键按下的处理
function SkillLock:clickCallBack( )
    local useType = self:judgeUseType()
    if useType == nil then
        return
    end
    local timelineId = 0
    local fishArrayId = 0
    
    if FishGI.isLock == false then
        timelineId,fishArrayId = self:getLockFishByScore()
    else
        timelineId = self.timelineId
        fishArrayId = self.fishArrayId
    end

    if timelineId == nil then
        return 
    end
    self:pushDataToPool(useType)
    self.useType = useType
    self.tem_timelineId = timelineId
    self.tem_fishArrayId = fishArrayId

    local data = {}
    data.useType = useType
    data.timelineId = timelineId
    data.fishArrayId = fishArrayId
    data.sendType = "start"
    self:sendNetMessage(data)
    self:runTimer()
    self.btn:setTouchEnabled(false)
	
	if FishGI.curGameRoomID == 1 then
		local dataTab = {}
		dataTab.funName = "showLockPointUI"
		LuaCppAdapter:getInstance():luaUseCppFun(dataTab);
	end
end

function SkillLock:getLockFishByScore( )
    local dataTab = {}
    dataTab.funName = "getLockFishByScore"
    local data = LuaCppAdapter:getInstance():luaUseCppFun(dataTab);
    local timelineId = data["timelineId"]
    local fishArrayId = data["fishArrayId"]
    if timelineId == nil then
        return 
    end

    return timelineId,fishArrayId
end

function SkillLock:getLockFishByPos( curPos )
    local locationInNode = FishGI.gameScene:convertToNodeSpace(curPos)
    local dataTab = {}
    dataTab.funName = "getFishByPos"
    dataTab.posX = locationInNode.x
    dataTab.posY = locationInNode.y
    local aimFish = LuaCppAdapter:getInstance():luaUseCppFun(dataTab);
    if aimFish["timelineId"] == 0 and  aimFish["fishArrayId"] == 0  then
        return 
    end
    local timelineId = aimFish["timelineId"]
    local fishArrayId = aimFish["fishArrayId"]

    return timelineId,fishArrayId
end

--得到我的目标鱼坐标
function SkillLock:getMyAimFishPos(  )
    local dataTab = {}
    dataTab.funName = "getAimFishPos"
    dataTab.playerId = FishGI.gameScene.playerManager.selfIndex
    local data = LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
    local aimPosX = 0
    local aimPosY = 0
    local state = 0
    if data ~= nil then
        aimPosX = data["posX"]
        aimPosY = data["posY"]
        state = data["state"]
    end

    return cc.p(aimPosX,aimPosY),state

end

--设置我的目标鱼
function SkillLock:setMyAimFish(timelineId,fishArrayId)
    -- if self.timelineId == timelineId and self.fishArrayId == fishArrayId then
    --     return
    -- end

    self.timelineId = timelineId
    self.fishArrayId = fishArrayId

    if FishGI.isLock == true then
        self:playLockChangeAim()
        --锁定目标变换
        self.playerSelf = FishGI.gameScene.playerManager:getMyData()
        self.playerSelf:setMyAimFish(self.timelineId,self.fishArrayId)
    end

end

--设置c++方面的目标鱼
function SkillLock:setCppAimFish(playerId, timelineId,fishArrayId)
    local dataTab = {}
    dataTab.funName = "setAimFish"
    dataTab.playerId = playerId
    dataTab.timelineId = timelineId
    dataTab.fishArrayId = fishArrayId
    LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
end

--开始我的锁定
function SkillLock:startMyLock( valTab)
    self.scaleX_,self.scaleY_,self.scaleMin_  = FishGF.getCurScale()
    self.playerSelf = FishGI.gameScene.playerManager:getMyData()
    local myPlayerId = self.playerSelf.playerInfo.playerId
    local useType = valTab.useType
    local newCrystal = valTab.newCrystal
    local isSuccess = valTab.isSuccess
    local skillPlus = valTab.skillPlus
    self.lock_userTime = self:getSkillData(4,"duration")
    if skillPlus ~= nil then
        self.lock_userTime = self.lock_userTime*skillPlus/100
    end
    if isSuccess == false then
        print("-----startMyLock--isSuccess == false-")
        self:clearDataFromPool(useType)
        self:stopTimer()
        self.tem_timelineId = 0
        self.tem_fishArrayId = 0
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000087),nil)
        return
    end

    self.btn.parentClasss:setState(2)

    if useType == 1 then
        --更新水晶
        FishGMF.upDataByPropId(myPlayerId,FishCD.PROP_TAG_02,newCrystal,false)
    elseif useType == 0 then
        FishGMF.addTrueAndFlyProp(myPlayerId,FishCD.PROP_TAG_04,-1,false)
    end
    self:clearDataFromPool(useType,false)

    FishGI.AudioControl:playEffect("sound/lock_01.mp3")

    FishGI.isLock = true
    --继续锁定
    self.startTime = os.time()
    self:runTimer()
    self:stopActionByTag(10006)
    local delayAct = cc.Sequence:create(cc.DelayTime:create(self.lock_userTime),cc.CallFunc:create(function ( ... )
        self:endLock();
    end))
    delayAct:setTag(10006)
    self:runAction(delayAct)
    
    self:setCppAimFish(myPlayerId,self.tem_timelineId,self.tem_fishArrayId)
    self:setMyAimFish(self.tem_timelineId,self.tem_fishArrayId)

    self.playerSelf.cannon.uiCannonChange:setAutoFire(false)
    
    local aimPos = self:getMyAimFishPos()

    print("get aim posx:"..aimPos.x.." posy:"..aimPos.y);
    if self.playerSelf ~= nil then
        if aimPos.x > 0 and  aimPos.y > 0 then
            print("shoot to aim");
            self.playerSelf:shoot(cc.p(aimPos.x,aimPos.y));
        end
    else
        print("player self is nil")
    end

    if self.schedulerID == nil then
       self.schedulerID = cc.Director:getInstance():getScheduler() :scheduleScriptFunc(function(dt)  
           self:upDataLock(dt)
       end,1/15,false) 
    end

end

--进入前台刷新时间
function SkillLock:upDateUserTime(disTime )
    if FishGI.isLock == false then
        return
    end
    local curTime =  os.time()
    local curdisTime = curTime - self.startTime
    if curdisTime <=0 then
        return
    end

    self:upDateTimer()

    if curdisTime > self.lock_userTime then
        self:endLock()
    else
        self:stopActionByTag(10006)
        local times = self.lock_userTime -curdisTime
        local delayAct = cc.Sequence:create(cc.DelayTime:create(times),cc.CallFunc:create(function ( ... )
            self:endLock();
        end))
        delayAct:setTag(10006)
        self:runAction(delayAct)
    end

end

function SkillLock:startOtherLock(data )
    local playerId = data.playerId
    local timelineId = data.timelineId
    local fishArrayId = data.fishArrayId
    self:setCppAimFish(playerId,timelineId,fishArrayId)

    --更新水晶
    FishGMF.upDataByPropId(playerId,2,data.newCrystal)
end

function SkillLock:upDataLock( dt )

    --判断是否停止定时器
    local bullerCount = 0
    if FishGI.isLock == false then
        local bullerCount = self:getLockBullet()
        --锁定子弹个数为0，并且锁定时间完了
        if bullerCount <= 0 then
            if  self.schedulerID ~= nil then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID )  
                self.schedulerID = nil
            end
            self:setCppAimFish(FishGI.gameScene.playerManager.selfIndex,0,0)
            self:setMyAimFish(0,0)
        end
    end

    --超出屏幕或者鱼死亡，转换目标鱼
    local sizeWin = cc.Director:getInstance():getWinSize()
    local aimPos,state = self:getMyAimFishPos()
    if aimPos == nil or state == FishCD.FishState.DEATH or
        (aimPos.x <= 0 or aimPos.x >=sizeWin.width 
            or aimPos.y <= 0 or aimPos.y >= sizeWin.height) then

        --选择分数最高的鱼
        local timelineId,fishArrayId = self:getLockFishByScore()
        
        if timelineId == 0 and fishArrayId == 0 then
            --判断新鱼不存在，锁定图片隐藏，玩家停止射击
            self:setLockSpr(false)
            self.playerSelf = FishGI.gameScene.playerManager:getMyData()
            if self.playerSelf ~= nil then
                self.playerSelf:endShoot();
            end
            return
        end

        self:setCppAimFish(FishGI.gameScene.playerManager.selfIndex,timelineId,fishArrayId)
        self:setMyAimFish(timelineId,fishArrayId)
        self:sendChangeAimFish()

    end

    --道具移动
    self:upDataLockSprAct(aimPos.x,aimPos.y)

    if FishGI.isLock == false then
        return
    end

    --发射子弹
    self.playerSelf = FishGI.gameScene.playerManager:getMyData()
    if self.playerSelf ~= nil then
        local currentGunRate = self.playerSelf.playerInfo.currentGunRate
        local maxGunRate = self.playerSelf.playerInfo.maxGunRate
        if FishGI.FRIEND_ROOM_STATUS == 0 and currentGunRate > maxGunRate then
            self.playerSelf:endShoot();
            self.playerSelf:setRotateByPos(cc.p(aimPos.x,aimPos.y));
            return
        end
        if self.playerSelf.isEnd == false and self.playerSelf.isShoot == false then
            --self:setLockSpr(true)
            self.playerSelf:shoot(cc.p(aimPos.x,aimPos.y));
        else
            self.playerSelf:shoot(cc.p(aimPos.x,aimPos.y));
            self.playerSelf:setRotateByPos(cc.p(aimPos.x,aimPos.y));
        end      
    end

end

--发送自己改变目标鱼消息
function SkillLock:sendChangeAimFish( )
    local playerId = FishGI.gameScene.playerManager.selfIndex
    local data = {}
    data.timelineId = self.timelineId
    data.fishArrayId = self.fishArrayId
    local bulletCount,bullets = self:getLockBullet(playerId)
    data.bullets = bullets
    data.sendType = "change"
    self:sendNetMessage(data)

end

--得到锁定子弹
function SkillLock:getLockBullet(playerId )
    local bullerCount = 0
    local bulletsTab = {}
    local dataTab = {}
    dataTab.funName = "getLockBullet"
    dataTab.playerId = playerId
    local bullets = LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
    for key,val in pairs(bullets) do
        bullerCount = bullerCount +1
        table.insert(bulletsTab,val)
    end

    return bullerCount,bulletsTab
end

--收到玩家改变目标消息
function SkillLock:bulletTargetChange(data )
    print("-0-OnBulletTargetChange----")
    local selfId = FishGI.gameScene.playerManager.selfIndex;
    if data.playerId ~= selfId then
        self:setCppAimFish(data.playerId,data.timelineId,data.fishArrayId)
    end 
    
end

return SkillLock;