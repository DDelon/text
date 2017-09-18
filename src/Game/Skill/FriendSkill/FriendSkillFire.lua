local FriendSkillFire = class("FriendSkillFire", require("Game/Skill/FriendSkill/FriendSkillBase"))

function FriendSkillFire.create(usePlayerId, targetPlayerId, propId)
	local obj = FriendSkillFire.new();
	obj:init(usePlayerId, targetPlayerId, propId);
	return obj;
end

function FriendSkillFire:init(usePlayerId, targetPlayerId, propId)
	FriendSkillFire.super.init(self, usePlayerId, targetPlayerId, propId);
end

function FriendSkillFire:playAnimation()
	local function shadePlayEnd()
		print("----------shade play end")
	end
	FishGI.GameEffect.skillShadeEffect(cc.c3b(255, 144, 0), shadePlayEnd);

	local chairId = FishGI.gameScene.playerManager:getPlayerChairId(self.usePlayerId)
	local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(self.usePlayerId)
	local cannonPos = player:getCannonPos();
	print("cannon posx:"..cannonPos.x.." cannon posy:"..cannonPos.y)
	local function playEffect()
		print("----------playEffect")
	end
	local wordPos = cc.p(cannonPos.x, (chairId == 1 or chairId == 2) and cannonPos.y+150 or cannonPos.y-150);
	print("word posx:"..wordPos.x.." word posy:"..wordPos.y)
	FishGI.GameEffect.skillWordEffect("battle/friend/effect/friendprop_pic_1.png", "battle/friend/effect/friendprop_pic_light_2.png", wordPos, playEffect)

	self.skillEffect = FishGI.GameEffect.friendSkillEffect("ui/battle/friend/uifriendhl", "fireani", true, cc.p(0, 0), 100);
	local upNode, downNode = FishGI.gameScene.uiMainLayer:getAniNodeLayer(self.usePlayerId)
	downNode:addChild(self.skillEffect, 100);
end

return FriendSkillFire;
