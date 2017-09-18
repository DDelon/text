
local GameScene = class("GameScene", function()
	return cc.Scene:create();
end)

function GameScene.create(client)
	local scene = GameScene.new();
    FishGI.gameScene = scene;
	scene:init(client);
	return scene;
end

function GameScene:init(client)
    self.sceneName = "game"
    FishGMF.setGameType(0)
    FishGMF.setGameState(3)
    FishGI.SERVER_STATE = 0
    
	self.net = client;
    self.scaleX_,self.scaleY_,self.scaleMin_  = FishGF.getCurScale()

    self:initBg()
    self:initUILayer()

    if FishGI.isOpenDebug then
        --秘籍
        self:secretUseLayer(self);
    end

    --玩家管理器
    self.playerManager = require("Game/PlayerManager/PlayerManager").create();
    self:addChild(self.playerManager,FishCD.ORDER_GAME_player);

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
            self:buttonClicked("SetButton", "exit")
        end
    end
    local listener = cc.EventListenerKeyboard:create();
    listener:registerScriptHandler(onKeyboardFunc, cc.Handler.EVENT_KEYBOARD_RELEASED);
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);


    -- local eventDispatcher = self:getEventDispatcher()
    -- local forelistener = cc.EventListenerCustom:create("applicationWillEnterForeground", handler(self, self.cancelAutoFire))
    -- eventDispatcher:addEventListenerWithSceneGraphPriority(forelistener, self)

    self:registerEnterBFgroundEvt()
end

function GameScene:doExitGame()
    FishGF.doMyLeaveGame(0)
    FishGI.hallScene.net:enterRoom(1);
end

function GameScene:registerEnterBFgroundEvt()
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
        print("___GameScene____enter");
        self.uiSkillView:upDateUserTime(FishGI.enterBackTime)
        FishGI.AudioControl:playLayerBgMusic()
        self:cancelAutoFire()

        print("enter back second:"..FishGI.enterBackTime);
    end

    --进入后台
    local function onAppEnterBackground()
        print("___GameScene____back");
        self.isEnterBg = true
        FishGI.enterBackTime = os.time();
        self.net:sendHeartBeat(LuaCppAdapter:getInstance():getCurFrame());
    end

    local eventDispatcher = self:getEventDispatcher()
    local forelistener = cc.EventListenerCustom:create("applicationWillEnterForeground", onAppEnterForeground)
    eventDispatcher:addEventListenerWithSceneGraphPriority(forelistener, self)
    local backlistener = cc.EventListenerCustom:create("applicationDidEnterBackground", onAppEnterBackground)
    eventDispatcher:addEventListenerWithSceneGraphPriority(backlistener, self)

end

--初始化背景
function GameScene:initBg() 
    local keyID = tostring(FishGI.curGameRoomID + 910000000)
    local bgName = tostring(FishGI.GameConfig:getConfigData("room", keyID, "bg_img"));
    self.bg = cc.Sprite:create("battle/battleUI/"..bgName)
    self.bg:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self.bg:setScale(1.03);
    self:addChild(self.bg)
    --self.bg:setVisible(false)

    --播放粒子特效文件1  
    local emitter1 = FishGI.GameEffect.createBubble(2) 
    emitter1:setPosition(cc.p(195*self.scaleX_,160*self.scaleY_))
    self:addChild(emitter1,2)  

    --播放粒子特效文件2  
    local emitter2 = FishGI.GameEffect.createBubble(2) 
    emitter2:setPosition(cc.p(1147*self.scaleX_,212*self.scaleY_))
    self:addChild(emitter2,2)

    --水波纹
    local spr_wave_1 = cc.Sprite:create("battle/effect/wave_1_00.png")
    spr_wave_1:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(spr_wave_1,1)
    spr_wave_1:setScale(2)
    spr_wave_1:setOpacity(0)
    local time = 0.9
    local seq = cc.Sequence:create(cc.FadeTo:create(time,255),cc.FadeTo:create(time,0))
    spr_wave_1:runAction(cc.RepeatForever:create(seq))

    local spr_wave_2 = cc.Sprite:create("battle/effect/wave_1_01.png")
    spr_wave_2:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(spr_wave_2,1)
    spr_wave_2:setScale(2)
    spr_wave_2:setOpacity(255)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function ( ... )
        local seq2 = cc.Sequence:create(cc.FadeTo:create(time,255),cc.FadeTo:create(time,0))
        spr_wave_2:runAction(cc.RepeatForever:create(seq2))
    end)))
end

--初始化ui层
function GameScene:initUILayer() 

    --------------游戏UI----------------------------------------------------------------------
    --桌面技能
    self.uiSkillView = require("Game/Skill/NormalSkill/SkillView").create()
    self:addChild(self.uiSkillView,5)

    --救济金
    self.uiAlmInfo = require("Game/AlmInfo").create()
    self:addChild(self.uiAlmInfo,5)
    self.uiAlmInfo:setVisible(false) 

    --公告
    self.uiAnnouncement = require("Game/Announcement").create()
    self.uiAnnouncement:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height*3/4))
    self:addChild(self.uiAnnouncement,FishCD.ORDER_SCENE_UI)
    self.uiAnnouncement:setScale(self.scaleMin_)
    self.uiAnnouncement:setVisible(false)

    --------------场景UI----------------------------------------------------------------------
    --获取鱼币按键
    local AddFishCoin = require("ui/hall/button/uibtn_hall").create()
    self.uiAddFishCoin = AddFishCoin.root
    self.uiAddFishCoin.animation = AddFishCoin.animation
    self.uiAddFishCoin:setPosition(cc.p(1200*self.scaleX_,570*self.scaleY_))
    self:addChild(self.uiAddFishCoin,FishCD.ORDER_SCENE_UI)
    local btn = self.uiAddFishCoin:getChildByName("btn")
    btn:loadTextureNormal("battle/battleUI/bl_pic_hqyb.png",0)
    btn:loadTexturePressed("battle/battleUI/bl_pic_hqyb.png",0)
    btn:loadTextureDisabled("battle/battleUI/bl_pic_hqyb.png",0)
    local btn_addFishCoin = AddFishCoin["btn"]
    btn_addFishCoin:onClickDarkEffect(handler(self,self.onClickAddFishcoin))
    AddFishCoin["spr_light"]:runAction(cc.RepeatForever:create(cc.RotateBy:create(1,FishCD.LIGHT_SPEED)))
    self.uiAddFishCoin:runAction(AddFishCoin.animation)
    self.uiAddFishCoin.animation:play("nojump", false)


    --右边按键面板
    self.uiSetButton = require("Game/SetButton").create()
    self.uiSetButton:setPosition(cc.p(cc.Director:getInstance():getWinSize().width,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiSetButton,FishCD.ORDER_SCENE_UI)
    self.uiSetButton:setScale(self.scaleMin_)

    --炮台升级 小于1000才创建升炮面板
    self.uiGunUpGrade = require("Game/GunUpGrade").create()
    self.uiGunUpGrade:setPosition(cc.p(0,512.94*self.scaleY_))
    self:addChild(self.uiGunUpGrade,FishCD.ORDER_SCENE_UI)
    self.uiGunUpGrade:setScale(self.scaleMin_)

    --抽奖面板
    self.uiLotteryPanel = require("Game/Lottery/LotteryPanel").create()
    self.uiLotteryPanel:setPosition(cc.p(0,390.56*self.scaleY_))
    self:addChild(self.uiLotteryPanel,FishCD.ORDER_SCENE_UI)
    self.uiLotteryPanel:setScale(self.scaleMin_)

    self.playerInfoLayer = {}
    for i = 1,4 do
        --创建个人信息层
        self.playerInfoLayer[i] = require("PlayerInfo/GamePlayerInfo").create();
        self.playerInfoLayer[i]:setPosByChairid(i)
        self:addChild(self.playerInfoLayer[i],FishCD.ORDER_LAYER_VIRTUAL+10);
        self.playerInfoLayer[i]:setVisible(false)
    end

    self.uiNewbieTask = require("Game/NewbieTask/NewbieTask").create()
    self.uiNewbieTask:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height+70*self.scaleMin_))
    self:addChild(self.uiNewbieTask,FishCD.ORDER_GAME_player)
    self.uiNewbieTask:setScale(self.scaleMin_)
    self.uiNewbieTask:setVisible(false)

    --------------层级UI----------------------------------------------------------------------

    --抽奖层
    self.uiLotteryLayer = require("Game/Lottery/LotteryLayer").create()
    self.uiLotteryLayer:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiLotteryLayer,FishCD.ORDER_LAYER_TRUE+1)
    self.uiLotteryLayer:setScale(self.scaleMin_)
    self.uiLotteryLayer:setVisible(false)

    --开始抽奖层
    self.uiLotteryStart = require("Game/Lottery/LotteryStart").create()
    self.uiLotteryStart:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiLotteryStart,FishCD.ORDER_LAYER_TRUE+2)
    self.uiLotteryStart:setScale(self.scaleMin_)
    self.uiLotteryStart:setVisible(false)    

    --鱼表
    self.uiFishForm = require("Game/FishForm").create()
    self.uiFishForm:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiFishForm,FishCD.ORDER_LAYER_TRUE+2)
    self.uiFishForm:initFishForm(FishGI.curGameRoomID)
    self.uiFishForm:setVisible(false)
    self.uiFishForm:setScale(self.scaleMin_)

    --声音设置
    self.uiSoundSet = require("AudioManager/SoundSet").create()
    self.uiSoundSet:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiSoundSet,FishCD.ORDER_LAYER_TRUE)
    self.uiSoundSet:setVisible(false)
    --self.uiSoundSet:setScale(self.scaleMin_)

    --换炮层
    self.uiSelectCannon = require("Game/SelectCannon/SelectCannon").create()
    self.uiSelectCannon:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiSelectCannon,FishCD.ORDER_LAYER_TRUE)
    self.uiSelectCannon:setScale(self.scaleMin_)
    self.uiSelectCannon:setVisible(false)

    --商店
    self.uiShopLayer = require("Shop/Shop").create()
    self.uiShopLayer:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiShopLayer,FishCD.ORDER_LAYER_TRUE)
    self.uiShopLayer:setVisible(false)   
    self.uiShopLayer:setScale(self.scaleMin_)

    --VIP特权
    self.uiVipRight = require("VipRight/VipRight").create()
    self.uiVipRight:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiVipRight,FishCD.ORDER_LAYER_TRUE)
    self.uiVipRight:setVisible(false)
    self.uiVipRight:setScale(self.scaleMin_)

    if not FishGI.isGetMonthCard then      
        --月卡
        self.uiMonthcard = require("hall/Monthcard/Monthcard").create()
        self.uiMonthcard:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,330*self.scaleY_))
        self:addChild(self.uiMonthcard,FishCD.ORDER_LAYER_TRUE)
        self.uiMonthcard:setVisible(false)
        self.uiMonthcard:setScale(self.scaleMin_)
    end

end

function GameScene:cancelAutoFire() 
    if  self.playerManager ~= nil then
        self.playerManager:onTouchEnded(nil, nil);
    end
end

--加载进度条
function GameScene:startLoad( isLoadData )
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

function GameScene:onEnter( )
    print("------GameScene:onEnter--")
    FishGI.GameTableData:clearGameTable(2)
    FishGMF.setGameType(0)
    LuaCppAdapter:getInstance():exitGame()
    FishGMF.setGameState(3)
    FishGI.SERVER_STATE = 0

    FishGI.FRIEND_ROOM_STATUS = 0
    FishGI.FRIEND_ROOMID = nil

	FishGI.shop = self.uiShopLayer;
    FishGI.hallScene.net.isEnterRoom = false;

    self:startLoad()

    FishGMF.clearRefreshData()

    if FishGI.hallScene ~= nil then
        FishGI.hallScene:closeAllSchedule()
    end

end

function GameScene:onExit( )
    print("GameScene:onExit( )")
    FishGI.isAutoFire = false
    FishGMF.clearRefreshData()
    FishGI.AudioControl:pauseMusic()
    FishGI.AudioControl:stopAllEffects()
    self:exitGame()
    --移除监听器
    FishGI.eventDispatcher:removeAllListener();

    FishGF.waitNetManager(true,nil,"exitGame")
end

function GameScene:startGame(data)

    self.isFishCome = false;
	local frame = data.frameId;
    local isGroup = data.isInGroup;
    local timeLineIndex = data.timelineIndex;
    local bulletNum =# data.bullets;
    local killedFishNum = #data.killedFishes;

    local bulletsTab = data.bullets;
    local killedFishTab = data.killedFishes;
    --call fish 
    local calledFishesTab = data.calledFishes;
    if calledFishesTab == {} then calledFishesTab = nil end
    
    local isInFreeze = data.isInFreeze
    local fishGroupComing = data.fishGroupComing
    local fishGroupComingLeftSeconds = data.leftFishGroupSeconds;
    local roomLv = FishGI.hallScene.net.roomLv;
    FishGI.frame = frame;

    data.winScaleX = self.scaleX_
    data.winScaleY = self.scaleY_
    --------------------鱼管理器
    local fishManagerData = data;
    local killedFishesTab = data.killedFishes;
    fishManagerData.isFlip = FishGI.isPlayerFlip;
    fishManagerData.roomLv = roomLv;
    self.fishManager = cc.Layer:create();
    self:addChild(self.fishManager, 2);

      --效果层
    --self.effectLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100));
    self.effectLayer = cc.Layer:create();
    self:addChild(self.effectLayer, 4, FishCD.TAG.EFFECT_LAYER_TAG);

    --UI层
    self.uiLayer = cc.Layer:create();
    self:addChild(self.uiLayer, 4, FishCD.TAG.UI_LAYER_TAG);

    

    self.fishLayer = cc.Layer:create();
    self:addChild(self.fishLayer, FishCD.ORDER_GAME_fish);
    LuaCppAdapter:getInstance():startGame(self.fishManager, self.fishLayer, fishManagerData, killedFishesTab, calledFishesTab);
    
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
        self.isFishCome = true;
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

    FishGI.eventDispatcher:registerCustomListener("UpdateNBombRate", self, function(valTab) 
        if valTab ~= nil then
            LuaCppAdapter:getInstance():updateNBombRate(valTab);
        end
    end);

    -----------------------------------------
    -- --玩家管理器
    -- self.playerManager = require("Game/PlayerManager/PlayerManager").create(playerTab);
    -- self:addChild(self.playerManager,FishCD.ORDER_GAME_player);
    --self.playerManager:initData(playerTab)

    --子弹管理器
    local bulletManagerData = data;
    self.bulletLayer = cc.Layer:create();
    self:addChild(self.bulletLayer, FishCD.ORDER_GAME_bullet);

    --子弹角度翻转
    local bullets = data.bullets;
    for key, val in pairs(bullets) do
        val.angle = FishGF.getCustomAngle(val.angle);
        val.angle = val.angle-90;
        local chairId = FishGI.gameScene.playerManager:getPlayerChairId(val.playerId)
        if chairId >=3 then
            val.angle = val.angle +180;
        end
    end
    if table.maxn(bulletManagerData.bullets) == 0 then
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
    self:addChild(self.netsLayer, FishCD.ORDER_GAME_nets);
    LuaCppAdapter:getInstance():startNets(self.netsLayer);

    --开启触摸监听器
    self:openTouchListener();

    self:openHeartBeatUpdate();
    
    --当前是否冰冻
    if isInFreeze == true then
        local freezePlayerId = data.freezePlayerId
        local val = {}
        val.playerId = freezePlayerId
        FishGI.eventDispatcher:dispatch("gameStartFreeze", val);
    end

    --鱼潮是否要来临
    if isGroup == false and fishGroupComing == true then
        FishGI.isFishGroupCome = true
        local  message = FishGF.getChByIndex(800000085)
        FishGF.showSystemTip(message)
        local delayTime = 0;
        if fishGroupComingLeftSeconds > FishCD.FISH_GROUP_COMING_CLEAR_TIME then
            delayTime = fishGroupComingLeftSeconds-FishCD.FISH_GROUP_COMING_CLEAR_TIME;
        end
        local function clearFunc()
            if self.isFishCome then
                self.isFishCome = false;
                return;
            end
            FishGI.GameEffect:fishGroupCome()
            LuaCppAdapter:getInstance():fishAccelerateOut();
        end
        FishGF.delayExcute(delayTime, clearFunc)
    else
        FishGI.isFishGroupCome = false
    end


    --其他玩家锁定目标切换
    local bulletsTab = data.bullets;
    local playerAimTab = {}
    if bulletsTab ~= nil and table.maxn(bulletsTab) ~= 0 then
        for i=#bulletsTab,1,-1 do
            local buttle = bulletsTab[i]
            if playerAimTab[buttle.playerId] == nil and buttle.timelineId ~= 0 then
                playerAimTab[buttle.playerId] = {}
                playerAimTab[buttle.playerId].timelineId = buttle.timelineId
                playerAimTab[buttle.playerId].fishArrayId = buttle.fishArrayId
                FishGMF.setCppAimFish(buttle.playerId, buttle.timelineId,buttle.fishArrayId)
            end
        end
    end


    --初始化奖池
    FishGI.eventDispatcher:dispatch("upDataFishCoinPool", data);

    --初始化特效
    FishGI.GameEffect:initGameEff()

    --初始化结束
    FishGF.setLodingEnd();

    --self:gameStartAct()
end

--游戏开始的界面处理
function GameScene:gameStartAct() 
    local delatTime = 0
    --灰色背景
    local grayBg = cc.Scale9Sprite:create("common/layerbg/com_pic_graybg.png");
    grayBg:setScale9Enabled(true);
    local size = cc.Director:getInstance():getWinSize();
    grayBg:setContentSize(size);
    grayBg:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(grayBg,900)
    grayBg:setOpacity(255*0.5)
    grayBg:runAction(cc.Sequence:create(cc.DelayTime:create(delatTime+2),cc.RemoveSelf:create(true)));

    --提示是我自己
    local noticeMine_word = cc.Sprite:create("battle/battleUI/bl_pic_ndwz.png")
    noticeMine_word:setPosition(cc.p(FishGF.getMyPos().x,FishGF.getMyPos().y + 180*self.scaleY_))
    self:addChild(noticeMine_word,902)
    local noticeMine_arrow = cc.Sprite:create("battle/battleUI/bl_pic_arrow.png")
    noticeMine_word:addChild(noticeMine_arrow)
    noticeMine_arrow:setPositionX(noticeMine_word:getContentSize().width/2)
    noticeMine_arrow:setPositionY(-noticeMine_word:getContentSize().height/2)
    noticeMine_word:runAction(cc.Sequence:create( 
        cc.DelayTime:create(delatTime),
        cc.MoveBy:create(0.5,cc.p(0,-10)),cc.MoveBy:create(0.5,cc.p(0,10)),
        cc.MoveBy:create(0.5,cc.p(0,-10)),cc.MoveBy:create(0.5,cc.p(0,10)),
        cc.RemoveSelf:create(true)
         ))

    self:runAction(cc.Sequence:create(cc.DelayTime:create(delatTime),cc.CallFunc:create(function ( ... )
        if not self.uiSetButton.isOpen then
            self.uiSetButton:setIsOpen();
        end
        if not self.uiSkillView.isOpen then
            self.uiSkillView:setIsOpen();
        end
        if not self.uiLotteryPanel.isOpen then
            self.uiLotteryPanel:setIsOpen(true);
        end
        if not self.uiGunUpGrade.isOpen then
            self.uiGunUpGrade:setIsOpen(true);
        end
    end),cc.DelayTime:create(2),cc.CallFunc:create(function ( ... )
        -- if self.uiSetButton.isOpen then
        --     self.uiSetButton:setIsOpen();
        -- end
        -- if self.uiSkillView.isOpen then
        --     self.uiSkillView:setIsOpen();
        --  end
    end) ))

    self.uiSkillView.Skill_14:continueCheck()
end

function GameScene:closeAllSchedule()
    if self.heartBeatUpdateId ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.heartBeatUpdateId);
    end
    if self.loadingLayer ~= nil then
        self.loadingLayer:closeAllSchedule()
    end
    self.net:closeSchedule();
    self.uiSkillView:closeSchedule();
    self.uiAlmInfo:endCountTime()
    FishGI.GameEffect:closeAllSchedule()
end

function GameScene:shakeBackground(timesInterval, times)
    local pos = cc.p(self.bg:getPositionX(), self.bg:getPositionY());
    local function move()
        if times == 0 then
            self.bg:stopAllActions();
            self.bg:setPosition(pos);
        else
            local function getDirect()
                return math.random(1, 2) == 2 and -1 or 1;
            end
            times = times-1;
            self.bg:stopActionByTag(11200);
            self.bg:setPosition(pos);
            local offset = 30/20*times;
            local tarPos = cc.p(math.random(-offset*getDirect(),offset*getDirect()), math.random(-offset*getDirect(),offset*getDirect()));
            local moveBy = cc.MoveBy:create(timesInterval/2, tarPos);
            local act = cc.RepeatForever:create(cc.Sequence:create(moveBy, moveBy:reverse()));
            act:setTag(11200);
            self.bg:runAction(act);
        end
        
    end
    self.bg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(move), cc.DelayTime:create(timesInterval))));
end

function GameScene:exitGame()
    print("------GameScene---exitGame------0----")
    self.net.mPlayer = {};
    self:closeAllSchedule();
    LuaCppAdapter:getInstance():exitGame();
    FishGI.isPlayerFlip = false;
    FishGI.isLogin = true
    print("------GameScene---exitGame-----2-----")
end

--开启心跳定时器
function GameScene:openHeartBeatUpdate()
    local function updateInline()
        self.net:sendHeartBeat(LuaCppAdapter:getInstance():getCurFrame());
    end
    self.heartBeatUpdateId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateInline, 2.0, false);
end

function GameScene:openTouchListener()
    local function onTouchBegan(touch, event)
        self.playerManager:onTouchBegan(touch, event);
        return true;
    end
    local function onTouchMoved(touch, event)
        self.playerManager:onTouchMoved(touch, event);
    end
    local function onTouchEnded(touch, event)
        self.playerManager:onTouchEnded(touch, event);
    end

    local function onTouchCancelled(touch, event)
        self.playerManager:onTouchCancelled(touch, event);
    end
    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self) 
end

function GameScene:onClickAddFishcoin( sender )
    print("-----onClickAddFishcoin------")

    local function showShop()
        self.uiShopLayer:showLayer()
        self.uiShopLayer:setShopType(1)
        self:packUpUI()
        if self.uiSetButton.isOpen then
            self.uiSetButton:setIsOpen();
        end
        if self.uiSkillView.isOpen then
            self.uiSkillView:setIsOpen();
        end
    end

    if self.uiSkillView.Skill_14:rechargeCheck(showShop) then
        return 
    end

    showShop()
end



--收起小面板
function GameScene:packUpUI( )
    print("-----packUpUI------")
    self.uiLotteryPanel:setIsOpen(false)
    if self.uiSetButton.isOpen == true then
        self.uiSetButton:onClickOpenlist(self.uiSetButton)
    end   

end

--秘籍面板
function GameScene:secretUseLayer(layer)
    local winSize = cc.Director:getInstance():getWinSize();
    local openSecretBt = nil;

    local function openSecretLayerFunc(pSender, eventName)
        if eventName == ccui.TouchEventType.ended then
            openSecretBt:setVisible(false);
            local secretLayer = cc.Layer:create();
            layer:addChild(secretLayer, 1999);
            local inputLayer = ccui.ImageView:create("common/layerbg/com_pic_infobg.png");
            inputLayer:setSwallowTouches(true);
            inputLayer:setScale9Enabled(true);
            inputLayer:setAnchorPoint(cc.p(0.5, 0.5))
            inputLayer:setPosition(cc.p(winSize.width*0.1, winSize.height*0.9));
            inputLayer:setContentSize(cc.size(200, 200));
            layer:addChild(inputLayer, 1888);

            local closeBt = ccui.Button:create("common/btn/com_btn_close_ex_0.png", "common/btn/com_btn_close_ex_1.png");
            closeBt:setScale9Enabled(true);
            closeBt:setContentSize(cc.size(60, 60));
            closeBt:setTitleFontSize(30);
            closeBt:setPosition(cc.p(inputLayer:getContentSize().width*0.8, inputLayer:getContentSize().height*0.78))
            closeBt:addTouchEventListener(function (pSender, eventName) if eventName == ccui.TouchEventType.ended then layer:removeChild(inputLayer); openSecretBt:setVisible(true); end end);
            inputLayer:addChild(closeBt);

            local propNumEdit = ccui.EditBox:create(cc.size(150 , 40 ), "we");
            propNumEdit:setPosition(cc.p(inputLayer:getContentSize().width/2, inputLayer:getContentSize().height*0.4));
            propNumEdit:setAnchorPoint(cc.p(0.5, 0.5))
            propNumEdit:setPlaceHolder("NUMBER")
            propNumEdit:setPlaceholderFontColor(cc.c3b(255, 100, 100))
            propNumEdit:setFontColor(cc.c3b(100, 100, 100))
            propNumEdit:setInputFlag(5);
            propNumEdit:setFontSize(25)
            propNumEdit:setPlaceholderFontSize(20)
            inputLayer:addChild(propNumEdit);

            local propIdEdit = ccui.EditBox:create(cc.size(150 , 40 ), "we");
            propIdEdit:setPosition(cc.p(inputLayer:getContentSize().width/2, inputLayer:getContentSize().height*0.6));
            propIdEdit:setAnchorPoint(cc.p(0.5, 0.5))
            propIdEdit:setPlaceHolder("ID")
            propIdEdit:setPlaceholderFontColor(cc.c3b(255, 100, 100))
            propIdEdit:setFontColor(cc.c3b(100, 100, 100))
            propIdEdit:setInputFlag(5);
            propIdEdit:setFontSize(25)
            propIdEdit:setPlaceholderFontSize(20)
            inputLayer:addChild(propIdEdit);

            local function sendSecretMessage(pSender, eventName)
                if eventName == ccui.TouchEventType.ended then
                    local num = tonumber(propNumEdit:getText());
                    local id = tonumber(propIdEdit:getText());
                    local data = {}
                    data.newProps = {}
                    local prop = {}
                    prop.propId = id;
                    prop.propCount = num;
                    table.insert(data.newProps,prop)
                    FishGI.gameScene.net:sendAddMoney(data)
                    FishGI.gameScene.net:sendReChargeSucceed()
                end
            end

            local addBt = ccui.Button:createInstance();
            addBt:setTitleText("add");
            addBt:setTitleFontSize(30);
            addBt:setTag(2);
            addBt:setPosition(cc.p(inputLayer:getContentSize().width/2, inputLayer:getContentSize().height*0.2))
            addBt:addTouchEventListener(sendSecretMessage);
            inputLayer:addChild(addBt);

            --[[local addMoneyBt = ccui.Button:createInstance();
            addMoneyBt:setTitleText("add Money");
            addMoneyBt:setTitleFontSize(15);
            addMoneyBt:setTag(1);
            addMoneyBt:setPosition(cc.p(inputLayer:getContentSize().width/2, inputLayer:getContentSize().height*0.1))
            addMoneyBt:addTouchEventListener(sendSecretMessage);
            inputLayer:addChild(addMoneyBt);]]--
        end
    end

    openSecretBt = ccui.Button:create("common/btn/com_btn_blue_0.png", "common/btn/com_btn_blue_1.png");

    openSecretBt:setTitleText("Secret");
    openSecretBt:setName("Secret");
    openSecretBt:setTitleFontSize(30);
    openSecretBt:addTouchEventListener(openSecretLayerFunc);
    openSecretBt:setPosition(cc.p(winSize.width*0.1, winSize.height*0.9));
    layer:addChild(openSecretBt, 1002);
end

function GameScene:buttonClicked(viewTag, btnTag)
    if viewTag == "SetButton" then 
        if btnTag == "exit" then 
            local dealed = self.uiSkillView.Skill_14:stopCheck(function ( ... )
                self:doExitGame()
            end)
            if dealed then
                return
            end

            local function callback(sender)
                local tag = sender:getTag()
                if tag == 2 then
                    self:doExitGame()
                end
            end   
            FishGF.showExitMessage(FishGF.getChByIndex(800000069),callback)
        end 
    end 
end

function GameScene:hideGunUpGradePanel()
    self.uiGunUpGrade:setVisible(false)
    self.uiLotteryPanel:setPosition(cc.p(0,450*self.scaleY_))
end

return GameScene;

