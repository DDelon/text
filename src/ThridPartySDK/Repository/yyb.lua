local YYBSDKInterface = class("YYBSDKInterface", FishGI.GameCenterSdkBase)

--[[

Java ����ԭ��:
public static void doPay(final int payAmount, int cbId)

Java ����ԭ��:
public static void doLogin()

-- Java �������
local className = "weile/buyu/game/AppActivity"
-- ���� Java ����
luaj.callStaticMethod(className, "doBilling", args)

]]

function YYBSDKInterface:trySDKLogin(info, loginCB)
    local function callBackDoLogin( strJson )
        local resultTab = json.decode(strJson, 1);
        local status = resultTab.state;
        local resultMsg = json.decode(resultTab.resultMsg, 1);
        FishGF.waitNetManager(true);
        print("doLogin callback:"..strJson);
        FishGI.Dapi:thirdLogin("ysdk", resultMsg, loginCB);
        --self:doGetTokenAndSsoid(callBackGetTokenAndSsoidResult)
    end
    self:doLogin(info, callBackDoLogin)
    return true
end

function YYBSDKInterface:doSDKLogout(info, logoutCB)

    self:doLogout(info, logoutCB)
    return true
end

function YYBSDKInterface:trySDKPay(payArgs, payCB)
    local payInfo = {}
    payInfo.orderid = payArgs.orderid
    payInfo.money = payArgs.money
    payInfo.name = payArgs.subject
    payInfo.productDesc = payArgs.body
    payInfo.goods = payArgs.goods
    payInfo.callbackurl = self:getPayCallBackUrl("midas")
    print("payInfo.callbackurl", payInfo.callbackurl)
    --{"goods":830000001,"token":"f0c7f383eb261b4cb6ad16adf228ff17","msg":"done","ingame":1,"body":"��� 830000001 x1","roomid":0,"callbackurl":"https://payback.weile.com/callback/alipay/264/207/1.1.5/0/","status":0,"money":600,"udid":"C2D6AFB6F8CC68D6371D91C175AA3FBA4A9A9596","subject":"30000���","type":"alipay_client","ext":{"partner":"2088221603340274","email":"jiaxianghudong@weile.com"},"debug":1,"orderid":"1704274949026739","virtual":0,"autobuy":1}
    self:doPay(payInfo, payCB)
    return true
end

function YYBSDKInterface:doGetUserInfo(loginCB)

    self:doImpl("doGetUserInfo", {}, loginCB)
    return true
end

function YYBSDKInterface:doReportUserGameInfoData(loginCB)

    local tGameInfo = {}
    tGameInfo.gameId = tostring(GAME_ID)
    tGameInfo.service = ""
    tGameInfo.role = ""
    tGameInfo.grade = ""
    self:doImpl("doReportUserGameInfoData", tGameInfo, loginCB)
    return true
end

function YYBSDKInterface:doGetVerifiedInfo(loginCB)

    self:doImpl("doGetVerifiedInfo", {}, loginCB)
    return true
end

return YYBSDKInterface