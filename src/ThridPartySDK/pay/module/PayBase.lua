local PayBase = class("PayBase")


local JAVA_CLASS_NAME = "com.weile.pay.PayApi"

function PayBase.create()
	local obj = PayBase.new();
	obj:init();
	return obj;
end

function PayBase:init()
	self.callfunc = nil;
end

function PayBase:doPay(payInfo)
	--发起http请求订单号
	local function callfunc(sdkCallInfo)
		--调起sdk
		if device.platform == "ios" then
			print("发起苹果支付")
			self:doPayIOS(sdkCallInfo);
		elseif device.platform == "android" then
			print("发起安卓支付")
			self:doPayAndroid(sdkCallInfo);
		else
			print("暂未开放此平台的支付功能")
		end
	end

	self:orderRequest(payInfo, callfunc)
end

function PayBase:orderRequest(payInfo, callfunc)
	assert(payInfo, "pay info is invalid");
    FishGF.waitNetManager(true,nil,"12345")
	local printStr = json
	local function ordercallback_(data)
        FishGF.waitNetManager(false,nil,"12345")
        if data and data.status == 0 then
            local payArgs = checktable(data)
            print("orderRequest data:"..json.encode(data))
            table.merge(payArgs, payInfo)
            local ext = data.ext;
            if  ext ~= nil then table.merge(payArgs, ext) end
            callfunc(payArgs)
        	
        else
            print("下单失败！" .. data.msg)
            --弹出提示框是否重试
        end
    end
	log("order Request: " .. json.encode(payInfo));
	FishGI.Dapi:OrderNew(payInfo, ordercallback_)
end

function PayBase:verifyIosReceipt_(luastr, paytype)
    print("verify:"..luastr)
    local ok, args = pcall(function()
        return loadstring(luastr)();
    end)
    if ok then
        print("-----------------ok verify")
		cc.UserDefault:getInstance():setStringForKey("verifydata", luastr);
        local scheduleId = 0;
        local oldVal = FishCD.OVER_TIME;
		local isRecv = false;
        FishCD.OVER_TIME = 9999;
        FishGF.waitNetManager(true,nil,"123456")
        local function requestVerify()
			dump(args)
        	FishGI.Dapi:VerifyIosReceipt(args, function(msg)
        		if scheduleId ~= 0 then
        			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId);
        		end
				if isRecv then
					return;
				end
	            FishGF.waitNetManager(false,nil,"123456")
				cc.UserDefault:getInstance():setStringForKey("verifydata", "");
	            FishCD.OVER_TIME = oldVal;
				isRecv = true;
	            if msg.status == 0 then
	                local ret_tab = { status = msg.status, paytype = paytype, msg = "支付成功！" }
	                
	                self:onCallback_(ret_tab)
	            else
	                print("iap order verify failure");
	            end
	 
	        end)
        end
        requestVerify();
        scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(requestVerify, 5, false)
        
    else
        printf("解析ios 参数失败 %s", luastr)
    end
end

function PayBase:doPayIOS(payInfo)
	payInfo.listener = handler(self, self.onIosCallback_);
	payInfo.money = tonumber(payInfo.money)/100;
	local cfgTable = checktable(PAY_CONFIG[payInfo.type][payInfo.productType]);

	if payInfo.type == "appstore" then
		local productids = table.values(cfgTable);
		payInfo.productidarray = json.encode(productids);
		payInfo.productid = cfgTable[payInfo.money];
		if not payInfo.productid then
			print("don't support item price check ios product config");
			return;
		end
	else
		table.merge(payInfo, cfgTable);
	end
	
	local iosClassName = "AppController";
	local methodName = "doPay";
    local luaoc = require("cocos.cocos2d.luaoc");
	local ok, ret = luaoc.callStaticMethod(iosClassName, "doPay", payInfo)
	if not ok then
		print("call oc class:"..iosClassName.." method:"..methodName.." failure");
	end
end

function PayBase:doPaySDK(payInfo)
	local function payResult(resultInfo)
    print("------------payResult")
	local resultTab = json.decode(resultInfo)
		if FishGI.GAME_STATE == 3 then
			FishGI.gameScene.net:sendBackFromCharge()
		end		
        if resultTab.resultCode == 0 then
            --成功
            FishGF.print("------recharge succeed----")
            if FishGI.GAME_STATE == 2 then
				FishGF.waitNetManager(true,nil,"doPaySDK")
				FishGI.IS_RECHARGE = 5
				FishCD.hallScene:doAutoLogin(2);
                --FishGI.hallScene.net.roommanager:sendDataGetInfo();
            elseif FishGI.GAME_STATE == 3 then
				FishGI.WebUserData:initWithUserId(FishGI.WebUserData:GetUserId())
                FishGI.gameScene.net:sendReChargeSucceed()
            end
        else
            FishGF.print("------recharge faile----")
            FishGF.showSystemTip(nil,800000169,1);
        end
        --删除面板
        cc.Director:getInstance():getRunningScene():removeChildByTag(FishCD.TAG.PAY_VIEW_TAG);
    end
    print("----------------do pay sdk")
    FishGI.GameCenterSdk:trySDKPay(payInfo, payResult)
end

function PayBase:addListener()
    local luaBridge = require("cocos.cocos2d.luaj")
    luaBridge.callStaticMethod(JAVA_CLASS_NAME, "addScriptListener", { handler(self, self.onCallback_) })
    return self 
end

function PayBase:removeListener()
    local luaBridge = require("cocos.cocos2d.luaj")
    luaBridge.callStaticMethod(JAVA_CLASS_NAME, "removeScriptListener")
end

function PayBase:onCallback_(luastr) 
	local ok = false;
	local resultInfo = nil;
	if type(luastr) == "string" then
		ok,resultInfo = pcall(function()         
			return loadstring(luastr)();
		end)
	else
		ok = true;
		resultInfo = luastr;
	end

	if FishGI.GAME_STATE == 3 then
		FishGI.gameScene.net:sendBackFromCharge()
	end		

	if ok then
		if resultInfo.status == 0 then
			--成功
			FishGF.print("------recharge succeed----")
			if not FishGI.WebUserData:isActivited() then	--"游客"
				FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000175),nil) 
			end
			
			if FishGI.GAME_STATE == 2 then
				FishGF.waitNetManager(true,nil,"doPaySDK")
				FishGI.IS_RECHARGE = 5
				--FishGI.hallScene.net.roommanager:sendDataGetInfo();
			elseif FishGI.GAME_STATE == 3 then
				FishGI.gameScene.net:sendReChargeSucceed()
				FishGI.WebUserData:initWithUserId(FishGI.WebUserData:GetUserId());
			end
			FishGI.eventDispatcher:dispatch("BuySuccessCall", resultInfo);
		else
			FishGF.print("------recharge faile----")
		end
		--删除面板
		cc.Director:getInstance():getRunningScene():removeChildByTag(FishCD.TAG.PAY_VIEW_TAG);
	else
		printf("PayUnionpay:onCallback_"..tostring(luastr))
	end 
end

function PayBase:onIosCallback_(status, paytype, msg)
	if paytype == "appstore" and status == 0 then
		self:verifyIosReceipt_(msg, paytype);
	else
		local retTab = {
			status = status,
			paytype = paytype,
			msg = msg,
		}
		self:onCallback_(retTab);
	end
end

function PayBase:verifyIosReceipt_(luastr, paytype)
    print("verify:"..luastr)
    local ok, args = pcall(function()
        return loadstring(luastr)();
    end)
    if ok then
        print("-----------------ok verify")

		FishGF.waitNetManager(true,FishGF.getChByIndex(800000186),"verifyIosReceipt_")
        FishGI.Dapi:VerifyIosReceipt(args, function(msg)
            FishGF.waitNetManager(false,FishGF.getChByIndex(800000186),"verifyIosReceipt_")
            if msg.status == 0 then
                local ret_tab = { status = msg.status, paytype = paytype, msg = "支付成功！" }
                --self:onPayCallback("return "..gg.SerialObject(ret_tab))
                self:onCallback_(ret_tab)
            else
                print("iap order verify failure");
            end
 
        end)
    else
        printf("解析ios 参数失败 %s", luastr)
    end
end

function PayBase:doPayAndroid(args)
    self:addListener()
    local javaMethodName = "doPay"
    args.virtual=checkint( args.virtual) 
    local jsonArgs = json.encode(args)
    local cfgTable = PAY_CONFIG[args.type]
    local jsonCfg = json.encode(cfgTable)

    printf("---------- PayAndroid:doPayReq" .. jsonArgs)
    printf("---------- doPayReq jsonCfg" .. jsonCfg)
    local javaParams = {
        args.type,
        jsonArgs,
        jsonCfg
    }
	local luaBridge = require("cocos.cocos2d.luaj")
    local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
    luaBridge.callStaticMethod(JAVA_CLASS_NAME, javaMethodName, javaParams, javaMethodSig)
end



function PayBase:doPaySDKResult(resultStr)
	--[[local ok,argtable = pcall(function()         
        return loadstring(resultStr)();
    end)]]--

	local resultTab = json.decode(resultStr);
	if FishGI.GAME_STATE == 3 then
		FishGI.gameScene.net:sendBackFromCharge()
	end		
    if resultTab ~= nil then
    	local payArgs = checktable(resultTab);
		if FishGI.GAME_STATE == 2 then
			FishGI.hallScene.net.roommanager:sendDataGetInfo();
		elseif FishGI.GAME_STATE == 3 then
			print("-------------------------ref------")
			FishGI.gameScene.net:sendReChargeSucceed()
		end
		
    	self.callfunc(payArgs);
    else
    	print("sdk返回的数据出错");
    end
end

return PayBase;