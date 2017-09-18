local TaskProcess = class("TaskProcess", cc.load("mvc").ViewBase)

TaskProcess.AUTO_RESOLUTION     = 0
TaskProcess.RESOURCE_FILENAME   = "ui/hall/task/uitask_process"
TaskProcess.RESOURCE_IMAGE_BASE = "res/hall/"

TaskProcess.RESOURCE_BINDING  = {
    ["loading_processbar"]      = { ["varname"] = "loading_processbar" },
    ["txt_active_count"]        = { ["varname"] = "txt_active_count" },
    ["panel"]                   = { ["varname"] = "panel" },
}
local PROCESS_PIXEL = 700

function TaskProcess:setPercent(percent, treasureConfig)
    local total = tonumber(treasureConfig[#treasureConfig])
    self.loading_processbar:setPercent(percent/total * 100)
    self.txt_active_count:setString(tostring(percent))
end

function TaskProcess:openTheBox(ActiveGrade)
    log("ActiveGrade "..ActiveGrade )
    
    self.treasureItem[tostring(ActiveGrade)]:setOpen()
end

function TaskProcess:isPosInNode(node, worldPos)
    local bg = node:getContentSize()
    local rect = cc.rect(0, 0, bg.width, bg.height)
    local nodePos = node:convertToNodeSpace(worldPos)

    return cc.rectContainsPoint(rect, nodePos)
end


function TaskProcess:displayTreasureBox(opened_treasures, curActive, treasureConfig)
    self.activeConfig = {}
    for i,v in ipairs(treasureConfig) do
        if self:isValueInTable(v, opened_treasures) then 
            self.treasureItem[v]:setOpen()
        
        elseif tonumber(v) <= curActive then
            self.activeConfig[#self.activeConfig + 1] = v
            self.treasureItem[v]:setActive()
        
        else
            self.treasureItem[v]:setClose()
        end
    end
end

function TaskProcess:getActiveItems()
    return self.activeConfig
end

function TaskProcess:removeTagTask(key)
    local index
    for k,v in pairs(self.activeConfig) do
        if v == key then
            index = k
            break
        end
    end
    
    table.remove(self.activeConfig, index)
end

function TaskProcess:initProcess(treasureConfig, tipString)
    log("TaskProcess:initProcess")
    self.treasureItem = {}
    local total = treasureConfig[#treasureConfig]
    self.loading_processbar.nodeType = "viewlist"
    for i,v in ipairs(treasureConfig) do
        log("process: " .. v)
        local x = PROCESS_PIXEL/total * tonumber(v)
        local y = 30

        local triangle = cc.Sprite:create(TaskProcess.RESOURCE_IMAGE_BASE .. "task/task_triangle.png")
        triangle:setPosition(x, -10)

        local treasureAnimation = require("hall/Task/TaskUI/TreasureBox").new()
        if i == #treasureConfig then
            treasureAnimation:setEndItem()
            x = x - 3
            y = y + 10
        end
        
        treasureAnimation:setScale(0.8)
        treasureAnimation:setPosition(x, y)
        treasureAnimation:setActiveLevel(v)
        treasureAnimation:setClose()
        treasureAnimation:setTipString(tipString[i])
        
        self.treasureItem[v] = treasureAnimation

        local subText = ccui.Text:create()
        subText:setTextColor({r = 72, g = 79, b = 89})
        subText:setFontSize(20)
        subText:setString(v)
        subText:setPosition(x, -20)

        self.loading_processbar:addChild(treasureAnimation)
        self.loading_processbar:addChild(subText)
        self.loading_processbar:addChild(triangle)
        
        log(i,v)
    end
end

-----------------------------------------------------------------------------
function TaskProcess:onCreate( ... )
    log("dsx TaskProcess:onCreate")
end

function TaskProcess:isPosInNode(node, worldPos)
    local bg = node:getContentSize()
    local rect = cc.rect(0, 0, bg.width, bg.height)
    local nodePos = node:convertToNodeSpace(worldPos)

    return cc.rectContainsPoint(rect, nodePos)
end

function TaskProcess:isValueInTable(value, tab)
    for i,v in ipairs(tab) do
        if value == v then
            return true
        end
    end

    return false
end

function TaskProcess:doPlayGainAnimate(propId, propCount, treasureId)
    FishGMF.addTrueAndFlyProp(FishGI.myData.playerId,tonumber(propId),tonumber(propCount),false)
    FishGMF.setAddFlyProp(FishGI.myData.playerId,tonumber(propId),tonumber(propCount),false)

    local propTab = {}
    propTab.playerId = FishGI.myData.playerId
    propTab.propId = tonumber(propId)
    propTab.propCount = tonumber(propCount)
    propTab.isRefreshData = true
    propTab.isJump = true
    propTab.firstPos = self:getFirstPos(self.treasureItem[tostring(treasureId)])
    propTab.dropType = "normal"
    propTab.isShowCount = false
    FishGI.GameEffect:playDropProp(propTab)
end

function TaskProcess:doPlayGainAnimateActive(rewardItems, seniorProps, treasureId)
    local playerId = FishGI.myData.playerId

    --普通道具
    for k,val in pairs(rewardItems) do
        FishGMF.addTrueAndFlyProp(playerId,val.propId,val.propCount,false)
        FishGMF.setAddFlyProp(playerId,val.propId,val.propCount,false)

        local propTab = {}
        propTab.playerId = playerId
        propTab.propId = val.propId
        propTab.propCount = val.propCount
        propTab.isRefreshData = true
        propTab.isJump = true
        propTab.firstPos = self:getFirstPos(self.treasureItem[tostring(treasureId)])
        propTab.dropType = "normal"
        propTab.isShowCount = false
        FishGI.GameEffect:playDropProp(propTab)
    end

    --高级道具
    for k,val in pairs(seniorProps) do
        FishGMF.refreshSeniorPropData(playerId,val,8,0)

        local propTab = {}
        propTab.playerId = playerId
        propTab.propId = val.propId
        propTab.propCount = 1
        propTab.isRefreshData = true
        propTab.isJump = true
        propTab.firstPos = self:getFirstPos(self.treasureItem[tostring(treasureId)])
        propTab.dropType = "normal"
        propTab.isShowCount = false
        propTab.seniorPropData = val
        FishGI.GameEffect:playDropProp(propTab)
    end
end

function TaskProcess:getFirstPos( nodeStar )
    log("TaskProcess:getFirstPos")
    local child = nodeStar
    if child == nil then
        return nil
    end 
    log("TaskProcess:getFirstPosx: ", child:getPositionX())
    log("TaskProcess:getFirstPosy: ", child:getPositionY())
    local pos = cc.p(child:getPositionX(),child:getPositionY())
    pos = self.panel:convertToWorldSpace(pos)

    return pos
end

return TaskProcess