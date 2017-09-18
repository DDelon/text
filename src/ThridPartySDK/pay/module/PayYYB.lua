local PayYYB = class("PayYYB", require("ThridPartySDK/pay/module/PayBase"))

function PayYYB.create()
	local obj = PayYYB.new();
	obj:init(payInfo);
	return obj;
end

function PayYYB:init()
	PayYYB.super.init(self);
end

function PayYYB:doPay(payInfo)
	payInfo["type"] = "midas";
	PayYYB.super.doPay(self, payInfo)
end

function PayYYB:doPayIOS(payInfo)
	
end

return PayYYB;