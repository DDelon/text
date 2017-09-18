local TaskItem = class("TaskItem", cc.load("mvc").ViewBase)

TaskItem.AUTO_RESOLUTION   = 0
TaskItem.RESOURCE_FILENAME = "ui/hall/task/uitask_item"
TaskItem.RESOURCE_BASE_PATH= "res/hall/task/icon/"
TaskItem.RESOURCE_FISH_PATH= "res/battle/form/pic_fishid/"
TaskItem.RESOURCE_PROP_PATH= "res/common/prop/"
 
TaskItem.RESOURCE_BINDING  = {
    ["panel"]               = { ["varname"] = "panel" }, 
    ["spr_icon"]            = { ["varname"] = "spr_icon" },                 -- 图框
    ["img_bgr"]             = { ["varname"] = "img_bgr" },                 -- 图框
    ["txt_reward"]          = { ["varname"] = "txt_reward" },                 -- 奖励
    ["loading_bar_process"] = { ["varname"] = "loading_bar_process" },      -- 进度条
    ["process_percentage"]  = { ["varname"] = "process_percentage" },       -- 进度条上的百分比
    ["btn_go"]              = { ["varname"] = "btn_go" ,["events"]={["event"]="click",["method"]="onClickGo"}},             -- 前往
    ["btn_get_reward"]      = { ["varname"] = "btn_get_reward" ,["events"]={["event"]="click",["method"]="onClickGet"}},    -- 领取
    ["txt_active_reward"]   = { ["varname"] = "txt_active_reward" },        -- 活跃度
    ["txt_title"]           = { ["varname"] = "txt_title" },                -- 任务标题栏
    ["txt_prop_reward"]     = { ["varname"] = "txt_prop_reward" },          -- 奖励道具数量
    ["img_gold"]            = { ["varname"] = "img_gold" },                 -- 金币图标
    ["img_crystal"]         = { ["varname"] = "img_crystal" },              -- 水晶图标
    ["img_done"]            = { ["varname"] = "img_done" },                 -- 已完成
    ["Image_2"]             = { ["varname"] = "Image_2" },                 -- 已完成
    ["btn_share"]           = { ["varname"] = "btn_share" ,["events"]={["event"]="click",["method"]="onClickShare"}},                 -- 已完成
    
}

function TaskItem:onCreate( ... )
    self.btn_go:setVisible(false)
    self.btn_get_reward:setVisible(true)
    self.isSpecial = false
    self:displayTaskCompleteBtn(false)
end

function TaskItem:onClickGo()
    log("TaskItem:onClickGo")

    local event = {}
    event.eventType = "DO_TASK_GO"
    event.taskType = self.taskType
    FishGI.eventDispatcher:dispatch("onTaskEvent", event)
end

function TaskItem:onClickGet()
    log("TaskItem:onClickGet")

    local event = {}
    event.eventType = "DO_TASK_GET"
    event.taskId = self.taskId
    FishGI.eventDispatcher:dispatch("onTaskEvent", event)
    self:setButtonDisplay(true)

end

function TaskItem:onClickShare()
    FishGI.wechatShareType = 0
    local shareInfo = FishGI.WebUserData:GetShareDataTable();
    FishGI.ShareHelper:doShareWebType(shareInfo.text,shareInfo.icon,shareInfo.url, nil, nil, shareInfo.id);
end

function TaskItem:initItem(taskId, process, isReward, task)
    log("TaskItem:initItem")
    self.taskId = taskId
    self.taskType = task.task_type

    self:setPercentage(process, task.task_data2)

    self:setProcess(process, task.task_data2)

    self:setRewardPropInfo(task.task_reward)

    self:setRewardActiveInfo(task.task_active)

    self:setTaskItemTitle(task.title)

    self:setButtonDisplay(isReward, process, task.task_data2)

    self:setTitleIcon(task.task_type, task.task_data1)
end

function TaskItem:setSpecial(bSpecial)
    self.isSpecial = bSpecial
end

function TaskItem:getSpecial()
    return self.isSpecial
end

function TaskItem:setPercentage(process, total)
    local count = tonumber(process)
    if count > tonumber(total) then
        count = tonumber(total)
    end

    local percentage = tostring(count) .. "&" .. tostring(total)
    self.process_percentage:setString(percentage)
end

function TaskItem:setProcess(process, total)
    local percent = process/total * 100
    self.loading_bar_process:setPercent(percent)
end

function TaskItem:setRewardActiveInfo(active_count)
    if active_count == "0" then
        self.txt_active_reward:setVisible(false)
        self.Image_2:setVisible(false)
        return
    end

    self.txt_active_reward:setString(active_count)
end

function TaskItem:setTaskItemTitle(title)
    self.txt_title:setString(title)
end

function TaskItem:setRewardPropInfo(task_reward)
    local infoTab = string.split(task_reward, ",")

    if task_reward == "" then
        self.img_crystal:setVisible(false)
        self.img_gold:setVisible(false)
        self.txt_prop_reward:setVisible(false)
        self.txt_reward:setVisible(false)
        return
    end

    self:setRewardGold(infoTab[1])

    if infoTab[2] == nil or tonumber(infoTab[2] == 0) then
        self.txt_prop_reward:setVisible(false)
        return
    end

    self.txt_prop_reward:setString(infoTab[2])
end

function TaskItem:setTitleIcon(task_type, itemId)
    local imageIcon
    log("task_type: " .. task_type)
    if task_type == "1" then    -- kill fish
        imageIcon = cc.Sprite:create(TaskItem.RESOURCE_FISH_PATH .. "fishid_" .. itemId .. ".png")
        imageIcon:setScale(0.8)
    elseif task_type == "2" then
        local propId
        if tonumber(itemId) < 10 then
            propId = "00" .. itemId
        else
            propId = "0" .. itemId
        end
        
        imageIcon = cc.Sprite:create(TaskItem.RESOURCE_PROP_PATH .. "prop_" .. propId .. ".png")
        imageIcon:setScale(0.6)
    else
        imageIcon = cc.Sprite:create(TaskItem.RESOURCE_BASE_PATH .. "task_type_" .. task_type .. ".png")
    end

    imageIcon:setPosition(53, 53)
    self.spr_icon:addChild(imageIcon)
end

function TaskItem:setButtonDisplay(isReward, process, total)

    if self.taskType == "10" then 
        return
    elseif self.taskType == "12" then
        self.btn_go:setVisible(false)
        self.btn_get_reward:setVisible(false)
        self.img_done:setVisible(false)

        self.btn_share:setVisible(true)
        return
    end

    if isReward then
        self.btn_go:setVisible(not isReward)
        self.btn_get_reward:setVisible(not isReward)
        self.img_done:setVisible(isReward)
        return
    end

    self:displayTaskCompleteBtn(self:isTaskComplete(process, total))
end

--------------------------------------------------------------
function TaskItem:displayTaskCompleteBtn(bComplete)
    self.btn_go:setVisible(not bComplete)
    self.btn_get_reward:setVisible(bComplete)
    self.img_done:setVisible(false)
end

function TaskItem:isTaskComplete(process, total)
    return tonumber(process) >= tonumber(total)
end

function TaskItem:isRewardGold(rewardProp)
    return rewardProp == "1"
end

function TaskItem:setRewardGold(reward)
    self.img_crystal:setVisible(reward ~= "1")
    self.img_gold:setVisible(reward == "1")
end

function TaskItem:doPlayGainAnimate(propId, propCount)
    FishGMF.addTrueAndFlyProp(FishGI.myData.playerId,tonumber(propId),tonumber(propCount),false)
    FishGMF.setAddFlyProp(FishGI.myData.playerId,tonumber(propId),tonumber(propCount),false)

    local propTab = {}
    propTab.playerId = FishGI.myData.playerId
    propTab.propId = tonumber(propId)
    propTab.propCount = tonumber(propCount)
    propTab.isRefreshData = true
    propTab.isJump = true
    propTab.firstPos = self:getFirstPos(self.img_gold)
    propTab.dropType = "normal"
    propTab.isShowCount = false
    FishGI.GameEffect:playDropProp(propTab)
    
end

function TaskItem:getFirstPos( nodeStar )
    local child = nodeStar
    if child == nil then
        return nil
    end 
    local pos = cc.p(child:getPositionX(),child:getPositionY())
    pos = self.img_bgr:convertToWorldSpace(pos)

    return pos
end

return TaskItem