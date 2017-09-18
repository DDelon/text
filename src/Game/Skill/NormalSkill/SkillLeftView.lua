local SkillLeftView = class("SkillLeftView", cc.load("mvc").ViewBase)

SkillLeftView.isOpen            = false
SkillLeftView.AUTO_RESOLUTION   = true
SkillLeftView.RESOURCE_FILENAME = "ui/battle/skill/uiskill_list_left"
SkillLeftView.RESOURCE_BINDING  = {    
    ["panel"]             = { ["varname"] = "panel" },  
    ["node_skill_left_1"] = { ["varname"] = "node_skill_left_1" },   
    ["node_skill_left_2"] = { ["varname"] = "node_skill_left_2" },
    ["node_skill_left_3"] = { ["varname"] = "node_skill_left_3" },
    
    ["btn_triangle"]      = { ["varname"] = "btn_triangle" ,      ["events"]={["event"]="click",["method"]="onClickOpen"}},
    
    ["panel_left"]        = { ["varname"] = "panel_left" },  
    ["image_skill_bg"]    = { ["varname"] = "image_skill_bg" },  
}

SkillLeftView.BTN_ARR  = {    
    FishCD.SKILL_TAG_MISSILE,
    FishCD.SKILL_TAG_BOMB,
    FishCD.SKILL_TAG_SUPERBOMB
}

function SkillLeftView:onCreate( ... )
end

function SkillLeftView:initView()
    self.firstPosX = self.image_skill_bg:getPositionX()
    self:setIsOpen()
    self:openTouchEventListener()
    self.panel_left:setSwallowTouches(false)

    self:runAction(self.resourceNode_["animation"])

    for i,v in ipairs(self.BTN_ARR) do
        local node = self["node_skill_left_"..(0+i)]
        self:runAction(self["node_skill_left_"..(0+i)].animation)
        local mode = require("Game/Skill/NormalSkill/SkillBtn")
        mode.RESOURCE_FILENAME = "ui/battle/skill/uiskillitem1"
        node = mode.new(self, node)
        node:initBtn(v,0)
        local btn = node:getBtn()
        btn.parentClasss = node
        self["node_skill_left_"..(0+i)] = node
    end

    self:initBtn()
    
    FishGI.eventDispatcher:registerCustomListener("setNewUsedPropId", self, function(valTab) self:setNewUsedPropId(valTab) end);

end

function SkillLeftView:initBtn()
    for i,v in ipairs(self.BTN_ARR) do
        local node = self["node_skill_left_"..(0+i)]:getBtn()
        self:initBtnByPropId(node,v)
    end

end

function SkillLeftView:initBtnByPropId(node,propId)
    print("----------------SkillLeftView:initBtnByPropId------------------")
    node:setTag(propId)
    local name = string.format("battle/skill/bl_pic_skill_prop_%03d.png",propId)
    local spr_lock = node:getChildByName("spr_lock")
    if not spr_lock:initWithFile(name) then
        print("----initWithFile is faile------")
    end
    node.parentClasss:setState(0)
end

function SkillLeftView:onClickOpen( sender )
	self:setIsOpen()
end

function SkillLeftView:onTouchBegan(touch, event) 
    local curPos = touch:getLocation()
    for k,v in pairs(FishCD.SKILLS) do
        local child = self.image_skill_bg
        local s = child:getContentSize()
        local locationInNode = child:convertToNodeSpace(curPos)
        local rect = cc.rect(0,0,s.width,s.height)
        if cc.rectContainsPoint(rect,locationInNode) then
            return false
        end        
    end

    if self.isOpen == true then
        self:setIsOpen()
    end

    return false
end

function SkillLeftView:setIsOpen()  
    self.isOpen = not self.isOpen
    if self.isOpen == true then
        self.btn_triangle:getChildByName("spr_triangle"):setRotation(180)
        self.image_skill_bg:stopAllActions()
        self.image_skill_bg:runAction(cc.MoveTo:create(0.2,cc.p(self.firstPosX,self.image_skill_bg:getPositionY())))
    else
        self.btn_triangle:getChildByName("spr_triangle"):setRotation(0)
        self.image_skill_bg:stopAllActions()
        --self.image_skill_bg:runAction(cc.MoveTo:create(0.2,cc.p(-102,self.image_skill_bg:getPositionY())))
        self.image_skill_bg:runAction(cc.MoveTo:create(0.2,cc.p(-133,self.image_skill_bg:getPositionY())))
    end
end

function SkillLeftView:getBtnByPropId( propId )
    for i,v in ipairs(self.BTN_ARR) do
        local node = self["node_skill_left_"..(0+i)]:getBtn()
        local tag = node:getTag()
        if tag == propId then
            return node
        end
    end
end

function SkillLeftView:setNewUsedPropId( propId )
    local propId = tonumber(propId)
    print("-------------propId="..propId)
    local newBtnArr = {}
    table.insert( newBtnArr, propId )

    local countArr = {}
    for i,v in ipairs(self.BTN_ARR) do
        if propId ~= v then
            table.insert( newBtnArr, v )
        end
        local fnt = self:getBtnByPropId(v):getChildByName("fnt_count")
        countArr[v] =tonumber(fnt:getString())
        print("-----countArr"..countArr[v])
    end

    self.BTN_ARR = newBtnArr
    self:initBtn()
    for k,v in pairs(FishCD.SKILLS) do
        for i,v2 in ipairs(self.BTN_ARR) do
            if v2 == v then
                local skillView = self:getParent():getParent()
                skillView["btn_skill_"..v] = self:getBtnByPropId(v)
                skillView["Skill_"..v]:initDataByPropId(k, v, skillView["btn_skill_"..v],countArr[v])
            end
        end
    end
end

return SkillLeftView;