local FriendSkillBase = class("FriendSkillBase")

function FriendSkillBase:init(usePlayerId, targetPlayerId, propId)
	self.propId = propId;
	self.duration = tonumber(FishGI.GameConfig:getConfigData("friendprop",tostring(420000000+self.propId),"duration"));
	self.propRes = FishGI.GameConfig:getConfigData("friendprop",tostring(420000000+self.propId),"friendprop_res");
	self.propName = FishGI.GameConfig:getConfigData("friendprop",tostring(420000000+self.propId),"friendprop_name");
	self.extraData = tonumber(FishGI.GameConfig:getConfigData("friendprop",tostring(420000000+self.propId),"extra_data"));
	self.isBuff = FishGI.GameConfig:getConfigData("friendprop",tostring(420000000+self.propId),"if_buff");
	self.isSposition = tonumber(FishGI.GameConfig:getConfigData("friendprop",tostring(420000000+self.propId),"if_superposition"));
	self.countdown = FishGI.GameConfig:getConfigData("friendprop",tostring(420000000+self.propId),"cool_down");
	self.usePlayerId = usePlayerId;
	self.targetPlayerId = targetPlayerId;

	self.skillEffect = nil
end

function FriendSkillBase:setSkillInfo(usePlayerId, targetPlayerId)
	self.usePlayerId = usePlayerId;
	self.targetPlayerId = targetPlayerId;
end

function FriendSkillBase:useSkill()
	--播放技能效果
	self:playAnimation();
	--播放技能冷却动画
	self:playCountDown();
	--扣除技能数量
	self:reducePropNum();
	--创建buff效果
	self:createBuff();
end

--播放技能动画
function FriendSkillBase:playAnimation()
	
end

--停止技能动画
function FriendSkillBase:stopAnimation()
	if self.skillEffect then 
		self.skillEffect.animation:stop()
		self.skillEffect:removeFromParent()
		self.skillEffect = nil
	end 
	if self.funCallBack then 
		self.funCallBack(self)
	end 
end

function FriendSkillBase:playCountDown()
	if self.usePlayerId == FishGI.gameScene.playerManager.selfIndex then
		FishGI.gameScene.uiMainLayer:runPropTimer(self.propId)
	end
	self:unscheduleDuration()
	local function updateTimeout()
		self:unscheduleDuration()
		self:stopAnimation()
    end
    self.durationScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTimeout, self.duration, false) 
end

function FriendSkillBase:unscheduleDuration()
    if self.durationScheduleId ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.durationScheduleId)
        self.durationScheduleId = nil
    end
end

function FriendSkillBase:reducePropNum()
	FishGMF.addTrueAndFlyProp(self.usePlayerId,self.propId+10000,-1,true,0,0);
end

function FriendSkillBase:createBuff()
	FishGI.gameScene.skillManager:createSkillBuff(self.targetPlayerId, self.propId, self.duration);
end

function FriendSkillBase:clear( )
	self:unscheduleDuration()
	self:stopAnimation()
end

function FriendSkillBase:callBackQuit( funCallBack )
	self.funCallBack = funCallBack
end

return FriendSkillBase;