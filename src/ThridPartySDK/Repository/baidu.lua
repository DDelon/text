local BaiduSDKInterface = class("BaiduSDKInterface", FishGI.GameCenterSdkBase)

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

function BaiduSDKInterface:trySDKLogin(info, loginCB)
    local function callBackGetTokenAndSsoidResult( strJson )
        print("--------callBackGetTokenAndSsoidResult", strJson)
        local resultTab = json.decode(strJson, 1);
        local resultMsg = json.decode(resultTab.resultMsg, 1)
        FishGI.Dapi:thirdLogin("baidu", resultMsg, loginCB)
        local function callBackGetUserInfoResult( strJson )
            print("--------callBackGetUserInfoResult", strJson)
        end
        --self:doGetUserInfo(callBackGetUserInfoResult)
    end
    local function callBackDoLogin( strJson )
        --self:doGetTokenAndSsoid(callBackGetTokenAndSsoidResult)
    end

    self:doLogin(info, callBackDoLogin)
    return true
end

function BaiduSDKInterface:doSDKLogout(info, logoutCB)
    self:doLogout(info, logoutCB)
    return true
end

function BaiduSDKInterface:trySDKGameExit(info, exitCallback)
    log("BaiduSDKInterface:trySDKGameExit")
    self:doGameExit(info, exitCallback)
    return true
end

function BaiduSDKInterface:trySDKPay(payArgs, payCB)
    log("BaiduSDKInterface:trySDKPay" .. json.encode(payArgs))
    local payInfo = {}
    payInfo.order = payArgs.orderid
    payInfo.mPropsId = self:getChargingPoint(payArgs.id)
    payInfo.productName = payArgs.name
    payInfo.price = payArgs.money/100
    --payInfo.callbackurl = self:getPayCallBackUrl("baidu")
    --print("payInfo.callbackurl", payInfo.callbackurl)
    --{"goods":830000001,"token":"f0c7f383eb261b4cb6ad16adf228ff17","msg":"done","ingame":1,"body":"鱼币 830000001 x1","roomid":0,"callbackurl":"https://payback.weile.com/callback/alipay/264/207/1.1.5/0/","status":0,"money":600,"udid":"C2D6AFB6F8CC68D6371D91C175AA3FBA4A9A9596","subject":"30000鱼币","type":"alipay_client","ext":{"partner":"2088221603340274","email":"jiaxianghudong@weile.com"},"debug":1,"orderid":"1704274949026739","virtual":0,"autobuy":1}
    self:doPay(payInfo, payCB)
    return true
end

function BaiduSDKInterface:doGetTokenAndSsoid(loginCB)
    self:doImpl("doGetTokenAndSsoid", {}, loginCB)
    return true
end

function BaiduSDKInterface:doGetUserInfo(loginCB)
    self:doImpl("doGetUserInfo", {}, loginCB)
    return true
end

function BaiduSDKInterface:doReportUserGameInfoData(loginCB)
    local tGameInfo = {}
    tGameInfo.gameId = tostring(GAME_ID)
    tGameInfo.service = ""
    tGameInfo.role = ""
    tGameInfo.grade = ""
    self:doImpl("doReportUserGameInfoData", tGameInfo, loginCB)
    return true
end

function BaiduSDKInterface:doGetVerifiedInfo(loginCB)
    self:doImpl("doGetVerifiedInfo", {}, loginCB)
    return true
end

--退出房间
function BaiduSDKInterface:doGameExit(argsTab, exitCallback)
    log("doGameExit")
    self:doImpl("doGameExit", argsTab, exitCallback)
end

--
function BaiduSDKInterface:getChargingPoint(id)
    local pointArr = {
        ["830000001"] = "28035",
        ["830000002"] = "28036",
        ["830000003"] = "28037",
        ["830000004"] = "28038",
        ["830000005"] = "28039",
        ["830000006"] = "28040",
        ["830000007"] = "28041",
        ["830000008"] = "28042",
        ["830000009"] = "28043",
        ["830000010"] = "28044",
        ["830000011"] = "28045",
        ["830000012"] = "28046",
        ["830000013"] = "28047",
        ["830000014"] = "28048",
        ["830000015"] = "28049",
    }

    local point = pointArr[tostring(id)]
    return point
end

return BaiduSDKInterface