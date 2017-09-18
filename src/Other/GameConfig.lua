local GameConfig = class("GameConfig")

function GameConfig.create()
	local config = GameConfig.new();
	config:init();
	return config;
end

function GameConfig:init()
	--self.fishArrConfig = require("luaconfig/fisharray");
    --self.fishConfig = require("luaconfig/fish");
    --self.fishPathConfig = require("luaconfig/fishpathEx");
    --self.timeLineConfig = require("luaconfig/timeline");
    --self.fishChildrenConfig = require("luaconfig/fishchildren");
    --self.fishGroupConfig = require("luaconfig/fishgroup");

    --self:initFishPath();

end

function GameConfig:initFishPath()
    for key, val in pairs(self.fishPathConfig) do
        local pointStr = val["pointdata"];
        
        val["pointdata"] = FishGF.strToVec3(pointStr);
    end
    
end

function GameConfig:getFishData(fishID)
    local data = LuaCallCpp:getInstance():getFishDataByID(tostring(fishID));
    if next(data) == nil then
        return nil;
    end
    return data;
end

function GameConfig:getFishArrData(arrID, count)
    local fishArrID = 310000000 + arrID*1000 + count;
    --local data = self.fishArrConfig[tostring(fishArrID)];
    local data = LuaCallCpp:getInstance():getFishArrDataByID(tostring(fishArrID));
    if next(data) == nil then
        return nil;
    end
    return data;
end

function GameConfig:getTimeLineData(roomID, isServer, timeLineIndex, count)
    local timeLineID = 320000000 + 100000*roomID + (isServer and 9 or 0)*10000 + timeLineIndex*1000 + count;
    --local data = self.timeLineConfig[tostring(timeLineID)];
    local data = LuaCallCpp:getInstance():getTimeLineDataByID(tostring(timeLineID));
    if next(data) == nil then
        return nil;
    end
    return data;
end

function GameConfig:getFishGroupData(groupID, count)
    local fishGroupID = 330000000 + groupID*100000 + count;
    --local data = self.fishGroupConfig[tostring(fishGroupID)];
    local data = LuaCallCpp:getInstance():getFishGroupDataByID(tostring(fishGroupID));
    if next(data) == nil then
        return nil;
    end
    return data;
end

function GameConfig:getPathWithID(pathID)
    pathID = 300000000+pathID;
    --local data = self.fishPathConfig[tostring(pathID)];
    local data = LuaCallCpp:getInstance():getPathByID(tostring(pathID));
    if next(data) == nil then
        return nil;
    end
    --data["pointdata"] = FishGF.strToVec3(data["pointdata"]);
    return data;
end

function GameConfig:getFishChildrenData(fishID)
    local fishChildrenID = fishID+90000000;
    --local data = self.fishChildrenConfig[tostring(fishChildrenID)];
    local data = LuaCallCpp:getInstance():getFishChildrenDataByID(tostring(fishChildrenID));
    if next(data) == nil then
        return nil;
    end
    return data;
end

function GameConfig:getLanguageFromBin(configName, keyID)
    return self:getConfigData(configName, keyID, FishCD.LanguageType);
end

function GameConfig:getConfigDataByName(ID)
    local ConfigID = ID+990000000
    local data = LuaCppAdapter:getInstance():getConfigDataByName(tostring(ConfigID));
    if next(data) == nil then
        return nil;
    end
    return data;
end

function GameConfig:getConfigData(configName,keyID,keyName)
    local data = LuaCppAdapter:getInstance():getConfigData(tostring(configName),tostring(keyID),tostring(keyName))
    return data;
end

return GameConfig;