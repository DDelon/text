--
-- Author: lee
-- Date: 2016-08-29 14:26:18
--
local PayMethod = class("PayMethod", require("ThridPartySDK/pay/view/ViewPop"))

PayMethod.PAY_RELATION={[1]="wechat",[2]="alipay_client",[3]="unionpay_client",[4]="appstore"}

PayMethod.RESOURCE_FILENAME="ui/store/pay_method.lua"

PayMethod.RESOURCE_BINDING = {
	["bk_bottom"] 			= {["varname"] = "bk_bottom"},
	["btn_close"] 			= {["varname"] = "btn_close",["events"]={["event"] = "click",["method"]="onClickClose"}}, 
	["txt_content"] 		= {["varname"] = "txt_content"},
	["txt_price"] 			= {["varname"] = "txt_price"},
	["txt_subject"] 		= {["varname"] = "txt_subject"},
    ["txt_line"]            = {["varname"] = "txt_line" },  --线
}

PayMethod.BUTTON={
    {id=4, ico="hall/store/pay_ico_apple.png",  name="苹果支付",  visible=false },
	{id=1, ico="hall/store/pay_ico_wx.png", 	name="微信支付",  visible=false },
	{id=2, ico="hall/store/pay_ico_alipay.png", name="支付宝支付",visible=false },
	{id=3, ico="hall/store/pay_ico_union.png",  name="银联支付",  visible=false },
	
}

PayMethod.RICHCHARCOLOR ={
    {"万","豆","钻","石","v","i","p","天","月","年"},
}


 
--[[  diamond price body
 
]]

function PayMethod:ctor(fn,data,switch)   
	self.fn_=fn
	self.data = data
	self.switch = switch
    PayMethod.super.ctor(self)
end

function PayMethod:onCreate(...)	
    --处理线
    -- gg.LineHandle( self.txt_line)
 	self.posArr_={}
    for i,v in ipairs(PayMethod.BUTTON) do
        local btn = self:child("btn_pay_"..i)  
        local line = btn:getChildByName("line")
        FishGF.HandleLineV(line)
    end 
    self.lableX =0       --富文本标签的开始位置

	if self.data.type ==PROP_ID_MONEY then
		self.data.name = self.data.count .."万豆"
	else
		self.data.name =self.data.name or FishCD.PROPNAME[self.data.type].."x"..self.data.count
	end

	self.data.name = self.data.name or FishCD.PROPNAME[self.data.type]
	self.txt_subject:setString(tostring(self.data.name)) -- 商品名称
	self.txt_price:setString("￥"..tostring(self.data.price)) --商品价格
	self:showTips() --隐藏兑换提示 
 	for i,v in ipairs(PayMethod.BUTTON) do
	 	local btn= self:child("btn_pay_"..i)
	 	btn:setVisible(v.visible)
 		btn:setTag(v.id)
	 	btn:getChildByName("ico"):setTexture(v.ico)
	 	btn:getChildByName("btn_content"):setString(v.name)	 	
	 	btn:onClickDarkEffect(handler(self, self.onClickPayButton))	 
	 	table.insert(self.posArr_, cc.p(btn:getPosition()))
	end
	self:refreshButton(self.switch)

	self:addEventListener( FishCD.PAY_EVENT.ON_PAY_RESULT, handler( self, self.onPayResultsCallBack ) )

end

function PayMethod:showTips(content)
	if not content then
		self.txt_content:setVisible(false)
		return
	end
	self.txt_content:setString("")
	self.txt_content:setTextColor({r = 160, g = 160, b = 160})      --子体显示灰色
	self.txt_content:setFontName("fonts/mnjcy.ttf")
	local test_text = {}
	table.insert( test_text , string.format( "<div fontColor=#a0a0a0>%s</div>",content) ) 
	for i=1, #test_text do
	    --local RichLabel = require("common.richlabel.RichLabel")
	    local label = RichLabel.new {
	        fontName = "res/fonts/mnjcy.ttf",
	        fontSize = 24,
	        fontColor = cc.c3b(255, 0, 0),
	        maxWidth=670,
	        lineSpace=0,
	        charSpace=0,
	    }
	    label:setAnchorPoint(cc.p(0,1))
	    label:setString(test_text[i])
	    local labelWidth = label:getSize().width
	    local rect = self.txt_content:getBoundingBox()
	    label:setPosition(cc.p(self.lableX,rect.height))
	    self.lableX=self.lableX+labelWidth

	    label:walkElements(function ( node ,index )
	    local ss = node:getString()
	    if tonumber(ss) then 
	       node:setTextColor(cc.c3b(128,42,42))
	       node:setFontSize( 26 )
	    end

	    for i =1,#PayMethod.RICHCHARCOLOR[1] do
	        if ss == PayMethod.RICHCHARCOLOR[1][i] then
	            node:setTextColor(cc.c3b(128,42,42))
	            node:setFontSize( 26 )
	        end
	    end
	    end)          
	    self.txt_content:addChild(label)         
	end
	self.txt_content:setVisible(true)
end

function PayMethod:getIdByString(met)
	return table.indexof(PayMethod.PAY_RELATION,met)
end

function PayMethod:getMethodById(id)
	id=checkint(id)
	if id>0 and id <=#PayMethod.PAY_RELATION then
		return PayMethod.PAY_RELATION[id]
	end
	return PayMethod.PAY_RELATION[1] 
end

function PayMethod:refreshButton(switch)
	local i=1
	if device.platform~="ios" then
    	PayMethod.BUTTON[1].visible=false
    end
	for _,v in ipairs(PayMethod.BUTTON) do
	 	local btn= self:child("btn_pay_"..i)	
	 	table.walk(checktable(switch),function(vv) 
	 	 	if v.id==vv.id  then 	  
	 	 		btn:setVisible(vv.visible)	
	 		 	i=i+1	 		 	
	 		end 
 		end)	  	 	 
	end
	i=1
	for k=1,4 do
		local btn= self:child("btn_pay_"..k)	
		if btn:isVisible() then 
			btn:setPosition(self.posArr_[i])
			i=i+1
		end
	end	
end

 
function PayMethod:onClickClose()	
	if self.fn_ then
		self.fn_()
	end
	self:removeSelf()
	--cc.Director:getInstance():getRunningScene():removeChildByTag(FishCD.TAG.PAY_VIEW_TAG);
end

function PayMethod:onService()
	-- body
end

function PayMethod:onClickPayButton(sender)
	print("-------onClickPayButton--------")
	local id=sender:getTag()
	if self.fn_ then
		if FishGI.GAME_STATE == 3 then
			FishGF.print("-------onClickPayButton---sendGotoCharge-----")
			FishGI.gameScene.net:sendGotoCharge()
		end
		self.fn_(self:getMethodById(id))
	end
	self:removeSelf()
end 

--[[
* @brief 支付结果回调处理
* @pram [in] status	0-成功,1-失败,2-取消,3-结果处理中
]]
function PayMethod:onPayResultsCallBack( event, result )
	
	-- 支付成功，移除支付界面
	if result.status == 0 then
		self:removeSelf()
	end

end

return PayMethod
