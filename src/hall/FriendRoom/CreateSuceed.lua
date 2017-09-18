local CreateSuceed = class("CreateSuceed", cc.load("mvc").ViewBase)

CreateSuceed.AUTO_RESOLUTION   = false
CreateSuceed.RESOURCE_FILENAME = "ui/hall/friend/uicreatesucceed"
CreateSuceed.RESOURCE_BINDING  = {    
    ["panel"]         = { ["varname"] = "panel" }, 
    
    ["text_notice_1"] = { ["varname"] = "text_notice_1" },
    ["text_notice_2"] = { ["varname"] = "text_notice_2" },
    
    ["text_roomno"]   = { ["varname"] = "text_roomno" },
    
    ["btn_share"]     = { ["varname"] = "btn_share" ,         ["events"]={["event"]="click",["method"]="onClickshare"}},
    ["btn_enter"]     = { ["varname"] = "btn_enter" ,         ["events"]={["event"]="click",["method"]="onClickenter"}},

}

function CreateSuceed:onCreate( ... )
    self:openTouchEventListener()

    self.text_notice_1:setString(FishGF.getChByIndex(800000246))
    self.text_notice_2:setString(FishGF.getChByIndex(800000247))

    self.btn_enter.enterPosX = self.btn_enter:getPositionX()

end

--设置是否开启微信
function CreateSuceed:setWechatIsOpen(isOpen)
    if not isOpen then
         self.btn_share:setVisible(false)
         self.btn_enter:setPositionX(0)
    else
         self.btn_share:setVisible(true)
         self.btn_enter:setPositionX(self.btn_enter.enterPosX)
    end
end

function CreateSuceed:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function CreateSuceed:onClickenter( sender )
    print("onClickenter")
    FishGI.hallScene.uiFriendRoom:sendJoinFriendRoom()
    self:hideLayer()
end

function CreateSuceed:onClickshare( sender )
    print("onClickshare")
    local shareInfo = FishGI.WebUserData:GetShareDataTable();
    local url = shareInfo.url
    if url == nil then
        url = "https://client-fish.weile.com/share/fish/channel_id/"..CHANNEL_ID.."/from_app/"..APP_ID.."/from_region/0"
    end
    local wechatAppId = shareInfo.id
    if wechatAppId == nil then
        wechatAppId = WX_APP_ID_LOGIN
    end
    local title = FishGF.getChByIndex(800000241)..FishGF.getChByIndex(800000218)..self.friendRoomNo
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_WINDOWS ~= targetPlatform) then
        FishGI.ShareHelper:doShareAppWebType(title,FishGF.getChByIndex(800000294),url,0,wechatAppId)
    end
end

function CreateSuceed:setRoomNo( friendRoomNo )
    print("setRoomNo")
    self.friendRoomNo = friendRoomNo
    self.text_roomno:setString(friendRoomNo)

end

return CreateSuceed;