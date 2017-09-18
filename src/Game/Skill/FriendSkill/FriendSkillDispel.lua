--驱散
local FriendSkillDispel = class("FriendSkillDispel", require("Game/Skill/FriendSkill/FriendSkillBase"))

function FriendSkillDispel.create(usePlayerId, targetPlayerId, propId)
	local obj = FriendSkillDispel.new();
	obj:init(usePlayerId, targetPlayerId, propId);
	return obj;
end

function FriendSkillDispel:init(usePlayerId, targetPlayerId, propId)
	FriendSkillDispel.super.init(self, usePlayerId, targetPlayerId, propId);
end

function FriendSkillDispel:playSelectAnimation(callfunc)
	callfunc(FishGI.gameScene.playerManager:getMyData().playerInfo.playerId);
end


function FriendSkillDispel:playAnimation()
	local function shadePlayEnd()
	end
	FishGI.GameEffect.skillShadeEffect(cc.c3b(14, 251, 255), shadePlayEnd);

	local chairId = FishGI.gameScene.playerManager:getPlayerChairId(self.usePlayerId)
	local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(self.usePlayerId)
	local cannonPos = player:getCannonPos();
	local function playEffect()
	end
	local wordPos = cc.p(cannonPos.x, (chairId == 1 or chairId == 2) and cannonPos.y+150 or cannonPos.y-150);
	FishGI.GameEffect.skillWordEffect("battle/friend/effect/friendprop_pic_6.png", "battle/friend/effect/friendprop_pic_light_2.png", wordPos, playEffect)

	local winSize = cc.Director:getInstance():getWinSize();
	local effect = FishGI.GameEffect.friendSkillEffect("ui/battle/friend/uifriendqs", "dispelani", false, cc.p(winSize.width/2, winSize.height/2), 10000);
	cc.Director:getInstance():getRunningScene():addChild(effect, 10000);
end

return FriendSkillDispel;