local NewbieTask = class("NewbieTask", cc.load("mvc").ViewBase)

NewbieTask.AUTO_RESOLUTION   = true
NewbieTask.RESOURCE_FILENAME = "ui/battle/newbietask/uinewbietask"
NewbieTask.RESOURCE_BINDING  = {
    ["spr_deng_left"]           = { ["varname"] = "spr_deng_left" },
    ["spr_deng_right"]          = { ["varname"] = "spr_deng_right" },
    ["spr_prop"]                = { ["varname"] = "spr_prop" },
    ["spr_prop_num"]            = { ["varname"] = "spr_prop_num" },
    ["text_desc"]               = { ["varname"] = "text_desc" },
    ["img_process_bg"]          = { ["varname"] = "img_process_bg" },
    ["loading_bar_process"]     = { ["varname"] = "loading_bar_process" },
    ["process_percentage"]      = { ["varname"] = "process_percentage" },
    ["btn_draw"]                = { ["varname"] = "btn_draw", ["events"]={["event"]="click",["method"]="onClickDraw"}},
}

NewbieTask.TASK_TYPE = {
    type_1 = 1, --获得鱼币数
    type_2 = 2, --击杀鱼数
    type_3 = 3, --击杀获得水晶数
    type_4 = 4, --升级炮倍数
}

function NewbieTask:onCreate( ... )
    self:init()
    self:initView()
end

function NewbieTask:init( )
    FishGI.eventDispatcher:registerCustomListener("onGetNewTaskInfo", self, function(valTab) self:onGetNewTaskInfo(valTab) end)
    FishGI.eventDispatcher:registerCustomListener("onGetNewTaskReward", self, function(valTab) self:onGetNewTaskReward(valTab) end)
    self.bTaskExecuting = false
    self.iCurTaskID = 0
    self.iCurTaskType = 0
    self.iCurTaskData = 0
    self.iTotalTaskData = 1
    self.iPorpId = 0
    self.iPropCount = 0
    self.strTaskDesc = ""
end

function NewbieTask:initView( )
    self.scaleX_,self.scaleY_,self.scaleMin_  = FishGF.getCurScale()
    self.isNewTask = true
end

function NewbieTask:onEnter( )
    local function callbackStartAni()
        self:sendGetNewTaskInfo()
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(callbackStartAni)))
end

function NewbieTask:onExit( )
    self:stopAllActions()
end

function NewbieTask:startAni()
    self:runAction(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, -140*self.scaleMin_))))
end

function NewbieTask:endAni(callback)
    self:runAction(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, 140*self.scaleMin_)), cc.CallFunc:create(callback)))
end

function NewbieTask:onTaskProcess( taskID, taskData )
    self.iCurTaskID = 450000000+taskID
    self.iCurTaskData = taskData
    self.iCurTaskType = FishGI.GameTableData:getNewtaskTable(self.iCurTaskID).task_type
    self.iTotalTaskData = FishGI.GameTableData:getNewtaskTable(self.iCurTaskID).task_data
    self.strTaskDesc = FishGI.GameTableData:getNewtaskTable(self.iCurTaskID).task_text
    self.strTmp = FishGI.GameTableData:getNewtaskTable(self.iCurTaskID).reward
    local tRewardData = string.split(FishGI.GameTableData:getNewtaskTable(self.iCurTaskID).reward, ',')
    self.iPorpId = tRewardData[1]
    self.iPropCount = tRewardData[2]
    if not self.bTaskExecuting then
        self:setIfTaskExecuting(true)
        self:refreshPropData()
    end
    self:refreshProcessData()
    if self.iCurTaskData >= self.iTotalTaskData then
        self:setIfTaskExecuting(false)
    end
end

function NewbieTask:isTaskExecuting()
    return self.bTaskExecuting
end

function NewbieTask:getTaskType()
    return self.iCurTaskType
end

function NewbieTask:setIfTaskExecuting(bTaskExecuting)
    if bTaskExecuting == nil then
        bTaskExecuting = false
    end
    self.bTaskExecuting = bTaskExecuting
    self.spr_deng_left:setVisible(bTaskExecuting)
    self.spr_deng_right:setVisible(bTaskExecuting)
    self.text_desc:setVisible(bTaskExecuting)
    self.img_process_bg:setVisible(bTaskExecuting)
    self.btn_draw:setVisible(not bTaskExecuting)
end

function NewbieTask:refreshPropData()
    --self.spr_prop:initWithFile("common/prop/"..FishGI.GameConfig:getConfigData("item", tostring(200000000 + self.iPorpId), "res"))
    self.spr_prop:initWithFile("common/prop/"..FishGI.GameTableData:getItemTable(self.iPorpId).res)
    if self.iPorpId == "1002" or self.iPorpId == "1003" then
        self.spr_prop:setScale(0.8)
    else
        self.spr_prop:setScale(1)
    end
    self.spr_prop_num:setString(tostring(self.iPropCount))
    self.text_desc:setString(self.strTaskDesc)
end

function NewbieTask:refreshProcessData()
    self.loading_bar_process:setPercent(self.iCurTaskData/self.iTotalTaskData*100)
    self.process_percentage:setString(tostring(self.iCurTaskData) .. "&" .. tostring(self.iTotalTaskData))
end

function NewbieTask:addTaskData( iTaskData )
    if self.bTaskExecuting and self.iCurTaskData < self.iTotalTaskData then 
        self.iCurTaskData = self.iCurTaskData + iTaskData
        if self.iCurTaskData >= self.iTotalTaskData then
            self.iCurTaskData = self.iTotalTaskData
            self:setIfTaskExecuting(false)
        else
            self:refreshPropData()
            self:refreshProcessData()
        end
    end
end

function NewbieTask:onClickDraw( sender )
    self:sendGetNewTaskReward()
end

function NewbieTask:sendGetNewTaskInfo()
    self.isNewTask = true
    local valTab = {}
    FishGI.gameScene.net:sendGetNewTaskInfo(valTab)
end

function NewbieTask:sendGetNewTaskReward()
    local valTab = {}
    valTab.nTaskID = self.iCurTaskID
    FishGI.gameScene.net:GetNewTaskReward(valTab)
end

function NewbieTask:onGetNewTaskInfo(valTab)
    if valTab.isSuccess then
        if valTab.nTaskID ~= -1 or valTab.nTaskData ~= -1 then
            if self.isNewTask then
                self:startAni()
                self.isNewTask = false
            end
            self:setVisible(true)
            self:onTaskProcess(valTab.nTaskID, valTab.nTaskData)
        else
            self:setVisible(false)
        end
    else
    end
end

function NewbieTask:onGetNewTaskReward(valTab)
    local playerId = valTab.playerID
    local propId = valTab.nPropID
    local propCount = valTab.nPropNum

    if playerId == FishGI.myData.playerId and not (valTab.isSuccess) then
        print("------onGetNewTaskReward fail-----")
        return 
    end

    if table.getn(valTab.SeniorProps) > 0 then
        for i,v in ipairs(valTab.SeniorProps) do
            if playerId ~= FishGI.myData.playerId then
                FishGMF.refreshSeniorPropData(playerId,v,1)
            else
                FishGMF.refreshSeniorPropData(playerId,v,8)
            end
        end
    else
        if playerId ~= FishGI.myData.playerId then
            FishGMF.addTrueAndFlyProp(playerId,propId,propCount,true)
        else
            FishGMF.addTrueAndFlyProp(playerId,propId,propCount,false)
            FishGMF.setAddFlyProp(playerId,propId,propCount,false)
        end
    end   

    if playerId ~= FishGI.myData.playerId then
        return 
    end

    if valTab.isSuccess then
        local function playDropProp( seniorPropData )
            local propTab = {}
            propTab.playerId = playerId
            propTab.propId = propId
            propTab.propCount = propCount
            propTab.isRefreshData = true
            propTab.isJump = false
            local child = self.spr_prop:getParent()
            local pos = cc.p(self.spr_prop:getPositionX(),self.spr_prop:getPositionY())
            pos = child:convertToWorldSpace(pos)
            propTab.firstPos = pos
            propTab.dropType = "normal"
            propTab.isShowCount = false
            propTab.seniorPropData = seniorPropData
            FishGI.GameEffect:playDropProp(propTab)
        end
        if table.getn(valTab.SeniorProps) > 0 then
            for i,v in ipairs(valTab.SeniorProps) do
                playDropProp(v)
            end
        else
            playDropProp()
        end
    end
    local function callbackEndAni()
        self:sendGetNewTaskInfo()
    end
    self:endAni(callbackEndAni)
end

return NewbieTask