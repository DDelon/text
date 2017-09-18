local TreasureBox = class("TreasureBox", cc.load("mvc").ViewBase)

TreasureBox.AUTO_RESOLUTION     = 0
TreasureBox.RESOURCE_FILENAME   = "ui/hall/check/uiawardbox"

TreasureBox.RESOURCE_BINDING  = {
    ["panel"]           = { ["varname"] = "panel" },   
    ["text_award"]      = { ["varname"] = "text_award" },   
    ["image_award_bg"]  = { ["varname"] = "image_award_bg" },   
    ["btn_lookaward"]   = { ["varname"] = "btn_lookaward", ["events"]={["event"]="touch",["method"]="onTouch"} },
    ["spr_light"]       = { ["varname"] = "spr_light" },
    ["spr_prop_2"]      = { ["varname"] = "spr_prop_2" },
    ["spr_box_close"]      = { ["varname"] = "spr_box_close" },
}

function TreasureBox:setActiveLevel(level)
    self.level = level
end

function TreasureBox:setEndItem()
    self.isEnd = true
end

function TreasureBox:setClose()
    log("TreasureBox:setClose")
    self.state = "close"
    self.spr_light:setVisible(false)
    
    if self.isEnd then
        self:play("close_big_prop", true)
    else 
        self:play("colse", true)
    end

end

function TreasureBox:setActive()
    log("TreasureBox:setActive")
    self.state = "active"
    self.spr_light:setVisible(true)

    local animate = "waiting_sm"
    if self.isEnd then
        animate = "waiting_big"
    end
    self:play(animate, true)
end

function TreasureBox:setOpen()
    log("TreasureBox:setOpen")
    self.state = "open"
    self.spr_light:setVisible(false)
    local animate = "open_prop_1"
    if self.isEnd then
        animate = "open_big"
    end
    self:play(animate, false)
end

function TreasureBox:setTipString(tip)
    self.tipString = tip
end

------------------------------------------------------------------------
function TreasureBox:onCreate( ... )
    self.text_award:setVisible(false)
    self.image_award_bg:setVisible(false)
    self.spr_prop_2:setVisible(false)
    
    self.resourceNode_.animation:retain()
    self:runAction(self.resourceNode_.animation)
    self.isEnd = false
   -- self:openTouchEventListener()
end

function TreasureBox:isPosInNode(node, worldPos)
    local bg = node:getContentSize()
    local rect = cc.rect(0, 0, bg.width, bg.height)
    local posX,posY = node:getPosition()
    local wpos = node:getParent():convertToWorldSpace(cc.p(node:getPosition()))
    local nodePos = node:convertToNodeSpace(worldPos)

    return cc.rectContainsPoint(rect, nodePos)
end

function TreasureBox:onTouch(touch)
    if touch.name == "began" then
        self.tip = require("hall/Task/TaskUI/TaskRewardTip").create()
        local x, y = self.tip:getPosition()
        self.tip:setPosition(x, y + 100)
        self.tip:setTip(self.tipString)
        self:addChild(self.tip)

    elseif touch.name == "ended" then
        if self.tip then
            self.tip:removeFromParent()
            self.tip = nil
        end
        self:onClickGet()
    elseif touch.name == "moved" then
    else
        if self.tip then
            self.tip:removeFromParent()
            self.tip = nil
        end
    end
end

function TreasureBox:play(type, loop)
    self.resourceNode_.animation:play(type, loop)
end

function TreasureBox:onClickGet()
    log("TreasureBox:onClickGet")
    if self.state ~= "active" then
        return 
    end

    local event = {}
    event.eventType = "DO_GET_ACTIVE_REWARD"
    event.ActiveGrade = self.level
    FishGI.eventDispatcher:dispatch("onTaskEvent", event);
end

return TreasureBox