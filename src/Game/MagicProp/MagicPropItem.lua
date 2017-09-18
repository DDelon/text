local MagicPropItem = class("MagicPropItem", cc.load("mvc").ViewBase)

MagicPropItem.AUTO_RESOLUTION   = 0
MagicPropItem.RESOURCE_FILENAME = "ui/battle/magicitem/uipropitem"

MagicPropItem.RESOURCE_BINDING  = {
    ["panel"]       = { ["varname"] = "panel" },
    ["spr_propbg"]  = { ["varname"] = "spr_propbg" },

    ["img_vip"]     = { ["varname"] = "img_vip" },
    ["text_select"] = { ["varname"] = "text_select" },
    ["img_subbg"]   = { ["varname"] = "img_subbg" },
    ["font_diamon"] = { ["varname"] = "font_diamon" },
    ["diamon"]      = { ["varname"] = "diamon" },
    ["img_select"]  = { ["varname"] = "img_select" },

}

local vip_level_0 = cc.c3b(255, 72, 0)
local vip_level_x = cc.c3b(0, 168, 204)

function MagicPropItem:onCreate( ... )
    self.text_select:setVisible(false)
    self.text_select:setTextColor(cc.c4b(255, 255, 255, 255))
end

function MagicPropItem:setDepend(level, count)
    if level ==0 and count > 0 then
        self:doShowBottomBg(count)
        return
    end

    if level == 0 and count == 0 then
        self:showVip(0)
    elseif level > 0 then
        self:showVip(level)
        self:doShowBottomBg(count)
    end

    self.img_vip:setVisible(true)
end

function MagicPropItem:showVip(level)
    self.text_select:setVisible(true)
    if level == 0 then
        self.img_vip:setColor(vip_level_0)
        self.text_select:setString(FishGF.getChByIndex(800000216))
    else
        self.img_vip:setColor(vip_level_x)
        self.text_select:setString("V"..tostring(level))
    end
end

function MagicPropItem:doShowBottomBg(count)
    self.font_diamon:setString(count)
    self.img_subbg:setVisible(true)

end

function MagicPropItem:setSelect(bSel)
    self.img_select:setVisible(bSel)
end

function MagicPropItem:isSelect()
    return self.img_select:isVisible()
end

function MagicPropItem:setImageView(img)
    self.spr_propbg:addChild(img)
end

return MagicPropItem