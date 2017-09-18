--瞄准
local FriendSkillAim = class("FriendSkillAim", require("Game/Skill/FriendSkill/FriendSkillBase"))

function FriendSkillAim.create(usePlayerId, targetPlayerId, propId)
	local obj = FriendSkillAim.new();
	obj:init(usePlayerId, targetPlayerId, propId);
	return obj;
end

function FriendSkillAim:init(usePlayerId, targetPlayerId, propId)
	FriendSkillAim.super.init(self, usePlayerId, targetPlayerId, propId);
end

function FriendSkillAim:playSelectAnimation(callfunc)
	callfunc(FishGI.gameScene.playerManager:getMyData().playerInfo.playerId);
end

function FriendSkillAim:playAnimation()
	local function shadePlayEnd()
		
	end
	FishGI.GameEffect.skillShadeEffect(cc.c3b(0, 255, 252), shadePlayEnd);

	local chairId = FishGI.gameScene.playerManager:getPlayerChairId(self.usePlayerId)
	local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(self.usePlayerId)
	local cannonPos = player:getCannonPos();

	local function playEffect()
	end
	local wordPos = cc.p(cannonPos.x, (chairId == 1 or chairId == 2) and cannonPos.y+150 or cannonPos.y-150);
	FishGI.GameEffect.skillWordEffect("battle/friend/effect/friendprop_pic_3.png", "battle/friend/effect/friendprop_pic_light_2.png", wordPos, playEffect)
end

return FriendSkillAim;