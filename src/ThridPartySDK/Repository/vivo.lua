local VivoSDKInterface = class("VivoSDKInterface", FishGI.GameCenterSdkBase)

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

function VivoSDKInterface:trySDKGameExit(info, exitCallback)
    self:doGameExit(info, exitCallback)
    return true
end

function VivoSDKInterface:trySDKPay(payArgs, payCB)
    local payInfo = {}
    payInfo.order = payArgs.ext.vivoOrder
    payInfo.amount = payArgs.ext.orderAmount
    payInfo.signature = payArgs.ext.vivoSignature
    payInfo.productName = payArgs.subject
    payInfo.productDesc = payArgs.body
    print("wegowegowmegweg")
    dump(payInfo)
    self:doPay(payInfo, payCB)
    return true
end

return VivoSDKInterface