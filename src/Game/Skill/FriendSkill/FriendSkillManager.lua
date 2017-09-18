--当前技能分成三种类型（时间型 叠加计数型 瞬时生效型）技能只需要分成这三种类型 具体的不同效果体现在buff那边
local FriendSkillManager = class("FriendSkillManager", function()
	return cc.Layer:create();
end)

function FriendSkillManager.create()
	local obj = FriendSkillManager.new();
	obj:init();
	return obj;
end

function FriendSkillManager:init()
	self.buffTab = {}
	self:registerListener();
	self.scheduleId = 0;
	self:openUpdate();
	self:initStatusData();
	self.tSkill = {}
end

function FriendSkillManager:initStatusData()
	self.isFree = false;
	self.scoreMul = 1;
end

function FriendSkillManager:initBuffWithData(playerId, effects)
	if effects == nil or table.maxn(effects) == 0 then
		return;
	end

	for key, val in pairs(effects) do
		local buffNum = 0;
		if val.effectId == FishCD.FRIEND_SKILL_ID.CURSE then
			--层数
			buffNum = val.extraData*tonumber(FishGI.GameConfig:getConfigData("friendprop",tostring(420000000+FishCD.FRIEND_SKILL_ID.CURSE),"extra_data"));
		elseif val.effectId == FishCD.FRIEND_SKILL_ID.WEAK then
			--数量
			buffNum = val.extraData
		else
			--时间
			buffNum = math.ceil(val.extraData/1000);
		end
		print("init skill buff propId:"..val.effectId.."num:"..buffNum)
		self:createSkillBuff(playerId, val.effectId, buffNum, true);
	end
end

function FriendSkillManager:registerListener()
	local customEventDispatch=cc.Director:getInstance():getEventDispatcher()  

	local useListenerCustom=cc.EventListenerCustom:create("UseFriendSKillResponse",function(data) self:useSkillResponse(data) end)  
    customEventDispatch:addEventListenerWithFixedPriority(useListenerCustom, 1)
    

    local updateListenerCustom=cc.EventListenerCustom:create("UpdateSkillResponse",function(data) self:updateSkillResponse(data) end)  
    customEventDispatch:addEventListenerWithFixedPriority(updateListenerCustom, 2)

    local shootListenerCustom=cc.EventListenerCustom:create("PlayerShoot",function(data) self:playerShoot(data) end)  
    customEventDispatch:addEventListenerWithFixedPriority(shootListenerCustom, 2)

    local onShootListenerCustom=cc.EventListenerCustom:create("OnPlayerShoot",function(data) self:onPlayerShoot(data) end)  
    customEventDispatch:addEventListenerWithFixedPriority(onShootListenerCustom, 2)
end

function FriendSkillManager:removeListener()
	cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners("UseFriendSKillResponse");
	cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners("UpdateSkillResponse");
	cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners("PlayerShoot");
	cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners("OnPlayerShoot");
end

--玩家发射子弹
function FriendSkillManager:playerShoot(data)

end

--收到服务器通知的玩家发射子弹成功的消息
function FriendSkillManager:onPlayerShoot(data)
	local playerId = data._usedata.playerId
	for i, v in pairs(data._usedata.effects) do
		local buff = self:getBuff(playerId, v)
		if buff then 
			if v == FishCD.FRIEND_PROP_05 then 
				buff:executeBuff(self)
			end 
		end 
	end
end

function FriendSkillManager:doBuff(playerId)
	--self:initStatusData();
	local tab = self:getPlayerBuff(playerId);
	for key, val in pairs(tab) do
		val:executeBuff(self);
	end
end

function FriendSkillManager:setFreeFire(val)
	self.isFree = val;
end
function FriendSkillManager:isFreeFire()
	return self.isFree;
end

function FriendSkillManager:setScoreMul(val)
	self.scoreMul = val;
end
function FriendSkillManager:getScoreMul()
	return self.scoreMul;
end

function FriendSkillManager:sendDataToServer(propId)
	if propId == FishCD.FRIEND_SKILL_ID.FIRE or propId == FishCD.FRIEND_SKILL_ID.CRAZY or propId == FishCD.FRIEND_SKILL_ID.AIM then
		local targetPlayerId = FishGI.gameScene.playerManager.selfIndex;
		FishGI.gameScene.net:sendUsePropSkill(propId, targetPlayerId);
	elseif propId == FishCD.FRIEND_SKILL_ID.CURSE or propId == FishCD.FRIEND_SKILL_ID.WEAK then
		local function selectTargetFunc(targetPlayerId)
			FishGI.gameScene.net:sendUsePropSkill(propId, targetPlayerId);
		end
		FishGI.GameEffect.createUseTargetEffet(selectTargetFunc);
	else
		FishGI.gameScene.net:sendUsePropSkill(propId, 0);
	end
end

function FriendSkillManager:useSkillResponse(evt)
	local data = evt._usedata
	local isSuccess = data.success;
	if isSuccess then
		local function callBack(skill)
			if skill and self.tSkill[skill.targetPlayerId] then 
				self.tSkill[skill.targetPlayerId][skill.propId] = nil
			end 
		end 
		local usePlayerId = data.playerId;
        local targetPlayerId = data.targetPlayerId;
        local propId = data.propId;
        local skill = self:createSkill(usePlayerId, targetPlayerId, propId);
		skill:callBackQuit(callBack)
		skill:useSkill();
		if self.tSkill[targetPlayerId] == nil then 
			self.tSkill[targetPlayerId] = {}
		end 
		if self.tSkill[targetPlayerId][propId] then 
			self.tSkill[targetPlayerId][propId]:clear()
			self.tSkill[targetPlayerId][propId] = nil
		end
		self.tSkill[targetPlayerId][propId] = skill
	else
		local errorCode = data.errorCode;
        if errorCode == 1 then
            print("无效的道具id");
        elseif errorCode == 2 then
            print("目标不存在");
        elseif errorCode == 3 then
            print("道具数量不足");
        end
	end
end

function FriendSkillManager:updateSkillResponse(evt)
	local data = evt._usedata
	local playerId = data.playerId;
	local lessBuffTab = data.effects;
    local buffTab = self:getPlayerBuff(playerId);

    for key1, val1 in pairs(buffTab) do
        local isNeedStop = true;
        for key2, val2 in pairs(lessBuffTab) do
            if val1.propId == val2.effectId then
                isNeedStop = false;
            end
        end
        if isNeedStop then
            val1:clearData();
        end
    end
end

function FriendSkillManager:openUpdate()
	local function updateInline(dt)
		self:update(dt);
	end

	self.scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateInline, 1, false);
end

function FriendSkillManager:closeUpdate()
	if self.scheduleId ~= 0 then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleId)
		self.scheduleId = 0;
	end
end

function FriendSkillManager:update(dt)
	local buffTab = self.buffTab;
	for key = table.maxn(self.buffTab), 1, -1 do
		if self.buffTab[key]:isStop() then
			--self.buffTab[key]:clearData();
			table.remove(self.buffTab, key);
		else
			--self.buffTab[key]:output();
		end
	end

	--print("buff table size:"..table.maxn(self.buffTab))
end

function FriendSkillManager:createSkill(usePlayerId, targetPlayerId, propId)
	--技能生成buff
	local skill = nil;
	if propId == FishCD.FRIEND_SKILL_ID.FIRE then
		skill = require("Game/Skill/FriendSkill/FriendSkillFire").create(usePlayerId, targetPlayerId, propId);
	elseif propId == FishCD.FRIEND_SKILL_ID.CRAZY then
		skill = require("Game/Skill/FriendSkill/FriendSkillCrazy").create(usePlayerId, targetPlayerId, propId);
	elseif propId == FishCD.FRIEND_SKILL_ID.AIM then
		skill = require("Game/Skill/FriendSkill/FriendSkillAim").create(usePlayerId, targetPlayerId, propId);
	elseif propId == FishCD.FRIEND_SKILL_ID.CURSE then
		skill = require("Game/Skill/FriendSkill/FriendSkillCurse").create(usePlayerId, targetPlayerId, propId);
	elseif propId == FishCD.FRIEND_SKILL_ID.WEAK then
		skill = require("Game/Skill/FriendSkill/FriendSkillWeak").create(usePlayerId, targetPlayerId, propId);
	elseif propId == FishCD.FRIEND_SKILL_ID.DISPEL then
		skill = require("Game/Skill/FriendSkill/FriendSkillDispel").create(usePlayerId, targetPlayerId, propId);
	end
	return skill;
end

function FriendSkillManager:createSkillBuff(targetPlayerId, propId, buffNum, isInit)
	local buff = nil;
	print("target player id:"..targetPlayerId)
	if propId == FishCD.FRIEND_SKILL_ID.FIRE then
		buff = require("Game/Skill/Buff/BuffFire").create(targetPlayerId, propId, buffNum);
	elseif propId == FishCD.FRIEND_SKILL_ID.CRAZY then
		buff = require("Game/Skill/Buff/BuffCrazy").create(targetPlayerId, propId, buffNum);
	elseif propId == FishCD.FRIEND_SKILL_ID.AIM then
		buff = require("Game/Skill/Buff/BuffAim").create(targetPlayerId, propId, buffNum);
	elseif propId == FishCD.FRIEND_SKILL_ID.CURSE then
		buff = require("Game/Skill/Buff/BuffCurse").create(targetPlayerId, propId, buffNum, isInit);
	elseif propId == FishCD.FRIEND_SKILL_ID.WEAK then
		buff = require("Game/Skill/Buff/BuffWeak").create(targetPlayerId, propId, buffNum);
	elseif propId == FishCD.FRIEND_SKILL_ID.DISPEL then
		buff = require("Game/Skill/Buff/BuffDispel").create(targetPlayerId, propId, buffNum);
	end
	if buff ~= nil then
		--2等于叠加型
		if buff:getType() == 2 then
			local oldBuff = self:getBuff(targetPlayerId, propId)
			if oldBuff ~= nil then
				oldBuff:superposition(buff);
				buff:clearData(false);
			else
				table.insert(self.buffTab, buff);
				buff:setBuffStatus();
			end
		else
			if buff:getType() == 1 then
				self:clearBuff(targetPlayerId, propId);
			end 
			table.insert(self.buffTab, buff);
			buff:executeBuff(self);
		end
	end
	return buff;
end

--获得玩家身上的buff类
function FriendSkillManager:getPlayerBuff(playerId)
	local tab = {}
	for key, val in pairs(self.buffTab) do
		if not val:isStop() and val:isThisPlayer(playerId) then
			table.insert(tab, val);
		end
	end
	return tab;
end

--获得玩家身上的propId
function FriendSkillManager:getPlayerBuffId(playerId)
	local tab = {}
	for key, val in pairs(self.buffTab) do
		if not val:isStop() and val:isThisPlayer(playerId) then
			table.insert(tab, val:getPropId());
		end
	end

	return tab;
end

--获得特定的buff
function FriendSkillManager:getBuff(playerId, propId)
	local tab = self:getPlayerBuff(playerId);

	for key, val in pairs(tab) do
		if val:isThisProp(propId) then
			return val;
		end
	end
end

--清除所有状态
function FriendSkillManager:clearAllBuff()
	if self.tSkill ~= nil then
		for i, v in pairs(self.tSkill) do
			for j, w in pairs(v) do
				w:clear()
			end
		end
	end
	for key, val in pairs(self.buffTab) do
		val:clearData();
	end
end

--清除指定类型的buff
function FriendSkillManager:clearBuffType(propId)
	if self.tSkill ~= nil then
		for i, v in pairs(self.tSkill) do
			for j, w in pairs(v) do
				w:clear()
			end
		end
	end
	for key, val in pairs(self.buffTab) do
		if val:isThisProp(propId) then
			val:clearData();
		end
	end
end

--删除指定的buff
function FriendSkillManager:clearBuff(playerId, propId)
	local buff = self:getBuff(playerId, propId);
	if buff ~= nil then
		buff:clearData();
	end
end

--暂停玩家身上的buff
function FriendSkillManager:pausePlayerAllBuff(playerId)
	local tab = self:getPlayerBuff(playerId);
	for key, val in pairs(tab) do
		val:pause();
	end
end

--恢复玩家身上的buff
function FriendSkillManager:resumePlayerAllBuff(playerId)
	local tab = self:getPlayerBuff(playerId);
	for key, val in pairs(tab) do
		val:resume();
	end
end

function FriendSkillManager:clear()
	if self.tSkill ~= nil then
		for i, v in pairs(self.tSkill) do
			for j, w in pairs(v) do
				w:clear()
			end
		end
	end
	if self.buffTab ~= nil then
		for key, val in pairs(self.buffTab) do
			val:clearData()
		end
	end
	self:removeListener()
	self:closeUpdate()
	self.tSkill = nil
	self.buffTab = nil
end

return FriendSkillManager;