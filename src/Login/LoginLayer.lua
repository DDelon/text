
local LoginLayer = class("LoginLayer", cc.load("mvc").ViewBase)

LoginLayer.AUTO_RESOLUTION   = true
LoginLayer.RESOURCE_FILENAME = "ui/login/uiloginlayer"
LoginLayer.RESOURCE_BINDING  = {  
    ["btn_start"]        = { ["varname"] = "btn_start" ,        ["events"]={["event"]="click",["method"]="onClickStart"}},  
    ["btn_close"]        = { ["varname"] = "btn_close" ,        ["events"]={["event"]="click",["method"]="onClickClose"}},
    ["spr_logo"]         = { ["varname"] = "spr_logo"  },   
    ["spr_login_bg"]     = { ["varname"] = "spr_login_bg"  },
    
    ["btn_accountstart"] = { ["varname"] = "btn_accountstart" , ["events"]={["event"]="click",["method"]="onClickaccountstart"}},
    ["btn_openlist"]     = { ["varname"] = "btn_openlist" ,     ["events"]={["event"]="click",["method"]="onClickopenlist"}},
    
    ["text_account"]     = { ["varname"] = "text_account"  },
    
    ["image_account_bg"] = { ["varname"] = "image_account_bg"  },    
    
    ["text_notice"]      = { ["varname"] = "text_notice"  },    
    ["text_ver"]         = { ["varname"] = "text_ver"  },
    ["btn_qq"]           = { ["varname"] = "btn_qq" ,           ["events"]={["event"]="click",["method"]="onClickqq"}},
    ["btn_wechat"]       = { ["varname"] = "btn_wechat" ,       ["events"]={["event"]="click",["method"]="onClickwechat"}},
    
    ["btn_retrieve"]     = { ["varname"] = "btn_retrieve" ,     ["events"]={["event"]="click",["method"]="onClickretrieve"}},
    
}

function LoginLayer:onCreate(...)
    self.text_notice:setString(FishGF.getChByIndex(800000017))
    self.text_notice:setScale(self.scaleMin_)
    local ver = "Ver"..table.concat(require("version"),".").."("..CHANNEL_ID..")";
    self.text_ver:setString(ver)
    self.text_ver:setScale(self.scaleMin_)

    self.uiChangeAccount = require("Login/ChangeAccount").create()
    self.uiChangeAccount:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiChangeAccount,1000)
    self.uiChangeAccount:setVisible(false)
    self.uiChangeAccount:setScale(self.scaleMin_)

    self.uiLoginNode = require("Login/LoginNode").create()
    self.uiLoginNode:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiLoginNode,1000)
    self.uiLoginNode:setVisible(false)
    self.uiLoginNode:setScale(self.scaleMin_)

    local accountTab = self.uiChangeAccount:getEndAccount()
    local count = FishGI.WritePlayerData:getMaxKeys()
    if accountTab == nil or (count == 1 and accountTab["isVisitor"] ~= nil )then
        self.text_account:setString("")
        self.image_account_bg:setVisible(false)
        self.btn_accountstart:setPositionY(cc.Director:getInstance():getWinSize().height*0.23)
        self.btn_start:setPositionY(cc.Director:getInstance():getWinSize().height*0.23)
    else
        local account = accountTab["account"]
        local isVisitor = accountTab["isVisitor"]
        if isVisitor ~= nil then
             account = isVisitor
        end
        self.text_account:setString(account)
        self.image_account_bg:setVisible(true)
    end
    
    FishGI.myData = nil

    local function onKeyboardFunc(code, event)
        if code == cc.KeyCode.KEY_BACK then
            FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
            if FishGF.isThirdSdk() and FishGF.isThirdSdkExit() then
                local closeCallback = function ( jsons )
                    log("exit game:" .. jsons)
                    local result = json.decode(jsons)
                    if CHANNEL_ID == CHANNEL_ID_LIST.qihu or CHANNEL_ID == CHANNEL_ID_LIST.baidu then
                        local tag = tonumber(result.resultMsg)
                        if tag == 2 then
                            os.exit(0);
                        end
                    else
                        local code = tonumber(result.resultCode)
                        if code == 0 then
                            os.exit(0);
                        end
                    end
                end

                FishGI.GameCenterSdk:trySDKGameExit({}, closeCallback)

                return
            end

            local function callback(sender)
                local tag = sender:getTag()
                if tag == 2 then
                    os.exit(0);
                end
            end   
            FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,FishGF.getChByIndex(800000139),callback)
        end
    end
    local listener = cc.EventListenerKeyboard:create();
    listener:registerScriptHandler(onKeyboardFunc, cc.Handler.EVENT_KEYBOARD_RELEASED);
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);

    if CHANNEL_ID == CHANNEL_ID_LIST.yyb then
        self.btn_wechat:setVisible(true)
        self.btn_qq:setVisible(true)
        self.btn_start:setVisible(false)
        self.btn_accountstart:setVisible(false)
        self.btn_wechat:setPositionY(cc.Director:getInstance():getWinSize().height*0.23)
        self.btn_qq:setPositionY(cc.Director:getInstance():getWinSize().height*0.23)
    elseif CHANNEL_ID == CHANNEL_ID_LIST.huawei then
        self.btn_accountstart:setVisible(false)
        self.btn_retrieve:setVisible(false)

        self.btn_start:setPosition(cc.Director:getInstance():getWinSize().width*0.5, cc.Director:getInstance():getWinSize().height*0.26)

        self.btn_wechat:setVisible(false)
        self.btn_qq:setVisible(false)
    else
        self.btn_wechat:setVisible(false)
        self.btn_qq:setVisible(false)
        self.btn_start:setVisible(true)
        self.btn_accountstart:setVisible(true)
    end
    if FishGF.isThirdSdk() and FishGF.isThirdSdkLogin() then
        self.btn_retrieve:setVisible(false)
    end

    local isWifi = FishGF.isWifiConnect();
    if isWifi then
        print("---------------------------------wifi connect");
    end
end

function LoginLayer:onEnter( )
    -- if FishGI.GAME_STATE ~= 2 then
    --     FishGI.AudioControl:playLayerBgMusic()
    -- end
    FishGI.isLogin = false
    FishGI.AudioControl:playLayerBgMusic()
    FishGI.CIRCLE_COUNT = 0
    FishGMF.setGameState(1)
    FishGI.myData = nil
    FishGI.isEnterBg = false
    FishGI.FRIEND_ROOM_STATUS = 0
    FishGI.FRIEND_ROOMID = nil
    FishGI.IS_RECHARGE = 0

    if device.platform == "android" then
    local luaBridge = require("cocos.cocos2d.luaj");
    local javaClassName = "org.cocos2dx.lib.Cocos2dxEditBoxHelper";
    local javaMethodName = "openKeyboard";
    local javaParams = {
    1001
    }
    local javaMethodSig = "(I)V";
    local ok = luaBridge.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig);
    end

    --移除监听器
    FishGI.eventDispatcher:removeAllListener();
	if device.platform == "android" or device.platform == "ios" then
		cc.Device:setKeepScreenOn(true);
	end
end

function LoginLayer:setNet(net)
    self.net = net;
end
 
function LoginLayer:onClickStart( sender )
    if (bit.band(FUN_SWITCH, 2) == 2 and true or false) then
        --服务器正在维护
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,"服务器正在维护中!",nil);
        return;
    end
    if FishGF.isThirdSdk() and FishGF.isThirdSdkLogin() then
        local function loginResult(state, data)
            log("loginResult")
            log(state, data)
            FishGF.waitNetManager(false);
            if state then
                FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,"解析失败",nil)
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
        print("third log----------------------------")
        FishGF.waitNetManager(true)
        FishGI.GameCenterSdk:trySDKLogin({type = 1},loginResult)
        return
    end

    local accountTab = FishGI.WritePlayerData:getEndData()
    if accountTab == nil or accountTab["isVisitor"] ~= nil then
        log("isVisitor")
        self.net:VisitorLogin()
    else
        local password = accountTab["password"]
        local account = accountTab["account"]
        if FishGF.checkAccount(account) and FishGF.checkPassword(password) then
            self.net:loginByUserAccount(account, password);
        end
    end
end

function LoginLayer:onClickaccountstart( sender )
    if (bit.band(FUN_SWITCH, 2) == 2 and true or false) then
        --服务器正在维护
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,"服务器正在维护中!",nil);
        return;
    end
    if FishGF.isThirdSdk() and FishGF.isThirdSdkLogin() then
        local function loginResult(state, data)
            FishGF.waitNetManager(false)
            if state then
                FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,"解析失败",nil)
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
        FishGF.waitNetManager(true)
        FishGI.GameCenterSdk:trySDKLogin({type = 2},loginResult)
        return
    end

    local accountTab = FishGI.WritePlayerData:getEndData()
    if accountTab ~= nil then
        self.uiLoginNode:setAccountData(accountTab)
    end

    self.uiLoginNode:showLayer() 
end

function LoginLayer:changeAccount( )
    local accountTab = FishGI.WritePlayerData:getEndData()
    if accountTab ~= nil then
        self.uiLoginNode:setAccountData(accountTab)
    end

    self.uiLoginNode:showLayer() 
end

function LoginLayer:onClickopenlist( sender )
    self.uiChangeAccount:showLayer() 
end

function LoginLayer:onClickClose( sender )
    if FishGF.isThirdSdk() and FishGF.isThirdSdkExit() then
        local closeCallback = function ( jsons )
            log("exit game:" .. jsons)
            local result = json.decode(jsons)
            if CHANNEL_ID == CHANNEL_ID_LIST.qihu or CHANNEL_ID == CHANNEL_ID_LIST.baidu then
                local tag = tonumber(result.resultMsg)
                if tag == 2 then
                    os.exit(0);
                end
            else
                local code = tonumber(result.resultCode)
                if code == 0 then
                    os.exit(0);
                end
            end
        end

        FishGI.GameCenterSdk:trySDKGameExit({}, closeCallback)

        return
    end

    local function callback(sender)
        local tag = sender:getTag()
        if tag == 2 then
            os.exit(0);
        end
    end   
    FishGF.showExitMessage(FishGF.getChByIndex(800000139),callback)
end

function LoginLayer:onClickqq( sender )
    print("--onClickqq---")

    if FishGF.isThirdSdk() and 
        FishGI.GameCenterSdkBase.ChannelInfoList[FishGI.GameCenterSdkBase.ChannelIdList[CHANNEL_ID]][FishGI.GameCenterSdkBase.ChannelInfoIndex.is_need_login] then
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


end

function LoginLayer:onClickwechat( sender )
    print("--onClickwechat---")


    if FishGF.isThirdSdk() and 
        FishGI.GameCenterSdkBase.ChannelInfoList[FishGI.GameCenterSdkBase.ChannelIdList[CHANNEL_ID]][FishGI.GameCenterSdkBase.ChannelInfoIndex.is_need_login] then
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
        FishGI.GameCenterSdk:trySDKLogin({type = 2},loginResult)
    end

end

function LoginLayer:onClickretrieve( sender )
    print("--onClickretrieve---")
    --FishGI.GameTableData:getRechargeTable(1)
    cc.Application:getInstance():openURL("http://ii.weile.com/forgot/password/");
end


return LoginLayer;
