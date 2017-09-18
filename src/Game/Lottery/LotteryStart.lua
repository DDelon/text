local LotteryStart = class("LotteryStart", cc.load("mvc").ViewBase)

LotteryStart.AUTO_RESOLUTION   = false
LotteryStart.RESOURCE_FILENAME = "ui/battle/lottery/uilotterystart"
LotteryStart.RESOURCE_BINDING  = {    
    ["btn_close"]        = { ["varname"] = "btn_close" ,        ["events"]={["event"]="click",["method"]="onClickClose"}},  
    ["btn_startlottery"] = { ["varname"] = "btn_startlottery" , ["events"]={["event"]="click",["method"]="onClickStartLottery"}},  
    ["node_sixshell"]    = { ["varname"] = "node_sixshell"  }, 
    ["spr_light"]        = { ["varname"] = "spr_light"  },
    ["text_leavenotice"] = { ["varname"] = "text_leavenotice"  },
    ["image_text_bg"]    = { ["varname"] = "image_text_bg"  },
    ["text_notice"]      = { ["varname"] = "text_notice"  },

}

function LotteryStart:onCreate( ... )
    math.randomseed(tostring(os.time()):reverse():sub(1, 6)) 

    self:runAction(self.resourceNode_["animation"])
    self.animation = self.resourceNode_["animation"]

    self:openTouchEventListener()
    
    --界面初始化
    self.text_leavenotice:setString(FishGF.getChByIndex(800000083))
    self:initToFirst()

    self.propData = {}
    self.choseIndex = nil
    self.serverIndex = nil
    self.LVTag = 1
    self.propArr = {}
    self.isOpenEnd = false
    self.isChoseEnd = true
    self.shwTime = tonumber(FishGI.GameConfig:getConfigData("config", tostring(990000023), "data"));

    FishGI.eventDispatcher:registerCustomListener("drawResult", self, function(valTab) self:drawResult(valTab) end);

end

function LotteryStart:initToFirst( )
    self:stopAllActions()
    self.propData = {}
    self.choseIndex = nil
    self.serverIndex = nil
    self.isOpenEnd = false
    self.isChoseEnd = true
    self.text_leavenotice:setVisible(false)
    self.btn_startlottery:setVisible(true)
    self.spr_light:setVisible(false)
    self.btn_close:setVisible(true)

    self.image_text_bg:setVisible(false)
    self.node_sixshell.animation:play("openall", false);
    for i=1,6 do
        local shellName = "node_shell_"..i
        local shell = self.node_sixshell:getChildByName(shellName)
        shell:setVisible(true)
    end

end

function LotteryStart:onTouchCancelled(touch, event)

end

function LotteryStart:onClickClose( sender )
    self:hideLayer(false)
    self:getParent().uiLotteryLayer:showLayer(false)
end

function LotteryStart:onTouchBegan(touch, event) 
    if not self:isVisible() then
        return false
    end

    --抽奖结束，奖品飞行收取
    if self.isOpenEnd then
        self.spr_light:stopAllActions()
        self:hideLayer(false)
        --道具飞行
        local propTab = {}
        propTab.playerId = self.propData.playerId
        propTab.propId = self.propData.propId
        propTab.propCount = self.propData.propCount
        propTab.isRefreshData = true
        propTab.isJump = false
        propTab.firstPos = cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2)
        propTab.dropType = "normal"
        propTab.isShowCount = false
        propTab.seniorPropData = self.propData.seniorPropData
        FishGI.GameEffect:playDropProp(propTab)

        return true
    end

    --选择奖品结束
    if self.isChoseEnd then
        return true
    end

    --选择奖品
    local curPos = touch:getLocation()
    for i=1,6 do
        local shellName = "node_shell_"..i
        local shell = self.node_sixshell:getChildByName(shellName)
        local shellopen = shell:getChildByName("spr_shell_open")
        local size = shellopen:getContentSize()
        local locationInNode = shellopen:convertToNodeSpace(curPos)
        local rect = cc.rect(0,0,size.width,size.height)
        if cc.rectContainsPoint(rect,locationInNode) then
            self:setCurChoseIndex(i)
            break
        end
    end

    return true
end

--点击开始播放抽奖动画
function LotteryStart:onClickStartLottery( sender )
    self:playStartLottery() 
end

--开始播放抽奖动画
function LotteryStart:playStartLottery(  )
    local time = self.shwTime
    local callback = function ( ... )
        --时间完了，自动抽奖
        time = time -1
        self.text_notice:setString(FishGF.getChByIndex(800000084).."..."..time)
        if time == 0 then
            local index = math.random(0,5) + 1
            self:setCurChoseIndex(index)
        end
    end

    local frameEventCallFunc = function (frameEventName)
        if frameEventName:getEvent() == "moveEnd" then
            print("-----------frameEventName = moveEnd-------")
            self.isChoseEnd = false
            self.image_text_bg:setVisible(true)
            self.text_notice:setString(FishGF.getChByIndex(800000084).."..."..self.shwTime)

            local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(callback))
            local repeatAct = cc.RepeatForever:create(seq)
            self.text_notice:runAction(repeatAct)
        end
    end

    self.btn_startlottery:setVisible(false)
    self.btn_close:setVisible(false)
    self.node_sixshell.animation:play("move", false);
    self.node_sixshell.animation:clearFrameEventCallFunc()  
    self.node_sixshell.animation:setFrameEventCallFunc(frameEventCallFunc)

end

--设置当前选择的贝壳，并发送抽奖消息
function LotteryStart:setCurChoseIndex(index)
    print("-----LotteryStart------setCurChoseIndex------------index="..index)
    self.choseIndex = index
    self.isChoseEnd = true
    self.text_notice:stopAllActions()
    FishGI.gameScene.net:sendStatrLottery(self.LVTag)
end

function LotteryStart:playLotteryResultAct()
    --交换当前选择贝壳和目标贝壳的位置
    local shellName = "node_shell_"..self.choseIndex
    local shell = self.node_sixshell:getChildByName(shellName)
    local shellName2 = "node_shell_"..self.serverIndex
    local shell2 = self.node_sixshell:getChildByName(shellName2)
    local posX = shell:getPositionX()
    local posY = shell:getPositionY()
    shell:setPosition(cc.p(shell2:getPositionX(),shell2:getPositionY()))
    shell2:setPosition(cc.p(posX,posY))
    local shellopen = shell2:getChildByName("spr_shell_open")
    local size = shellopen:getContentSize()

    local act1 = cc.ScaleTo:create(0.28,0.8)
    --打开当前贝壳
    local callFun1 = cc.CallFunc:create(function ( ... )
        self.image_text_bg:setVisible(false)
        shell2.animation:play("open", false);
    end)

    --隐藏其他5个贝壳
    local callFun2 = cc.CallFunc:create(function ( ... )
        if self.serverIndex ~= nil then
            for i=1,6 do
                if self.serverIndex ~= i then
                    local shellName = "node_shell_"..i
                    local shell = self.node_sixshell:getChildByName(shellName)
                    shell:setVisible(false)
                end
            end
        end
    end)

    local moveAct = cc.MoveTo:create(0.4,cc.p(0,-size.height/2))

    local callFun3 = cc.CallFunc:create(function ( ... )
        self.isOpenEnd = true
        self.spr_light:setVisible(true)
        self.spr_light:runAction(cc.RepeatForever:create(cc.RotateBy:create(1,FishCD.LIGHT_SPEED)))
        self.image_text_bg:setVisible(true)
        self.text_notice:setString(FishGF.getChByIndex(800000005))
        self.text_leavenotice:setVisible(true)
        FishGI.AudioControl:playEffect("sound/congrat_01.mp3",false)
    end)

    local sequenceAct = cc.Sequence:create(
        act1,
        callFun1,
        cc.DelayTime:create(0.3),
        callFun2,
        cc.DelayTime:create(0.28),
        moveAct,
        cc.DelayTime:create(0.04),
        callFun3)
    shell2:runAction(sequenceAct)

end

function LotteryStart:upDataSixShellByKeyId(LVTag, propArr)
    self.LVTag = LVTag
    self.propArr = propArr
    for i=1,6 do
        local propId = self.propArr[i].propId
        local propCount = self.propArr[i].propCount

        local shellName = "node_shell_"..i
        local shell = self.node_sixshell:getChildByName(shellName)

        local shellopen = shell:getChildByName("spr_shell_open")
        local fnt_prop_count = shellopen:getChildByName("fnt_prop_count")
        fnt_prop_count:setString(FishGF.changePropUnitByID(propId,propCount,false))
        local spr_prop = shellopen:getChildByName("spr_prop")
        local res = "common/prop/"..FishGI.GameTableData:getItemTable(propId).res
        spr_prop:initWithFile(res)

        shell.animation:play("open", false);
    end
end

function LotteryStart:drawResult(val)
    local playerId = val.playerId
    local selfId = FishGI.gameScene.playerManager.selfIndex;
    local isSuccess = val.isSuccess
    local killRewardFishInDay = val.killRewardFishInDay
    local drawRequireRewardFishCount = val.drawRequireRewardFishCount
    local rewardRate = val.rewardRate

    self.propData = {}

    local propId = 0
    local propCount = 0

    if val.props == nil then
        val.props = {}
    end
    for k,val in pairs(val.props) do
        if val ~= nil and val.propId ~= nil then
            propId = val.propId
            propCount = val.propCount
        end
    end

    if val.seniorProps == nil then
        val.seniorProps = {}
    end
    for k,val in pairs(val.seniorProps) do
        if val ~= nil and val.propId ~= nil then
            propId = val.propId
            propCount = propCount + 1
            self.propData.seniorPropData = val
        end
    end

    self.propData.playerId = playerId
    self.propData.propId = propId
    self.propData.propCount = propCount

    if playerId == selfId then
        if isSuccess then
            self.serverIndex = nil
            for i=1,6 do
                local Id = self.propArr[i].propId
                local Count = self.propArr[i].propCount
                if Id == propId and  Count == propCount  then
                    self.serverIndex = i
                    break
                end  
            end
            if self.serverIndex == nil then
                print("------LotteryStart------no this things---------")
                self:initToFirst()
                self:hideLayer(false)
                FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000086),nil)
                return
            end
            print("------LotteryStart-----result-------serverIndex="..self.serverIndex)
            for k,val in pairs(val.props) do
                if val ~= nil and val.propId ~= nil then
                    FishGMF.addTrueAndFlyProp(playerId,val.propId,val.propCount,false)
                    FishGMF.setAddFlyProp(playerId,val.propId,val.propCount,false)
                end
            end

            for k,val in pairs(val.seniorProps) do
                if val ~= nil and val.propId ~= nil then
                    FishGMF.refreshSeniorPropData(playerId,val,8,0)
                end
            end
            self:playLotteryResultAct()
        else
            --停止抽奖，弹出提示
            print("------------stopLottery---------")
            self:initToFirst()
            self:hideLayer(false)
            FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000086),nil)
        end

    else
        FishGMF.addTrueAndFlyProp(playerId,propId,propCount,true)
    end

end

return LotteryStart;