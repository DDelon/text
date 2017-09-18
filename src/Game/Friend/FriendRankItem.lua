local FriendRankItem = class("FriendRankItem", cc.load("mvc").ViewBase)

FriendRankItem.AUTO_RESOLUTION   = true
FriendRankItem.RESOURCE_FILENAME = "ui/battle/friend/uifriendrankitem"
FriendRankItem.RESOURCE_BINDING  = {
    ["img_rank_1"]          = { ["varname"] = "img_rank_1" },
    ["img_rank_2"]          = { ["varname"] = "img_rank_2" },
    ["text_integral"]       = { ["varname"] = "text_integral" },
}

function FriendRankItem:onCreate( ... )
    self:init()
    self:initView()
end

function FriendRankItem:init( )
    self.bOwner = false
end

function FriendRankItem:initView( )
    self.text_integral:setString(FishGI.GameConfig:getConfigData("config", "990000075", "data"))
    self:runAction(self.resourceNode_["animation"])
end

function FriendRankItem:setRankIndex(rankIndex)
    self.rankIndex = rankIndex
    self.scale1 = self.img_rank_1:getScale()
    local anchorPoint = self.img_rank_1:getAnchorPoint()
    self.img_rank_1:loadTexture(string.format("battle/friend/friend_rank_%d.png", rankIndex), 0)
    self.img_rank_1:setAnchorPoint(cc.p(anchorPoint))
    self.img_rank_1:setScale(self.scale1)
    self.scale2 = self.img_rank_2:getScale()
    anchorPoint = self.img_rank_2:getAnchorPoint()
    self.img_rank_2:loadTexture(string.format("battle/friend/friend_rank_%d.png", rankIndex), 0)
    self.img_rank_2:setAnchorPoint(cc.p(anchorPoint))
    self.img_rank_2:setScale(self.scale2)
end

function FriendRankItem:setScore(score)
    self.text_integral:setString(tostring(score))
end

function FriendRankItem:setOwner(bOwner)
    bOwner = bOwner ~= nil and bOwner or false
    if self.bOwner ~= bOwner and bOwner then
        local frameEventCallFunc = function (frameEventName)
            if frameEventName:getEvent() == "shake_end" then
                self.img_rank_1:setScale(self.scale1)
                self.img_rank_2:setScale(self.scale2)
            end
        end 
        self.resourceNode_["animation"]:play("shake", false)
        self.resourceNode_["animation"]:clearFrameEventCallFunc()
        self.resourceNode_["animation"]:setFrameEventCallFunc(frameEventCallFunc)
    end
    self.bOwner = bOwner
    if bOwner then
        self.text_integral:setColor(cc.c3b(255, 248, 199))
    else
        self.text_integral:setColor(cc.c3b(255, 222, 89))
    end
end

return FriendRankItem