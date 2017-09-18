local AllocRoomStrategy = class("AllocRoomStrategy")
local oldRoomTab = {611, 636}
local newRoomTab = {527, 606}

function AllocRoomStrategy.create()
	local obj = AllocRoomStrategy.new();
	obj:init();
	return obj;
end

function AllocRoomStrategy:init()

end

function AllocRoomStrategy:getRoomsIndexTab(roomTab, versionTab, channelId)
	local bigVersion = versionTab[2];
	local rooms = {}
	if bigVersion == 3 then
		--找旧的房间
		for key1, val1 in pairs(oldRoomTab) do
			for key2, val2 in pairs(roomTab) do
				if key2 == val1 then
					rooms[key2] = val2
				end
			end
		end
	else
		--找新的房间
		for key1, val1 in pairs(newRoomTab) do
			for key2, val2 in pairs(roomTab) do
				if key2 == val1 then
					rooms[key2] = val2
				end
			end
		end
	end
	local limitDownNum = 500;	--下限 小于这个数量就优先导入玩家
	local limitUpNum = 5000;	--上限 大于这个数就不导入玩家

	local limitDownMax = 0
	local index = 0
	for key, val in pairs(rooms) do
		if val.gameid == GAME_ID and (val.cmd.friend == nil or val.cmd.friend ~="1") then
			local playerNum = val.players;
			if playerNum <= limitDownNum and playerNum >= limitDownMax then
				
				limitDownMax = playerNum;
				index = key;
			end
		end
	end

	if limitDownMax == 0 and index == 0 then
		--没有低于500的房间
		--排除大于5000的房间
		local selectTab = {}
		local limitUpMin = 0
		for key, val in pairs(rooms) do
			local playerNum = val.players;
			if playerNum < limitUpNum then
				table.insert(selectTab, key);
			end
		end

		if table.maxn(selectTab) == 0 then
			return nil;
		else
			return self:randomSelectRoom(selectTab);
		end

	else
		return index;
	end

	
end

function AllocRoomStrategy:randomSelectRoom(roomIndexTab)
	local roomIndex = math.random(1,table.maxn(roomIndexTab));
	return roomIndexTab[roomIndex];
end

return AllocRoomStrategy;