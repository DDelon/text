--虚弱
local FriendSkillWeak = class("FriendSkillWeak", require("Game/Skill/FriendSkill/FriendSkillBase"))

function FriendSkillWeak.create(usePlayerId, targetPlayerId, propId)
	local obj = FriendSkillWeak.new();
	obj:init(usePlayerId, targetPlayerId, propId);
	return obj;
end

function FriendSkillWeak:init(usePlayerId, targetPlayerId, propId)
	FriendSkillWeak.super.init(self, usePlayerId, targetPlayerId, propId);
end


function FriendSkillWeak:playAnimation(targetPlayerId)
	local function shadePlayEnd()
	end
	FishGI.GameEffect.skillShadeEffect(cc.c3b(141, 0, 194), shadePlayEnd);

	local chairId = FishGI.gameScene.playerManager:getPlayerChairId(self.targetPlayerId)
	local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(self.targetPlayerId)
	local cannonPos = player:getCannonPos();
	local function playEffect()
	end
	local wordPos = cc.p(cannonPos.x, (chairId == 1 or chairId == 2) and cannonPos.y+150 or cannonPos.y-150);
	FishGI.GameEffect.skillWordEffect("battle/friend/effect/friendprop_pic_5.png", "battle/friend/effect/friendprop_pic_light_3.png", wordPos, playEffect)
	cannonPos = FishGI.gameScene.playerManager:getPlayerByPlayerId(self.targetPlayerId):getCannonPos();
	local effectPos = cc.p(cannonPos.x, (chairId == 1 or chairId == 2) and cannonPos.y+35 or cannonPos.y-35);
	local effect = FishGI.GameEffect.friendSkillEffect("ui/battle/friend/uifriendxr", "weakani", false, effectPos, 10000);
	cc.Director:getInstance():getRunningScene():addChild(effect, 10000);
end

function FriendSkillWeak:createBuff()
	FishGI.gameScene.skillManager:createSkillBuff(self.targetPlayerId, self.propId, self.extraData);
end


return FriendSkillWeak;