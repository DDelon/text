local TaskMessage = class("TaskMessage", nil)

function TaskMessage:create()
    local taskMessage = TaskMessage.new();
    return taskMessage
end

function TaskMessage:initTaskMessage(valTab)
    log("TaskMessage:initTaskMessage")
    FishGI.eventDispatcher:registerCustomListener("onGetTaskInfoResult", self, function(valTab) self:onGetTaskInfoResult(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("onTaskRewardResult", self, function(valTab) self:onTaskRewardResult(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("onActiveReward", self, function(valTab) self:onActiveReward(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("onTaskFinished", self, function(valTab) self:onTaskFinished(valTab) end);
end 

function TaskMessage:requestForTaskInfo()
    if FishGI.hallScene.net.roommanager ~= nil then
        FishGI.hallScene.net.roommanager:sendRequestForTaskInfo()
    end
end

function TaskMessage:requestForReward(valTab)
    if FishGI.hallScene.net.roommanager ~= nil then
        FishGI.hallScene.net.roommanager:sendRequestForTaskReward(valTab)
    end
end

function TaskMessage:requestForActiveReward(valTab)
    if FishGI.hallScene.net.roommanager ~= nil then
        FishGI.hallScene.net.roommanager:sendRequestForActiveReward(valTab)
    end
end

function TaskMessage:onGetTaskInfoResult(valTab)
    self:dispatchToTaskMain("ON_TASK_INFO_RESULT", valTab)
end

function TaskMessage:onTaskRewardResult(valTab)
    self:dispatchToTaskMain("ON_TASK_REWARD_RESULT", valTab)
end

function TaskMessage:onActiveReward(valTab)
    self:dispatchToTaskMain("ON_ACTIVE_REWARD_RESULT", valTab)
end

function TaskMessage:onTaskFinished(valTab)
    self:dispatchToTaskMain("ON_TASK_FINISH", valTab)
end

function TaskMessage:dispatchToTaskMain(eventType, valTab)
    local event = {}
    event.eventType = eventType
    event.result = valTab
    FishGI.eventDispatcher:dispatch("onTaskEvent", event);
end

-------------test unit---------------------
function TaskMessage:test()
    self:onGetTaskInfoResult(self:mockTaskInfos())
end

function TaskMessage:mockTaskInfos()
    local valtab =  {}
    valtab.TaskInfo = {}

    valtab.TaskInfo[1] = self:mockTaskInfo(1, 3, false)

    valtab.TaskInfo[2] = self:mockTaskInfo(12, 4, false)
    
    valtab.TaskInfo[3] = self:mockTaskInfo(15, 4, false)
    
    valtab.TaskInfo[4] = self:mockTaskInfo(21, 24, false)

    valtab.TaskInfo[5] = self:mockTaskInfo(27, 14, false)

    valtab.TaskInfo[6] = self:mockTaskInfo(33, 14, false)

    valtab.TaskInfo[7] = self:mockTaskInfo(34, 14, false)

    valtab.TaskInfo[8] = self:mockTaskInfo(35, 14, false)

    valtab.TaskInfo[9] = self:mockTaskInfo(36, 14, false)

    return valtab
end

function TaskMessage:mockTaskInfo(id, num, isRward)
    local infoTab = {}
    infoTab.nTaskID = id
    infoTab.nTaskNum = num
    infoTab.isReward = isRward 

    return infoTab
end

-------------------------------------------

return TaskMessage