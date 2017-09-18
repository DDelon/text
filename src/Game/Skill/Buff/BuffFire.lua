local BuffFire = class("BuffFire", require("Game/Skill/Buff/BuffTime"))

function BuffFire.create(targetPlayerId, propId, buffNum)
	print("fire create ")
	local obj = BuffFire.new();
	obj:init(targetPlayerId, propId, buffNum);
	return obj;
end

function BuffFire:init(targetPlayerId, propId, buffNum)
	BuffFire.super.init(self, targetPlayerId, propId, buffNum);
end

function BuffFire:executeBuff(skillManager)
	--发射子弹不扣数量(设置一个统一的标志量 数值代表执行不同的效果)
	print("execute free fire")
	BuffFire.super.executeBuff(self, skillManager);

	if self.targetPlayerId ~= FishGI.gameScene.playerManager.selfIndex then
        return;
    end
	skillManager:setFreeFire(true);
end

function BuffFire:stopBuff()
	BuffFire.super.stopBuff(self);

	if self.targetPlayerId ~= FishGI.gameScene.playerManager.selfIndex then
        return;
    end
	self.skillManager:setFreeFire(false);
end

return BuffFire;