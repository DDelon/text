local SkillBtn = class("SkillBtn", cc.load("mvc").ViewBase)

SkillBtn.AUTO_RESOLUTION   = true
SkillBtn.RESOURCE_BINDING  = {    
    ["panel"]        = { ["varname"] = "panel" },  
    ["btn_skill"]    = { ["varname"] = "btn_skill"},
    ["spr_lock"]     = { ["varname"] = "spr_lock"},
    ["spr_gray"]     = { ["varname"] = "spr_gray" },  
    
    ["node_light_1"] = { ["varname"] = "node_light_1" },  
    ["node_light_2"] = { ["varname"] = "node_light_2" },   
    ["num_bg"]       = { ["varname"] = "num_bg" },   
    ["fnt_count"]    = { ["varname"] = "fnt_count" },   
    ["fnt_price"]    = { ["varname"] = "fnt_price" },   
    ["spr_price"]    = { ["varname"] = "spr_price" },
}

function SkillBtn:onCreate( ... )
    self:runAction(self.resourceNode_["animation"])
    self.animation = self.resourceNode_["animation"]

end

function SkillBtn:initBtn( propId ,index)
    self:initBtnState(propId)
    self.btn_skill:setTag(propId)

    local picName = string.format( "battle/skill/bl_pic_skill_prop_%03d.png",propId)
    if not self.spr_lock:initWithFile(picName) then
        print("----initWithFile is faile------")
    end    

    self.node_light_1:stopAllActions()
    self.node_light_1:runAction(self.node_light_1.animation)

    if index == 0 then
        self.node_light_1.animation:play("doplay", true)
    else
        local dis = 55
        local seq = cc.Sequence:create(cc.DelayTime:create(index*dis/60),cc.CallFunc:create(function ( ... )
            local sequence = cc.Sequence:create(
            cc.CallFunc:create(function ( ... )
                self.node_light_1.animation:play("doplay", false);
            end),
            cc.DelayTime:create(4*dis/60))
            local action = cc.RepeatForever:create(sequence)
            self:runAction(action)
        end)) 
        self:runAction(seq)
    end
    
    --要先停止原先变形的动画，再播放最新的动画
    self.node_light_2:stopAllActions()
    self.node_light_2:runAction(self.node_light_2.animation)
    self.node_light_2.animation:play("doplay", true);

    self:initProgressTimer()

end

--阴影进度条
function SkillBtn:initProgressTimer( )
    self.spr_gray:setVisible(false)
    if self["Timer"] ~= nil then
        self["Timer"]:setPercentage(0) 
        return 
    end
    self["Timer"] = cc.ProgressTimer:create(self.spr_gray)  
    self["Timer"]:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self["Timer"]:setPercentage(0) 
    self["Timer"]:setPosition(cc.p(self.spr_gray:getPositionX(),self.spr_gray:getPositionY()))  
    self.btn_skill:addChild(self["Timer"]) 
    self["Timer"]:setLocalZOrder(self.spr_gray:getLocalZOrder())
    self.fnt_count:setLocalZOrder(self.spr_gray:getLocalZOrder()+1)
    self.fnt_price:setLocalZOrder(self.spr_gray:getLocalZOrder()+2)
end

function SkillBtn:getProgressTimer( )
    if self["Timer"] == nil then
        self:initProgressTimer()
    end
    return self["Timer"]
end

function SkillBtn:initBtnState( propId )
    if propId == 3 or propId == 4 or propId == 5 or propId == 17 then
        self:setState(1)
    elseif propId == 14 or propId == 6 or propId == 15 or propId == 16 then
        self:setState(0)
    end
end

function SkillBtn:getBtn(  )
    return self.btn_skill
end

function SkillBtn:setState( type )
    self.node_light_2:setVisible(false)
    self.node_light_1:setVisible(false)
    if type == 0 then                           --全部隐藏
    elseif type == 1 then                          --只显示光环1
        self.node_light_1:setVisible(true)
    elseif type == 2 then                          --只显示光环2
        self.node_light_2:setVisible(true)
    elseif type == 3 then                          --显示光环1和2
        self.node_light_2:setVisible(true)
        self.node_light_1:setVisible(true)
    end
end

function SkillBtn:replayStateAct( propId )
    if propId == 14 then
        local uiTimeRevert = require("ui/battle/hourglass/uiskillanimation").create()
        local timeRevert = uiTimeRevert.root   
        self.node_light_2:addChild(timeRevert)
        timeRevert:setPosition(cc.p(0,0))
        timeRevert:runAction(uiTimeRevert.animation)
        uiTimeRevert.animation:play("doplay",true)
        timeRevert:setScale(1/self.node_light_2:getScale())
    end

end

--设置道具价格
function SkillBtn:setPricce( val )
    local tag = val.propId
    local price = val.price
    local fnt_price = self.fnt_price
    fnt_price:setString(price)
    self.price = price
end

--设置道具个数
function SkillBtn:setSkillByTag( val )
    self.spr_price:setVisible(false)
    local tag = val.propId
    local count = val.propCount
    local price = val.price
    local showWidth = self.num_bg:getContentSize().width
    self.fnt_count:setString(count)
    FishGF.isScaleByCount(self.fnt_count,count,self.fnt_count:getContentSize().width,showWidth)
    if price ~= nil then
        self.price = price
        self.fnt_price:setString(price)
        -- local width2 = 34*0.74*self.fnt_price:getScale() + self.fnt_price:getContentSize().width
        -- FishGF.isScaleByCount(self.fnt_price,price,width2,showWidth)
    end
    if count <=0 then
        self.num_bg:setVisible(true)
        self.fnt_price:setVisible(true)
        self.fnt_count:setVisible(false)
        if self.price > 999 then
            self.spr_price:setVisible(true)
            self.fnt_price:setVisible(false)
        end
    else
        self.num_bg:setVisible(false)
        self.fnt_price:setVisible(false)
        self.fnt_count:setVisible(true)
    end
end

function SkillBtn:getFntCount()
    return tonumber(self.fnt_count:getString())
end

function SkillBtn:getFntPrice()
    return tonumber(self.fnt_price:getString())
end

--CD进度条
function SkillBtn:runTimer(cooldown,per,callbackAct)
    local Timer = self["Timer"]
    if Timer == nil then
        return
    end
    Timer:setVisible(true)
    Timer:stopAllActions()
    Timer:setPercentage(100) 

    local progressTo = nil
    if per == 0 then
        progressTo = cc.ProgressTo:create(cooldown,per)  
    else
        progressTo = cc.ProgressFromTo:create(cooldown,per,0)  
    end

    local seq = cc.Sequence:create(progressTo,callbackAct)
    Timer:runAction(seq)

end

--停止CD进度条
function SkillBtn:stopTimer()
    local Timer = self["Timer"]
    if Timer == nil then
        return
    end
    Timer:setVisible(true)
    Timer:stopAllActions()
    Timer:setPercentage(0) 
    self.btn_skill:setTouchEnabled(true)
end

return SkillBtn;