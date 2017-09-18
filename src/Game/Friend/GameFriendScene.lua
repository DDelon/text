
local GameFriendScene = class("GameFriendScene", function()
	return cc.Scene:create();
end)

function GameFriendScene.create(client)
	local scene = GameFriendScene.new();
    FishGI.gameScene = scene;
	scene:init(client);
	return scene;
end

function GameFriendScene:init(client)
    self.sceneName = "game"
    FishGMF.setGameType(1)
    FishGMF.setGameState(3)
    
    FishGI.SERVER_STATE = 0
    
	self.net = client;
    self.scaleX_,self.scaleY_,self.scaleMin_  = FishGF.getCurScale()

    self:initView()

    --子弹数量
    FishGI.bulletNumMax = tonumber(FishGI.GameConfig:getConfigData("room", tostring(FishGI.curGameRoomID + 910000000), "max_bullet"));
    --子弹间隔
    FishCD.PLAYER_SHOOT_INTERVAL = tonumber(FishGI.GameConfig:getConfigData("cannon", "920000001", "interval"))/1000;

    local function onNodeEvent(event )
        if event == "enter" then
            self:onEnter()
        elseif event == "enterTransitionFinish" then

        elseif event == "exit" then
            self:onExit()
        elseif event == "exitTransitionStart" then

        elseif event == "cleanup" then

        end

    end
    self:registerScriptHandler(onNodeEvent)

    --添加安卓返回键监听
    local function onKeyboardFunc(code, event)
        if code == cc.KeyCode.KEY_BACK then
            FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
            self.uiMainLayer:buttonClicked("SetButton", "exit")
        end
    end
    local listener = cc.EventListenerKeyboard:create();
    listener:registerScriptHandler(onKeyboardFunc, cc.Handler.EVENT_KEYBOARD_RELEASED);
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);

    self:registerEnterBFgroundEvt()
end

function GameFriendScene:registerEnterBFgroundEvt()
    --进入前台
    local function onAppEnterForeground()
        if not self.isEnterBg then
            return
        end
        self.isEnterBg = false

        FishGI.enterBackTime = os.time() -FishGI.enterBackTime;
        if FishGI.enterBackTime < 0 then
            FishGI.enterBackTime = 0;
        end
        print("___GameFriendScene____enter");
        FishGI.AudioControl:playLayerBgMusic()
        self:cancelAutoFire()

        -- local dataTab = {}
        -- dataTab.funName = "setSocketPause"
        -- dataTab.isPause = false
        -- LuaCppAdapter:getInstance():luaUseCppFun(dataTab)

        print("enter back second:"..FishGI.enterBackTime);

        self.uiMainLayer.uiSettlement:onEnterForeground()
    end

    --进入后台
    local function onAppEnterBackground()
        print("___GameFriendScene____back");
        self.isEnterBg = true
        FishGI.enterBackTime = os.time();

        -- local dataTab = {}
        -- dataTab.funName = "setSocketPause"
        -- dataTab.isPause = true
        -- LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
        self.net:sendHeartBeat(LuaCppAdapter:getInstance():getCurFrame());
    end

    local eventDispatcher = self:getEventDispatcher()
    local forelistener = cc.EventListenerCustom:create("applicationWillEnterForeground", onAppEnterForeground)
    eventDispatcher:addEventListenerWithSceneGraphPriority(forelistener, self)
    local backlistener = cc.EventListenerCustom:create("applicationDidEnterBackground", onAppEnterBackground)
    eventDispatcher:addEventListenerWithSceneGraphPriority(backlistener, self)

end

--初始化ui层
function GameFriendScene:initView() 

    self.uiMainLayer = require("Game/Friend/FriendMainLayer").create()
    self:addChild(self.uiMainLayer)
    self.uiMainLayer.net = self.net

    --玩家管理器
    self.playerManager = require("Game/FriendPlayerManager/FriendPlayerManager").create()
    self:addChild(self.playerManager)

    self.playerManager:initPlayers(self.uiMainLayer)
end

function GameFriendScene:onEnter()
    print("------GameScene:onEnter--")
    FishGI.GameTableData:clearGameTable(3)
    FishGMF.setGameType(1)
    LuaCppAdapter:getInstance():exitGame()
    FishGMF.setGameState(3)
    FishGI.SERVER_STATE = 0
    FishGI.FRIEND_ROOM_STATUS = 3

	FishGI.shop = self.uiShopLayer;
    self:startLoad()

    FishGMF.clearRefreshData()

    if FishGI.hallScene ~= nil then
        FishGI.hallScene:closeAllSchedule()
    end

    self.net:sendClientGameLoadedMessage()

end

function GameFriendScene:exitGame()
    local valTab = {}
    valTab.player = {}
    valTab.player.id = FishGI.myData.playerId
    self.playerManager:playerLeave(valTab)
    
    self.net.mPlayer = {}
    self.uiMainLayer:closeAllSchedule()
    LuaCppAdapter:getInstance():exitGame()
    if self.skillManager ~= nil then
        self.skillManager:clear();
    end
    
    FishGI.isPlayerFlip = false;
    FishGI.isLogin = true

    FishGI.isExitRoom = true
    FishGI.isNoticeClose = false

end

function GameFriendScene:onExit( )
    print("GameScene:onExit( )")
    --FishGMF.setGameState(1)
    FishGI.FRIEND_ROOM_STATUS = 0
    FishGI.FRIEND_ROOMID = nil
    FishGI.isExitRoom = true

    FishGI.isAutoFire = false
    FishGMF.clearRefreshData()
    FishGI.AudioControl:pauseMusic()
    FishGI.AudioControl:stopAllEffects()
    self:exitGame()
    --移除监听器
    FishGI.eventDispatcher:removeAllListener();
    FishGI.gameScene = nil
    FishGF.waitNetManager(true,nil,"exitGame")
end

function GameFriendScene:buttonClicked(viewTag, btnTag)
    if viewTag == "FriendPropItem" then 
        print("use skill")
        if FishGI.SERVER_STATE == 0 then
            FishGF.showSystemTip(nil,800000274,1)
            return 
        end

        local iPropId = btnTag
        self.skillManager:sendDataToServer(iPropId);
    end 
end



function GameFriendScene:onGameLoaded(data)
    print("GameFriendScene:onGameLoaded")
        --初始化特效
    FishGI.GameEffect:initGameEff()

    --初始化结束
    FishGF.setLodingEnd();

    FishGF.UpdataWechat()
    
    self.uiMainLayer:onGameLoaded(data)

    if data.roomInfo.started then 
        self:startGame(data.roomInfo)
    end 

end

function GameFriendScene:OnPlayerJoin(iChairId)
    self.uiMainLayer:OnPlayerJoin(iChairId)
end

function GameFriendScene:onReady(data)
    print("GameFriendScene:onReady")
    data.status = 1
    self.uiMainLayer:onReady(data)
    self.playerManager:setPlayerGameStatus(data)

    local playerId = data.playerId
    for k,val in pairs(data.initFriendProps) do
        local propId = val.propId + FishCD.FRIEND_INDEX
        local delayTime = 0
        FishGMF.addTrueAndFlyProp(playerId,propId,val.propCount,true,val.propCount,delayTime)
        FishGMF.updateInline()
    end

end

function GameFriendScene:onStartGame(data)
    print("GameFriendScene:onStartGame")
    local success = data.success
    local errorCode = data.errorCode
    local timelineId = data.timelineId

    if success then
        --开始时间线
        print("----------onStartGame--------true--------")
        local tab = {}
        tab.timelineIndex = data.timelineId
        tab.frameId = 0
        tab.killedFishes = {}
        tab.bullets = {}
        self:startGame(tab)
        self.uiMainLayer:onStartGame(data)
    else
        if errorCode == 1 then 
            --1:准备的人数小于
            FishGF.showToast(FishGF.getChByIndex(800000263))
        elseif errorCode == 2 then 
            --2,已经开始
            FishGF.showToast(FishGF.getChByIndex(800000302))
        elseif errorCode == 3 then 
            --3,不是房主
            FishGF.showToast(FishGF.getChByIndex(800000297))
        end

    end


end

function GameFriendScene:startGame(data)
    self.net:openNetSchedule();
    self.net:openUpdateInline();

    FishGI.SERVER_STATE = 1
    --玩家状态更新
    self.playerManager:updataAllPlayerStatus()

    --初始化朋友场技能管理器
    self.skillManager = require("Game/Skill/FriendSkill/FriendSkillManager").create();
    self:addChild(self.skillManager, 10000);

    local playerTab = {}
    for k,v in pairs(self.playerManager.playerTab) do
        local dataTab = {}
        self.skillManager:initBuffWithData(v.playerInfo.playerId, v.playerInfo.effects);
        dataTab.playerInfo = v.playerInfo
        table.insert( playerTab,dataTab )
    end

    --鱼
    --------------------鱼管理器
    local fishManagerData = {};
    fishManagerData.playerTab = playerTab
    fishManagerData.winScaleX = self.scaleX_
    fishManagerData.winScaleY = self.scaleY_
    fishManagerData.roomId = tostring(FishGI.FRIEND_ROOMID)
    fishManagerData.isFlip = FishGI.isPlayerFlip;
    fishManagerData.isInGroup = false
    FishGI.frame = data.frameId;
    fishManagerData.roomLv = 4;

    fishManagerData.timelineIndex = data.timelineIndex
    fishManagerData.frameId = data.frameId;

    local killedFishes = data.killedFishes;
    --if killedFishes == {} then killedFishes = nil end

    self.fishManager = cc.Layer:create();
    self.uiMainLayer:addChild(self.fishManager, 2);

    self.fishLayer = cc.Layer:create();
    self.uiMainLayer:addChild(self.fishLayer, FishCD.ORDER_GAME_fish);
    FishGF.print("------------startGame------fishManagerData-----------")
    LuaCppAdapter:getInstance():startGame(self.fishManager, self.fishLayer, fishManagerData, killedFishes, {});

    --------------------------鱼的网络消息
    FishGI.eventDispatcher:registerCustomListener("SyncFrame", self, function(valTab) 
        LuaCppAdapter:getInstance():syncFrame(valTab);
    end);

    FishGI.eventDispatcher:registerCustomListener("SetGunRate", self, function(valTab) 
        LuaCppAdapter:getInstance():setGunRate(valTab);
    end);

    FishGI.eventDispatcher:registerCustomListener("fishSwitchColor", self, function(valTab) 
        LuaCppAdapter:getInstance():fishSwithColor(valTab);
    end);

    FishGI.eventDispatcher:registerCustomListener("FishGroupCome", self, function(valTab) 
        
        LuaCppAdapter:getInstance():fishGroupCome(valTab);
    end);

    FishGI.eventDispatcher:registerCustomListener("TimeLineCome", self, function(valTab) 
        LuaCppAdapter:getInstance():fishTimeLineCome(valTab);
    end);

    FishGI.eventDispatcher:registerCustomListener("UpdateThunderRate", self, function(valTab) 
        if valTab ~= nil then
            LuaCppAdapter:getInstance():updateThunderRate(valTab);
        end
    end);


   --子弹管理器
    
    self.bulletLayer = cc.Layer:create();
    self.uiMainLayer:addChild(self.bulletLayer, FishCD.ORDER_GAME_bullet);

     --子弹角度翻转
    local bullets = data.bullets;
    for key, val in pairs(bullets) do
        val.pos = cc.p(val.pointX, val.pointY);
        val.angle = FishGF.getCustomAngle(val.angle);
        val.angle = val.angle-90;
        local chairId = FishGI.gameScene.playerManager:getPlayerChairId(val.playerId)
        if chairId >=3 then
            val.angle = val.angle +180;
        end
    end
    local bulletManagerData = {};
    bulletManagerData.bullets = bullets
    if table.maxn(bulletManagerData.bullets) == 0 then
        FishGF.print("------------startBullet------bulletManagerData.bullets = nil-----------")
        bulletManagerData.bullets = nil;
    end

    LuaCppAdapter:getInstance():startBullet(self.bulletLayer, bulletManagerData);
    ----------------------------子弹网络消息
    FishGI.eventDispatcher:registerCustomListener("PlayerShoot", self, function(valTab) 
        --其他玩家射击子弹
        LuaCppAdapter:getInstance():playerFire(valTab);
    end);
    FishGI.eventDispatcher:registerCustomListener("RemovePlayerBullet", self, function(valTab)
        LuaCppAdapter:getInstance():removePlayerBullet(valTab);
    end);
    FishGI.eventDispatcher:registerCustomListener("OtherBulletHit", self, function(valTab) 
        --其他玩家子弹碰撞
        LuaCppAdapter:getInstance():otherPlayerBulletCollision(valTab);
    end);
    FishGI.eventDispatcher:registerCustomListener("BulletTargetChange", self, function(valTab) 
        LuaCppAdapter:getInstance():bulletChangeTarget()
    end);

    -----------------------------------------
    --渔网管理
    self.netsLayer = cc.Layer:create();
    self.uiMainLayer:addChild(self.netsLayer, FishCD.ORDER_GAME_nets);
    LuaCppAdapter:getInstance():startNets(self.netsLayer);

    self:openHeartBeatUpdate();
    

    --初始化特效
    FishGI.GameEffect:initGameEff()

    print("init friend skill manager")
    

end 

function GameFriendScene:onLeaveGame(data)
    print("GameFriendScene:onLeaveGame")
    self.playerManager:playerLeave(data)
end

function GameFriendScene:cancelAutoFire() 
    if  self.playerManager ~= nil then
        self.playerManager:onTouchEnded(nil, nil);
    end
end

--加载进度条
function GameFriendScene:startLoad( isLoadData )
    if self.loadingLayer == nil then
        self.loadingLayer = require("Loading/LoadingLayer").new()
        self:addChild(self.loadingLayer,FishCD.ORDER_LOADING)
    end

    FishGI.loading_index = 0
    FishGI.loading_sp = 1
    FishGI.isloadingEnd = false;

    self.loadingLayer:preloadResNil(handler(self, self.gameStartAct));

    --FishGF.setLodingEnd()
    --初始化特效
    FishGI.GameEffect:initGameEff()
end

function GameFriendScene:gameStartAct()
    self.uiMainLayer:gameStartAct()
end

--开启心跳定时器
function GameFriendScene:openHeartBeatUpdate()
    local function updateInline()
        self.net:sendHeartBeat(LuaCppAdapter:getInstance():getCurFrame());
    end
    self.heartBeatUpdateId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateInline, 2.0, false);
end

return GameFriendScene;

