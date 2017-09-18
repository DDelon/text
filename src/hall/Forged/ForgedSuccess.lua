
local ForgedSuccess = class("ForgedSuccess", cc.load("mvc").ViewBase)

ForgedSuccess.AUTO_RESOLUTION   = false
ForgedSuccess.RESOURCE_FILENAME = "ui/hall/forged/uiforgedsuccess"
ForgedSuccess.RESOURCE_BINDING  = {  
    ["panel"]                   = { ["varname"] = "panel" },
    ["text_notice_1"]           = { ["varname"] = "text_notice_1" },
    ["text_notice_2"]           = { ["varname"] = "text_notice_2" },
    ["spr_light"]               = { ["varname"] = "spr_light" },
    ["fnt_gun_times_1"]         = { ["varname"] = "fnt_gun_times_1" },
    ["fnt_gun_times_2"]         = { ["varname"] = "fnt_gun_times_2" },
    ["spr_gun"]                 = { ["varname"] = "spr_gun" },
    ["btn_sure"]                = { ["varname"] = "btn_sure", ["events"]={["event"]="click",["method"]="onClickSure"}},
}

function ForgedSuccess:onCreate( ... )

    --初始化
    self:init()

    -- 初始化View
    self:initView() 

end

function ForgedSuccess:init()   
    self.panel:setSwallowTouches(false)

    --添加触摸监听
    self:openTouchEventListener()

end

--初始化视图
function ForgedSuccess:initView()
    self.text_notice_1:setString(FishGF.getChByIndex(800000214))
    self.text_notice_2:setString(FishGF.getChByIndex(800000215))
    self:runAction(self.resourceNode_["animation"])
end

function ForgedSuccess:showLayer(isAct)
    self.super.showLayer(self,isAct)
    self.resourceNode_["animation"]:play("show", false)
    FishGI.AudioControl:playEffect("sound/lvup_01.mp3")
end

--点击确定
function ForgedSuccess:onClickSure( sender )
    self.spr_light:stopAllActions()
    self:hideLayer()
    if self.funCallBackClose then
        self.funCallBackClose()
    end
end

function ForgedSuccess:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false  
    end
    return true
end

function ForgedSuccess:onTouchMoved(touch, event)
end

function ForgedSuccess:onTouchEnded(touch, event) 
end

--设置炮倍
function ForgedSuccess:setGunRate( newGunRate )
    self.fnt_gun_times_1:setString(tostring(newGunRate))
    self.fnt_gun_times_2:setString(tostring(newGunRate))
    self.spr_light:runAction(cc.RepeatForever:create(cc.RotateBy:create(1,FishCD.LIGHT_SPEED)))
end

--设置回调函数
function ForgedSuccess:setCallBackClose( funCallBackClose )
    self.funCallBackClose = funCallBackClose
end

--设置vip
function ForgedSuccess:setVIPLevel( vip_level )
    self.vip_level = vip_level
    local strGunImg = FishGI.GameTableData:getGunOutlookTableByVip(vip_level).cannon_img
    local strGumImg = string.format("battle/cannon/%s", strGunImg)
    self.spr_gun:initWithFile(strGumImg)
end

return ForgedSuccess;