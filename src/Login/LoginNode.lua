
local LoginNode = class("LoginNode", cc.load("mvc").ViewBase)

LoginNode.AUTO_RESOLUTION   = true
LoginNode.RESOURCE_FILENAME = "ui/login/uiloginnode"
LoginNode.RESOURCE_BINDING  = {    
       ["panel"]       = { ["varname"] = "panel" },
       ["btn_close"]   = { ["varname"] = "btn_close" ,     ["events"]={["event"]="click",["method"]="onClickclose"}},     
       ["btn_OK"]      = { ["varname"] = "btn_OK",         ["events"]={["event"]="click",["method"]="onClickOK"} }, 
       
       ["tf_account"]  = { ["varname"] = "tf_account" },     
       ["tf_password"] = { ["varname"] = "tf_password" }, 
       
}

function LoginNode:onCreate( ... )
    self:initWinEditBox("tf_account")
    self:initWinEditBox("tf_password",true)

    self.tf_account:setNewPlaceHolder(FishGF.getChByIndex(800000131))
    self.tf_password:setNewPlaceHolder(FishGF.getChByIndex(800000132))

    self:openTouchEventListener()

end

function LoginNode:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function LoginNode:onClickclose( sender )
    self:hideLayer() 
end

function LoginNode:onClickOK( sender )
    self:hideLayer() 
    local account   = self.tf_account:getString()
    local password   = self.tf_password:getString()

    if FishGF.checkAccount(account) and FishGF.checkPassword(password) then
        self:getParent().net:loginByUserAccount(account, password);
    end

    print("zhanghao"..account.."mima"..password)  
end

function LoginNode:setAccountData( accountTab )
    local account = accountTab["account"]
    local password = accountTab["password"]
    local isVisitor = accountTab["isVisitor"]

    if isVisitor ~= nil then
        account = ""
        password = ""
    end
    self.tf_account:setString(account)
    self.tf_password:setString(password)

end

return LoginNode;