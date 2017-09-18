local PayWechat = class("PayWechat", require("ThridPartySDK/pay/module/PayBase"))

function PayWechat.create()
	local obj = PayWechat.new();
	obj:init(payInfo);
	return obj;
end

function PayWechat:init()
	self.super:init();
end

function PayWechat:doPay(payInfo)
	payInfo["type"] = "wechat";
	self.super:doPay(payInfo)
end

return PayWechat;