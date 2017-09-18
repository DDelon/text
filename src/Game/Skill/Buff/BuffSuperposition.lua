local BuffSuperposition = class("BuffSuperposition", require("Game/Skill/Buff/BuffBase"))

function BuffSuperposition:init(targetPlayerId, propId, buffNum)
	BuffSuperposition.super.init(self, targetPlayerId, propId, buffNum);
	self.type = 2;
end

function BuffSuperposition:executeBuff(skillManager)
	if self.num <= 0 then
		self:stopBuff();
	else
		self.num = self.num-1;
	end
	print("execute buff superposition")
end

--buff叠加效果 
function BuffSuperposition:superposition(buff)
	print("superposition num:"..self.num)
	self.num = self.num+buff:getCountNum();
	print("superposition num:"..self.num)
	self:setBuffStatus();
end

--刷新剩余数量
function BuffSuperposition:setBuffStatus()
	FishGI.gameScene.uiMainLayer:setPropBuff(self.targetPlayerId, self.propId, self.num, tostring(self.num));
end

function BuffSuperposition:stopBuff()
	BuffSuperposition.super.stopBuff(self);
end

return BuffSuperposition;