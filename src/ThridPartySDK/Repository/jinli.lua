local JinLiSDKInterface = class("JinLiSDKInterface", FishGI.GameCenterSdkBase)

function JinLiSDKInterface:trySDKLogin(info, loginCB)
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

function JinLiSDKInterface:doSDKLogout(info, logoutCB)
    self:doLogout(info, logoutCB)
    return true
end

function JinLiSDKInterface:trySDKGameExit(info, exitCallback)
    self:doGameExit(info, exitCallback)
    return true
end

function JinLiSDKInterface:trySDKPay(payTab, payCB)
    local payInfo = {}
    log("JinLiSDKInterface:trySDKPay")
    log(json.encode(payTab))
    payInfo.orderid     = payTab.orderid
    --payInfo.money       = payTab.money/100
    payInfo.money       = tonumber(payTab.money)/100
    payInfo.callbackurl = self:getPayCallBackUrl("jinli")
    payInfo.productname = payTab.subject
    payInfo.productid   = payTab.goods
    payInfo.username    = FishGI.myData.account
    payInfo.userid      = FishGI.myData.playerId

    self:doPay(payInfo, payCB)
    return true
end

function JinLiSDKInterface:doGetTokenAndSsoid(callback)
    self:doImpl("doGetTokenAndSsoid", {}, callback)
    return true
end

function JinLiSDKInterface:doGetUserInfo(callback)
    self:doImpl("doGetUserInfo", {}, callback)
    return true
end

function JinLiSDKInterface:doGetVerifiedInfo(callback)
    self:doImpl("doGetVerifiedInfo", {}, callback)
    return true
end

function JinLiSDKInterface:doGameExit(argsTab, exitCallback)
    log("doGameExit")
    self:doImpl("doGameExit", argsTab, exitCallback)
end

return JinLiSDKInterface