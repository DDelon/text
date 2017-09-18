local BaseClient = require("Other/BaseClient");
local WebTool = require("Other/WebTool");

local GameNet = class("GameNet", BaseClient)
local proto = FishGI.gameNetMesProto
function GameNet:ctor()
	self.msg = FishNM;
	BaseClient.ctor(self);
    FishGI.eventDispatcher:removeAllListener();
	--注册网络事件
    --self:sendClientReadyMessage();
    self:RegisterMsgProcess(FishNM.HEAD.MSG_S2C_JMSG, self.OnJMsg, "OnJMsg");

    self.needRefrshGold = false;
end

function GameNet:OnCreateScene()
    local scene = require("Game/GameScene").create(self);
    FishGI.gameScene = scene;
    self:sendClientReadyMessage();
    return FishGI.gameScene;
end

function GameNet:OnInitialize()
  return true;
end

function GameNet:openNetSchedule()
    local count = FishCD.HEART_DELAYTIME;
    local function updateInline()
        if self.isSend then
            if self.isRecv then
                count = FishCD.HEART_DELAYTIME;
                self.isRecv = false;
            else
                count = count-1;
                if count <= 0 then
                    self.isSend = false;
                    self.isRecv = false;
                    FishGF.print("cannot recv heart data close net");
                    count = FishCD.HEART_DELAYTIME;
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.netScheduleId);
                    self:disconnectTips();
                end
            end
        end
    end
    self.netScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateInline, 1.0, false);
end

function GameNet:openUpdateInline()
    local function updateInline()
        FishGMF.updateInline()
    end
    self.onRefreshDataId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateInline, 1/20, false);
end

function GameNet:closeSchedule()
    if self.netScheduleId ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.netScheduleId);
        self.netScheduleId = nil
    end
    if self.onRefreshDataId ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.onRefreshDataId);
        self.onRefreshDataId = nil
    end
end


function GameNet:disconnectTips()
    local msg = FishGI.GameConfig:getLanguageFromBin("language", "800000036");
    FishGF.createCloseSocketNotice(msg,"GameNetdisconnectTips")
end

------------------------------------------------------------------------------------------------
-------------------------------------------从服务器接收消息-------------------------------------
------------------------------------------------------------------------------------------------
function GameNet:OnJMsg(msg)
    
    local ptr = msg:ReadData(0)
    local data, typeName = jmsg.decodeBinary(proto, ptr)

    if self.isWaitLoaded == nil and  typeName ~= "MSGS2CGameStatus" then
        return
    end
    self.isWaitLoaded = false

    --log("typeName= " .. typeName)
    self.isRecv = true;
    self.isSend = false;
    if typeName == "MSGS2CGameStatus" then
        self:OnGameStatus(data)
    elseif typeName == "MSGS2CPlayerShoot" then
        self:OnPlayerShoot(data)
    elseif typeName == "MSGS2CHeartBeat" then
        self:OnServerHeartBeat(data)
    elseif typeName == "MSGS2CPlayerHit" then
        self:OnHit(data)
    elseif typeName == "MSGS2CGunRateChange" then
        self:OnGunRateChange(data)
    elseif typeName == "MSGS2CBulletTargetChange" then
        self:OnBulletTargetChange(data)
    elseif typeName == "MSGS2CFreezeResult" then
        self:OnFreezeResult(data)
    elseif typeName == "MSGS2CFreezeStart" then
        self:OnOtherFreezeStart(data)
    elseif typeName == "MSGS2CFreezeEnd" then
        self:OnFreezeEnd(data)
    elseif typeName == "MSGS2CAimResult" then
        self:OnMyAimResult(data)
    elseif typeName == "MSGS2CAim" then
        self:OnOtherAim(data)
    elseif typeName == "MSGS2CPlayerJion" then
        self:OnPlayerJionGame(data)
    elseif typeName == "MSGS2CUpgrade" then
        self:OnPlayerUpgrade(data)
    elseif typeName == "MSGS2CUpgradeCannonResult" then
        self:OnCannonUpgrade(data)
    elseif typeName == "MSGS2CSetProp" then
        self:onServerAddMoney(data)
    elseif typeName == "MSGS2CStartFishGroup" then
        self:OnStartFishGroup(data)
    elseif typeName == "MSGS2CStartTimeline" then
        self:OnStartTimeline(data)
    elseif typeName == "MSGC2SBankup" then
        self:OnPlayerBankup(data)
    elseif typeName == "MSGS2CAlmInfo" then
        self:OnAlmInfo(data)
    elseif typeName == "MSGS2CApplyAlmResult" then
        self:OnApplyAlmResult(data)
    elseif typeName == "MSGS2CFishGroupNotify" then
        self:OnFishGroupNotify(data)
    elseif typeName == "MSGS2CDrawStatusChange" then
        self:OnDrawStatusChange(data)
    elseif typeName == "MSGS2CDrawResult" then
        self:OnDrawResult(data)
    elseif typeName == "MSGS2CGameAnnouncement" then
        self:OnGameAnnouncement(data)
    elseif typeName == "MSGS2CCallFish" then
        self:OnCallFish(data)
    elseif typeName == "MSGS2CGunTpyeChange" then
        self:OnGunTpyeChange(data)
    elseif typeName == "MSGS2CNBomb" then
        self:OnNBombUseResult(data)
    elseif typeName == "MSGS2CNBombBlast" then
        self:OnNBombHit(data)
    elseif typeName == "MSGPlayerInfo" then
        self:OnPlayerInfo(data)
    elseif typeName == "MSGS2CGetPlayerInfo" then
        self:OnGetPlayerInfo(data)
    elseif typeName == "MSGS2CEmoticon" then
        self:onEmotionIcon(data)
    elseif typeName == "MSGS2CMagicprop" then
        self:onMagicprop(data)
    elseif typeName == "MSGS2CGetVipDailyReward" then
        FishGI.eventDispatcher:dispatch("GetVipDailyReward", data);
    elseif typeName == "MSGS2CUseTimeHourglass" then
        self:onStartTimeHourGlass(data)
    elseif typeName == "MSGS2CStopTimeHourglass" then
        self:onStopTimeHourGlass(data)
    elseif typeName == "MSGS2CGetTimeHourglass" then
        self:onTryGetTimeHourGlass(data)
    elseif typeName == "MSGS2CContinueTimeHourglass" then
        self:onContinueTimeHourGlass(data)
    elseif typeName == "MSGS2CGetNewTaskInfo" then
        self:onGetNewTaskInfo(data)
    elseif typeName == "MSGS2CGetNewTaskReward" then
        self:onGetNewTaskReward(data)
    elseif typeName == "MSGS2CUsePropCannon" then
        self:onUsePropCannon(data)
    elseif typeName == "MSGS2CViolent" then
        self:OnUseViolentResult(data)
    elseif typeName == "MSGS2CViolentTimeOut" then
        self:OnViolentTimeOut(data)
    end

    return true;
end

--[[
* @brief 玩家进入桌子，
* @param player 进入的玩家对象
* @param isSelf 是否是自己
--]]
function GameNet:OnPlayerJoin(player, isSelf)
    
    local function exchange(tab, index1, index2)
        local temp = tab[index1];
        tab[index1] = tab[index2];
        tab[index2] = temp;
        return tab;
    end
    if isSelf then
        FishGI.deskId = player.deskid;
        print("------FishGI.deskId="..FishGI.deskId)
    end
    local temp1 = FishGI;
    local temp2 = player.deskid;
    print("GameNet OnPlayerJoin---player.id="..player.id);
    print(isSelf);

    local chairId = player.chairid+1;
    local playerTab = {};
    playerTab.player = {};
    playerTab.player.chairId = chairId;
    playerTab.player.id = player.id;
    playerTab.isSelf = isSelf;

    if FishGI.isPlayerFlip then
        if chairId == 1 then
            playerTab.player.chairId = 3;
        elseif chairId == 2 then
            playerTab.player.chairId = 4;
        elseif chairId == 3 then
            playerTab.player.chairId = 1;
        elseif chairId == 4 then
            playerTab.player.chairId = 2;
        end
        self.mPlayer[playerTab.player.chairId] = playerTab;
    else
        if isSelf then
        --是玩家
            if chairId == 3 then
                --换位置
                playerTab.player.chairId = 1;
                self.mPlayer[playerTab.player.chairId] = playerTab;
                FishGI.isPlayerFlip = true;
            elseif chairId == 4 then
                playerTab.player.chairId = 2;
                self.mPlayer[playerTab.player.chairId] = playerTab;
                FishGI.isPlayerFlip = true;
            else
                self.mPlayer[chairId] = playerTab;
            end
        else

            self.mPlayer[chairId] = playerTab;
        end
    end 
    local tempTab = self.mPlayer;
    --FishGI.eventDispatcher:dispatch("PlayerJoin", playerTab);
end

--玩家加入游戏场景
function GameNet:OnPlayerJionGame(data)
    print("GameNet OnPlayerJionGame");
    for key, val in pairs(self.mPlayer) do
        print("GameNet OnPlayerJionGame---data.playerId = "..data.playerInfo.playerId.."---val.player.id="..val.player.id);
        if data.playerInfo.playerId == val.player.id then
            val.playerInfo = data.playerInfo
            val.playerInfo.chairId = val.player.chairId
            val.playerInfo.isSelf = val.isSelf
            FishGI.eventDispatcher:dispatch("PlayerJoin", val);
            break
        end
    end
end

--[[
* @brief 玩家离开桌子
* @param player 玩家对象
--]]
function GameNet:OnPlayerLeave(player)
    print(player);
    local chairId = player.chairid;
    print("玩家离开_____________________"..chairId);   
     
    if FishGI.isPlayerFlip then
    end
    local playerTab = self.mPlayer;
    if FishGI.isPlayerFlip then
        if chairId+1 == 1 then
            self.mPlayer[3] = nil;
        elseif chairId+1 == 2 then
            self.mPlayer[4] = nil;
        elseif chairId+1 == 3 then
            self.mPlayer[1] = nil;
        elseif chairId+1 == 4 then
            self.mPlayer[2] = nil;
        end
    else
        self.mPlayer[chairId+1] = nil;
    end
    local valTab = {};
    valTab.player = {};
    valTab.player.id = player.id;
    valTab.player.chairId = chairId+1;
    local playerIdTab = {};
    playerIdTab.id = player.id;
    FishGI.eventDispatcher:dispatch("PlayerLeave", valTab);
    FishGI.eventDispatcher:dispatch("MaigcPropPlayerLeave", valTab);
    FishGI.eventDispatcher:dispatch("RemovePlayerBullet", playerIdTab);

end

function GameNet:OnGameStatus(data)
    FishGI.SERVER_STATE = 1
    self:openNetSchedule();
    self:openUpdateInline();
    for i = 1, #data.bullets do
        local bullet = data.bullets[i]
    end
    
    --房间号
    data.roomId = FishGI.serverConfig["RoomId"]..","..FishGI.deskId;

    --玩家加入游戏
    for k,val in pairs(data.playerInfos) do
        val.effectId = 0;
        if data.inViolent ~= nil then
            for key, playerId in pairs(data.inViolent) do
                if val.playerId == playerId then
                    val.effectId = FishCD.SKILL_TAG_VIOLENT;
                end
            end
        end

        local dataPlayer = {}
        dataPlayer.playerInfo = val
        self:OnPlayerJionGame(dataPlayer)
    end
    data.playerTab = self.mPlayer;

    local thunderRate = 0;
    local nbombRate = 0;
    for key2,val2 in pairs(data.playerInfos) do
        if thunderRate == 0 then
            thunderRate = val2.thunderRate;
        end
        if nbombRate == 0 then
            nbombRate = val2.nBombRate;
        end
    end

    --计算子弹发射点的位置
    for key, val in pairs(data.bullets) do
        val.pos = cc.p(val.pointX, val.pointY);
    end
    
    print("收到游戏状态,帧号:"..data.frameId..
          ",是否是鱼群："..tostring(data.isInGroup)..
          ",时间线索引:"..data.timelineIndex..
          ",子弹个数:"..#data.bullets..
          ",死去鱼的个数"..#data.killedFishes)
        --进入游戏场景
    --FishGI.eventDispatcher:dispatch("CreateGameScene", data);
    FishGI.gameScene:startGame(data);

    FishGI.eventDispatcher:dispatch("UpdateThunderRate", thunderRate);
    FishGI.eventDispatcher:dispatch("UpdateNBombRate", nbombRate);
    FishGI.eventDispatcher:dispatch("UpdateBufferLogo", data.inTimeHourGlass);
end

function GameNet:OnServerHeartBeat(data)
--     print("收到心跳回复,服务端帧号:"..data.frameCount)
    FishGI.eventDispatcher:dispatch("SyncFrame", data)      
end

--玩家射击消息
function GameNet:OnPlayerShoot(data)
    if FishGI.SERVER_STATE == 0 then
        --还没有OnGameStatus
        return;
    end

    --自己确认发射成功，真的减钱
    if data.playerId == FishGI.gameScene.playerManager.selfIndex then
        local dataTab = {};
        dataTab.upDataType = "onPlayerShoot"
        dataTab.createType = "normal"
        dataTab.playerId = data.playerId;
        dataTab.bulletRate = data.gunRate
        dataTab.effectId = (data.isViolent and FishCD.SKILL_TAG_VIOLENT or 0)
        dataTab.cost = (data.isViolent and dataTab.bulletRate*2 or dataTab.bulletRate)
        dataTab.fireType = 2
        FishGMF.pushRefreshData(dataTab)
        return;
    end   
  
    data.angle = FishGF.getCustomAngle(data.angle)
    -- --添加子弹翻转
    -- local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale()
    -- if FishGI.isPlayerFlip then
    --     local winSize = cc.Director:getInstance():getWinSize();
    --     local cfg_ds= CC_DESIGN_RESOLUTION
    --     data.pointX = cfg_ds.width-data.pointX;
    --     data.pointY = cfg_ds.height-data.pointY;
    -- end
    -- --计算子弹发射点的位置
    -- for key, val in pairs(self.mPlayer) do
    --     if data.playerId == val.player.id then
    --         data.pos = {}
    --         data.pos.x= data.pointX*scaleX_
    --         data.pos.y= data.pointY*scaleY_
    --     end
    -- end
    data.frameId = 0;

    --其他玩家炮塔转动
    FishGI.eventDispatcher:dispatch("OtherPlayerShoot", data);

    local dataTab = {};
    dataTab.upDataType = "onPlayerShoot"
    --dataTab.pos = cc.p(data.pos.x, data.pos.y);
    dataTab.degree = data.angle - 90
    local chairId = FishGI.gameScene.playerManager:getPlayerChairId(data.playerId)
    if chairId == nil then
        print("*********************OnPlayerShoot chairId nil!!");
        return
    end
    if chairId >=3 then
        dataTab.degree = dataTab.degree +180
    end
    local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(data.playerId)
    dataTab.pos = player.cannon:getLauncherPos()

    dataTab.playerId = data.playerId;
    dataTab.lifeTime = 0
    dataTab.bulletId = data.bulletId
    dataTab.timelineId = data.timelineId
    dataTab.fishArrayId = data.fishArrayId
    dataTab.bulletRate = data.gunRate
    dataTab.effectId = (data.isViolent and FishCD.SKILL_TAG_VIOLENT or 0)
    dataTab.cost = (data.isViolent and dataTab.bulletRate*2 or dataTab.bulletRate)
    dataTab.fireType = 0
    FishGMF.pushRefreshData(dataTab)

    --其他玩家炮塔转动
    --FishGI.eventDispatcher:dispatch("OtherPlayerShoot", data);
end

function GameNet:OnHit(data) 
    if FishGI.SERVER_STATE == 0 then
        --还没有OnGameStatus
        return;
    end

    local dataValue = data;
    dataValue.chairId = FishGI.gameScene.playerManager:getPlayerChairId(data.playerId);
    if table.maxn(data.killedFishes) == 0 then
        dataValue.killedFishes = nil;
    end

    if table.maxn(data.dropProps) == 0 then
        dataValue.dropProps = nil;
    end
    
    if table.maxn(data.dropSeniorProps) == 0 then
        dataValue.dropSeniorProps = nil;
    end

    dataValue.upDataType = "onHit"
    dataValue.hitType = "comHit"
    FishGMF.pushRefreshData(dataValue)

    if dataValue.chairId == FishGI.gameScene.playerManager.selfIndex then
        local newThunderRate = data.newThunderRate;
        FishGI.eventDispatcher:dispatch("UpdateThunderRate", newThunderRate)
        return
    end
  
end 

--核弹申请使用结果
function GameNet:OnNBombUseResult(data)
    local event = cc.EventCustom:new("NBombUseResult")
    event._usedata = data
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)    
end

--核弹爆炸
function GameNet:OnNBombHit(data)
    dump(data)
    if data.isSuccess ~= true then
        local failureId = data.failReason
        print("--OnNBombHit---failReason-")
        return;
    end
    local chairId = FishGI.gameScene.playerManager:getPlayerChairId(data.playerId);
    local dataValue = data;
    dataValue.chairId = chairId;
    if table.maxn(data.killedFishes) == 0 then
        dataValue.killedFishes = nil;
    end
    dataValue.upDataType = "onHit"

    dataValue.hitType = "NBombHit"
    FishGMF.pushRefreshData(dataValue)

end

--申请使用狂暴结果
function GameNet:OnUseViolentResult(data)
    if FishGI.SERVER_STATE == 0 then
        return;
    end
    FishGI.eventDispatcher:dispatch("UseViolentResult", data);
end

--狂暴技能结束
function GameNet:OnViolentTimeOut(data)
    if FishGI.SERVER_STATE == 0 then
        return;
    end
    FishGI.eventDispatcher:dispatch("ViolentTimeOut", data);
end

--锁定技能转换目标
function GameNet:OnBulletTargetChange(data)
    if FishGI.SERVER_STATE == 0 then
        return;
    end
    FishGI.eventDispatcher:dispatch("bulletTargetChange", data);
end

--玩家加钱
function GameNet:onServerAddMoney(data)

end

--自己锁定技能结果
function GameNet:OnMyAimResult(data)
    FishGI.eventDispatcher:dispatch("startMyLock", data);
end

--其他人锁定
function GameNet:OnOtherAim(data)
    FishGI.eventDispatcher:dispatch("startOtherLock", data);
end

--自己申请冰冻结果
function GameNet:OnFreezeResult(data)
    FishGI.eventDispatcher:dispatch("startMyFreeze", data);
end

--其他人开始冰冻
function GameNet:OnOtherFreezeStart(data)
    FishGI.eventDispatcher:dispatch("otherFreezeStart", data);
end

--冰冻结束
function GameNet:OnFreezeEnd(data)
    FishGI.eventDispatcher:dispatch("endFreeze", data);
end

--炮倍转换
function GameNet:OnGunRateChange(data)
    FishGI.eventDispatcher:dispatch("GunRateChange", data);
end

--玩家升级 
function GameNet:OnPlayerUpgrade(data)
    FishGI.eventDispatcher:dispatch("PlayerUpgrade", data);
end

--炮倍升级 
function GameNet:OnCannonUpgrade(data)
    FishGI.eventDispatcher:dispatch("CannonUpgrade", data);
end

function GameNet:OnStartFishGroup(data)
    FishGI.eventDispatcher:dispatch("FishGroupCome", data);
end

function GameNet:OnStartTimeline(data)
    FishGI.eventDispatcher:dispatch("TimeLineCome", data);
end

function GameNet:OnAlmInfo(data)
    FishGI.eventDispatcher:dispatch("AlmInfoing", data);
end

function GameNet:OnApplyAlmResult(data)
    if FishGI.SERVER_STATE == 0 then
        --还没有OnGameStatus
        return;
    end
    FishGI.eventDispatcher:dispatch("ApplyAlmResult", data);
end

--提示鱼潮来临，技能禁用
function GameNet:OnFishGroupNotify(data)
    local  message = FishGF.getChByIndex(800000085)
    FishGF.showSystemTip(message)
    FishGI.isFishGroupCome = true

    local function clearFunc()
        if FishGI.gameScene.isFishCome then
                FishGI.gameScene.isFishCome = false;
                return;
            end
        FishGI.GameEffect:fishGroupCome()
        LuaCppAdapter:getInstance():fishAccelerateOut();
    end
    FishGF.delayExcute(14-FishCD.FISH_GROUP_COMING_CLEAR_TIME, clearFunc)
end

--打中奖金鱼
function GameNet:OnDrawStatusChange(data)
    FishGI.eventDispatcher:dispatch("upDataFishCoinPool", data);
end

--抽奖结果
function GameNet:OnDrawResult(data)
    if FishGI.SERVER_STATE == 0 then
        --还没有OnGameStatus
        return;
    end
    local selfId = FishGI.gameScene.playerManager.selfIndex;
    FishGI.eventDispatcher:dispatch("drawResult", data);
    if selfId == data.playerId then
        FishGI.eventDispatcher:dispatch("upDataFishCoinPool", data);
    end
end

function GameNet:OnGameAnnouncement(data)
    log("OnGameAnnouncement")
    local params = data.params
    FishGI.eventDispatcher:dispatch("pushAnnouncementData", data);
end

--召唤鱼
function GameNet:OnCallFish(data)
    if FishGI.SERVER_STATE == 0 then
        return;
    end
    FishGI.eventDispatcher:dispatch("startCallFish", data);
end

function GameNet:OnGunTpyeChange(data)
    log("--------OnGunTpyeChange-")
    if FishGI.SERVER_STATE == 0 then
        return;
    end
    FishGI.eventDispatcher:dispatch("changePlayerGun", data);
end

function GameNet:OnPlayerInfo(data)
    log("---OnPlayerInfo----")
    FishGI.eventDispatcher:dispatch("upDataByPlayerInfo", data);
end

--玩家破产
function GameNet:OnPlayerBankup(data)
    log("---OnPlayerBankup----")
    data.isBankup = true
    FishGI.eventDispatcher:dispatch("OnPlayerBankup", data);
end

--玩家信息
function GameNet:OnGetPlayerInfo(data)
    log("---OnGetPlayerInfo----")
    FishGI.eventDispatcher:dispatch("OnGetPlayerInfo", data);
end

--表情
function GameNet:onEmotionIcon(data)
    log("onEmotion")
    FishGI.eventDispatcher:dispatch("onEmotionIcon", data);
end

--魔法道具
function GameNet:onMagicprop(data)
    log("onMagicprop")
    FishGI.eventDispatcher:dispatch("onMagicprop", data);
end

--启动时光沙漏
function GameNet:onStartTimeHourGlass(data)
    log("onStartHourGlass")
    FishGI.eventDispatcher:dispatch("onStartHourGlass", data);
end

--结束时光沙漏
function GameNet:onStopTimeHourGlass(data)
    log("oStopHourGlass")
    FishGI.eventDispatcher:dispatch("oStopHourGlass", data);
end

--获取当前时光沙漏
function GameNet:onTryGetTimeHourGlass(data)
    log("onTryGetHourGlass")
    FishGI.eventDispatcher:dispatch("onTryGetHourGlass", data);
end

--继续时光沙漏
function GameNet:onContinueTimeHourGlass(data)
    log("onContinueHourGlass")
    FishGI.eventDispatcher:dispatch("onContinueHourGlass", data);
end

--获取新手任务信息
function GameNet:onGetNewTaskInfo(data)
    log("onGetNewTaskInfo")
    FishGI.eventDispatcher:dispatch("onGetNewTaskInfo", data);
end

--领取新手任务奖励
function GameNet:onGetNewTaskReward(data)
    log("onGetNewTaskReward")
    FishGI.eventDispatcher:dispatch("onGetNewTaskReward", data);
end

--使用限时炮台
function GameNet:onUsePropCannon(data)
    print("--onUsePropCannon--")
    FishGF.waitNetManager(false,nil,"UsePropCannon")
    FishGI.eventDispatcher:dispatch("onUsePropCannon", data)

end

------------------------------------------------------------------------------------------------
-------------------------------------------向服务器发送消息-------------------------------------
------------------------------------------------------------------------------------------------
function GameNet:sendJMsg( name, data )
    --设置发送消息的标识 判断断线的时候用
    
        local encoded, len = jmsg.encodeBinary(proto, name, data)
        local msg = CLuaMsgHeader.New()
        msg.id = self.msg.HEAD.MSG_C2S_JMSG
    --    print("encoded len="..len)
        msg:WriteData(encoded, len)
       
        self:SendData(msg)
        jmsg.freeBinary(encoded)
end

--[[
客户端准备就绪
]]
function  GameNet:sendClientReadyMessage()
    self:sendJMsg("MSGC2SClientReady", {})
end

--[[
发射发送子弹事件
bulletId 子弹id
frameId 该时刻的帧号
angle 子弹的方向
gunRate 炮倍
--]]
function GameNet:sendBullet(bulletId, frameId, angle, gunRate,timelineId,fishArrayId,posx, posy, isViolent)
    angle = FishGF.getStandardAngle(angle)
    local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale()
    posx = posx/scaleX_
    posy = posy/scaleY_
    if FishGI.isPlayerFlip then
        local winSize = cc.Director:getInstance():getWinSize();
        local cfg_ds= CC_DESIGN_RESOLUTION
        posx = cfg_ds.width-posx;
        posy = cfg_ds.height-posy;
    end

    local data = {}
    data.bulletId = bulletId;
    --data.frameId = frameId;
    data.angle = angle;
    data.gunRate = gunRate;
    data.timelineId = timelineId;
    data.fishArrayId = fishArrayId;
    data.pointX = posx;
    data.pointY = posy;
    data.isViolent = isViolent
    
    self:sendJMsg("MSGC2SPlayerShoot", data)
end

--锁定变换目标
function GameNet:sendBulletTargetChange(data)
    FishGF.print("-0-sendBulletTargetChange----")
    if data == nil then
        return
    end
    self:sendJMsg("MSGC2SBulletTargetChange", data)
end

--申请冰冻
function  GameNet:sendFreezeStart(useType)
    local data = {
        useType = useType,
    }
    self:sendJMsg("MSGC2SFreezeStart", data)
end

--申请锁定
function  GameNet:sendlockFish(timelineId,fishArrayId,useType)
    local data = {
        timelineId = timelineId,
        fishArrayId = fishArrayId,
        useType = useType,
    }
    self:sendJMsg("MSGC2SAim",data)
end

--[[
发送心跳消息
frameCount:客户端帧号
]]
function GameNet:sendHeartBeat(localFrameCount)
    local data = {
        frameCount = localFrameCount
    }
    self.isSend = true;
    self:sendJMsg("MSGC2SHeartBeat", data)
end

--[[
发送碰撞消息
]]
function GameNet:sendHit(bulletId, frameId, fishes, effectedFishes)
    local data = {
        bulletId = bulletId,
        frameId = frameId,
        killedFishes = fishes,
        effectedFishes = effectedFishes,
    }
  self:sendJMsg("MSGC2SPlayerHit", data)
end

--召唤鱼
function GameNet:sendCallFish(fishId, useType)
    local data = {
        callFishId = fishId,
        useType = useType,
    }
    self:sendJMsg("MSGC2SCallFish", data)
end

--核弹申请使用
function GameNet:sendNBomb(id, pos, useType)
    local data = {
        pointX = pos.x,
        pointY = pos.y,
        nBombId = FishGI.nbombCount,
        useType = useType,
        nPropID = id,
    }
    self:sendJMsg("MSGC2SNBomb", data)
    FishGI.nbombCount = FishGI.nbombCount+1;
end

--核弹爆炸
function GameNet:sendNBombBalst(id, killedFishes)
    local data = {
        killedFishes = killedFishes,
        nBombId = id,
    }
    self:sendJMsg("MSGC2SNBombBlast", data)
end

--普通场使用狂暴技能
function GameNet:sendUseViolent(useType)
    local data = {
        useType = useType,
    }
    self:sendJMsg("MSGC2SViolent", data)
end

--[[
发送加钱请求
]]
function GameNet:sendAddMoney(data)
    if data == nil then
        return
    end
    self:sendJMsg("MSGC2SSetProp", data)
end

--切换炮倍
function GameNet:sendNewGunRate(gunRate)
    local data = {}
    data.newGunRate = gunRate
    self:sendJMsg("MSGC2SGunRateChange", data)
end

--解锁炮倍申请
function GameNet:sendUpgradeCannon()
    local data = {}
    self:sendJMsg("MSGC2SUpgradeCannon", data)
end

--准备申请救济金
function GameNet:sendAlmInfo()
    local data = {}
    self:sendJMsg("MSGC2SAlmInfo", data)
end

--开始申请救济金
function GameNet:sendApplyAlm()
    local data = {}
    self:sendJMsg("MSGC2SApplyAlm", data)
end

--发送开始抽奖
function GameNet:sendStatrLottery(drawGradeId)
    local data = {
        drawGradeId = drawGradeId,
    }
  self:sendJMsg("MSGC2SDraw", data)
end

--发送换炮类型
function GameNet:sendNewGunType(newGunType)
    print("--sendNewGunType-")
    local data = {
        newGunType = newGunType,
    }
  self:sendJMsg("MSGC2SGunTpyeChange", data)
end

--充值成功发送消息
function GameNet:sendReChargeSucceed()
    print("--sendReChargeSucceed--")
    local data = {}
    self:sendJMsg("MSCC2SRechargeSuccess", data)
end

--进入充值界面发送消息使不会被踢
function GameNet:sendGotoCharge()
    print("--sendGotoCharge--")
    local data = {}
    self:sendJMsg("MSGC2SGotoCharge", data)
end

--退出充值界面发送消息
function GameNet:sendBackFromCharge()
    print("--sendBackFromCharge--")
    local data = {}
    self:sendJMsg("MSGC2SBackFromCharge", data)
end

--刷新玩家数据
function GameNet:sendUpDataPlayerData(playerId)
    print("--sendUpDataPlayerData--")
    local data = {
        playerId = playerId,
    }
    self:sendJMsg("MSGC2SGetPlayerInfo", data)
end

--显示表示
function GameNet:sendEmotionIcon(emoticonId)
    print("--sendEmotion--")
    local data = {
        emoticonId = emoticonId,
    }

    self:sendJMsg("MSGC2SEmoticon", data)
end

--魔法道具
function GameNet:sendMagicProp(magicpropId, toPlayerID)
    print("--sendMagicProp--")
    local data = {
        magicpropId = magicpropId,
        toPlayerID = toPlayerID,
    }

    self:sendJMsg("MSGC2SMagicprop", data)
end

--发送vip每日领取
function GameNet:sendGetVipDailyReward(tabVal)
    self:sendJMsg("MSGC2SGetVipDailyReward", tabVal)
end

--开启时光沙漏
function GameNet:sendToStartTimeHourglass(tabVal)
log("GameNet:sendToStartTimeHourglass")
for k,v in pairs(tabVal) do
    log(k,v)
end
    self:sendJMsg("MSGC2SUseTimeHourglass", tabVal)
end

--停止时光沙漏
function GameNet:sendToStopTimeHourglass(tabVal)
    log("GameNet:sendToStopTimeHourglass")
    self:sendJMsg("MSGC2SStopTimeHourglass", tabVal)
end

--继续时光沙漏
function GameNet:sendToContinueTimeHourglass(tabVal)
    log("GameNet:sendToContinueTimeHourglass")
    self:sendJMsg("MSGC2SContinueTimeHourglass", tabVal)
end

--获取新手任务信息
function GameNet:sendGetNewTaskInfo(tabVal)
    log("GameNet:sendGetNewTaskInfo")
    self:sendJMsg("MSGC2SGetNewTaskInfo", tabVal)
end

--使用限时炮台
function GameNet:sendUsePropCannon(useType,propID)
    print("--sendUsePropCannon--")
    FishGF.waitNetManager(true,nil,"UsePropCannon")
    local data = {
        useType = useType,
        propID = propID,        
    }
    self:sendJMsg("MSGC2SUsePropCannon", data)
end

--领取新手任务奖励
function GameNet:GetNewTaskReward(tabVal)
    log("GameNet:GetNewTaskReward")
    self:sendJMsg("MSGC2SGetNewTaskReward", tabVal)
end

GameNet.new();


