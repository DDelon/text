local BuffCrazy = class("BuffCrazy", require("Game/Skill/Buff/BuffTime"))

function BuffCrazy.create(targetPlayerId, propId, buffNum)
	local obj = BuffCrazy.new();
	obj:init(targetPlayerId, propId, buffNum);
	return obj;
end

function BuffCrazy:init(targetPlayerId, propId, buffNum)
	BuffCrazy.super.init(self, targetPlayerId, propId, buffNum);
end

function BuffCrazy:executeBuff(skillManager)
	--获得的积分翻倍
	BuffCrazy.super.executeBuff(self, skillManager);
end

function BuffCrazy:stopBuff()
	BuffCrazy.super.stopBuff(self);
	FishGI.gameScene.uiMainLayer:stopFirePowerAni(self.targetPlayerId);
end

return BuffCrazy;