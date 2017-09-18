local BuffBase = class("BuffBase")

function BuffBase:init(targetPlayerId, propId, buffNum)
	--(buff类型有三种 计时刷新型 计数叠加型 即时生效型)

	self.targetPlayerId = targetPlayerId;
	self.propId = propId;
	self.num = buffNum;
	print("num:"..self.num)
	self.isBuffEnd = false;
end

function BuffBase:executeBuff(skillManager)
	self.skillManager = skillManager;
end

function BuffBase:getType()
	return self.type;
end

function BuffBase:getPropId()
	return self.propId;
end

--获取效果数量 如果是计时类型就是时间 如果是计数类型就是数量
function BuffBase:getCountNum()
	return self.num;
end

function BuffBase:isThisPlayer(playerId)
	if self.targetPlayerId == playerId then
		return true;
	else
		return false;
	end
end

function BuffBase:isThisProp(propId)
	if self.propId == propId then
		return true;
	else
		return false;
	end
end

function BuffBase:isStop()
	return self.isBuffEnd;
end

function BuffBase:stopBuff()
	print("stop buff super")
	self.isBuffEnd = true;
end

function BuffBase:setBuffStatus()
	
end

function BuffBase:pause()
end

function BuffBase:resume()
end

function BuffBase:clearData(bUpdate)
	--self:init(0, 0, 0);
	print("clear data super")
	if bUpdate == nil then 
		bUpdate = true
	end 
	self:stopBuff(bUpdate)
end

return BuffBase