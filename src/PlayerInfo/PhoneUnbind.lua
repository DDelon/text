
local PhoneUnbind = class("PhoneUnbind", cc.load("mvc").ViewBase)

PhoneUnbind.AUTO_RESOLUTION   = false
PhoneUnbind.RESOURCE_FILENAME = "ui/playerinfo/uiphone_unbind"
PhoneUnbind.RESOURCE_BINDING  = {    
    ["panel"]       = { ["varname"] = "panel" },
    ["btn_close"]   = { ["varname"] = "btn_close" ,     ["events"]={["event"]="click",["method"]="onClickclose"}},     
    ["btn_cancel"]  = { ["varname"] = "btn_cancel",     ["events"]={["event"]="click",["method"]="onClickclose"} }, 
    ["btn_sure"]    = { ["varname"] = "btn_sure",       ["events"]={["event"]="click",["method"]="onClicksuer"} },               
    ["btn_getcode"] = { ["varname"] = "btn_getcode",    ["events"]={["event"]="click",["method"]="onClickgetcode"} },               
    
    ["tf_phone"]    = { ["varname"] = "tf_phone" },     
    ["tf_code"]     = { ["varname"] = "tf_code" }, 
    
}

function PhoneUnbind:onCreate( ... )
    self:initWinEditBox("tf_phone")
    self:initWinEditBox("tf_code")
    self:initEditBoxStr("");

    self.tf_phone:setPlaceHolder(FishGF.getChByIndex(800000133))
    self.tf_code:setPlaceHolder("")

    self:openTouchEventListener()
    
    self.btn_getcode:setEnabled(true)
--    self.btn_getcode:setBright(true)
    local spr_nosend = self.btn_getcode:getChildByName("spr_nosend")
    local spr_sendend = self.btn_getcode:getChildByName("spr_sendend")
    spr_nosend:setVisible(true)
    spr_sendend:setVisible(false)

end

function PhoneUnbind:initEditBoxStr(str)
    self.tf_phone:setString(str);
    self.tf_code:setString(str);
end

function PhoneUnbind:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function PhoneUnbind:onClickclose( sender )
    self:hideLayer() 
    FishGI.hallScene.uiPlayerInfo:showLayer() 
end

function PhoneUnbind:onClickgetcode( sender )
    print("onClickgetcode")
    --self:onClickUnLinkPhoneCode()
--    FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
    FishGF.onClickGetCode(sender,self.tf_phone:getString(),"unbind")
end

function PhoneUnbind:onClicksuer( sender )
    print("onClicksuer")
--    FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
    self:onClickUnLinkPhone()
end

--[[
* @brief 手机解绑事件
--]]
function PhoneUnbind:onClickUnLinkPhone()

    local phoneid   = self.tf_phone:getString()
    local code      = self.tf_code:getString()

    local callback=function(x)
        --隐藏待框
        FishGF.waitNetManager(false,nil,"PhoneUnbind")

        if x.status == 0 then
            -- 手机绑定成功通知 
            local str = FishGF.getChByIndex(800000148)..phoneid..FishGF.getChByIndex(800000149)
            FishGF.showMessageLayer(FishCD.MODE_MIN_OK_ONLY,str,nil)

            --界面更新
            self.tf_phone:setString("")
            self.tf_code:setString("")
            self:hideLayer() 
            FishGI.WebUserData:initWithUserId(FishGI.WebUserData:GetUserId());
            FishGI.hallScene.uiPlayerInfo:upDataBtnState(true,false)
            FishGI.WebUserData:setUserData("attr",1)
        else
            FishGF.showToast(x.msg)
        end
    end

    -- 检测用户输入
    if FishGF.checkPhone( phoneid ) and FishGF.checkCode( code )  then

        FishGI.Dapi:UnbindPhone(phoneid,code,callback)

        --显示等待框
        FishGF.waitNetManager(true,nil,"PhoneUnbind")
    end
end

return PhoneUnbind;