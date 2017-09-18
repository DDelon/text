--region *
--Date
--此文件由[BabeLua]插件自动生成

local PlayerManager = class("PlayerManager", function()
    return cc.Layer:create();
end)

function PlayerManager.create()
    local manager = PlayerManager.new();
    manager:init();
    return manager;
end

function PlayerManager:init()
	self.playerTab = {}
	self:initListener()

	self.timelineId  = 0
    self.fishArrayId = 0

	--初始化等待标志
	self.waiting = {}
	self.playerInfoLayer = {}
	local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale()
	for i = 1,4 do
		self.waiting[i] = cc.Sprite:create("battle/battleUI/bl_pic_ddjr.png")
    	self.waiting[i]:setPosition(cc.p(FishCD.aimPosTab[i].x*scaleX_,  (FishCD.aimPosTab[i].y)*scaleY_))
    	self.waiting[i]:setScale(scaleMin_*self.waiting[i]:getScale())
    	self:addChild(self.waiting[i],50)
    	self.waiting[i]:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.8,0),cc.DelayTime:create(0.2),cc.FadeTo:create(0.8,255))))
	end
end

--注册监听事件
function PlayerManager:initListener()
	--注册监听事件
	FishGI.eventDispatcher:registerCustomListener("PlayerJoin", self, function(valTab) self:playerJoin(valTab) end);
	FishGI.eventDispatcher:registerCustomListener("PlayerLeave", self, function(valTab) self:playerLeave(valTab) end);
	FishGI.eventDispatcher:registerCustomListener("OtherPlayerShoot", self, function(valTab) self:otherPlayerShoot(valTab) end);
	FishGI.eventDispatcher:registerCustomListener("sendPlayerFire", self, function(valTab) self:sendPlayerFire(valTab) end);    
	FishGI.eventDispatcher:registerCustomListener("GunRateChange", self, function(valTab) self:GunRateChange(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("PlayerUpgrade", self, function(valTab) self:PlayerUpgrade(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("CannonUpgrade", self, function(valTab) self:CannonUpgrade(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("PlayerNewVIP", self, function(valTab) self:PlayerNewVIP(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("OnPlayerBankup", self, function(valTab) self:OnPlayerBankup(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("OnGetPlayerInfo", self, function(valTab) self:OnGetPlayerInfo(valTab) end);


    FishGI.eventDispatcher:registerCustomListener("upDataByPlayerInfo", self, function(valTab) self:upDataByPlayerInfo(valTab) end);

end

--玩家加入
function PlayerManager:playerJoin(valTab)
	local isSelf = valTab.playerInfo.isSelf
	if isSelf then
		self.selfIndex = valTab.playerInfo.playerId;
		FishGMF.setMyPlayerId(valTab.playerInfo.playerId)
	end

	if valTab.playerInfo == nil then
		return
	end

	local player = self:getPlayerByPlayerId(valTab.playerInfo.playerId)
	if player ~= nil then
		return
	end

	local player = require("Game/PlayerManager/Player").create(valTab);
	self:addChild(player);
	self.playerTab[valTab.playerInfo.playerId] =player

	player.playerInfoLayer = FishGI.gameScene.playerInfoLayer[valTab.playerInfo.chairId]

	self.waiting[valTab.playerInfo.chairId]:stopAllActions()
	self.waiting[valTab.playerInfo.chairId]:setVisible(false)

    local playerData = {};
	playerData.addType = "normal"
    playerData.playerId = player.playerInfo.playerId;
    playerData.currentGunRate = player.playerInfo.currentGunRate
    playerData.maxGunRate = player.playerInfo.maxGunRate
    playerData.gold = player.playerInfo.fishIcon
    playerData.gem = player.playerInfo.crystal
	playerData.props = player.playerInfo.props
	local posTab = player:getCannonPos()
	playerData.posX = posTab.x
	playerData.posY = posTab.y
	if table.maxn(playerData.props) == 0 then
		playerData.props = nil
	end
	playerData.seniorProps = player.playerInfo.seniorProps
	if playerData.seniorProps ~= nil and table.maxn(playerData.seniorProps) == 0 then
		playerData.seniorProps = nil
	end
    LuaCppAdapter:getInstance():addPlayer(playerData);

    --绑定金币ui
    local data = {}
    data.playerId = player.playerInfo.playerId;
    data.propId = FishCD.PROP_TAG_01
    LuaCppAdapter:getInstance():bindUI(data,player.cannon.fnt_coins,player.cannon.fnt_curadd);

    --绑定水晶ui
    local data2 = {}
    data2.playerId = player.playerInfo.playerId;
    data2.propId = FishCD.PROP_TAG_02
    LuaCppAdapter:getInstance():bindUI(data2,player.cannon.fnt_diamonds,player.cannon.fnt_curadd);

	--更新VIP
    local valVIP = {}
    valVIP.playerId = player.playerInfo.playerId
    valVIP.vipExp = player.playerInfo.vipExp
    self:PlayerNewVIP(valVIP)

    if isSelf then
		local keyID = tostring(FishGI.curGameRoomID + 910000000)
	    self.roomMinRate = tonumber(FishGI.GameConfig:getConfigData("room", keyID, "cannon_min"));
    	self.roomMaxRate = tonumber(FishGI.GameConfig:getConfigData("room", keyID, "cannon_max"));

    	player:initMyData()
    end 

    if player.playerInfo.fishIcon <=0 then
    	FishGMF.setIsBankup(player.playerInfo.playerId,true)
    end

end

--玩家离开
function PlayerManager:playerLeave(valTab)
	print("--------------------PlayerManager:playerLeave----------------------")
    local playerData ={}
    playerData.funName = "delPlayer"
    playerData.playerId = valTab.player.id
    LuaCppAdapter:getInstance():luaUseCppFun(playerData);

	local dataValue ={};
    dataValue.funName = "delPlayerCannon"
    dataValue.data = valTab.player.id
    LuaCppAdapter:getInstance():luaUseCppFun(dataValue);
	local playerTab = self.playerTab;
	for key, val in pairs(self.playerTab) do
		if val.playerInfo.playerId == valTab.player.id then
			FishGI.gameScene.playerInfoLayer[val.playerInfo.chairId]:setVisible(false)
			self.waiting[val.playerInfo.chairId]:setVisible(true)
			self.waiting[val.playerInfo.chairId]:runAction(cc.RepeatForever:create(cc.Sequence:create(
				cc.FadeTo:create(0.8,0),cc.DelayTime:create(0.2),cc.FadeTo:create(0.8,255))))
			self.playerTab[key] = nil;
			self:removeChild(val);
			break;
		end
	end
end

--触摸
function PlayerManager:onTouchBegan(touch, event)
	local pos = touch:getLocation();
    local playerSelf = self.playerTab[self.selfIndex];
    playerSelf:shoot(pos);
    playerSelf:setRotateByPos(pos);
end

function PlayerManager:onTouchMoved(touch, event)
	local pos = touch:getLocation();
	local playerSelf = self.playerTab[self.selfIndex];
	playerSelf:setRotateByPos(pos);
end

function PlayerManager:onTouchEnded(touch, event)
	local playerSelf = self.playerTab[self.selfIndex];
    if playerSelf ~= nil then
        playerSelf:endShoot();
    end
end

function PlayerManager:onTouchCancelled(touch, event)
	local playerSelf = self.playerTab[self.selfIndex];
    if playerSelf ~= nil then
        playerSelf:endShoot();
    end
end

--通过玩家id获取Cluaplayer的结构体
function PlayerManager:getPlayerData(playerId)
	for key, val in pairs(self.playerTab) do
		if playerId == val.playerInfo.playerId then
			return val.playerInfo;
		end
	end
end

function PlayerManager:getPlayerChairId(playerId)
	for key, val in pairs(self.playerTab) do
		if playerId == val.playerInfo.playerId then
			return val.playerInfo.chairId;
		end
	end
end

function PlayerManager:isAcross(selfChairId, otherChairId)
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

function PlayerManager:getPlayerByChairId(chairId)
	local obj = nil
	for k,val in pairs(self.playerTab) do
		if val.playerInfo.chairId == chairId then
			obj = val
			break
		end
	end
	return obj;
end

function PlayerManager:getPlayerByPlayerId(playerId)
	local obj = nil
	for k,val in pairs(self.playerTab) do
		if val.playerInfo.playerId == playerId then
			obj = val
			break
		end
	end
	return obj;
end

--得到玩家的游戏数据
function PlayerManager:getPlayerData(playerId)
	for key, val in pairs(self.playerTab) do
		if playerId == val.playerInfo.playerId then
			return val.playerInfo;
		end
	end
end

--得到玩家的游戏数据
function PlayerManager:getMyData()
	return self.playerTab[self.selfIndex];
end

--得到我的chairId
function PlayerManager:getMyChairId()
	return self.playerTab[self.selfIndex].playerInfo.chairId
end

--得到玩家炮台坐标
function PlayerManager:getPlayerPos(playerId,chairId)
	for k,val in pairs(self.playerTab) do
		if playerId ~= nil and val.playerInfo.playerId == playerId then
			return val:getCannonPos()
		end
		
		if chairId ~= nil and val.playerInfo.chairId == chairId then
			return val:getCannonPos()
		end
	end
end

--自己发射子弹
function PlayerManager:sendPlayerFire(dataTab)
    --发送消息

	local isViolent = (dataTab.effectId == FishCD.SKILL_TAG_VIOLENT and true or false)
    FishGI.gameScene.net:sendBullet(dataTab.bulletId, dataTab.frameId, dataTab.degree + 90, dataTab.bulletRate,dataTab.timelineId,dataTab.fishArrayId, dataTab.pos.x, dataTab.pos.y, isViolent);
end

--其他人射击
function PlayerManager:otherPlayerShoot(valTab)
	local playerId = valTab.playerId;
	local degree = valTab.angle;
	for key, val in pairs(self.playerTab) do
		if val.playerInfo.playerId == playerId then
			val:setRotateByDeg(degree);
		end
	end
end

--更新VIP
function PlayerManager:PlayerNewVIP(valTab)
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

    FishGI.myData.vipExp = costMoney
    FishGI.myData.vip_level = backData.vip_level
    FishGI.myData.extra_sign = backData.extra_sign
    FishGI.myData.next_All_money = backData.next_All_money
    FishGI.myData.daily_items_reward = backData.daily_items_reward    

    --更新商店
    FishGI.gameScene.uiShopLayer:upDataLayer(backData)
    --更新VIP特权
    FishGI.gameScene.uiVipRight:upDataLayer(backData)
    FishGI.gameScene.uiVipRight:setRewardIsToken(FishGI.IS_GET_VIP_REWARD)
    
    --更新换炮层
    FishGI.gameScene.uiSelectCannon:setCurGunType(vip_level,player.playerInfo.gunType)

end

--玩家破产
function PlayerManager:OnPlayerBankup(valTab)
	local playerId = valTab.playerId
	local isBankup = valTab.isBankup
	for key, val in pairs(self.playerTab) do
		if val.playerInfo.playerId == playerId then
			val.cannon:playBankrupt(isBankup)

			if playerId == self.selfIndex then
				if isBankup then
					FishGI.gameScene.uiAlmInfo.isSendEnd = true
	    			FishGI.gameScene.net:sendAlmInfo()
					FishGI.gameScene.uiAddFishCoin.animation:play("jump", true)
				else
					FishGI.gameScene.uiAlmInfo:endCountTime()	
					FishGI.gameScene.uiAddFishCoin.animation:play("nojump", false)
				end
			end

			if isBankup then
				FishGMF.setIsBankup(playerId,isBankup)
			end
			break
		end
	end
end

--炮倍转换
function PlayerManager:GunRateChange(valTab)
	local playerId = valTab.playerId;
	local newGunRate = valTab.newGunRate;
	if self.selfIndex ~= nil and playerId == self.selfIndex then
		FishGI.AudioControl:playEffect("sound/gunswitch_01.mp3")
	end

	for key, val in pairs(self.playerTab) do
		if val.playerInfo.playerId == playerId then
			val.cannon:setMultiple(newGunRate)
			val.playerInfo.currentGunRate = newGunRate
			FishGMF.changeGunRate(playerId,newGunRate,0)
		end
	end
end

--玩家升级
function PlayerManager:PlayerUpgrade(valTab)
	local playerId = valTab.playerId
	local newGrade = valTab.newGrade
	local dropFishIcon = valTab.dropFishIcon
	local newFishIcon = valTab.newFishIcon
	local dropCrystal = valTab.dropCrystal
	local newCrystal = valTab.newCrystal
	local dropProps = valTab.dropProps
	local dropSeniorProps = valTab.dropSeniorProps

	print("--------PlayerUpgrade--升级-----")
	for key, player in pairs(self.playerTab) do
		if player.playerInfo.playerId == playerId then
			player.playerInfo.grade = newGrade

		    local isShow = nil
		    if self.selfIndex == playerId then
		        isShow = false
		    end
			--更新鱼币
		    FishGMF.upDataByPropId(playerId,1,newFishIcon,isShow)

			--更新水晶
		    FishGMF.upDataByPropId(playerId,2,newCrystal,isShow)

		    --更新增加道具
		    for k,val in pairs(dropProps) do
		        FishGMF.addTrueAndFlyProp(playerId,val.propId,val.propCount,isShow)
		    end

		    --更新增加高级道具
			if dropSeniorProps ~= nil then
				for k,val in pairs(dropSeniorProps) do
					FishGMF.refreshSeniorPropData(playerId,val,8,0)
				end
			else
				valTab.dropSeniorProps = {}
			end

		    if self.selfIndex == playerId then
				FishGI.GameEffect:playerLevelUp(valTab)
			end

		end
	end
end

--炮倍解锁
function PlayerManager:CannonUpgrade(valTab)
	 print("炮倍解锁CannonUpgrade")

	local playerId = valTab.playerId
	local isSuccess = valTab.isSuccess
	local newFishIcon = valTab.newFishIcon
	local newCrystal = valTab.newCrystal
	local costProps = valTab.costPropsd
	local dropSeniorProps = valTab.dropSeniorProps

	if self.selfIndex == playerId then
	    local aimCrystal = FishGI.gameScene.uiGunUpGrade:getAimCrystal()
	    FishGMF.isSurePropData(FishGI.gameScene.playerManager.selfIndex,FishCD.PROP_TAG_02,aimCrystal,true)
	end

	if not isSuccess  then
		print("炮倍解锁失败")
		FishGMF.upDataByPropId(playerId,FishCD.PROP_TAG_02,newCrystal,true)
		return
	end

	local playerSelf = self.playerTab[self.selfIndex]
	if self.selfIndex == playerId then

	    local propData = FishGMF.getPlayerPropData(playerId,1)

		local data = {};
	    data.playerId = playerId
	    data.chairId = FishGI.gameScene.playerManager:getPlayerChairId(valTab.playerId)
	    data.moneyCount = valTab.newFishIcon - propData.realCount
	    --显示得到多少特效
	    data.showType = "gunUpGrade"
	    FishGI.GameEffect:playGunUpGrade(data)
	end

	--更新鱼币水晶
	FishGMF.CannonUpgrade(playerId,valTab.newFishIcon,valTab.newCrystal)

	if self.selfIndex == playerId then
		local playerSelf =  FishGI.gameScene.playerManager:getMyData()

		--根据自己的最高炮倍得到下一个炮倍
	    local nextRate = FishGMF.getNextRateBtType(4)

        --保存lua玩家最高炮倍
        playerSelf.playerInfo.currentGunRate = nextRate
        playerSelf.playerInfo.maxGunRate = nextRate
		playerSelf.cannon:setMultiple(nextRate)

		FishGMF.changeGunRate(nil,nextRate,nextRate)
		
		--发送切换炮倍
		FishGI.gameScene.net:sendNewGunRate(nextRate)

		--隐藏面板
		if nextRate >= 1000 then
			print("----000-curMaxRate="..nextRate)
			FishGI.gameScene:hideGunUpGradePanel()
		end
		
		--更新解炮面板
		valTab.nextRate = nextRate
		FishGI.eventDispatcher:dispatch("GunUpgrade", valTab);

		--大于房间最高炮倍，踢出房间
		if self.roomMaxRate ~= nil and self.roomMaxRate ~= -1 and nextRate >= self.roomMaxRate then
			FishGF.doMyLeaveGame(1)
		end
	end

end

--通过playerId 更新数据
function PlayerManager:OnGetPlayerInfo(valTab)
	print("---------------OnGetPlayerInfo-----------")
	if not valTab.isSuccess then
		print("--OnGetPlayerInfo---faile-----")
		return
	end
	local playerInfo = valTab.playerInfo

	local playerId = playerInfo.playerId
	local player = self:getPlayerByPlayerId(playerId)

	playerInfo.vip_level = FishGI.GameTableData:getVIPByCostMoney(playerInfo.vipExp).vip_level
	playerInfo.grade = FishGI.GameTableData:getLVByExp(playerInfo.gradeExp).level

    local data = {}
    data.nickName = playerInfo.nickName      
    data.vip_level = playerInfo.vip_level
    data.maxGunRate = playerInfo.maxGunRate
    data.playerId = playerId
    data.grade = playerInfo.grade    
	data.gunType = playerInfo.gunType    
    player.playerInfoLayer:setPlayerData(data)
    player.playerInfoLayer:showAct()

end

--通过playerInfo 更新数据
function PlayerManager:upDataByPlayerInfo(valTab)
	print("---------------upDataByPlayerInfo-----------")
	local playerId= valTab.playerId
	local fishIcon = valTab.fishIcon
	local grade = valTab.grade
	local maxGunRate = valTab.maxGunRate
	local crystal = valTab.crystal
	local props = valTab.props
	local currentGunRate = valTab.currentGunRate
	local thunderRate =valTab.thunderRate
	local gunType =valTab.gunType
	local nBombRate =valTab.nBombRate
	local vipExp=valTab.vipExp
	local loginDrawUsed=valTab.loginDrawUsed
	local vipDrawCountUsed=valTab.vipDrawCountUsed
	local signInDays=valTab.signInDays
	local hasSignToday=valTab.hasSignToday
	local leftMonthCardDay =valTab.leftMonthCardDay
	local monthCardRewardToken=valTab.monthCardRewardToken

	--更新鱼币
    FishGMF.upDataByPropId(playerId,1,fishIcon)

	--更新水晶
    FishGMF.upDataByPropId(playerId,2,crystal)

    --更新增加道具
    for k,val in pairs(props) do
        FishGMF.upDataByPropId(playerId,val.propId,val.propCount)
    end

	--更新VIP
	local data = {}
	data.playerId = playerId
	data.vipExp = vipExp
	print("--------------------vipExp="..vipExp)
	FishGI.eventDispatcher:dispatch("PlayerNewVIP", data);

	--更新月卡
	if self.selfIndex == playerId and FishGI.gameScene.uiMonthcard ~= nil then
		FishGI.gameScene.uiMonthcard:setLeftMonthCardDay(leftMonthCardDay ,monthCardRewardToken)
	end

	--更新炮倍
	local player = self:getPlayerByPlayerId(playerId)
	player.cannon:setMultiple(currentGunRate)
	FishGMF.changeGunRate(playerId,currentGunRate,maxGunRate)

end

return PlayerManager;

--endregion
