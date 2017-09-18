local LoginManager = class("LoginManager", function()
	return cc.Scene:create();
end)

function LoginManager.create()
	local manager = LoginManager.new();
	manager:init();
	return manager;
end

function LoginManager:onEnter()
    if FishGI.isTestAccount then
        local function callback(sender)
        
        end
        FishGF.showMessageLayer(FishCD.MODE_MIN_OK_ONLY,FishGF.getChByIndex(800000312),callback);
        --FishGF.showMessageLayer(FishCD.MODE_MIN_OK_ONLY,"测试号码已加入黑名单 无法进入游戏")
        FishGI.isTestAccount = false;
    end
    print("show message")
    local noDelList = {"doPaySDK"}
    FishGF.clearSwallowLayer(noDelList)
end

function LoginManager:init()
    self.sceneName = "login"
	--创建视图 创建网络
	local loginNet = require("Login/LoginNet").create();
	local loginLayer = require("Login/LoginLayer").create();
	if loginNet ~= nil then
		loginLayer:setNet(loginNet)
		loginLayer:setName("loginLayer")
	end

	self:addChild(loginLayer);
	self.view = loginLayer;
	self.net = loginNet;
    --FishGF.clearSwallowLayer()
    
	self:registerEnterBFgroundEvt()

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
end

function LoginManager:registerEnterBFgroundEvt()
    --进入前台
    local function onAppEnterForeground()
        print("___LoginManager____enter");
        FishGI.AudioControl:playLayerBgMusic()
        if self.isEnterBg == false then
            return;
        end
    end

    --进入后台
    local function onAppEnterBackground()
        print("___LoginManager____back");
        self.isEnterBg = true
    end

    local eventDispatcher = self:getEventDispatcher()
    local forelistener = cc.EventListenerCustom:create("applicationWillEnterForeground", onAppEnterForeground)
    eventDispatcher:addEventListenerWithSceneGraphPriority(forelistener, self)
    local backlistener = cc.EventListenerCustom:create("applicationDidEnterBackground", onAppEnterBackground)
    eventDispatcher:addEventListenerWithSceneGraphPriority(backlistener, self)
	
end

function LoginManager:decode()
end

return LoginManager;
