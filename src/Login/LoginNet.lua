local loginType = LOGIN_TYPE_NONE;  --//当前登录类型
local strLoginUserName = "";        --//最后登录的账号
local strNickName = "";             --//最后登录用户的昵称
local strLoginPassword = "";        --//最后登录的密码信息

local evt = {};

local LoginNet = FishGF.ClassEx("LoginNet", function()
	local obj =  CLoginManager.New()
	obj.event = evt;
	return obj;
end)

function LoginNet.create()
	local loginNet = LoginNet.new();
	if loginNet:Initialize() then
		return loginNet;
	else
		return nil
	end
	
end

function LoginNet:init( )
	self.serverIndex = 1
	self.autoLogin = false
	self.loginType = FishCD.LOGIN_TYPE_NONE
	self.strLoginUserName = ""
	self.userName = ""
	self.password = ""
end

function LoginNet:initServerConfig()
	self.serverIndex = 1;
	self.autoLogin = false;
end

function LoginNet:updateAccountPass(account, password)
	self.loginType = FishCD.LOGIN_TYPE_BY_NAME
	self.userName = account;
    self.password = password;
end

function LoginNet:DoAutoLogin()
	print("-------------DoAutoLogin-------------")
	self.autoLogin = true;
	if self.loginType == FishCD.LOGIN_TYPE_BY_NAME then
		--账号密码登录
		self:startConnect();
	elseif self.loginType == FishCD.LOGIN_TYPE_BY_THIRD_LOGIN then
		--第三方登陆
		self:loginByThird(self.thirdLoginInfo);
	else
		--快速登录
		self:VisitorLogin();
	end
	self.autoLogin = false;
end

function LoginNet:startConnect()
	if FishGI.serverConfig == nil or table.maxn(FishGI.serverConfig) == 0 then
		print("服务器配置表为空");
	else
		print("--------------------------startConnect");
		--弹出等待服务器返回的屏蔽层
		if not FishGI.isLogin then
			FishGF.waitNetManager(true,self.autoLogin and FishGF.getChByIndex(800000163) or nil,"startConnect")
			FishGI.isLogin = true
		end
		local serverInfo = FishGI.serverConfig[self.serverIndex];
		local isExist = cc.FileUtils:getInstance():isFileExist("accountlist.plist");
		if FishGI.serverConfig["url"] ~= nil then
			serverInfo.url = FishGI.serverConfig["url"];
		end
        print("server ip:"..serverInfo.url.." port:"..serverInfo.port);
		self:Reconnect(serverInfo.url, serverInfo.port);
	end
end

--通过账号密码登录
function LoginNet:loginByUserAccount(userName, password)
	FishGI.PLAYER_STATE = 1
    --检查用户名密码
    if userName ~= nil and password ~= nil and userName ~= "" and password ~= "" then
        self.loginType = FishCD.LOGIN_TYPE_BY_NAME;
        self.userName = userName;
        self.password = password;
        FishGF.setAccountAndPassword(userName,password,nil)
        self:startConnect();
    end
end

--[[
* @brief 使用游客账号登录
]]
function LoginNet:VisitorLogin()

    -- 找到本地存储的游客账号
    --local visitorUnname = cc.UserDefault:getInstance():getStringForKey("visitorUnname")
    -- if visitorUnname ~= nil and visitorUnname ~= "" then
    --     self:LoginByUnname( visitorUnname )
    --     return
    -- end

    local accountTab = FishGI.WritePlayerData:getEndData()
    if accountTab ~= nil and accountTab["account"] ~= "" and accountTab["isVisitor"] ~= nil then
    	--FishGF.setAccountAndPassword("","",accountTab["isVisitor"])
        self:LoginByUnname( accountTab["account"] )
        return
    end

    -- 没游客账号（分配）
    self:AllocNewUser()
end

--[[
* @brief 使用游客账号登录
* @param [in] session 游客账号会话ID
* @return 成功返回true
]]
function LoginNet:LoginByUnname( session )
    local accountTab = FishGI.WritePlayerData:getEndData()
    if accountTab ~= nil and accountTab["account"] ~= "" and accountTab["isVisitor"] ~= nil then
    	FishGF.setAccountAndPassword("","",accountTab["isVisitor"])
    end

	FishGI.PLAYER_STATE = 0
    self.strLoginUserName = session;
    self.loginType = FishCD.LOGIN_TYPE_BY_UNNAME;
    self:startConnect();
    return true;
end

--[[
* @brief 分配一个新的游客账号
* @param [in] strNickName 昵称
]]
function LoginNet:AllocNewUser( strNickName)

    if strNickName == nil or strNickName =="" then
        if IS_REVIEW_MODE then
            strNickName = "mobile";
        else
            strNickName = Helper.GetDeviceUserName();
        end
    end

    self.loginType = FishCD.LOGIN_TYPE_ALLOC_USER;
    self.userName = strNickName;
    self:startConnect();
end

--[[
* @brief 添加一个游客账号
* @param [in] session 游客会话ID，必须为32个16进制字符
]]
function LoginNet:AddRoleInfo(session,userfrom)
    assert(type(session)=="string" and #session==32,"无效的会话ID");
    --cc.UserDefault:getInstance():setStringForKey("visitorUnname",session)    
    local AccountTab = {}
    AccountTab["account"] = session
    AccountTab["password"] = nil
    AccountTab["isVisitor"] = FishGF.getChByIndex(800000176)..string.sub(session,1,8)
    FishGI.WritePlayerData:upDataAccount(AccountTab)

    --cc.UserDefault:getInstance():flush()
end

--登录失败提示
function LoginNet:OnLoginError(strMsg)
	FishGF.pring("---OnLoginError---strMsg="..strMsg)
	FishGF.waitNetManager(false,nil,"startConnect")
	FishGI.isLogin = false
    -- local function callback(sender)
    --     local tag = sender:getTag()
    --     if tag == 1 then
    --         local curScene = cc.Director:getInstance():getRunningScene()
    --         curScene.view:changeAccount();
    --     end
    -- end
    -- FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,strMsg,callback)
    FishGF.createCloseSocketNotice(strMsg,"OnLoginError")
end

--第三方登陆接口
function LoginNet:loginByThird(info)
	self.loginType = FishCD.LOGIN_TYPE_BY_THIRD_LOGIN;
	self.thirdLoginInfo = info
	FishGI.mainManagerInstance:createHallManager(info);
end

-----------------------------------------------evt事件表-------------------------
function evt.Initialize(login)
	print("login initialize");
	login:init()
	--读取服务器配置表
	login:initServerConfig();
	return true;
end

function evt.OnConnect(login, connected)
	print("login OnConnect");
	if connected then
		print("连接到服务器 index:"..login.serverIndex.."成功");

	else
		if login.serverIndex < table.maxn(FishGI.serverConfig) then
			print("尝试连接下一组服务器");
			login.serverIndex = login.serverIndex+1;
			login:startConnect();
		else
			local noDelList = {"doPaySDK"}
        	FishGF.clearSwallowLayer(noDelList)
			local curScene = cc.Director:getInstance():getRunningScene();
    		local sceneName = curScene.sceneName
			FishGI.connectCount = FishGI.connectCount +1
			if FishGI.connectCount < 5 then
				--在大厅帮玩家登陆
				FishGF.waitNetManager(true,nil,"startAllConnect")
				local  seq = cc.Sequence:create(cc.DelayTime:create(0.8),cc.CallFunc:create(function ( ... )
					FishGF.waitNetManager(false,nil,"startAllConnect")
					FishGI.loginScene.net:DoAutoLogin()
				end))
				curScene:runAction(seq)
				return 
			end
			if  FishGI.isLogin then
				FishGI.isLogin = false
				FishGI.connectCount = 0
				FishGF.createCloseSocketNotice(FishGF.getChByIndex(800000033),"LoginOnOnConnect")
			end
		end
	end
end

--登录服务器连接断开
function evt.OnSocketClose(obj,nErrorCode)
	print("login OnSocketClose")
	FishGF.waitNetManager(false,nil,"startConnect")
	FishGF.createCloseSocketNotice(FishGF.getChByIndex(800000070),"LoginOnSocketClose")
end

--登录服务器检测版本应答 发送登录请求
function evt.OnCheckVersion(obj,result)
	print("login OnCheckVersion")
	if not result then
		return;
	end
	print("obj.loginType:"..obj.loginType)
	if obj.loginType == FishCD.LOGIN_TYPE_BY_NAME then  
		obj:DispatchLoginByName(true,obj.userName,obj.password);
	elseif obj.loginType == FishCD.LOGIN_TYPE_BY_UNNAME then
		printf(obj.strLoginUserName);
		obj:DispatchLoginByUnName(IS_WEILE,obj.strLoginUserName);
	elseif obj.loginType == FishCD.LOGIN_TYPE_ALLOC_USER then
		print("OnCheckVersion:LOGIN_TYPE_ALLOC_USER")
		strNickName = Helper.GetDeviceUserName();
		obj:DispatchAllocUser(strNickName,1,IS_WEILE,APP_ID,CHANNEL_ID);
	end
end

--[[
* @brief 登录成功应答
* @param [in] obj 产生事件的对象，这里是CLoginManager的对象
* @param [in] session 连接大厅放服务器的会话ID
* @param [in] userid 用户ID
* @param [in] serverip 大厅服务器IP地址（整型）
* @param [in] serverport 大厅服务器端口
]]
function evt.OnMsgLoginReply(obj,session,userid,serverip,serverport)
	print("login OnMsgLoginReply")
	local valTab = {}
	valTab.session = session
	valTab.userid = userid
	valTab.serverip = serverip;
	
	valTab.serverport = serverport
	FishGI.mainManagerInstance:createHallManager(valTab);
end

--[[
* @brief 登录失败
* @param [in] obj 产生事件的对象，这里是CLoginManager的对象
* @param [in] result 登录失败原因
]]
function evt.OnMsgLoginFailed( obj,result)
    print("login OnMsgLoginFailed")
    local msgs= {"登录失败，账号或者密码错误",
	"登录失败，账号或者密码错误",
	"登录失败，帐号已经登录！",
	"登录失败，该帐号已经绑定其它机器！",
	"登录失败，该帐号被锁，请与管理员联系",
	"登录失败，服务器忙，请稍后尝试！",
	"登录失败，您尝试的错误次数太多，暂时无法登录",
	"登录失败，您需要输入验证码!",
	"登录失败，验证码已过期或者不存在",
	"登录失败，验证码不正确"};
	FishGF.print("login failed result:"..result);
    print(msgs[result] or "登录失败，未知错误,请与管理员联系");
	
    FishGF.waitNetManager(false,nil,"startConnect")
	FishGI.isLogin = false
    -- local function callback(sender)
    --     local tag = sender:getTag()
    --     if tag == 1 then
    --         --FishGI.showLayerData:hideLayer(sender:getParent():getParent():getParent(),true) 
    --         local curScene = cc.Director:getInstance():getRunningScene()
    --         curScene.view:changeAccount();
    --     end
    -- end   
    -- FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,msgs[result] or FishGF.getChByIndex(800000034)..result,callback) 
	FishGF.createCloseSocketNotice(msgs[result] or FishGF.getChByIndex(800000034)..result,"OnMsgLoginFailed")
end

--[[
* @brief 请求分配游客帐号应答
* @param [in] obj 产生事件的对象，这里是CLoginManager的对象
* @param [in] result 分配结果，为０为成功
* @param [in] session 游客会话id
]]
function evt.OnMsgAllocRoleReply( obj,result,session )

    if result and result>0 then
        --GameApp:dispatchEvent(gg.Event.SHOW_MESSAGE_DIALOG,"游客登录失败，请稍后重试!")
    else
        obj:AddRoleInfo(session);
        obj:LoginByUnname(session);
    end   
end


--[[
* @breif 登录服务器附带消息
* @param [in] obj 产生事件的对象，这里是CLoginManager的对象
* @param [in] bUrl 消息内容是否是url
* @param [in] msg 如果bUrl是true,则msg为网址，应该用浏览器打开，否则是消息内容
]]
function evt.OnMsgLoginMessage(obj,bUrl,msg)
    print("login OnMsgLoginMessage")
end

return LoginNet;