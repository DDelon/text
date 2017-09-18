local PayApple = class("PayApple", require("ThridPartySDK/pay/module/PayBase"))

function PayApple.create()
	local obj = PayApple.new();
	obj:init(payInfo);
	return obj;
end

function PayApple:init()
	self.super:init();
end

function PayApple:doPay(payInfo)
	payInfo["type"] = "appstore";
	self.super:doPay(payInfo)
end

function PayApple:doPayAndroid(payInfo)
	print("暂未开放iap的安卓支付")
end

return PayApple;