local LenovoSDKInterface = class("LenovoSDKInterface", FishGI.GameCenterSdkBase)

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

function LenovoSDKInterface:trySDKLogin(info, loginCB)
    local function callBackDoLogin( strJson )
        print("--------callBackDoLogin", strJson)
        local resultTab = LIB_CJSON.decode(strJson)
        local resultMsg = {}
        resultMsg.token = resultTab.resultMsg
		FishGF.waitNetManager(true)
        FishGI.Dapi:thirdLogin("lenovo", resultMsg, loginCB)
    end
    self:doLogin(info, callBackDoLogin)
    return true
end

function LenovoSDKInterface:doSDKLogout(info, logoutCB)
    self:doLogout(info, logoutCB)
    return true
end

function LenovoSDKInterface:trySDKGameExit(info, exitCallback)
    self:doGameExit(info, exitCallback)
    return true
end

function LenovoSDKInterface:trySDKPay(payArgs, payCB)
    local tWaresidList = {}
    tWaresidList["830000001"] = 148920
    tWaresidList["830000002"] = 148198
    tWaresidList["830000003"] = 148199
    tWaresidList["830000004"] = 148200
    tWaresidList["830000005"] = 148201
    tWaresidList["830000006"] = 148202
    tWaresidList["830000007"] = 148203
    tWaresidList["830000008"] = 148204
    tWaresidList["830000009"] = 148205
    tWaresidList["830000010"] = 148206
    tWaresidList["830000011"] = 148207
    tWaresidList["830000012"] = 148208
    tWaresidList["830000013"] = 148209
    tWaresidList["830000014"] = 148210
    tWaresidList["830000015"] = 148211
    local payInfo = {}
    payInfo.waresid = tWaresidList[tostring(payArgs.goods)]
    payInfo.exorderno = payArgs.orderid
    payInfo.price = payArgs.money/100
    payInfo.notifyurl = ""
    --{"goods":830000001,"token":"f0c7f383eb261b4cb6ad16adf228ff17","msg":"done","ingame":1,"body":"鱼币 830000001 x1","roomid":0,"callbackurl":"https://payback.weile.com/callback/alipay/264/207/1.1.5/0/","status":0,"money":600,"udid":"C2D6AFB6F8CC68D6371D91C175AA3FBA4A9A9596","subject":"30000鱼币","type":"alipay_client","ext":{"partner":"2088221603340274","email":"jiaxianghudong@weile.com"},"debug":1,"orderid":"1704274949026739","virtual":0,"autobuy":1}
    self:doPay(payInfo, payCB)
    return true
end

function LenovoSDKInterface:doGetToken(loginCB)
    self:doImpl("doGetToken", {}, loginCB)
    return true
end

return LenovoSDKInterface