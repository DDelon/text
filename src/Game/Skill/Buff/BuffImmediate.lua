local BuffImmediate = class("BuffImmediate", require("Game/Skill/Buff/BuffBase"))


function BuffImmediate:init(targetPlayerId, propId, buffNum)
	self.type = 3;
	BuffImmediate.super.init(self, targetPlayerId, propId, buffNum);
end

function BuffImmediate:executeBuff(skillManager)
	
end

return BuffImmediate;