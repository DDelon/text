local WritePlayerData = class("WritePlayerData", nil);

function WritePlayerData.create()
	local obj = WritePlayerData.new();
	obj:init();
	return obj;
end

function WritePlayerData:init()
	self.filePath = "";
	self.data = {};
	self.key = 0;
end

function WritePlayerData:loadFile(fileName)
	
	local filePath = cc.FileUtils:getInstance():getWritablePath()..fileName;
	local isExist = cc.FileUtils:getInstance():isFileExist(filePath);
	if isExist then
		self.filePath = filePath;
		self.data = cc.FileUtils:getInstance():getValueMapFromFile(filePath);
		self:upDateData()
	else
		self.filePath = filePath;
		FishGF.print("loadfile filepath is invalid filepath create "..fileName);
	end
end

function WritePlayerData:getKey(dataKey, dataVal)
	for key1, val1 in pairs(self.data) do
		for key2, val2 in pairs(val1) do
			if (key2 == dataKey) and (val2 == dataVal) then
				return tonumber(key1);
			end
		end
	end
	return 0;
end

function WritePlayerData:upDateData()
	local count = self:getMaxKeys();
	local dataTab = {}
	local i = 0 
	local curCount = 0
	while(true) do
		local data = self.data[tostring(i)]
		if data~= nil then
			curCount = curCount +1
			dataTab[tostring(curCount)] = data
		end
		if curCount >= count then
			break
		end
		i = i +1
	end
	self.data = dataTab
	self.key = self:getMaxKeys();

	if i ~= curCount then
		self:wirte()
	end

end

function WritePlayerData:getMaxKeys()
	local count = 0;
	for key, val in pairs(self.data) do 
		count = count+1;
	end
	return count;
end

function WritePlayerData:getAllData()
	return self.data;
end

function WritePlayerData:getEndData()
	return self.data[tostring(self:getMaxKeys())];
end

function WritePlayerData:getDataByKey(key)
	return self.data[tostring(key)];
end

function WritePlayerData:removeByKey(key)
	if key == 0 then
		return
	end
	local count = self:getMaxKeys()
	local newData = {};
	--self.data[tostring(key)] = nil;

	for i=1,count do
		local data = self.data[tostring(i)] 
		if data ~= nil and key ~= i then
			table.insert(newData, data);
		end
	end
	self:assign(newData);
end

function WritePlayerData:removeByAccount(account)
	if account == nil then
		return
	end
	local key = self:getKey("account",account)
	local count = self:getMaxKeys()
	local newData = {};
	for i=1,count do
		local data = self.data[tostring(i)] 
		if data ~= nil and key ~= i then
			table.insert(newData, data);
		end
	end
	self:assign(newData);
end

--追加
function WritePlayerData:append(appendData)
	if appendData == nil or appendData == {} then
		return;
	end
	self.key = self.key+1;
	self.data[tostring(self.key)] = appendData;
end

function WritePlayerData:wirte()
	cc.FileUtils:getInstance():writeToFile(self.data, self.filePath);
end

function WritePlayerData:upDataAccount(appendData)
	if appendData == nil or appendData == {} then
		return;
	end
	local key = self:getKey("account",appendData.account)
	print("-----key="..key)
	self:removeByKey(key)
	self:append(appendData)
	self:wirte()
end

--覆盖写入
function WritePlayerData:assign(assignDataTab)
	self:clear();
	self.key = 0;
	for key, val in ipairs(assignDataTab) do
		self:append(val);
	end
	self:wirte();
end

function WritePlayerData:clear()
	self.data = {};
	self.key = 0;
	self:wirte();
end

return WritePlayerData;