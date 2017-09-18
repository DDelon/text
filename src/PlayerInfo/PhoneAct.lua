
local PhoneAct = class("PhoneAct", cc.load("mvc").ViewBase)

PhoneAct.AUTO_RESOLUTION   = false
PhoneAct.RESOURCE_FILENAME = "ui/playerinfo/uiphone_act"
PhoneAct.RESOURCE_BINDING  = {    
    ["panel"]       = { ["varname"] = "panel" },
    ["btn_close"]   = { ["varname"] = "btn_close" ,     ["events"]={["event"]="click",["method"]="onClickclose"}},     
    ["btn_cancel"]  = { ["varname"] = "btn_cancel",     ["events"]={["event"]="click",["method"]="onClickclose"} }, 
    ["btn_sure"]    = { ["varname"] = "btn_sure",       ["events"]={["event"]="click",["method"]="onClicksuer"} },               
    ["btn_getcode"] = { ["varname"] = "btn_getcode",    ["events"]={["event"]="click",["method"]="onClickgetcode"} },               
    
    ["tf_phone"]    = { ["varname"] = "tf_phone" },     
    ["tf_set"]      = { ["varname"] = "tf_set" }, 
    ["tf_code"]     = { ["varname"] = "tf_code" },     

}

function PhoneAct:onCreate( ... )
    self:initWinEditBox("tf_phone")
    self:initWinEditBox("tf_set",true)
    self:initWinEditBox("tf_code")
    

    self.tf_phone:setPlaceHolder(FishGF.getChByIndex(800000133))
    self.tf_set:setPlaceHolder(FishGF.getChByIndex(800000136))
    self.tf_code:setPlaceHolder("")

    self:openTouchEventListener()
    
    self.btn_getcode:setEnabled(true)
    --self.btn_getcode:setBright(true)
    local spr_nosend = self.btn_getcode:getChildByName("spr_nosend")
    local spr_sendend = self.btn_getcode:getChildByName("spr_sendend")
    spr_nosend:setVisible(true)
    spr_sendend:setVisible(false)

end

function PhoneAct:initEditBoxStr(str)
    self.tf_phone:setString(str);
    self.tf_set:setString(str);
    self.tf_code:setString(str);
end

function PhoneAct:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function PhoneAct:onClickclose( sender )
    self:hideLayer() 
    FishGI.hallScene.uiPlayerInfo:showLayer() 
end

function PhoneAct:onClickgetcode( sender )
    FishGF.onClickGetCode(sender,self.tf_phone:getString(),"activate")
end

function PhoneAct:onClicksuer( sender )
    self:onClickPhoneActive()
end

--[[
* @brief 手机激活点击事件
]]
function PhoneAct:onClickPhoneActive()

    local phoneid = ""
    local pwd = ""
    local callback=function(x)

        -- 隐藏等待框
        FishGF.waitNetManager(false,nil,"PhoneAct")

        if x.status == 0 then
            FishGI.PLAYER_STATE = 1
            
            --更新本地账号存储信息
            local AccountTab = {}
            AccountTab["account"] = phoneid
            AccountTab["password"] = pwd
            local count = FishGI.WritePlayerData:getMaxKeys()
            local maxCount = tonumber(FishGI.GameConfig:getConfigData("config", tostring(990000046), "data"))
            if count >= maxCount then
                FishGI.WritePlayerData:removeByKey(1)
            end
            
            local accountTab = FishGI.WritePlayerData:getEndData()
            if accountTab ~= nil and accountTab["isVisitor"] ~= nil then
                FishGI.WritePlayerData:removeByAccount(accountTab["account"])
            end

            FishGI.WritePlayerData:upDataAccount(AccountTab)
            FishGF.setAccountAndPassword(phoneid,pwd,nil)
            print("------password="..pwd.."----phoneid="..phoneid)
            FishGI.hallScene.net.userName = phoneid
            
            --更新登陆那边的账号信息 以便于下次大厅刷新账号消息
            FishGI.loginScene.net:updateAccountPass(account, pwd);
            
            -- 激活账号成功通知 
            local str = FishGF.getChByIndex(800000143)..phoneid..FishGF.getChByIndex(800000144)
            FishGF.showMessageLayer(FishCD.MODE_MIN_OK_ONLY,str,nil)

            --界面更新
            self.tf_phone:setString("")
            self.tf_set:setString("")
            self.tf_code:setString("")
            self:hideLayer() 
            FishGI.WebUserData:initWithUserId(FishGI.WebUserData:GetUserId());
            FishGI.hallScene.uiPlayerInfo:upDataBtnState(true,true)

            FishGI.myData.account =  phoneid
            FishGI.hallScene.uiPlayerInfo:upDataPlayerData()
            if FishGI.WebUserData.setUserData ~= nil then
                FishGI.WebUserData:setUserData("attr",2)
            end
            FishGI.hallScene.taskPanel:requestForTaskInfo()

        else
            FishGF.showToast(x.msg)
        end
    end

    phoneid    = self.tf_phone:getString() --电话号码
    local code = self.tf_code:getString()  --验证码
    pwd        = self.tf_set:getString()   --密码
    -- 验证
    if FishGF.checkPhone( phoneid )and FishGF.checkCode( code ) and FishGF.checkPassword( pwd )   then
        -- 请求
        FishGI.Dapi:ActivateMobile(phoneid,code,pwd,Helper.GetDeviceCode(),callback)
        --显示等待框
        FishGF.waitNetManager(true,nil,"PhoneAct")
    end
end

return PhoneAct;