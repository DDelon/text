local TaskMain = class("TaskMain", cc.load("mvc").ViewBase)

TaskMain.AUTO_RESOLUTION   = 0
TaskMain.RESOURCE_FILENAME = "ui/hall/task/uitask_main"

TaskMain.RESOURCE_BINDING  = {
    ["panel"]               = { ["varname"] = "panel" },      
    ["scl_task_container"]  = { ["varname"] = "scl_task_container",         ["nodeType"]="viewlist"   },
    ["btn_close"]           = { ["varname"] = "btn_close"  ,                ["events"]={["event"]="click",["method"]="onClickClose"}},
    ["img_bg"]              = { ["varname"] = "img_bg" },   
}

local PROCESS_BAR_INTERVAL = 113
local PROCESS_BAR_WIDTH = 910
local MAIN_WIDTH = 934

function TaskMain:onTaskEvent(valTab)
    log("eventType: " .. valTab.eventType)
    
    if valTab.eventType == "DO_TASK_GO" then
        local task = {}
        task.nTaskID = valTab.taskId
        task.taskType = valTab.taskType
        self:hideLayer(false)
        self:doEventUtil(task)

    elseif valTab.eventType == "DO_TASK_GET" then
        local task = {}
        task.nTaskID = valTab.taskId
        local item = self.taskItems[valTab.taskId]
        self.TaskMessage:requestForReward(task)

    elseif valTab.eventType == "DO_GET_ACTIVE_REWARD" then
        local data = {}
        data.ActiveGrade = valTab.ActiveGrade
        self.TaskMessage:requestForActiveReward(data)

    elseif valTab.eventType == "ON_TASK_INFO_RESULT" then
        local taskInfoSorted = self:doTaskInfoUtil(valTab.result.TaskInfo)
        self.treasureOpened = valTab.result.TaskTreasureChest
        self:initTaskScroll(taskInfoSorted)
        self:initTaskProcess(taskInfoSorted, self.treasureOpened)
        self:checkAndShowTaskButton()
        if self.doShow then
            self.doShow = false
            self:showLayer()
        end
    elseif valTab.eventType == "ON_TASK_REWARD_RESULT" then
        local task_reward_result = valTab.result
        if not task_reward_result.isSuccess then return end

        local task_databin = self.taskDatas:getTaskDataById(430000000 + task_reward_result.nTaskID)
        local val = string.split(task_databin.task_reward,",")
        self.active_count = task_databin.task_active + self.active_count

        self.processbar:setPercent(self.active_count, self.taskDatas:getTreasureConfig())
        self:setItemButtonDone(task_reward_result.nTaskID)
        self:displayTreasureBox(self.treasureOpened, self.active_count, self.taskDatas:getTreasureConfig())
        self:removeTagTask(task_reward_result.nTaskID, self.getableTable)
        self:notifyUserReward(val[1], val[2])
        self:checkAndShowTaskButton()
        self.taskItems[task_reward_result.nTaskID]:doPlayGainAnimate(val[1], val[2])

    elseif valTab.eventType == "ON_ACTIVE_REWARD_RESULT" then
        local result = valTab.result
        if not result.isSuccess then return end

        self.treasureOpened[#self.treasureOpened + 1] = result.ActiveGrade
        self.processbar:openTheBox(result.ActiveGrade)
        self.processbar:removeTagTask(result.ActiveGrade)
        self:checkAndShowTaskButton()
        self:notifyUserRewardActive(result.props, result.seniorProps)
        self.processbar:doPlayGainAnimateActive(result.props, result.seniorProps, result.ActiveGrade)

    elseif valTab.eventType == "ON_TASK_FINISH" then
        self:addTagTask(valTab.result.nTaskID, self.getableTable)
        self:checkAndShowTaskButton()
    end
end

function TaskMain:onEnterHall()
    log("dsx TaskMain:onEnterHall")
    FishGI.eventDispatcher:registerCustomListener("onTaskEvent", self, function(valTab) self:onTaskEvent(valTab) end);
    self.TaskMessage:initTaskMessage()
    self:requestForTaskInfo()
end

function TaskMain:onClickClose()
    self:hideLayer()
end

function TaskMain:onCreate( ... )
    log("dsx TaskMain:onCreate")
    self:setScale(self.scaleMin_)
    self.taskDatas = require("hall/Task/TaskData").create()
    self.TaskMessage = require("hall/Task/TaskMessage").create()
    self.processbar = require("hall/Task/TaskUI/TaskProcess").new()

    self.processbar:initProcess(self.taskDatas:getTreasureConfig(), self.taskDatas:getRewardTaskInfo())
    self.processbar:setPosition(45, 158)

    self.panel:addChild(self.processbar)

    self:openTouchEventListener()
end

--------------------------------------------------------------------
function TaskMain:checkAndShowTaskButton()
    local isJumping = #self.getableTable > 0 or #self.processbar:getActiveItems() > 0

    FishGI.hallScene.view:setBtnIsLight(2, isJumping)
end

function TaskMain:notifyUserRewardActive(props, seniorProps)
    local out = ""
    for k,val in pairs(props) do
        if out == "" then
            out = self:getPropInfo(val.propId, val.propCount)
        else 
            out = out .. ", " .. self:getPropInfo(val.propId, val.propCount)
        end
    end

    for k,val in pairs(seniorProps) do
        if out == "" then
            out = self:getPropInfo(val.propId, 1)
        else 
            out = out .. ", " .. self:getPropInfo(val.propId, 1)
        end
    end
    
    FishGF.showSystemTip(out, nil, 3)
end

function TaskMain:notifyUserReward(nPropId, nPropCount)
    FishGF.showSystemTip(self:getPropInfo(nPropId, nPropCount), nil, 3)
end

function TaskMain:getPropInfo(nPropId, nPropCount)
    local itemName = FishGI.GameTableData:getItemTable(nPropId).name
    local output = string.format("%s %s %s", FishGF.getChByIndex(800000005), nPropCount, itemName)

    return output
end

function TaskMain:setItemButtonDone(taskId)
   local task = self.taskItems[taskId]
    task:setButtonDisplay(true)
end

function TaskMain:removeTagTask(taskId, taskTags)
    local index
    for k,v in pairs(taskTags) do
        if v == taskId then
            index = k
            break
        end
    end
    
    table.remove(taskTags, index)
end


function TaskMain:addTagTask(taskId, taskTags)
    table.insert(taskTags, #taskTags + 1, taskId)
end

function TaskMain:isPosInNode(node, worldPos)
    local bg = node:getContentSize()
    local rect = cc.rect(0, 0, bg.width, bg.height)
    local nodePos = node:convertToNodeSpace(worldPos)

    return cc.rectContainsPoint(rect, nodePos)
end

------------------------------------------------------------------------
function TaskMain:onTouchBegan(touch, event)
    if not self:isVisible() then
        return false
    end
    log("TaskMain:onTouchBegan")

    return true
end

function TaskMain:onTouchEnded(touch, event)
    if not self:isVisible() then
        return false
    end
    log("TaskMain:onTouchEnded")

    return true
end

function TaskMain:initTaskScroll(taskInfos)
    log("TaskMain:initTaskScroll")
    log("#taskInfo: " .. #taskInfos)

    self.scl_task_container:removeAllChildren()
    self.scl_task_container:setSwallowTouches(false)
    self.scl_task_container:setScrollBarEnabled(false)
    self.scl_task_container:setInnerContainerSize(cc.size(PROCESS_BAR_WIDTH, PROCESS_BAR_INTERVAL * #taskInfos))

    self.taskItems = {}
    local hideCount = 0
    for i,task in ipairs(taskInfos) do
        log(i,task)
        local task_databin = self.taskDatas:getTaskDataById(430000000 + task.nTaskID)
        local isAdded = self:addTaskItem(task.nTaskID, task.nTaskNum, task.isReward, task_databin, i - hideCount, #taskInfos)
        if isAdded == false then 
            hideCount = hideCount + 1
        end
    end
end

	

function TaskMain:doTaskInfoUtil(taskInfos)  -- 排序 筛选 大厅是否跳跃
    local tableNew = {}
    local head = 0
    local special = 0
    local getable = 0
    local normal = 0
    self.getableTable = {}
    local isNoPlayGetAct = (bit.band(FUN_SWITCH, 8) == 8)
    local isOpenWechat = not (bit.band(FUN_SWITCH, 1) == 1)

    for i,task in ipairs(taskInfos) do
        if self:isTypeShare(task) then
            if isOpenWechat then
                table.insert(tableNew, 1, task)
                head = head + 1
            end
            
        elseif self:isTypeShare2(task) then
            if not isNoPlayGetAct then
                head = head + 1
                table.insert(tableNew, head, task)
            end

        elseif self:isTaskInvite(task) then
            if FishGI.isOpenWechat then
                special = special + 1
                table.insert(tableNew, head + getable + special, task)
            end

        elseif self:isTaskGetable(task) then
            self.getableTable[#self.getableTable + 1] = task.nTaskID
            getable = getable + 1
            table.insert(tableNew, head + getable, task)

        elseif not task.isReward then
            if self:isSpecialTask(task) then
                special = special + 1
                table.insert(tableNew, head + getable + special, task)

            else
                normal = normal + 1
                table.insert(tableNew, head + getable + special + normal, task)
                
            end

        else
            if not self:isSpecialTask(task) then
                table.insert(tableNew, #tableNew + 1, task)
            end
        end
    end

    return tableNew
end

function TaskMain:isTypeShare(task)
    local task_databin = self.taskDatas:getTaskDataById(430000000 + task.nTaskID)
    return task_databin.task_type == "10"
end

function TaskMain:isTypeShare2(task)
    local task_databin = self.taskDatas:getTaskDataById(430000000 + task.nTaskID)
    return task_databin.task_type == "12"
end

function TaskMain:isTaskInvite(task)
    local task_databin = self.taskDatas:getTaskDataById(430000000 + task.nTaskID)
    return task_databin.task_type == "11"
end

function TaskMain:isSpecialTask(task)
    local task_databin = self.taskDatas:getTaskDataById(430000000 + task.nTaskID)
    
    return task_databin.task_if == "1"
end

function TaskMain:isTaskGetable(task)
    local task_databin = self.taskDatas:getTaskDataById(430000000 + task.nTaskID)
    if self:isTypeShare(task) then
        return false
    end

    if self:isSpecial(task_databin.task_if) then 
        if tonumber(task_databin.task_type) == 8
            and FishGI.WebUserData:isActivited() then -- 激活
                return true

        elseif tonumber(task_databin.task_type) == 9 
            and FishGI.WebUserData:isBindPhone() then -- 绑定手机
                return true
        end
    end

    if tonumber(task.nTaskNum) >= tonumber(task_databin.task_data2) and not task.isReward then
        return true
    end

    return false
end

function TaskMain:needToHide(is_Special, isReward, isInvite)
    if isInvite and FishGI.hallScene.uiInviteFriend.isUsed then
        return true
    end

    return self:isSpecial(is_Special) and isReward
end

function TaskMain:isSpecial(is_Special) --needToAskWeb
    return (is_Special == "1")
end

function TaskMain:addTaskItem(taskId, taskCount, isReward, task_databin_data, curIndex, totalIndex)
        if self:needToHide(task_databin_data.task_if, isReward, tonumber(task_databin_data.task_type) == 11) then return false end         -- 特殊任务 已经领取了 就不显示了

        if self:isSpecial(task_databin_data.task_if) then 
            if tonumber(task_databin_data.task_type) == 8
                and FishGI.WebUserData:isActivited() then -- 激活
                    taskCount = 1 

            elseif tonumber(task_databin_data.task_type) == 9 
                and FishGI.WebUserData:isBindPhone() then -- 绑定手机
                    taskCount = 1            
            elseif tonumber(task_databin_data.task_type) == 11
                and FishGI.hallScene.uiInviteFriend.isUsed then -- 输入邀请码
                    taskCount = 1
                    isReward = true
            end
        end

        if tonumber(task_databin_data.task_type) == 10 
                and FishGI.hallScene.uiWeChatShare.shareLinkUsed then -- 好友分享
                    taskCount = 1 
        end

        if tonumber(task_databin_data.task_type) == 12 
                and FishGI.hallScene.uiWeChatShare.shareLinkUsed then -- 好友分享
                    taskCount = 1 
        end

        local taskItem = require("hall/Task/TaskUI/TaskItem").new()
        taskItem.nodeType = "cocosStudio"
        taskItem:setAnchorPoint(0,1)
        taskItem:setPosition(MAIN_WIDTH/2, PROCESS_BAR_INTERVAL * totalIndex - PROCESS_BAR_INTERVAL * curIndex + PROCESS_BAR_INTERVAL/2)
        taskItem:initItem(taskId, taskCount, isReward, task_databin_data)
        taskItem:setSpecial(self:isSpecial(task_databin_data.task_if))

        self.taskItems[taskId] = taskItem
        self.scl_task_container:addChild(taskItem)

        return true
end

function TaskMain:initTaskProcess(taskInfos, treasures)
    self:setTaskProcessPercentage(taskInfos)
    self:displayTreasureBox(treasures, self.active_count, self.taskDatas:getTreasureConfig())
end

function TaskMain:setTaskProcessPercentage(taskInfos)
    self.active_count = 0
    for i,task in ipairs(taskInfos) do
        log(i,task)
        if task.isReward then
            local task_databin = self.taskDatas:getTaskDataById(430000000 + task.nTaskID)
            self.active_count = task_databin.task_active + self.active_count
        end
    end

    self.processbar:setPercent(self.active_count, self.taskDatas:getTreasureConfig())
end

function TaskMain:displayTreasureBox(opened_treasures, totalActive, treasureConfig)
    self.processbar:displayTreasureBox(opened_treasures, totalActive, treasureConfig)
end

function TaskMain:onClickShow()
    self.doShow = true
    self:requestForTaskInfo()
end

function TaskMain:requestForTaskInfo()
    self.TaskMessage:requestForTaskInfo()
end

function TaskMain:doEventUtil(valTab)
    local type = valTab.taskType

    if type == "1" then
        self:doQuikStart()

    elseif type == "2" then
        self:doQuikStart()

    elseif type == "3" then
        self:doQuikStart()

    elseif type == "4" then
        self:doQuikStart()

    elseif type == "5" then
        self:doQuikStart()

    elseif type == "6" then
        self:doCheckin()

    elseif type == "7" then
        self:showConsumePanel()

    elseif type == "8" then
        self:showPlayerInfoPanel()

    elseif type == "9" then
        self:showPlayerInfoPanel()

    elseif type == "10" then
        FishGI.hallScene.uiWeChatShare:showLayer() 

    elseif type == "11" then
        FishGI.hallScene.uiInviteFriend:showLayer()

    end
end

function TaskMain:showPlayerInfoPanel()
    FishGI.myData.isActivited = FishGI.WebUserData:isActivited()
    FishGI.myData.isBindPhone = FishGI.WebUserData:isBindPhone()
    FishGI.hallScene.uiPlayerInfo:upDataBtnState(FishGI.myData.isActivited, FishGI.myData.isBindPhone)
    FishGI.hallScene.uiPlayerInfo:showLayer()
end

function TaskMain:showConsumePanel()
    FishGI.hallScene.uiShopLayer:showLayer()
    FishGI.hallScene.uiShopLayer:setShopType(1)
end

function TaskMain:doQuikStart()
    FishGI.hallScene.uiAllRoomView:fastStartGame()
end

function TaskMain:doCheckin()
    FishGI.hallScene.uiCheck:showLayer() 
end

return TaskMain