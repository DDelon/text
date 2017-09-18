local UpDateScene = class("UpDateScene", function() 
	return cc.Scene:create()
end);

function UpDateScene.create(urlkey, appid, channelid, version)
	local scene = UpDateScene.new();
	scene:init(urlkey, appid, channelid, version);
	return scene;
end

function UpDateScene:getHotUpdatrUrl(appid, channelid, version)
	version = version or HALL_WEB_VERSION
    local a_id = "/" .. appid
    local c_id = "/" .. channelid
    local verstr="/"..table.concat(version,".")
    local preStr = PREFIX_DOMAIN;
    local up_url = "http://client."..WEB_DOMAIN .. "/update"..a_id..c_id..verstr.. "/" .. Helper.GetDeviceCode()
    return up_url;
end

function UpDateScene:initUIWithBuyu()
	self.view = require("Update/hotUpdate/UpDate").create();
	self:addChild(self.view);

	--大版本更新界面
	self.uiBigUpDate = require("Update/bigUpdate/BigUpDate").create();
	self.uiBigUpDate:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
	self:addChild(self.uiBigUpDate);
	self.uiBigUpDate:setVisible(false)
end

function UpDateScene:initUIWithChildGame()
	self.view = require("Update/hotUpdate/ChildGameUpdate").create();
	self:addChild(self.view);


end

function UpDateScene:init(urlkey, appid, channelid, version)
	
	--
	self.appid = appid or APP_ID;
	self.channelid = channelid or CHANNEL_ID;
	self.version = version;


    FishGI.AudioControl:pauseMusic()

	self.oldKey = URLKEY;
	URLKEY = urlkey;
	local function getChannelId()
	    if device.platform == "android" then
	        local luaBridge = require("cocos.cocos2d.luaj");
	        local javaClassName = "com.weile.api.NativeHelper";
	        local javaMethodName = "getChannelId";
	        local javaParams = {
	            "asdawdwad"
	        }
	        local javaMethodSig = "(Ljava/lang/String;)I";
	        local ok, ret = luaBridge.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig);
	        return ret;
	    end
	end
	
	if device.platform == "android" then
		CHANNEL_ID = getChannelId()
	end

	self.update = require("Update/UpdateModule/Update").create();

	if appid == "263" or appid == "264" then
		self:initUIWithBuyu();
	else
		self:initUIWithChildGame();
	end

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

	--注册热更新模块所需的监听器
	self.listener = {}
	local updateCompelteListener=cc.EventListenerCustom:create("updateComplete",handler(self, self.updateFinish))  
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(updateCompelteListener, 2)
	table.insert(self.listener, updateCompelteListener)

	local updateErrorListener=cc.EventListenerCustom:create("updateError",handler(self, self.checkVersionRetry))  
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(updateErrorListener, 2)
	table.insert(self.listener, updateErrorListener)

	local updateNoticeListener=cc.EventListenerCustom:create("updateNotice",handler(self, self.showUpdateDialog))  
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(updateNoticeListener, 2)
	table.insert(self.listener, updateNoticeListener)

	local beginDownloadListener=cc.EventListenerCustom:create("beginDownload",handler(self, self.openUpdateUI))  
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(beginDownloadListener, 2)
	table.insert(self.listener, beginDownloadListener)

	local updateNoticeListener=cc.EventListenerCustom:create("updating",handler(self, self.updateViewPercent))  
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(updateNoticeListener, 2)
	table.insert(self.listener, updateNoticeListener)
	

	
end

function UpDateScene:onEnter()
	self:checkVersion();
end

function UpDateScene:checkVersion()
	print("check version")
	local event = cc.EventCustom:new("startUpdate")
    event._userdata = {url = self:getHotUpdatrUrl(self.appid, self.channelid, self.version)}
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function UpDateScene:checkVersionRetry()

	--清除更新任务
	local event = cc.EventCustom:new("cleanUpdate")
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

	local function callback(sender)
        local tag = sender:getTag()
        if tag == 2 then
        	--ok
            self:checkVersion();
        elseif tag == 3 then
        	os.exit(0);
        end
    end
    FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,"版本检测失败，请重试！",callback)

end

function UpDateScene:showUpdateDialog(evt)

	local data = evt._userdata;
	local version = data.version;
	local notice = data.notice;
	local func = data.callback;


	local function wifiTips()
		local isWifiConnect = FishGF.isWifiConnect()
		if isWifiConnect then
			func()
		else
			local function callback(pSender)
				local tag = pSender:getTag()
                if tag == 2 then
                    func()
				else
					os.exit(0);
                end
			end
			FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,"您当前网络环境为非WIFI模式，是否使用流量继续下载更新资源？",callback);
		end
	end
	local version = version;
	local updateMsg = notice;

	self.uiBigUpDate:setVisible(true)
	self.uiBigUpDate:setCurVersions(version);
	self.uiBigUpDate:setVersionsData(updateMsg);
	self.uiBigUpDate:setUpdateFunc(wifiTips);
end

function UpDateScene:openUpdateUI()
	print("open update ui")
	self.view:isCheckVer(false);
	--self.uiBigUpDate:setVisible(true)
end

function UpDateScene:updateViewPercent(evt)
	local data = evt._userdata
	local cur = data.cur
	local all = data.total
	local speed = data.speed
	local progress = data.progress
	self.view:receiveData(cur,all,speed);
end

function UpDateScene:updateFinish()

	self.view:loadingEnd();
	self.view = nil;

	cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners("updateComplete");
	cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners("updateError");
	cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners("updateNotice");
	cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners("beginDownload");
	cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners("updating");
	self.update = nil;
	
end

function UpDateScene:reloadFiles()
	cc.exports.FishGI = nil;
	cc.exports.FishGF = nil;
	cc.exports.FishCD = nil;
	package.loaded["Other/LoadFile"] = nil;
	package.loaded["GlobalCom/ConstantDef"] = nil;
	package.loaded["GlobalCom/GlobalFunc"] = nil;
	package.loaded["GlobalCom/GameFunc"] = nil;
	package.loaded["GlobalCom/GlobalInstance"] = nil;
	package.loaded["Other/NetMessage"] = nil;
	package.loaded["Other/LoadFile"] = nil;
	cc.FileUtils:getInstance():purgeCachedEntries();
end

function UpDateScene:runNextScene()
	if self.appid == "263" or self.appid == "264" then
		LuaCppAdapter:getInstance():loadDataBin();
		self:reloadFiles();
		require("Other/LoadFile");
		FishGI.mainManagerInstance:createLoginManager();

		if FishGF.isThirdSdk() and FishGF.isThirdSdkLogin() then
			local function loginResult(state, data)
				print("------------------------loginResult")
				FishGF.waitNetManager(false);
				if state then
					FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,"解析错误！",nil)
				else
					local resultMsg = nil;
					local ok, datatable = pcall(function() return loadstring(data)(); end)
					if ok == false then
						resultMsg = json.decode(data)
					else
						resultMsg = {}
						resultMsg.data = datatable
					end
					local resultData = resultMsg.data
					local valTab = {};
					valTab.session = resultData.code
					valTab.userid = resultData.id
					valTab.serverip = resultData.ip
					valTab.serverport = resultData.port
					FishGI.loginScene.net:loginByThird(valTab);
				end
			end
			FishGI.GameCenterSdk:trySDKLogin({type = 1},loginResult)
		end

		URLKEY = self.oldKey
	else
		
		URLKEY = self.oldKey
		cc.Director:getInstance():popScene()
		FishGF.enterGameGtsp()
	end
end
return UpDateScene;