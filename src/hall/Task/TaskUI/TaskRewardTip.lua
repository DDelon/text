local TaskRewardTip = class("TaskRewardTip", cc.load("mvc").ViewBase)

TaskRewardTip.AUTO_RESOLUTION     = 0
TaskRewardTip.RESOURCE_FILENAME   = "ui/hall/task/uitask_tips"

TaskRewardTip.RESOURCE_BINDING  = {
    ["fnt_tip"]           = { ["varname"] = "fnt_tip" },   
}

------------------------------------------------------------------------
function TaskRewardTip:onCreate( ... )
end

function TaskRewardTip:setTip(tip)
    self.fnt_tip:setString(tip)
end

return TaskRewardTip