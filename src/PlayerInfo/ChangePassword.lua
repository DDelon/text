
local ChangePassword = class("ChangePassword", cc.load("mvc").ViewBase)

ChangePassword.AUTO_RESOLUTION   = false
ChangePassword.RESOURCE_FILENAME = "ui/playerinfo/uichange_password"
ChangePassword.RESOURCE_BINDING  = {    
    ["panel"]      = { ["varname"] = "panel" },
    ["btn_close"]  = { ["varname"] = "btn_close" ,      ["events"]={["event"]="click",["method"]="onClickclose"}},     
    ["btn_cancel"] = { ["varname"] = "btn_cancel",      ["events"]={["event"]="click",["method"]="onClickclose"} }, 
    ["btn_sure"]   = { ["varname"] = "btn_sure",        ["events"]={["event"]="click",["method"]="onClicksure"} },               
    
    ["tf_initial"] = { ["varname"] = "tf_initial" },     
    ["tf_set"]     = { ["varname"] = "tf_set" }, 
    ["tf_sure"]    = { ["varname"] = "tf_sure" }, 

}

function ChangePassword:onCreate( ... )
    self:initWinEditBox("tf_initial",true)
    self:initWinEditBox("tf_set",true)
    self:initWinEditBox("tf_sure",true)
    self:initEditBoxStr("");

    self.tf_initial:setPlaceHolder(FishGF.getChByIndex(800000135))
    self.tf_set:setPlaceHolder(FishGF.getChByIndex(800000136))
    self.tf_sure:setPlaceHolder(FishGF.getChByIndex(800000137))
    
    self:openTouchEventListener()
    
end

function ChangePassword:initEditBoxStr(str)
    self.tf_initial:setString(str);
    self.tf_set:setString(str);
    self.tf_sure:setString(str);
end

function ChangePassword:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function ChangePassword:onClickclose( sender )
    self:hideLayer() 
    FishGI.hallScene.uiPlayerInfo:showLayer() 
end

function ChangePassword:onClicksure( sender )
    print("onClicksure")
--    FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
    local initialpassword   = self.tf_initial:getString()
    local setpassword   = self.tf_set:getString()
    local surepassword   = self.tf_sure:getString()

    self:onClickCommit()
end

function ChangePassword:onClickCommit()

    local new = ""
    local callback=function(x)
        FishGF.waitNetManager(false,nil,"ChangePassword")
        if x.status == 0 then
            -- 刷新本地密码密码存储 
            local account,password = FishGF.getAccountAndPassword()
            local AccountTab = {}
            AccountTab["account"] = account
            AccountTab["password"] = new
            local count = FishGI.WritePlayerData:getMaxKeys()
            local maxCount = tonumber(FishGI.GameConfig:getConfigData("config", tostring(990000046), "data"))
            if count >= maxCount then
                FishGI.WritePlayerData:removeByKey(1)
            end
            FishGI.WritePlayerData:upDataAccount(AccountTab)
            FishGF.setAccountAndPassword(account,new,nil)
            --更新登陆那边的账号信息 以便于下次大厅刷新账号消息
            FishGI.loginScene.net:updateAccountPass(account, new);
            print("------newpassword="..new)

            --界面更新
            self.tf_initial:setString("")
            self.tf_set:setString("")
            self.tf_sure:setString("")
            self:hideLayer() 

            --修改密码成功
            FishGF.showMessageLayer(FishCD.MODE_MIN_OK_ONLY,FishGF.getChByIndex(800000151),nil)

        else
            FishGF.showMessageLayer(FishCD.MODE_MIN_OK_ONLY,x.msg,nil)
        end
    end


    local old   = self.tf_initial:getString()
    new = self.tf_set:getString()
    local new2  = self.tf_sure:getString()

    if #old <=0 then
        FishGF.showToast(FishGF.getChByIndex(800000135))
        return 
    end

    -- 密码验证
    if new ~= new2 then
        FishGF.showToast(FishGF.getChByIndex(800000233))
        return
    end

    -- 检查新密码是否符合规范
    if FishGF.checkPassword( new ) then
        --发送消息
        FishGI.Dapi:ModifyPassword(old,new,callback)

        --显示等待框
        FishGF.waitNetManager(true,nil,"ChangePassword")
    end
end

return ChangePassword;