local FriendBox = class("FriendBox", cc.load("mvc").ViewBase)

FriendBox.AUTO_RESOLUTION   = true
FriendBox.RESOURCE_FILENAME = "ui/battle/friend/uifriendbox"
FriendBox.RESOURCE_BINDING  = {
    ["loading_bar"]         = { ["varname"] = "loading_bar" },
    ["node_box_bg_1"]       = { ["varname"] = "node_box_bg_1" },
    ["node_box_bg_2"]       = { ["varname"] = "node_box_bg_2" },
    ["node_box_bg_3"]       = { ["varname"] = "node_box_bg_3" },
    ["node_box_bg_4"]       = { ["varname"] = "node_box_bg_4" },
    ["node_box_1"]          = { ["varname"] = "node_box_1"},
    ["node_box_2"]          = { ["varname"] = "node_box_2"},
    ["node_box_3"]          = { ["varname"] = "node_box_3"},
    ["node_box_4"]          = { ["varname"] = "node_box_4"},
    ["fnt_box_1"]           = { ["varname"] = "fnt_box_1" },
    ["fnt_box_2"]           = { ["varname"] = "fnt_box_2" },
    ["fnt_box_3"]           = { ["varname"] = "fnt_box_3" },
    ["fnt_box_4"]           = { ["varname"] = "fnt_box_4" },
}

function FriendBox:onCreate( ... )
    self:init()
    self:initView()
end

function FriendBox:init()
    self:openTouchEventListener()
    self.score = 0
    self.loading_bar:setPercent(0)
    self.tProgress = {}
    self.node_box_item = {}
    self.tLevelData = {}
end

function FriendBox:onTouchBegan(touch, event)
    return false
end

function FriendBox:initView()
end

function FriendBox:onEnter()
    self.scaleX_,self.scaleY_,self.scaleMin_  = FishGF.getCurScale()
    local strBoxProgress = FishGI.GameConfig:getConfigData("config", "990000077", "data")
    local tBoxData = string.split(strBoxProgress, ";")
    FriendBox.super.onEnter(self)
    for i, v in pairs(tBoxData) do 
        if string.len( v ) > 0 then 
            self.node_box_item[i] = require("Game/Friend/FriendBoxItem").new(self, self["node_box_"..i])
            self.node_box_item[i]:setTag(i)
            self.node_box_item[i]:setPos(cc.p(self:getPositionX()+self["node_box_bg_"..i]:getPositionX()+self.node_box_item[i]:getPositionX(), 
                self:getPositionY()-self.loading_bar:getContentSize().width*self.scaleMin_/2+self["node_box_bg_"..i]:getPositionY()*self.scaleMin_+self.node_box_item[i]:getPositionY()*self.scaleMin_))
            self.tProgress[i] = tonumber(string.split(v, ",")[1])
            self["fnt_box_"..i]:setString(tostring(self.tProgress[i]))
        end 
    end 
end

function FriendBox:setLevelData( score, tProps )
    if score and table.getn(tProps) then
        for i, v in pairs(self.tProgress) do
            if v == score then 
                self.tLevelData[i] = {} 
                self.tLevelData[i].iPlayStatus = 0 -- 宝箱动画状态：0：未开始，1：进行中，2：已完成
                self.tLevelData[i].tProps = tProps
                break
            end 
        end
    end 
end 

function FriendBox:setScore( score )
    if self.score == score then 
        return
    end 
    self.score = score

    local iBoxIndex = 0
    local iTotalPos = self["node_box_bg_"..table.getn(self.tProgress)]:getPositionY()
    if score >= self.tProgress[table.getn(self.tProgress)] then 
        self.loading_bar:setPercent(100)
        iBoxIndex = table.getn(self.tProgress)
    elseif score < self.tProgress[1] then 
        local pos = score/self.tProgress[1]*(self["node_box_bg_"..1]:getPositionY())
        self.loading_bar:setPercent(pos/iTotalPos*100)
        iBoxIndex = 0
    else 
        for i = table.getn(self.tProgress), 1, -1 do 
            if score >= self.tProgress[i] then 
                local posYMinBox = self["node_box_bg_"..i]:getPositionY()
                local posYBetweenBoxs = (score-self.tProgress[i])/(self.tProgress[i+1]-self.tProgress[i])*(self["node_box_bg_"..i+1]:getPositionY()-posYMinBox)
                self.loading_bar:setPercent((posYMinBox+posYBetweenBoxs)/iTotalPos*100)
                iBoxIndex = i
                break
            end 
        end
    end 
    if iBoxIndex > 0 then 
        for i=1,iBoxIndex do
            local node_box_item = self.node_box_item[i]
            if self.tLevelData[i] and table.getn(self.tLevelData[i].tProps) > 0 then 
                if self.tLevelData[i].iPlayStatus == 0 then
                    self.tLevelData[i].iPlayStatus = 1
                    local function callBackAni(nodeBoxItem)
                        local iNodeTag = nodeBoxItem:getTag()
                        self.tLevelData[iNodeTag].iPlayStatus = 2
                    end
                    node_box_item:setStatus(node_box_item.g_eStatus.eOpen,self.tLevelData[i].tProps, callBackAni)
                elseif self.tLevelData[i].iPlayStatus == 2 then
                    node_box_item:setStatus(node_box_item.g_eStatus.eAfterOpen)
                end 
            else 
                node_box_item:setStatus(node_box_item.g_eStatus.eAfterOpen)
            end  
        end 
    end 
end

return FriendBox