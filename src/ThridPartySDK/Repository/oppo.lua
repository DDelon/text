local OppoSDKInterface = class("OppoSDKInterface", FishGI.GameCenterSdkBase)

--[[

Java 方法原型:
public static void doPay(final int payAmount, int cbId)

Java 方法原型:
public static void doLogin()

-- Java 类的名称
local className = "weile/buyu/game/AppActivity"
-- 调用 Java 方法
luaj.callStaticMethod(className, "doBilling", args)

]]

function OppoSDKInterface:trySDKLogin(info, loginCB)
    local function callBackGetTokenAndSsoidResult( strJson )
        print("--------callBackGetTokenAndSsoidResult", strJson)
        local resultTab = LIB_CJSON.decode(strJson)
        local resultMsg = LIB_CJSON.decode(resultTab.resultMsg)
		FishGF.waitNetManager(true)
        FishGI.Dapi:thirdLogin("oppo", resultMsg, loginCB)
    end
    local function callBackDoLogin( strJson )
        self:doGetTokenAndSsoid(callBackGetTokenAndSsoidResult)
    end

    self:doLogin(info, callBackDoLogin)
    return true
end

function OppoSDKInterface:doSDKLogout(info, logoutCB)
    self:doLogout(info, logoutCB)
    return true
end

function OppoSDKInterface:trySDKGameExit(info, exitCallback)
    self:doGameExit(info, exitCallback)
    return true
end

function OppoSDKInterface:trySDKPay(payArgs, payCB)
    local payInfo = {}
    payInfo.order = payArgs.orderid
    payInfo.amount = payArgs.money
    payInfo.productName = payArgs.subject
    payInfo.productDesc = payArgs.body
    payInfo.callbackurl = self:getPayCallBackUrl("oppo")
    --{"goods":830000001,"token":"f0c7f383eb261b4cb6ad16adf228ff17","msg":"done","ingame":1,"body":"鱼币 830000001 x1","roomid":0,"callbackurl":"https://payback.weile.com/callback/alipay/264/207/1.1.5/0/","status":0,"money":600,"udid":"C2D6AFB6F8CC68D6371D91C175AA3FBA4A9A9596","subject":"30000鱼币","type":"alipay_client","ext":{"partner":"2088221603340274","email":"jiaxianghudong@weile.com"},"debug":1,"orderid":"1704274949026739","virtual":0,"autobuy":1}
    self:doPay(payInfo, payCB)
    return true
end

function OppoSDKInterface:doGetTokenAndSsoid(loginCB)
    self:doImpl("doGetTokenAndSsoid", {}, loginCB)
    return true
end

function OppoSDKInterface:doGetUserInfo(loginCB)
    self:doImpl("doGetUserInfo", {}, loginCB)
    return true
end

function OppoSDKInterface:doReportUserGameInfoData(loginCB)
    local tGameInfo = {}
    tGameInfo.gameId = tostring(GAME_ID)
    tGameInfo.service = ""
    tGameInfo.role = ""
    tGameInfo.grade = ""
    self:doImpl("doReportUserGameInfoData", tGameInfo, loginCB)
    return true
end

function OppoSDKInterface:doGetVerifiedInfo(loginCB)
    self:doImpl("doGetVerifiedInfo", {}, loginCB)
    return true
end

--退出房间
function OppoSDKInterface:doGameExit(argsTab, exitCallback)
    self:doImpl("doGameExit", argsTab, exitCallback)
end

return OppoSDKInterface