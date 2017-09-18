local TimehourEnd = class("TimehourEnd", cc.load("mvc").ViewBase)

TimehourEnd.AUTO_RESOLUTION   = false
TimehourEnd.RESOURCE_FILENAME = "ui/battle/hourglass/uihourglasssecond"
TimehourEnd.RESOURCE_BINDING  = {
    ["BitmapFontLabel_1"]     = { ["varname"] = "BitmapFontLabel_1" },
}

function TimehourEnd:onCreate( ... )
    self:runAction(self.resourceNode_.animation)
    self.resourceNode_.animation:play("revert", false)
end

function TimehourEnd:setRevertCoin(count, curCoin, callback)    
    FishGI.GameEffect:jumpingNumber(self.BitmapFontLabel_1, 2.5, count, curCoin, callback)
end


return TimehourEnd