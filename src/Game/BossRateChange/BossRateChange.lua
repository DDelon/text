local BossRateChange = class("BossRateChange", cc.load("mvc").ViewBase)

BossRateChange.FNT_COUNT = 4
BossRateChange.AUTO_RESOLUTION   = false
BossRateChange.RESOURCE_FILENAME = "ui/battle/bossratechange/uibossratechange"
BossRateChange.RESOURCE_BINDING  = {    
    ["panel"] = { ["varname"] = "panel" },

    ["node_fnt_1"] = { ["varname"] = "node_fnt_1" },
    ["node_fnt_2"] = { ["varname"] = "node_fnt_2" },
    ["node_fnt_3"] = { ["varname"] = "node_fnt_3" },
    ["node_fnt_4"] = { ["varname"] = "node_fnt_4" },
}

function BossRateChange:onCreate( ... )
    self.animation = self.resourceNode_["animation"]
    self:runAction(self.animation)
    --self.animation:play("gold", true);
    self.animation:clearFrameEventCallFunc()  
    self.animation:setFrameEventCallFunc(function(frameEventName)
        if frameEventName:getEvent() == "openend" then
            FishGF.print("-----------BossRateChange = openend-------")
            self:playRateChangeAct(self.endNum)
        elseif frameEventName:getEvent() == "closeend" then
            self:setVisible(false)          
        end
    end)

    for i=1,self.FNT_COUNT do
        self["node_fnt_"..i] = require("Game/BossRateChange/FntItem").new(self, self["node_fnt_"..i])
        self["node_fnt_"..i]:setScale(self.scaleMin_)
        self["node_fnt_"..i]:setPalyTime(0+i*0.65)
        if i == self.FNT_COUNT then
            self["node_fnt_"..i]:setPlaySound(true)
        else    
            self["node_fnt_"..i]:setPlaySound(false)
        end
    end

end

function BossRateChange:playAct(endNum )
    for i=1,self.FNT_COUNT do
        self["node_fnt_"..i]:initView()
    end  
    self.endNum = endNum
    self.animation:play("open", false)
end

function BossRateChange:playRateChangeAct(endNum )
    self.curEndIndex = 1
    print("-------playRateChangeAct------endNum="..endNum)
    local oldNum = endNum
    for i=self.FNT_COUNT,1,-1 do
        local num = oldNum%10
        self["node_fnt_"..i]:setEndNum(num)
        self["node_fnt_"..i]:playAct()
        self["node_fnt_"..i]:setVisible(true)
        self["node_fnt_"..i]:setScale(1)
        oldNum = oldNum/10
        oldNum = math.floor(oldNum)
        self["node_fnt_"..i]:setEndCallBack(handler(self, self.fntEndActBack))
    end

    local seq = cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function ( ... )
        self["node_fnt_"..self.curEndIndex]:setIsEnd(true)
    end))
    seq:setTag(1111)
    self:stopActionByTag(1111)
    self:runAction(seq)
end

function BossRateChange:fntEndActBack( )
    print("-------playRateChangeAct----fntEndActBack--=")
    self.curEndIndex = self.curEndIndex + 1
    if self.curEndIndex > self.FNT_COUNT then
        local seq = cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function ( ... )
            FishGMF.bossRateChangeEnd(self.cppData)
            self:hideAct()
        end))
        self:runAction(seq)
        return 
    end
    self["node_fnt_"..self.curEndIndex]:setIsEnd(true)

end

function BossRateChange:setCppData(cppData )
    print("-------playRateChangeAct----hideAct--=")
    self.cppData = cppData
end

function BossRateChange:hideAct( )
    print("-------playRateChangeAct----hideAct--=")
    self.animation:play("close", false)
end

function BossRateChange:closeAllSchedule()
    for i=1,self.FNT_COUNT do
        self["node_fnt_"..i]:closeAllSchedule()
    end  
end

return BossRateChange;