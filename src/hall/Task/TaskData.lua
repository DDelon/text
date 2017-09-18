local TaskData = class("TaskData", nil)

TaskData.START_INDEX = 430000000

function TaskData:fillWithTaskTitle(taskTab)
    taskTab.title = self:getTaskTitle(taskTab.task_text, taskTab.task_type, taskTab.task_data1, taskTab.task_data2)
end

function TaskData:getTaskData()
    return self.taskTable
end

function TaskData:getTaskDataById(id)
    return self.taskTable[id]
end

function TaskData:getTreasureConfig()
    return self.taskTreasureConfig
end

function TaskData:getRewardTaskInfo()
    return self.rewardTaskInfo
end

function TaskData:initData()
    log("TaskData:initData")
    self.taskTable = {}

    local taskInfos = self:getDataCpp()
    for k,task in pairs(taskInfos) do
        local id = task.id
        if string.len(id) == 0 then
            break;
        end
        local taskTab = {}

        taskTab.task_type   =   task.task_type
        taskTab.task_data1  =   task.task_data1
        taskTab.task_data2  =   task.task_data2
        taskTab.task_reward =   task.task_reward
        taskTab.task_active =   task.task_active
        taskTab.task_if     =   task.task_if
        taskTab.task_text   =   task.task_text
        self:fillWithTaskTitle(taskTab)

        self.taskTable[tonumber(id)] = taskTab
    end

    self.taskTreasureConfig = {}
    self.rewardTaskInfo = {}
    local treasureConfig = self:getTaskTreasureConfig()
    local configTab = string.split(treasureConfig, ";")
    for i,v in ipairs(configTab) do
        local info = string.split(v, ',')
        self.taskTreasureConfig[#self.taskTreasureConfig + 1] = info[1]

        self.rewardTaskInfo[#self.rewardTaskInfo + 1] = self:getRewardInfo(info[2]) 
    end

    for k,v in pairs(self.taskTable) do
        log("-------------------" .. k .. "-------------------")
        log(k,v)
        for k,v in pairs(v) do
            log(k,v)
        end
    end
end

function TaskData:getRewardInfo(info)
    local ret = FishGF.getChByIndex(800000316) .. "\n"
    local bFirst = true

    local infos = string.split(info, "^")
    for k,v in pairs(infos) do
        if v == "" then
            return ret
        end
        local val = string.split(v, "_")

        ret = ret .. val[2] .. "*".. self:getPropName(tonumber(val[1]))
        if bFirst then
            ret = ret .. "\n"
        end
        
    end

    return ret
end


---------------------------------------------------------------------------------------------------------------------------------------------------------

function TaskData:create()
    local taskData = TaskData.new();
    local dataTab = {}
	taskData:initData()
    return taskData
end

function TaskData:getDataCpp()
    local taskinfos = FishGI.GameTableData:getTaskTable()  
    for k,v2 in pairs(taskinfos) do
        for k,v in pairs(v2) do
            log(k,v)
        end
    end

    return taskinfos
end

function TaskData:getTaskTitle(title, task_type, id, target)
    local title_
    if task_type == "1" then                                                    -- 杀鱼
        local propName = self:getFishName(tonumber(id))
        title_ = string.format(title, target, propName)

    elseif task_type == "2" then                                                -- 技能
        local skill_Name = self:getPropName(tonumber(id))
        title_ = string.format(title, skill_Name, target)

    elseif task_type == "3" then                                                -- 消费鱼币800000098 水晶800000099
        local propName = self:getPropName(tonumber(id))
        title_ = string.format(title, target, propName)

    elseif task_type == "4" then                                                -- 获取鱼币 水晶
        local propName = self:getPropName(tonumber(id))
        title_ = string.format(title, target, propName)

    elseif task_type == "5" then                                                -- 固定炮倍 打炮
        local gunTime = id -- self:getGunTimes(tonumber(id))
        title_ = string.format(title, gunTime, target)
        
    elseif task_type == "6" then                                                -- 签到
        title_ = string.format(title, target)

    elseif task_type == "7" then                                                -- 充值
        title_ = string.format(title, target)

    elseif task_type == "8" then                                                -- 激活
        title_ = string.format(title, target)

    elseif task_type == "9" then                                                -- 绑定
        title_ = string.format(title, target)

    elseif task_type == "10" then                                                -- 绑定
        title_ = title
    elseif task_type == "11" then                                                -- 绑定
        title_ = title
    elseif task_type == "12" then                                                -- 绑定
        title_ = title
    end

    return title_
end

function TaskData:getFishName(index)
    return FishGI.GameConfig:getConfigData("fish", tostring(100000000 + index), "name")
end

function TaskData:getGunTimes(index)
    return FishGI.GameConfig:getConfigData("cannon", tostring(920000000 + index), "times")
end

function TaskData:getPropName(index)
    return FishGI.GameTableData:getItemTable(index).name
end

function TaskData:getTaskTreasureConfig()
    return FishGI.GameConfig:getConfigData("config", 990000080, "data")
end

return TaskData