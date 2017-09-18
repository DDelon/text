--region *
--Date
--此文件由[BabeLua]插件自动生成

local FriendPlayerManager = class("FriendPlayerManager", function()
    return cc.Layer:create();
end)

function FriendPlayerManager.create()
    local manager = FriendPlayerManager.new();
    manager:init();
    return manager;
end

function FriendPlayerManager:init()
	self.playerTab = {}
	self.playerViewTab = {}
	self:initListener()

	self.timelineId  = 0
    self.fishArrayId = 0
end

--注册监听事件
function FriendPlayerManager:initListener()
	--注册监听事件
	FishGI.eventDispatcher:registerCustomListener("PlayerJoin", self, function(valTab) self:playerJoin(valTab) end);
	FishGI.eventDispatcher:registerCustomListener("PlayerLeave", self, function(valTab) self:playerLeave(valTab) end);
	FishGI.eventDispatcher:registerCustomListener("OtherPlayerShoot", self, function(valTab) self:otherPlayerShoot(valTab) end);
	FishGI.eventDispatcher:registerCustomListener("sendPlayerFire", self, function(valTab) self:sendPlayerFire(valTab) end);  
	FishGI.eventDispatcher:registerCustomListener("GunRateChange", self, function(valTab) self:GunRateChange(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("PlayerNewVIP", self, function(valTab) self:PlayerNewVIP(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("OnGetPlayerInfo", self, function(valTab) self:OnGetPlayerInfo(valTab) end);

end

--玩家初始化
function FriendPlayerManager:initPlayers(nodeParent)
	for i=1, 4, 1 do 
		self.playerViewTab[i] = require("Game/FriendPlayerManager/FriendPlayer").create()
		nodeParent:addChild(self.playerViewTab[i],FishCD.ORDER_GAME_player)
		self.playerViewTab[i]:initPos(i)
		self.playerViewTab[i]:setScale(self.playerViewTab[i].scaleMin_)
		self.playerViewTab[i].playerInfoLayer = FishGI.gameScene.uiMainLayer.uiPlayerInfoLayer:getPlayerInfoByChairId(i)
		self.playerViewTab[i]:isShowPlayer(false)
	end 
end

--得到房主
function FriendPlayerManager:getCreatorPlayerId()
	return self.creatorPlayerId
end 

--刚进入游戏是所有玩家
function FriendPlayerManager:onAllPalyerInfo(valTab)
	local playerData = valTab.roomInfo.playerInfos
	self.creatorPlayerId = valTab.roomInfo.creatorPlayerId

	--设置自己的playerId 和确定是否翻转
	FishGI.isPlayerFlip = false
	for k,val in pairs(playerData) do
		if val.playerId == FishGI.myData.playerId then
			--我自己
			self.selfIndex = val.playerId
			FishGMF.setMyPlayerId(val.playerId)
			playerData[k].isSelf = true
			if val.chairId == 2 or val.chairId == 3 then
				FishGI.isPlayerFlip = true 
			end
			break
		end
	end

	--玩家加入
	for k,val in pairs(playerData) do
		self:playerJoin(val)
	end

end

--c++的chairId的转换
function FriendPlayerManager:ChangeChairIdByCToLua(C_chairId)
		local chairId = C_chairId
		local newChairId = 0
		-- chairId 的翻转
		if FishGI.isPlayerFlip then
			newChairId = math.mod((chairId+2),4) + 1
		else
			newChairId = chairId + 1
		end
		return newChairId
end

--玩家加入
function FriendPlayerManager:playerJoin(valTab)
	--c++的chairId的转换
	local chairId = valTab.chairId
	local newChairId = self:ChangeChairIdByCToLua(chairId)
	valTab.chairId = newChairId

	local player = self:getPlayerByPlayerId(valTab.playerId)
	if player ~= nil and valTab ~= nil then
		player:initWithData(valTab)
		return
	end

	--c++的chairId的转换
	-- local chairId = valTab.chairId
	-- local newChairId = self:ChangeChairIdByCToLua(chairId)
	-- valTab.chairId = newChairId

	if valTab.isLeave and FishGI.SERVER_STATE == 0 then
		return 
	end

	local player = self.playerViewTab[newChairId]
	player:init(valTab)
	player:isShowPlayer(true)
	self.playerTab[valTab.playerId] = player

	FishGI.gameScene.uiMainLayer.uiPlayerInfoLayer:addPlayer(newChairId)

	--绑定c++的玩家
    local playerData = {};
	playerData.addType = "friend"
    playerData.playerId = valTab.playerId;
    playerData.currentGunRate = valTab.currentGunRate
	playerData.maxGunRate = valTab.maxGunRate
	playerData.score = valTab.score
	playerData.bulletUsed = valTab.bulletUsed
	playerData.crystal = valTab.crystal
	playerData.gradeExp = valTab.gradeExp
	playerData.friendProps = valTab.friendProps
	for k,val in pairs(playerData.friendProps) do
		playerData.friendProps[k].propId = val.propId + FishCD.FRIEND_INDEX
	end
	if playerData.friendProps == {} then 
		playerData.friendProps = nil
	end 
	local posTab = player:getCannonPos()
	playerData.posX = posTab.x
	playerData.posY = posTab.y
    LuaCppAdapter:getInstance():addPlayer(playerData);

    --绑定积分
    local data2 = {}
    data2.playerId = valTab.playerId;
    data2.propId = FishCD.PROP_TAG_SCORE
    LuaCppAdapter:getInstance():bindUI(data2,player.fnt_integral,player.fnt_curadd);

    --绑定子弹个数
    local data = {}
    data.playerId = valTab.playerId;
    data.propId = FishCD.PROP_TAG_BULLET
    LuaCppAdapter:getInstance():bindUI(data,player.fnt_bullet,player.fnt_bullet);

    if valTab.isSelf ~= nil and valTab.isSelf == true then
		--绑定水晶ui
		local data2 = {}
		data2.playerId = valTab.playerId
		data2.propId = FishCD.PROP_TAG_02
		LuaCppAdapter:getInstance():bindUI(data2,player.fnt_diamonds,player.fnt_curadd);


		local keyID = tostring(FishGI.curGameRoomID + 910000000)
	    self.roomMinRate = tonumber(FishGI.GameConfig:getConfigData("room", keyID, "cannon_min"));
    	self.roomMaxRate = tonumber(FishGI.GameConfig:getConfigData("room", keyID, "cannon_max"));

    	player:initMyData()
    end 

	--更新VIP
    local valVIP = {}
    valVIP.playerId = valTab.playerId
    valVIP.vipExp = valTab.vipExp
    self:PlayerNewVIP(valVIP)

end

--玩家离开
function FriendPlayerManager:playerLeave(valTab)
	print("--------------------FriendPlayerManager:playerLeave----------------------")
	local leaveType = valTab.leaveType
	local playerId = valTab.playerId
	FishGI.gameScene.uiMainLayer.uiPlayerInfoLayer:removePlayer(self:getPlayerChairId(playerId))
	if playerId == self.selfIndex then 
		FishGF.doMyLeaveGame(leaveType)
	else
		if self.playerTab[playerId] == nil then
			return
		end
		if FishGI.SERVER_STATE == 0 then
			self.playerTab[playerId]:isShowPlayer(false)
			self.playerTab[playerId] = nil
			
			local dataValue ={};
			dataValue.funName = "delPlayerCannon"
			dataValue.data = playerId
			LuaCppAdapter:getInstance():luaUseCppFun(dataValue);
		else
			--分数清零
			FishGMF.upDataByPropId(playerId,FishCD.PROP_TAG_SCORE,0)
			self.playerTab[playerId]:setPlayerGameStatus(4)
		end
	end 

    FishGI.eventDispatcher:dispatch("MaigcPropPlayerLeave", valTab);

	local playerIdTab = {}
	playerIdTab.id = playerId
    FishGI.eventDispatcher:dispatch("RemovePlayerBullet", playerIdTab);    

end

--开始游戏更新玩家状态
function FriendPlayerManager:updataAllPlayerStatus()
	for k,val in pairs(self.playerTab) do
		if val:getPlayerGameStatus() == 1 then
			val:setPlayerGameStatus(3)
		end
		val.playerInfoLayer:openKickOut(false)
	end
end 

--触摸
function FriendPlayerManager:onTouchBegan(touch, event)
	local pos = touch:getLocation();
    local playerSelf = self.playerTab[self.selfIndex];
    playerSelf:shoot(pos);
    playerSelf:setRotateByPos(pos);
end

function FriendPlayerManager:onTouchMoved(touch, event)
	local pos = touch:getLocation();
	local playerSelf = self.playerTab[self.selfIndex];
	playerSelf:setRotateByPos(pos);
end

function FriendPlayerManager:onTouchEnded(touch, event)
	local playerSelf = self.playerTab[self.selfIndex];
    if playerSelf ~= nil then
        playerSelf:endShoot();
    end
end

function FriendPlayerManager:onTouchCancelled(touch, event)
	local playerSelf = self.playerTab[self.selfIndex];
    if playerSelf ~= nil then
        playerSelf:endShoot();
    end
end

function FriendPlayerManager:isAcross(selfChairId, otherChairId)
	if selfChairId > 2 then
		if otherChairId <= 2 then
			return true
		end
	else
		if otherChairId > 2 then
			return true
		end
	end
	return false;
end

function FriendPlayerManager:getPlayerChairId(playerId)
	for key, val in pairs(self.playerTab) do
		if playerId == val.playerInfo.playerId then
			return val.playerInfo.chairId;
		end
	end
end

function FriendPlayerManager:getPlayerByChairId(chairId)
	local obj = nil
	for k,val in pairs(self.playerTab) do
		if val.playerInfo.chairId == chairId then
			obj = val
			break
		end
	end
	return obj;
end

function FriendPlayerManager:getPlayerByPlayerId(playerId)
	local obj = nil
	for k,val in pairs(self.playerTab) do
		if val.playerInfo.playerId == playerId then
			obj = val
			break
		end
	end

	if obj  == nil then
		obj = self.playerTab[playerId]
	end
	return obj;
end

--得到玩家的游戏数据
function FriendPlayerManager:getMyData()
	return self.playerTab[self.selfIndex];
end

--得到我的chairId
function FriendPlayerManager:getMyChairId()
	return self.playerTab[self.selfIndex].playerInfo.chairId
end

--自己发射子弹
function FriendPlayerManager:sendPlayerFire(dataTab)
    --发送消息
    FishGI.gameScene.net:sendBullet(dataTab.bulletId, dataTab.frameId, dataTab.degree + 90, dataTab.bulletRate,dataTab.timelineId,dataTab.fishArrayId, dataTab.pos.x, dataTab.pos.y);
end

--其他人射击
function FriendPlayerManager:otherPlayerShoot(valTab)
	local playerId = valTab.playerId;
	local degree = valTab.angle;
	for key, val in pairs(self.playerTab) do
		if val.playerInfo.playerId == playerId then
			val:setRotateByDeg(degree);
		end
	end
end

--更新VIP
function FriendPlayerManager:PlayerNewVIP(valTab)
	local playerId = valTab.playerId;
	local vipExp = valTab.vipExp;
	local backData = FishGI.GameTableData:getVIPByCostMoney(vipExp)
	--local backData = FishGMF.getAndSetPlayerData(playerId,true,"vipExp",vipExp)
	if backData == nil then
		print("----PlayerNewVIP----backData == nil------")
		return
	end
	backData.vipExp = vipExp  
    local vip_level = backData["vip_level"]
    local player = self:getPlayerByPlayerId(playerId)
	if player == nil then
		FishGF.print("----PlayerNewVIP----player == nil------"..playerId)
		return
	end

    player.playerInfo.vipExp = vipExp
    player.playerInfo.vip_level = backData.vip_level
    player.playerInfo.extra_sign = backData.extra_sign
    player.playerInfo.next_All_money = backData.next_All_money
    player.playerInfo.daily_items_reward = backData.daily_items_reward

    if self.selfIndex == nil or self.selfIndex ~= playerId then
    	return
    end

    FishGI.myData.vipExp = vipExp
    FishGI.myData.vip_level = backData.vip_level
    FishGI.myData.extra_sign = backData.extra_sign
    FishGI.myData.next_All_money = backData.next_All_money
    FishGI.myData.daily_items_reward = backData.daily_items_reward

    --更新商店
    FishGI.gameScene.uiMainLayer.uiShopLayer:upDataLayer(backData)
    --更新VIP特权
    FishGI.gameScene.uiMainLayer.uiVipRight:upDataLayer(backData)
    FishGI.gameScene.uiMainLayer.uiVipRight:setRewardIsToken(FishGI.IS_GET_VIP_REWARD)
    
    --更新换炮层
    FishGI.gameScene.uiMainLayer.uiSelectCannon:setCurGunType(vip_level,player.playerInfo.gunType)

end

--设置玩家状态  0正常    1准备    2断线
function FriendPlayerManager:setPlayerGameStatus(valTab)
	local playerId = valTab.playerId
	local status = valTab.status
	for key, val in pairs(self.playerTab) do
		if val.playerInfo.playerId == playerId then
			val:setPlayerGameStatus(status)
			break
		end
	end
end

--炮倍转换
function FriendPlayerManager:GunRateChange(valTab)
	local playerId = valTab.playerId;
	local newGunRate = valTab.gunRate;
	if self.selfIndex ~= nil and playerId == self.selfIndex then
		FishGI.AudioControl:playEffect("sound/gunswitch_01.mp3")
	end

	for key, val in pairs(self.playerTab) do
		if val.playerInfo.playerId == playerId then
			val.cannon:setMultiple(newGunRate)
			val.currentGunRate = newGunRate
			val:startGunPromoteAni()
			FishGMF.changeGunRate(playerId,newGunRate,0)
			if playerId == self.selfIndex then
				FishGI.AudioControl:playEffect("sound/gunswitch_01.mp3")
			end
		end
	end
end

--通过playerId 更新数据 玩家小信息框
function FriendPlayerManager:OnGetPlayerInfo(valTab)
	if not valTab.success then
		print("--OnGetPlayerInfo---faile-----")
		return
	end

	self:upDataByPlayerInfo(valTab.playerInfo)

end

--通过playerInfo 更新数据
function FriendPlayerManager:upDataByPlayerInfo(valTab)
	local playerId= valTab.playerId
	local player = self:getPlayerByPlayerId(playerId)
	if player == nil then
		FishGF.print("--------------upDatByPlayerInfo-------player == nil-----------")
		return
	end

	local oldChairId = valTab.chairId
	local newChairId = self:ChangeChairIdByCToLua(oldChairId)
	valTab.chairId = newChairId

	if self.selfIndex ~= nil and valTab.playerId == self.selfIndex then
		valTab.isSelf = true
	else
		valTab.isSelf = false
	end

	-- local chairId = valTab.chairId
	-- local nickName = valTab.nickName
	-- local ready = valTab.ready
	-- local score = valTab.score
	-- local bulletUsed = valTab.bulletUsed
	-- local effects = valTab.effects
	-- local isDisonnected = valTab.isDisonnected
	-- local friendProps = valTab.friendProps
	-- local currentGunRate =valTab.currentGunRate
	-- local gunType = valTab.gunType
	-- local vipExp = valTab.vipExp
	-- local crystal = valTab.crystal
	-- local leftMonthCardDay = valTab.vipleftMonthCardDayExp
	-- local monthCardRewardToken = valTab.monthCardRewardToken

	--更新已使用子弹
	FishGMF.upDataByPropId(playerId,FishCD.PROP_TAG_USED_BULLET,valTab.bulletUsed)

	--更新分数
	FishGMF.upDataByPropId(playerId,FishCD.PROP_TAG_SCORE,valTab.score)

	--更新水晶
    FishGMF.upDataByPropId(playerId,2,valTab.crystal)

	--更新道具
	for k,v in pairs(valTab.friendProps) do
		local propId = v.propId + FishCD.FRIEND_INDEX
		local propCount = v.propCount
		FishGMF.upDataByPropId(playerId,propId,propCount,true)
	end

	--更新VIP
	local data = {}
	data.playerId = playerId
	data.vipExp = valTab.vipExp
	FishGI.eventDispatcher:dispatch("PlayerNewVIP", data);

	--更新月卡
	if self.selfIndex == playerId and FishGI.gameScene.uiMainLayer.uiMonthcard ~= nil then
		FishGI.gameScene.uiMainLayer.uiMonthcard:setLeftMonthCardDay(valTab.leftMonthCardDay ,valTab.monthCardRewardToken)
	end

	--玩家更新
	player:initWithData(valTab)

	--小的个人信息框数据更新
    local data = {}
    data.nickName = valTab.nickName
    data.vip_level = valTab.vip_level
    data.maxGunRate = valTab.maxGunRate
    data.playerId = playerId
    data.grade = player.playerInfo.grade
	data.chairId = player.playerInfo.chairId
	data.gunType = player.playerInfo.gunType  
    player.playerInfoLayer:setPlayerData(data)

end

--断线重连
function FriendPlayerManager:OnPlayerReconnect(data)
	--更新数据
	self:upDataByPlayerInfo(data.playerInfo)
end 

--得到玩家炮台坐标
function FriendPlayerManager:getPlayerPos(playerId,chairId)
	for k,val in pairs(self.playerTab) do
		if playerId ~= nil and val.playerInfo.playerId == playerId then
			return val:getCannonPos()
		end
		
		if chairId ~= nil and val.playerInfo.chairId == chairId then
			return val:getCannonPos()
		end
	end
end

return FriendPlayerManager;

--endregion
