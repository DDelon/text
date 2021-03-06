
local PhoneBind = class("PhoneBind", cc.load("mvc").ViewBase)

PhoneBind.AUTO_RESOLUTION   = false
PhoneBind.RESOURCE_FILENAME = "ui/playerinfo/uiphone_bind"
PhoneBind.RESOURCE_BINDING  = {    
    ["panel"]       = { ["varname"] = "panel" },
    ["btn_close"]   = { ["varname"] = "btn_close" ,     ["events"]={["event"]="click",["method"]="onClickclose"}},     
    ["btn_cancel"]  = { ["varname"] = "btn_cancel",     ["events"]={["event"]="click",["method"]="onClickclose"} }, 
    ["btn_sure"]    = { ["varname"] = "btn_sure",       ["events"]={["event"]="click",["method"]="onClicksuer"} },               
    ["btn_getcode"] = { ["varname"] = "btn_getcode",    ["events"]={["event"]="click",["method"]="onClickgetcode"} },               
    
    ["tf_phone"]    = { ["varname"] = "tf_phone" },     
    ["tf_code"]     = { ["varname"] = "tf_code" },     

}

function PhoneBind:onCreate( ... )
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

function PhoneBind:initEditBoxStr(str)
    self.tf_phone:setString(str);
    self.tf_code:setString(str);
end

function PhoneBind:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function PhoneBind:onClickclose( sender )
    self:hideLayer() 
    FishGI.hallScene.uiPlayerInfo:showLayer() 
end

function PhoneBind:onClickgetcode( sender )
    print("onClickgetcode")
    --self:onClickLinkPhoneCode()
--    FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
    FishGF.onClickGetCode(sender,self.tf_phone:getString(),"bind")
end

function PhoneBind:onClicksuer( sender )
    print("onClicksuer")
--    FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
    self:onClickLinkPhone()
end

--[[
* @brief 手机绑定事件
--]]
function PhoneBind:onClickLinkPhone()

    local phoneid = ""
    local callback=function(x)

        --隐藏等待框
        FishGF.waitNetManager(false,nil,"PhoneBind")
        
        if x.status == 0 then

            print("----phoneid="..phoneid)

            -- 手机激活成功通知 
            local str = FishGF.getChByIndex(800000143)..phoneid..FishGF.getChByIndex(800000147)
            FishGF.showMessageLayer(FishCD.MODE_MIN_OK_ONLY,str,nil)

            --界面更新
            self.tf_phone:setString("")
            self.tf_code:setString("")
            self:hideLayer() 
            FishGI.WebUserData:initWithUserId(FishGI.WebUserData:GetUserId());
            FishGI.hallScene.uiPlayerInfo:upDataBtnState(true,true)

            FishGI.WebUserData:setUserData("attr",2)
            FishGI.hallScene.taskPanel:requestForTaskInfo()
        else
            FishGF.showToast(x.msg)
        end
    end

    phoneid = self.tf_phone:getString()
    -- local personid  = "350623199007080054"    --身份证号
    local code      = self.tf_code:getString()

    --验证
    if FishGF.checkPhone( phoneid ) and FishGF.checkCode( code ) then

        -- 发送绑定请求
        FishGI.Dapi:BindPhone(phoneid,code,callback)

        --显示等待框
        FishGF.waitNetManager(true,nil,"PhoneBind")
    end
end



return PhoneBind;