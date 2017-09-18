local TimehourBanner = class("TimehourBanner", cc.load("mvc").ViewBase)

TimehourBanner.AUTO_RESOLUTION   = false
TimehourBanner.RESOURCE_FILENAME = "ui/battle/hourglass/uihourglassfirst"
TimehourBanner.RESOURCE_BINDING  = {    
    ["fnt"]     = { ["varname"] = "fnt" },
}

function TimehourBanner:onCreate( ... )
    self:init()
    self:runAction(self.resourceNode_.animation)
    self.resourceNode_.animation:play("start", false)
    FishGI.AudioControl:playEffect("sound/hourglass_01.mp3") 
end

function TimehourBanner:init( ... )
    self.fnt:setString(300)
    
    local repeateAndCallfunction = self:delayPeriodAndCallFunc(1, function ( ... )
        local remain = tonumber(self.fnt:getString())
        self.fnt:setString(tostring(remain - 1))
    end)

    local repeat5time = cc.Repeat:create(repeateAndCallfunction, 5)
    self.fnt:runAction(repeat5time)
end

function TimehourBanner:delayPeriodAndCallFunc(period, callback)
    local sequence = {}

    sequence[#sequence + 1] = cc.DelayTime:create(period)
    sequence[#sequence + 1] = cc.CallFunc:create(callback)

    return transition.sequence(sequence)
end

return TimehourBanner