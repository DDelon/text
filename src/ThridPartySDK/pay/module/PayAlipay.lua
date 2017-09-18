local PayAlipay = class("PayAlipay", require("ThridPartySDK/pay/module/PayBase"))

function PayAlipay.create()
	local obj = PayAlipay.new();
	obj:init(payInfo);
	return obj;
end

function PayAlipay:init()
	self.super:init();
end

function PayAlipay:doPay(payInfo)
	payInfo["type"] = "alipay_client";
	self.super:doPay(payInfo)
end

return PayAlipay;