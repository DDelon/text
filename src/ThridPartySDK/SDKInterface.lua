local SDKInterface = class("SDKInterface")



SDKInterface.ChannelIdList = {}
for i, v in pairs(CHANNEL_ID_LIST) do
    SDKInterface.ChannelIdList[v] = i
end

SDKInterface.ChannelInfoIndex = {
    -- 渠道中文名
    channel_name = 1,
    -- app id
    app_id = 2,
    -- app key
    app_key = 3,
    -- app secret
    app_secret = 4,
    -- 包名
    package_name = 5,
    -- 签名
    package_sign = 6,
    -- 微信ID
    wechat_id = 7,
    -- lua文件名
    lua_file_name = 8, 
    -- 充值订单请求字段
    pay_order_req_type = 9,
    -- 是否需要登录
    is_need_login = 10,
    -- 是否需要退出
    is_need_exit = 11,
}

SDKInterface.ChannelInfoList = {
    baidu = {
        "百度",
        "9331288",
        "QfOmaPHj0bwWTvp3l6A1akjE",
        "z5YwYEIpZ4FRGKVQbGwxGQiyLG36rFLL",
        "weile.buyu.game.baidu",
        "88d90cfb31eb73411a999976f7202b4e",
        "wx6b53067ef087b992",
        "baidu",
        "baidu",
        false,
        true,
    },
    mi = {
        "小米",
        "2882303761517552128",
        "5321755239128",
        "/LHwtfSDcDgzbJdrXUkIsw==",
        "weile.buyu.game.mi",
        "88d90cfb31eb73411a999976f7202b4e",
        "wxb37194c1fff8c9e8",
        "mi",
        "mi",
        true,
        false,
    },
    oppo = {
        "oppo",
        "3560766",
        "9Fyr4EqaKaGwso4Cg4S08gw0G",
        "2bDd850cfa83f9fCf398FD6ab5Df9692",
        "weile.buyu.game.nearme.gamecenter",
        "88d90cfb31eb73411a999976f7202b4e",
        "wxfbe64adcae8cc0b8",
        "oppo",
        "oppo",
        true,
        true,
    },
    qihu = {
        "360",
        "203518846",
        "13102cd31e1a21a08b71a0ea78c595c5",
        "6e5b8dc23e4c0de12d822d496b20140e",
        "weile.buyu.game.sll",
        "88d90cfb31eb73411a999976f7202b4e",
        "wxb10734b802896935",
        "qihu",
        "360",
        true,
        true,
    },
    vivo = {
        "vivo",
        "fcedf09d51f2566c0f856ba02d3b9a9d",
        "a264c6b3794e17c8db24164b1acebd82",
        "",
        "com.jxhd.weile.buyu.vivo",
        "88D90CFB31EB73411A999976F7202B4E",
        "wx00a3f6a1ef59558d",
        "vivo",
        "vivo",
        false,
        true,
    },
    huawei = {
        "huawei",
        "10913329",
        "",
        "",
        "weile.buyu.game.huawei",
        "88D90CFB31EB73411A999976F7202B4E",
        "wx00a3f6a1ef59558d",
        "huawei",
        "huawei",
        true,
        false,
    },
    jinli = {
        "jinli",
        "",
        "",
        "",
        "weile.buyu.game.jinli",
        "88D90CFB31EB73411A999976F7202B4E",
        "wxb621d8ee3a4f3949",
        "jinli",
        "jinli",
        false,
        false,
    },
    lenovo = {
        "lenovo",
        "1706150203632.app.ln",
        "",
        "",
        "weile.buyu.game.lenovo",
        "88D90CFB31EB73411A999976F7202B4E",
        "wxec7c9af3f6c58f83",
        "lenovo",
        "lenovo",
        true,
        true,
    },
    yyb = {
        "应用宝",
        "",
        "",
        "",
        "com.tencent.tmgp.weile.buyu",
        "88d90cfb31eb73411a999976f7202b4e",
        "wxcdb27c947b7d066e",
        "yyb",
        "midas",
        true,
        false,
    }
}

local luaj = require("cocos.cocos2d.luaj")

function SDKInterface:trySDKLogin(info, loginCB)
    assert("渠道登录接口未实现！")
    return true
end

function SDKInterface:doSDKLogout(info, logoutCB)
    self:doLogout(info, logoutCB)
    return true
end

function SDKInterface:trySDKPay(payAmountTab, payCB)
    assert("渠道支付接口未实现！")
    return true
end

function SDKInterface:trySDKGameExit(info, exitCallback)
    assert("推出游戏接口未实现!")
    return false
end

function SDKInterface:commitParam(paramTab, commitCB)
    return true
end

--发起第三方登陆请求

function SDKInterface:callGcsdkBaseStaticMethod(strMothodName, javaParams, javaMethodSig)
    local javaClassName = "com.weile.gcsdk.GameCenterBase"
	local javaMethodName = strMothodName
    local isOk, ret = luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig);
    if not isOk then
        print("Can't find method "..javaMethodName)
    end
end

function SDKInterface:callGcsdkStaticMethod(strMothodName, javaParams, javaMethodSig)
    local javaClassName = "com.weile.gcsdk.GameCenter"
	local javaMethodName = strMothodName
    local isOk, ret = luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig);
    if not isOk then
        print("Can't find method "..javaMethodName)
    end
end

function SDKInterface:loadGcsdk(strName, iType)
    print("loadGcsdk")
    local jClassName = "com/weile/gcsdk/"..strName
    local javaParams = {
        iType,
		jClassName
	}
    local javaMethodSig = "(ILjava/lang/String;)V";
    self:callGcsdkBaseStaticMethod("loadPlugin", javaParams, javaMethodSig)
end

function SDKInterface:initGcsdk()
    if FishGF.isThirdSdkLogin() then 
        self:loadGcsdk("Login", 1)
    end 
    self:loadGcsdk("Pay", 2)
end

function SDKInterface:doLogin(argsTab, loginCB)
    log("doLogin")
    self:doImplBase("doLogin", argsTab, loginCB)
end

function SDKInterface:doLogout(argsTab, logoutCB)
    log("doLogout")
    self:doImplBase("doLogout", argsTab, logoutCB)
end

function SDKInterface:doPay(argsTab, payCB)
    log("doPayForProduct")
    self:doImplBase("doPayForProduct", argsTab, payCB)
end

function SDKInterface:doGameExit(argsTab, logoutCB)
    log("doGameExit")
    self:doImplBase("doGameExit", argsTab, logoutCB)
end


function SDKInterface:doImplBase(sFunc, argsTab, cb)
	local jsonStr = json.encode(argsTab);
	local javaParams = {
        jsonStr,
        cb
	}
	local javaMethodSig = "(Ljava/lang/String;I)I"
    self:callGcsdkBaseStaticMethod(sFunc, javaParams, javaMethodSig)
end

function SDKInterface:doImpl(sFunc, argsTab, cb)
	local jsonStr = json.encode(argsTab);
	local javaParams = {
        jsonStr,
        cb
	}
	local javaMethodSig = "(Ljava/lang/String;I)I"
    self:callGcsdkStaticMethod(sFunc, javaParams, javaMethodSig)
end

function SDKInterface:getClassField(iType, strFieldName)
	local javaParams = {
		strFieldName
	}
	local javaMethodSig = "(ILjava/lang/String;)Ljava/lang/String;"
    self:callGcsdkBaseStaticMethod("getClassField", javaParams, javaMethodSig)
end

function SDKInterface:getPayCallBackUrl( channel )
    local ver_str = FishGF.getHallVerison()
    return string.format("http://thirdpay.%s/callback/%s/%s/%s/%s/%s", WEB_DOMAIN, channel, APP_ID, CHANNEL_ID, ver_str, REGION_CODE)
end

return SDKInterface