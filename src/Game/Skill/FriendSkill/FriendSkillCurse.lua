--诅咒
local FriendSkillCurse = class("FriendSkillCurse", require("Game/Skill/FriendSkill/FriendSkillBase"))

function FriendSkillCurse.create(usePlayerId, targetPlayerId, propId)
	local obj = FriendSkillCurse.new();
	obj:init(usePlayerId, targetPlayerId, propId);
	return obj;
end

function FriendSkillCurse:init(usePlayerId, targetPlayerId, propId)
	FriendSkillCurse.super.init(self, usePlayerId, targetPlayerId, propId);
end

function FriendSkillCurse:playAnimation()
	local function shadePlayEnd()
	end
	FishGI.GameEffect.skillShadeEffect(cc.c3b(120, 0, 254), shadePlayEnd);

	FishGI.gameScene.net:sendFriendGetPlayerInfo(self.targetPlayerId);
	local chairId = FishGI.gameScene.playerManager:getPlayerChairId(self.targetPlayerId)
	local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(self.targetPlayerId)
	local cannonPos = player:getCannonPos();
	local function playEffect()
	end
	local wordPos = cc.p(cannonPos.x, (chairId == 1 or chairId == 2) and cannonPos.y+150 or cannonPos.y-150);
	FishGI.GameEffect.skillWordEffect("battle/friend/effect/friendprop_pic_4.png", "battle/friend/effect/friendprop_pic_light_3.png", wordPos, playEffect)
	cannonPos = FishGI.gameScene.playerManager:getPlayerByPlayerId(self.targetPlayerId):getCannonPos();
	local effectPos = cc.p(cannonPos.x, (chairId == 1 or chairId == 2) and cannonPos.y+35 or cannonPos.y-35);
	local effect = FishGI.GameEffect.friendSkillEffect("ui/battle/friend/uifriendzz", "curseani", false, effectPos, 10000);
	cc.Director:getInstance():getRunningScene():addChild(effect, 10000);
end

function FriendSkillCurse:createBuff()
	FishGI.gameScene.skillManager:createSkillBuff(self.targetPlayerId, self.propId, self.extraData);
end


return FriendSkillCurse;