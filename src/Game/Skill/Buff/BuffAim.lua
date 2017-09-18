local BuffAim = class("BuffAim", require("Game/Skill/Buff/BuffTime"))

function BuffAim.create(targetPlayerId, propId, buffNum)
	local obj = BuffAim.new();
	obj:init(targetPlayerId, propId, buffNum);
	return obj;
end

function BuffAim:init(targetPlayerId, propId, buffNum)
	BuffAim.super.init(self, targetPlayerId, propId, buffNum);

end

function BuffAim:executeBuff(skillManager)
	BuffAim.super.executeBuff(self, skillManager)

    self.countdown = 15;
    local customEventDispatch=cc.Director:getInstance():getEventDispatcher()  
    local useListenerCustom=cc.EventListenerCustom:create("BulletTargetChange",function(data) self:onBulletTargetChange(data) end)  
    customEventDispatch:addEventListenerWithFixedPriority(useListenerCustom, 1)

    if self.targetPlayerId ~= FishGI.gameScene.playerManager.selfIndex then
        return;
    end
	local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(FishGI.gameScene.playerManager.selfIndex);
	self.cannonPos = player:getCannonPos();
	self:setAim();
    self:sendChangeAimFish();
	local aimPos = self:getMyAimFishPos();
	
	self.lockAni = FishGI.GameEffect.createLockAni(8, self.cannonPos, aimPos, function(pSender, eventName) self:playerSelectFish(pSender, eventName) end);
	FishGI.gameScene.uiMainLayer:addChild(self.lockAni, FishCD.ORDER_GAME_lock);

	self.playerSelf = FishGI.gameScene.playerManager:getMyData()
	self.playerSelf.cannon.uiCannonChange:setAutoFire(false)

	if self.playerSelf ~= nil then
        if aimPos.x > 0 and  aimPos.y > 0 then
            print("shoot to aim");
            self.playerSelf:shoot(cc.p(aimPos.x,aimPos.y));
        end
    else
        print("player self is nil")
    end
end

function BuffAim:stopBuff()
	BuffAim.super.stopBuff(self);
    if self.playerSelf ~= nil then
        self.playerSelf:endShoot();
        self.playerSelf:setMyAimFish(0,0)
    end
    if self.lockAni ~= nil then
    	self.lockAni:removeFromParent();
        self.lockAni = nil;
    end
    cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners("BulletTargetChange");
end

function BuffAim:playerSelectFish(pSender, eventName)
    if eventName == ccui.TouchEventType.ended then
        local curPos = pSender:getTouchEndPosition();


        local myPlayerId = FishGI.gameScene.playerManager.selfIndex

        local timelineId,fishArrayId = self:getLockFishByPos(curPos)

        if timelineId == nil or (timelineId == 0 and  fishArrayId == 0)  then
            return true
        end

        self:setCppAimFish(myPlayerId,timelineId,fishArrayId)
        self:setMyAimFish(timelineId,fishArrayId)

        --锁定目标变换
        self:sendChangeAimFish()
    end
end

function BuffAim:openUpdate()
	local function updateInline(dt)
		self:update(dt);
	end
	if self.scheduleId == 0 then
		self.scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateInline, 1/15, false);
	end
end

function BuffAim:update(dt)
    if self.isBuffEnd then
        self:closeUpdate();
        return;
    end
	self.countdown = self.countdown-1;
	if self.countdown == 0 then
		BuffAim.super.update(self, dt);
		self.countdown = 15
	end
    if self.targetPlayerId ~= FishGI.gameScene.playerManager.selfIndex then
        return;
    end
	local aimPos,status = self:getMyAimFishPos()
	if self:isReselection(aimPos, status) then

		--选择分数最高的鱼
        local timelineId,fishArrayId = self:getLockFishByScore()
        
        if timelineId == 0 and fishArrayId == 0 then
            --判断新鱼不存在，锁定图片隐藏，玩家停止射击
            
            self.playerSelf = FishGI.gameScene.playerManager:getMyData()
            if self.playerSelf ~= nil then
                self.playerSelf:endShoot();
            end
            self:stopBuff();
            return
        end

        self:setCppAimFish(FishGI.gameScene.playerManager.selfIndex,timelineId,fishArrayId)
        self:setMyAimFish(timelineId,fishArrayId)
        self:sendChangeAimFish()
	end

	FishGI.GameEffect.updateLockPos(self.lockAni, 8, self.cannonPos, aimPos);

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

--是否重选目标鱼
function BuffAim:isReselection(aimPos, status)
	local sizeWin = cc.Director:getInstance():getWinSize();
	if status == FishCD.FishState.DEATH or
        (aimPos.x <= 0 or aimPos.x >=sizeWin.width 
            or aimPos.y <= 0 or aimPos.y >= sizeWin.height) then
        return true
    else
    	return false
    end
end

function BuffAim:getLockFishByPos( curPos )
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

function BuffAim:setCppAimFish(playerId, timelineId, fishArrayId)
	local dataTab = {}
    dataTab.funName = "setAimFish"
    dataTab.playerId = playerId
    dataTab.timelineId = timelineId
    dataTab.fishArrayId = fishArrayId
    LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
end

--设置我的目标鱼
function BuffAim:setMyAimFish(timelineId,fishArrayId)
    self.timelineId = timelineId
    self.fishArrayId = fishArrayId

    --if FishGI.isLock == true then
    --    self:playLockChangeAim()
        --锁定目标变换
    FishGI.GameEffect.updateLockAim(self.lockAni);
    self.playerSelf = FishGI.gameScene.playerManager:getMyData()
    self.playerSelf:setMyAimFish(self.timelineId,self.fishArrayId)
    --end

end

--得到锁定子弹
function BuffAim:getLockBullet(playerId )
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

--得到我的目标鱼坐标
function BuffAim:getMyAimFishPos(  )
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

--获取存活的分数最高的鱼
function BuffAim:getLockFishByScore( )
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

function BuffAim:setAim()
	local timelineId, fishArrayId = self:getLockFishByScore();
	local playerId = FishGI.gameScene.playerManager.selfIndex;
	self:setCppAimFish(playerId,timelineId,fishArrayId)
    self:setMyAimFish(timelineId,fishArrayId)

    self.playerSelf.cannon.uiCannonChange:setAutoFire(false)
end

--发送自己改变目标鱼消息
function BuffAim:sendChangeAimFish( )
    local playerId = FishGI.gameScene.playerManager.selfIndex
    local data = {}
    data.timelineId = self.timelineId
    data.fishArrayId = self.fishArrayId
    local bulletCount,bullets = self:getLockBullet(playerId)
    data.bullets = bullets

    local tab = {}
    tab.bullets = data.bullets
    tab.timelineId = data.timelineId
    tab.fishArrayId = data.fishArrayId
    FishGI.gameScene.net:sendBulletTargetChange(tab)
	print("send message change aim fish")
end

function BuffAim:onBulletTargetChange(evt)
    print("aim target change");
    local data = evt._userdata;
    local selfId = FishGI.gameScene.playerManager.selfIndex;
    if data.playerId ~= selfId then
        self:setCppAimFish(data.playerId,data.timelineId,data.fishArrayId)
    end 
end



return BuffAim;