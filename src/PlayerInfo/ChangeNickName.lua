
local ChangeNickName = class("ChangeNickName", cc.load("mvc").ViewBase)

ChangeNickName.AUTO_RESOLUTION   = false
ChangeNickName.RESOURCE_FILENAME = "ui/playerinfo/uichange_name"
ChangeNickName.RESOURCE_BINDING  = {    
    ["panel"]         = { ["varname"] = "panel" },
    ["btn_close"]     = { ["varname"] = "btn_close" ,       ["events"]={["event"]="click",["method"]="onClickclose"}},     
    
    ["btn_cancel"]    = { ["varname"] = "btn_cancel",       ["events"]={["event"]="click",["method"]="onClickclose"} }, 
    ["btn_sure"]      = { ["varname"] = "btn_sure",         ["events"]={["event"]="click",["method"]="onClicksure"} },               
    
    ["tf_nick"]       = { ["varname"] = "tf_nick" },     
    ["text_notice"]   = { ["varname"] = "text_notice" },     
    
}

function ChangeNickName:onCreate( ... )
    self:initWinEditBox("tf_nick")
    self:initEditBoxStr("");

    self.tf_nick:setPlaceHolder(FishGF.getChByIndex(800000205))
    self.text_notice:setString(FishGF.getChByIndex(800000223));

    self:openTouchEventListener()
end

function ChangeNickName:initEditBoxStr(str)
    self.tf_nick:setString(str);
end

function ChangeNickName:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function ChangeNickName:onClickclose( sender )
    self:hideLayer() 
    FishGI.hallScene.uiPlayerInfo:showLayer() 
end

function ChangeNickName:onClicksure( sender )
    print("onClicksure")
    self:onClickCommit()
end

function ChangeNickName:onClickCommit()
    print("---------ChangeNickName:onClickCommit----------")
    local nick   = self.tf_nick:getString()

    --检查新密码是否符合规范
    if FishGF.checkNickName( nick ) then
        local function callback(sender)
            local tag = sender:getTag()
            if tag == 2 then
                --self:hideLayer(false) 
                --发送消息
                FishGI.hallScene.net.roommanager:sendChangeNickName(nick)
            end
        end
        local str = FishGF.getChByIndex(800000191)..nick..FishGF.getChByIndex(800000192)
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,str,callback)
    end

end

return ChangeNickName;