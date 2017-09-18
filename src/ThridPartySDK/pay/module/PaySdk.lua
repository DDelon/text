local PaySdk = class("PaySdk", require("ThridPartySDK/pay/module/PayBase"))

function PaySdk.create()
	local obj = PaySdk.new();
	obj:init(payInfo);
	return obj;
end

function PaySdk:init()
	PaySdk.super.init(self);
end

function PaySdk:doPay(payInfo)
	PaySdk.super.doPay(self, payInfo)
end

function PaySdk:doPayIOS(payInfo)
	print("暂未开放sdk的ios支付")
end

function PaySdk:doPayAndroid(payInfo)
	print("-----sdk pay");
	PaySdk.super.doPaySDK(self, payInfo);
end

return PaySdk;