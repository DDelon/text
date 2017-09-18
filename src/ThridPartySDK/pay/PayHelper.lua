local PayHelper = class("PayHelper");

function PayHelper.create()
	local obj = PayHelper.new();
	obj:init();
	return obj;
end

function PayHelper:init()
end


function PayHelper:doPay(payInfo)

	if not FishGF.isThirdSdk() then
		--微乐自运营渠道 lua需要弹出微乐支付面板 ios 只有支付就不需要弹出面板
		if bit.band(PAY_SWITCH, 8) == 8 and PAY_SWITCH == 8 then
            payInfo.productType = payInfo.type
            local cfgTable = checktable(PAY_CONFIG["appstore"][payInfo.type])
            payInfo.goods = cfgTable[payInfo.price]
			print("goods "..payInfo.goods);
			self:createPay("appstore"):doPay(payInfo);
		else
			self:createWeileView(payInfo);
		end
	else
		payInfo["type"] = FishGI.GameCenterSdkBase.ChannelInfoList[FishGI.GameCenterSdkBase.ChannelIdList[CHANNEL_ID]][FishGI.GameCenterSdkBase.ChannelInfoIndex.pay_order_req_type];
		self:createPay("sdk"):doPay(payInfo);
	end
end

function PayHelper:createPay(method)
	if FishGI.GAME_STATE == 3 then
		print("-------onClickPayButton---sendGotoCharge-----")
		FishGI.gameScene.net:sendGotoCharge()
	end

	if method == "yyb" then
		return require("ThridPartySDK/pay/module/PaySdk").create();
	elseif method == "appstore" then
		return require("ThridPartySDK/pay/module/PayApple").create();
	elseif method == "wechat" then
		return require("ThridPartySDK/pay/module/PayWechat").create();
	elseif method == "alipay_client" then
		return require("ThridPartySDK/pay/module/PayAlipay").create();
	elseif method == "unionpay_client" then
		return require("ThridPartySDK/pay/module/PayUnionpay").create();
	elseif method == "sdk" then
		print("--------------pay Sdk");
		return require("ThridPartySDK/pay/module/PaySdk").create();
	end
end

function PayHelper:createWeileView(paydata)
	local payInfo = checktable(paydata);
	local uiObj = payInfo["uiObj"];

	local function selectedPayMethod(method)
		--玩家点击面板选择了支付方式
		if method then
            print("PayHelper:createWeileView selectedPayMethod args : " .. json.encode(payInfo))
            print("method:"..method);
            if method == "appstore" then
                payInfo.productType = payInfo.type
                local cfgTable = checktable(PAY_CONFIG["appstore"][payInfo.type])
                payInfo.goods = cfgTable[payInfo.price]
            end
            self:createPay(method):doPay(payInfo)
        end
	end

	if uiObj then
		local viewData = { 
			{ id = 1, visible = (bit.band(PAY_SWITCH, 1) == 1 and true or false) }, 	--微信支付
			{ id = 2, visible = (bit.band(PAY_SWITCH, 2) == 2 and true or false) }, 	--支付宝支付
			{ id = 3, visible = (bit.band(PAY_SWITCH, 4) == 4 and true or false) }, 	--银联支付
			{ id = 4, visible = (bit.band(PAY_SWITCH, 8) == 8 and true or false) } 		--苹果支付
		}
		local weilePayView = require("ThridPartySDK/pay/view/PayMethodPView")
		local methodObj = weilePayView.new(selectedPayMethod, clone(payInfo), viewData)
        methodObj:addTo(cc.Director:getInstance():getRunningScene(), 1000, FishCD.TAG.PAY_VIEW_TAG);
	end
end


return PayHelper;