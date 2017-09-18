local FriendStartGame = class("FriendStartGame", cc.load("mvc").ViewBase)

FriendStartGame.AUTO_RESOLUTION   = true
FriendStartGame.RESOURCE_FILENAME = "ui/battle/friend/uifriendstartgame"
FriendStartGame.RESOURCE_BINDING  = {
    ["panel"]               = { ["varname"] = "panel" },
    ["text_room_num"]       = { ["varname"] = "text_room_num" },
    ["text_room_number"]    = { ["varname"] = "text_room_number" },
    ["btn_invite_friend"]   = { ["varname"] = "btn_invite_friend", ["events"]={["event"]="click",["method"]="onClickInviteFriend"}},
    ["btn_start_game"]      = { ["varname"] = "btn_start_game", ["events"]={["event"]="click",["method"]="onClickStartGame"}},
    ["btn_ready_game"]      = { ["varname"] = "btn_ready_game", ["events"]={["event"]="click",["method"]="onClickReadyGame"}},
    ["btn_dissolve_room"]   = { ["varname"] = "btn_dissolve_room", ["events"]={["event"]="click",["method"]="onClickDissolveRoom"}},
}

function FriendStartGame:onCreate( ... )
    self:init()
    self:initView()
end

function FriendStartGame:init()   
    self.panel:setSwallowTouches(false)
    self:openTouchEventListener()
    self.bRoomOwner = false
    self.btn_start_game.startPosX = self.btn_start_game:getPositionX()
    self.btn_ready_game.readyPosX = self.btn_ready_game:getPositionX()
end

function FriendStartGame:initView()
    --设置房间号
    self.text_room_number:setString(FishGI.FRIEND_ROOMNO)
end

function FriendStartGame:onEnter()
    FriendStartGame.super.onEnter(self)
    self.panel:setContentSize(cc.size(display.width, display.height))
end

function FriendStartGame:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false  
    end
    return true
end

function FriendStartGame:onClickInviteFriend( sender )
    self.parent_:buttonClicked("FriendStartGame", "InviteFriend")
end

function FriendStartGame:onClickStartGame( sender )
    self.parent_:buttonClicked("FriendStartGame", "StartGame")
end

function FriendStartGame:onClickReadyGame( sender )
    self.parent_:buttonClicked("FriendStartGame", "ReadyGame")
end

function FriendStartGame:onClickDissolveRoom( sender )
    self.parent_:buttonClicked("FriendStartGame", "DissolveRoom")
end

function FriendStartGame:setRoomOwner( bRoomOwner )
    self.bRoomOwner = bRoomOwner
    self.btn_start_game:setVisible(self.bRoomOwner)
    self.btn_dissolve_room:setVisible(self.bRoomOwner)
    self.btn_ready_game:setVisible(not self.bRoomOwner)
end

--设置是否开启微信
function FriendStartGame:setWechatIsOpen(isOpen)
    if not isOpen then
         self.btn_invite_friend:setVisible(false)
         self.btn_start_game:setPositionX(0)
         self.btn_ready_game:setPositionX(0)
    else
         self.btn_invite_friend:setVisible(true)
         self.btn_start_game:setPositionX(self.btn_start_game.gamePosX)
         self.btn_ready_game:setPositionX(self.btn_ready_game.readyPosX)
    end
end

return FriendStartGame