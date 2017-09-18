local SkillView = class("SkillView", cc.load("mvc").ViewBase)

SkillView.isOpen            = false
SkillView.AUTO_RESOLUTION   = true
SkillView.RESOURCE_FILENAME = "ui/battle/skill/uiskilldesk"
SkillView.RESOURCE_BINDING  = {    
    ["btn_skill_3"]         = { ["varname"] = "btn_skill_3"},
    ["btn_skill_4"]         = { ["varname"] = "btn_skill_4" },
    ["btn_skill_5"]         = { ["varname"] = "btn_skill_5"},
    --    ["btn_skill_6"]   = { ["varname"] = "btn_skill_6" ,      ["events"]={["event"]="click",["method"]="onClickSkillBack"}},
    ["btn_skill_14"]        = { ["varname"] = "btn_skill_14" },
    ["btn_skill_17"]        = { ["varname"] = "btn_skill_17" },
    
    ["node_left"]           = { ["varname"] = "node_left" },   
    ["btn_triangle"]        = { ["varname"] = "btn_triangle" ,      ["events"]={["event"]="click",["method"]="onClickOpen"}},
    
    ["node_skll_desk"]      = { ["varname"] = "node_skll_desk" },  

}

--左边的按键
SkillView.BOMB_LIST  = {
    "Skill_6",
    "Skill_15",
    "Skill_16",
}

--底部的按键
SkillView.DOWN_LIST  = {
    { ["varname"] = "btn_skill_3",["propId"] = 3,["index"] = 1}, 
    { ["varname"] = "btn_skill_4",["propId"] = 4,["index"] = 2},
    { ["varname"] = "btn_skill_5",["propId"] = 5,["index"] = 3},
    { ["varname"] = "btn_skill_17",["propId"] = 17,["index"] = 4},
    { ["varname"] = "btn_skill_14",["propId"] = 14,["index"] = 0},
}

function SkillView:onCreate( ... )
    self.node_left = require("Game/Skill/NormalSkill/SkillLeftView").new(self, self.node_left)
    self.node_left:setScale(self.scaleMin_)
    self.node_left:initView()
    self.btn_skill_14:setScale(self.scaleMin_)

    self:runAction(self.resourceNode_["animation"])
    self.node_skll_desk:setScale(self.scaleMin_)

    --按键在效果层上
    self.node_skll_desk:setLocalZOrder(100)
    self.node_left:setLocalZOrder(100)
    self.btn_skill_14:setLocalZOrder(100)

    --冰冻
    self.Layer = self:getChildByName("Layer")
    self.Skill_3 = require("Game/Skill/NormalSkill/SkillFreeze").create()
    self.Layer:addChild(self.Skill_3,5)

    --锁定
    self.Skill_4 = require("Game/Skill/NormalSkill/SkillLock").create()
    self.Layer:addChild(self.Skill_4,5)

    --召唤鱼
    self.Skill_5 = require("Game/Skill/NormalSkill/SkillCallFish").create()
    self.Layer:addChild(self.Skill_5,6)

    --核弹
    self.Skill_6 = require("Game/Skill/NormalSkill/SkillNBomb").create()
    self.Layer:addChild(self.Skill_6,7)
    self.Skill_6:setPropId(6)

    --导弹
    self.Skill_15 = require("Game/Skill/NormalSkill/SkillNBomb").create()
    self.Layer:addChild(self.Skill_15,7)
    self.Skill_15:setPropId(15)

    --氢弹
    self.Skill_16 = require("Game/Skill/NormalSkill/SkillNBomb").create()
    self.Layer:addChild(self.Skill_16,7)
    self.Skill_16:setPropId(16)

    --时光倒流
    self.Skill_14 = require("Game/Skill/NormalSkill/SkillTimeRevert").create()
    self.Layer:addChild(self.Skill_14,7)
    

    --狂暴
    self.Skill_17 = require("Game/Skill/NormalSkill/SkillViolnet").create()
    self.Layer:addChild(self.Skill_17,7)
    self.Skill_17:setPropId(17)

    self.btn_skill_6 = self.node_left:getBtnByPropId(6)
    self.btn_skill_6:onClickDarkEffect(self:handler(self,self.onClickSkillBack))

    self.btn_skill_15 = self.node_left:getBtnByPropId(15)
    self.btn_skill_15:onClickDarkEffect(self:handler(self,self.onClickSkillBack))

    self.btn_skill_16 = self.node_left:getBtnByPropId(16)
    self.btn_skill_16:onClickDarkEffect(self:handler(self,self.onClickSkillBack))

    for k,v in ipairs(self.DOWN_LIST) do
        local mode = require("Game/Skill/NormalSkill/SkillBtn")
        mode.RESOURCE_FILENAME = "ui/battle/skill/uiskillitem2"
        self[v.varname] = mode.new(self, self[v.varname])
        self[v.varname]:initBtn(v.propId,v.index)
        self[v.varname]:replayStateAct(v.propId)
        local btn = self[v.varname]:getBtn()
        btn.parentClasss = self[v.varname]
        self[v.varname] = btn
        self[v.varname]:onClickDarkEffect(self:handler(self,self.onClickSkillBack))
    end


    for k,v in pairs(FishCD.SKILLS) do
        self["Skill_"..v]:initDataByPropId(k, v, self["btn_skill_"..v])
    end
    
    self:openTouchEventListener()


    self:initListener()
end

--初始化监听器
function SkillView:initListener()
    FishGI.eventDispatcher:registerCustomListener("updataPropUI", self, function(valTab) self:updataPropUI(valTab) end)
end

function SkillView:clearAllbomb(  )
    self.Skill_15:clearUseNBomb()
    self.Skill_16:clearUseNBomb()
    self.Skill_6:clearUseNBomb()
end

function SkillView:onClickOpen( sender )
	self:setIsOpen()
end

function SkillView:setIsOpen()  
    self.isOpen = not self.isOpen
end

function SkillView:onClickSkillBack( sender )
    log("SkillView-onClickSkillBack: " .. sender:getTag())
    if FishGI.isFishGroupCome == true and not self.Skill_14.isCountingDown then
        return
    end
    local tag = sender:getTag()
    self["Skill_"..tag]:clickCallBack()

end

function SkillView:setPricce( val )
    local tag = val.propId
    self["Skill_"..tag]:setPricce(val)
end

function SkillView:setSkillByTag( val )
    local tag = val.propId
    local count = val.propCount
    if self["Skill_"..tag] ~= nil then
        self["Skill_"..tag]:setSkillByTag(val)
    end
end

function SkillView:isTouchBtn(touch) 
    local curPos = touch:getLocation()  
    for k,v in pairs(FishCD.SKILLS) do
        local child = self["btn_skill_"..v]
        local s = child:getContentSize()
        local locationInNode = child:convertToNodeSpace(curPos)
        local rect = cc.rect(0,0,s.width,s.height)
        if cc.rectContainsPoint(rect,locationInNode) then
            return true
        end     
    end
    return false
end

function SkillView:onTouchBegan(touch, event) 
    local curPos = touch:getLocation()
    for k,v in pairs(FishCD.SKILLS) do
        local child = self["btn_skill_"..v]
        local s = child:getContentSize()
        local locationInNode = child:convertToNodeSpace(curPos)
        local rect = cc.rect(0,0,s.width,s.height)
        if cc.rectContainsPoint(rect,locationInNode) then
            return true
        end        
    end

    if self.isOpen == true then
        self:setIsOpen()
    end

    return false
end

function SkillView:onTouchCancelled(touch, event)

end

function SkillView:closeSchedule()
    for k,v in pairs(FishCD.SKILLS) do
        self["Skill_"..v]:closeSchedule()
    end
end

function SkillView:updataPropUI(data)
    if FishGI.myData ~= nil and FishGI.myData.poops ~= nil then
        local isAdd = true
        for k,v in pairs(FishGI.myData.poops) do
            if v.propId == val.propId then
                v.propCount = val.propCount
                isAdd = false
            end
        end
        if isAdd then
            table.insert( FishGI.myData.poops,val)
        end
    end
    
    self:setSkillByTag(data)
end

function SkillView:upDateUserTime(disTime )
    self.Skill_4:upDateUserTime(disTime)
    self.Skill_3:upDateUserTime(disTime)
    self.Skill_17:upDateUserTime(disTime)
end

return SkillView;