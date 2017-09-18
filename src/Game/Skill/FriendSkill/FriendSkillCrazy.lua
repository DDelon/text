--狂暴
local FriendSkillCrazy = class("FriendSkillCrazy", require("Game/Skill/FriendSkill/FriendSkillBase"))

function FriendSkillCrazy.create(usePlayerId, targetPlayerId, propId)
	local obj = FriendSkillCrazy.new();
	obj:init(usePlayerId, targetPlayerId, propId);
	return obj;
end

function FriendSkillCrazy:init(usePlayerId, targetPlayerId, propId)
	FriendSkillCrazy.super.init(self, usePlayerId, targetPlayerId, propId);
end

function FriendSkillCrazy:playAnimation()
	local function shadePlayEnd()
	end
	FishGI.GameEffect.skillShadeEffect(cc.c3b(168, 0, 0), shadePlayEnd);

	local chairId = FishGI.gameScene.playerManager:getPlayerChairId(self.usePlayerId)
	local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(self.usePlayerId)
	local cannonPos = player:getCannonPos();
	local function playEffect()
	end
	local wordPos = cc.p(cannonPos.x, (chairId == 1 or chairId == 2) and cannonPos.y+150 or cannonPos.y-150);
	FishGI.GameEffect.skillWordEffect("battle/friend/effect/friendprop_pic_2.png", "battle/friend/effect/friendprop_pic_light_2.png", wordPos, playEffect)

	local function playCannonEffect()
		print("play cannon effect");
		FishGI.gameScene.uiMainLayer:startFirePowerAni(self.targetPlayerId);
	end
	
	local effect = FishGI.GameEffect.friendSkillEffect("ui/battle/friend/uifriendkb", "crazyani", false, cannonPos, 10000, playCannonEffect);
	cc.Director:getInstance():getRunningScene():addChild(effect, 10000);
end


return FriendSkillCrazy;