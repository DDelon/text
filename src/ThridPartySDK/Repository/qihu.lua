local QihuSDKInterface = class("QihuSDKInterface", FishGI.GameCenterSdkBase)

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

function QihuSDKInterface:trySDKLogin(info, loginCB)
    local function loginCallback( strJson )
        log("--------callBackGetTokenAndSsoidResult", strJson)
        local msgTab = json.decode(strJson);

        local resultCode = tonumber(msgTab.resultCode)
        if resultCode ~= 0 then
            return
        end

        FishGF.waitNetManager(true)
        local resultMsg = json.decode(msgTab.resultMsg)

        FishGI.Dapi:thirdLogin("login360", resultMsg, loginCB)
    end

    self:doLogin(info, loginCallback)
    return true
end

function QihuSDKInterface:doSDKLogout(info, logoutCB)
    self:doLogout(info, logoutCB)
    return true
end

function QihuSDKInterface:trySDKGameExit(info, exitCallback)
    self:doGameExit(info, exitCallback)
    return true
end

function QihuSDKInterface:trySDKPay(payTab, payCB)
    local payInfo = {}
    log("QihuSDKInterface:trySDKPay")
    log(json.encode(payTab))
    payInfo.orderid = payTab.orderid
    payInfo.money = payTab.money
    payInfo.callbackurl = self:getPayCallBackUrl("360")
    payInfo.productname = payTab.subject
    payInfo.productid   = payTab.goods
    payInfo.username    = FishGI.myData.account
    payInfo.userid      = FishGI.myData.playerId

    self:doPay(payInfo, payCB)
    return true
end

function QihuSDKInterface:doGetTokenAndSsoid(callback)
    self:doImpl("doGetTokenAndSsoid", {}, callback)
    return true
end

function QihuSDKInterface:doGetUserInfo(callback)
    self:doImpl("doGetUserInfo", {}, callback)
    return true
end

function QihuSDKInterface:doGetVerifiedInfo(callback)
    self:doImpl("doGetVerifiedInfo", {}, callback)
    return true
end

function QihuSDKInterface:doGameExit(argsTab, exitCallback)
    log("doGameExit")
    self:doImpl("doGameExit", argsTab, exitCallback)
end
return QihuSDKInterface