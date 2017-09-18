local BuffDispel = class("BuffDispel", require("Game/Skill/Buff/BuffImmediate"))

function BuffDispel.create(targetPlayerId, propId, buffNum)
	local obj = BuffDispel.new();
	obj:init(targetPlayerId, propId, buffNum);
	return obj;
end

function BuffDispel:init(targetPlayerId, propId, buffNum)
	BuffDispel.super.init(self, targetPlayerId, propId, buffNum);
end

function BuffDispel:executeBuff(skillManager)
	--驱散所有人的所有buff
	skillManager:clearAllBuff();
end

function BuffDispel:stopBuff()
	self.isBuffEnd = true;
end


return BuffDispel;