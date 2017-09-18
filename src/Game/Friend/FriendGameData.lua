local FriendGameData = class("FriendGameData", cc.load("mvc").ViewBase)

FriendGameData.AUTO_RESOLUTION   = true
FriendGameData.RESOURCE_FILENAME = "ui/battle/friend/uifriendgamedata"
FriendGameData.RESOURCE_BINDING  = {
    ["spr_bswks"]           = { ["varname"] = "spr_bswks" },
    ["node_game_timeout"]   = { ["varname"] = "node_game_timeout" },
    ["fnt_time_minu"]       = { ["varname"] = "fnt_time_minu" },
    ["fnt_time_sec"]        = { ["varname"] = "fnt_time_sec" },
    ["img_rank_my_bg"]      = { ["varname"] = "img_rank_my_bg" },
    ["node_rank_1"]         = { ["varname"] = "node_rank_1" },
    ["node_rank_2"]         = { ["varname"] = "node_rank_2" },
    ["node_rank_3"]         = { ["varname"] = "node_rank_3" },
    ["node_rank_4"]         = { ["varname"] = "node_rank_4" },
}

function FriendGameData:onCreate( ... )
    self:init()
    self:initView()
end

function FriendGameData:init()
    self:openTouchEventListener()
    self.iGameTimeout = tonumber(FishGI.GameConfig:getConfigData("config", "990000071", "data"))
    self.node_rank_item = {}
    self.tListInfo = {}
    self.tSortList = {}
    self.iCount = 0
    self.bTimeoutAni = false
end

function FriendGameData:onTouchBegan(touch, event)
    return false
end

function FriendGameData:initView()
    for i = 1, 4 do
        self.node_rank_item[i] = require("Game/Friend/FriendRankItem").new(self, self["node_rank_"..i])
        self.node_rank_item[i]:setRankIndex(i)
        self.node_rank_item[i]:setVisible(false)
    end
    self.img_rank_my_bg:setVisible(false)
    self:runAction(self.resourceNode_["animation"])
    self.resourceNode_["animation"]:play("init", false)
end

function FriendGameData:updateGameStatus(bStart)
    self.bStart = bStart or false
    self.spr_bswks:setVisible(not self.bStart)
    self.node_game_timeout:setVisible(self.bStart)
    self:unscheduleTimes()
    self.fnt_time_minu:setString(string.format( "%02d",math.floor( self.iGameTimeout / 60 ) ))
    self.fnt_time_sec:setString(string.format( "%02d",self.iGameTimeout % 60 ))
    if self.bStart then 
        local function updateTimeout()
            local iCountDown = self.iGameTimeout-math.floor( LuaCppAdapter:getInstance():getCurFrame()*0.05 )
            if iCountDown > 0 then 
                local iMinu = math.floor( iCountDown / 60 )
                local iSec = iCountDown % 60
                self.fnt_time_minu:setString(string.format( "%02d",iMinu ))
                self.fnt_time_sec:setString(string.format( "%02d",iSec ))
                if iMinu == 0 then
                    if not self.bTimeoutAni then
                        self.bTimeoutAni = true
                        self.resourceNode_["animation"]:play("effect_light", true)
                    end
                end
            else 
                self.fnt_time_minu:setString("00")
                self.fnt_time_sec:setString("00")
                self:unscheduleTimes()
                self.resourceNode_["animation"]:play("init", false)
                if self.funTimeoutCallBack then 
                    self.funTimeoutCallBack()
                end 
            end 
        end
        self.getCurFrameScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTimeout, 0.1, false)
    end 
end

function FriendGameData:unscheduleTimes()
    if self.getCurFrameScheduleId ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.getCurFrameScheduleId)
        self.getCurFrameScheduleId = nil
    end
end

--设置回调
function FriendGameData:setTimeoutCallBack( callback )
    self.funTimeoutCallBack = callback
end

function FriendGameData:setOwnerIndex(iOwnerIndex)
    self.iOwnerIndex = iOwnerIndex
end

function FriendGameData:setPlayerScore( iScore, iChairId )
    local bNew = false
    if self.tListInfo[iChairId] == nil then 
        self.iCount = self.iCount + 1
        self.node_rank_item[self.iCount]:setVisible(true)
        self.tListInfo[iChairId] = iScore
        table.insert( self.tSortList, iChairId )
        bNew = true
    else
        if self.tListInfo[iChairId] ~= iScore then 
            self.tListInfo[iChairId] = iScore
        else 
            return
        end
    end 
    -- 根据积分排序
    local iSortIndex = table.getn(self.tSortList)
    if not bNew then 
        for i = 1, table.getn(self.tSortList) do 
            if self.tSortList[i] == iChairId then 
                iSortIndex = i
                break
            end 
        end
    end 
    local iFind = table.getn(self.tSortList)
    for i, v in pairs(self.tSortList) do
        if iChairId == v then 
            --自己跳过
        elseif iScore > self.tListInfo[v] then 
            if iSortIndex > i then
                iFind = i
            else
                iFind = i-1
            end
            break
        end 
    end
    if iFind ~= iSortIndex then 
        if iFind < iSortIndex then 
            for i = iSortIndex, iFind+1, -1 do 
                self.tSortList[i] = self.tSortList[i-1]
            end 
        else
            for i = iSortIndex, iFind-1, 1 do 
                self.tSortList[i] = self.tSortList[i+1]
            end 
        end 
        self.tSortList[iFind] = iChairId
    end

    for i, v in pairs(self.tSortList) do
        self.node_rank_item[i]:setScore(self.tListInfo[v])
        if v == self.iOwnerIndex then 
            self.img_rank_my_bg:setPositionY(self.node_rank_item[i]:getPositionY())
            self.img_rank_my_bg:setVisible(true)
            self.node_rank_item[i]:setOwner(true)
        else
            self.node_rank_item[i]:setOwner(false)
        end
    end
end

return FriendGameData