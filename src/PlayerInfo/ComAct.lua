
local ComAct = class("ComAct", cc.load("mvc").ViewBase)

ComAct.AUTO_RESOLUTION   = false
ComAct.RESOURCE_FILENAME = "ui/playerinfo/uicom_act"
ComAct.RESOURCE_BINDING  = {    
    ["panel"]      = { ["varname"] = "panel" },
    ["btn_close"]  = { ["varname"] = "btn_close" ,      ["events"]={["event"]="click",["method"]="onClickclose"}},     
    ["btn_cancel"] = { ["varname"] = "btn_cancel",      ["events"]={["event"]="click",["method"]="onClickclose"} }, 
    ["btn_sure"]   = { ["varname"] = "btn_sure",        ["events"]={["event"]="click",["method"]="onClicksure"} },               
    
    ["tf_account"] = { ["varname"] = "tf_account" },     
    ["tf_set"]     = { ["varname"] = "tf_set" }, 
    ["tf_sure"]    = { ["varname"] = "tf_sure" }, 

}

function ComAct:onCreate( ... )
    self:initWinEditBox("tf_account")
    self:initWinEditBox("tf_set",true)
    self:initWinEditBox("tf_sure",true)
    self:initEditBoxStr("");

    self.tf_account:setPlaceHolder(FishGF.getChByIndex(800000131))
    self.tf_set:setPlaceHolder(FishGF.getChByIndex(800000136))
    self.tf_sure:setPlaceHolder(FishGF.getChByIndex(800000137))
    
    self:openTouchEventListener()
    
end

function ComAct:initEditBoxStr(str)
    self.tf_account:setString(str);
    self.tf_set:setString(str);
    self.tf_sure:setString(str);
end

function ComAct:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function ComAct:onClickclose( sender )
    self:hideLayer() 
    FishGI.hallScene.uiPlayerInfo:showLayer() 
end

function ComAct:onClicksure( sender )
    print("onClicksure")
--    FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
    self:onClickNormalActive()
end

--[[
* @brief 普通激活点击事件
]]
function ComAct:onClickNormalActive()

    local account = ""
    local pwd = ""
    local callback=function(x)
        -- 隐藏等待框
        FishGF.waitNetManager(false,nil,"ComAct")
        if x.status == 0 then            
            FishGI.PLAYER_STATE = 1
            -- 更新本地账号存储信息
            local AccountTab = {}
            AccountTab["account"] = account
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
            FishGF.setAccountAndPassword(account,pwd,nil)
            print("------password="..pwd.."----account="..account)
            FishGI.hallScene.net.userName = account

            --更新登陆那边的账号信息 以便于下次大厅刷新账号消息
            FishGI.loginScene.net:updateAccountPass(account, pwd)

            -- 激活账号成功通知 
            local str = FishGF.getChByIndex(800000143)..account..FishGF.getChByIndex(800000146)
            FishGF.showMessageLayer(FishCD.MODE_MIN_OK_ONLY,str,nil)

            --界面更新
            self.tf_account:setString("")
            self.tf_set:setString("")
            self.tf_sure:setString("")
            self:hideLayer() 
            FishGI.WebUserData:initWithUserId(FishGI.WebUserData:GetUserId());
            FishGI.hallScene.uiPlayerInfo:upDataBtnState(true,false)

            FishGI.myData.account =  account
            FishGI.hallScene.uiPlayerInfo:upDataPlayerData()
            
            if FishGI.WebUserData.setUserData ~= nil then
                FishGI.WebUserData:setUserData("attr",1)
            end
            FishGI.hallScene.taskPanel:requestForTaskInfo()

        else
            FishGF.showToast(x.msg)
        end
    end

    -- local name      = "真实姓名"
    -- personid      = "350623199007080054"   --身份证号
    account     = self.tf_account:getString()
    pwd         = self.tf_sure:getString()

    if FishGF.checkAccount( account ) and FishGF.checkPassword( pwd ) then
        FishGI.Dapi:ActivateAccount(account,pwd,Helper.GetDeviceCode(),callback)
        --显示等待框
        FishGF.waitNetManager(true,nil,"ComAct")
    end

end

return ComAct;