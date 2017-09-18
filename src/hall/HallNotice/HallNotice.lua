
local HallNotice = class("HallNotice", cc.load("mvc").ViewBase)

HallNotice.AUTO_RESOLUTION   = false
HallNotice.RESOURCE_FILENAME = "ui/common/uihallnotice"
HallNotice.RESOURCE_BINDING  = {  
    ["panel"]      = { ["varname"] = "panel" },
    ["panel_clip"] = { ["varname"] = "panel_clip" },    
}

function HallNotice:onCreate(...)
    self.curAccountIndex = 0
    self.AccountSpeed = 200

    self.delayEvery =  tonumber(FishGI.GameConfig:getConfigData("config", tostring(990000048), "data"));
    self.delayList =  tonumber(FishGI.GameConfig:getConfigData("config", tostring(990000049), "data"));

end

function HallNotice:setAccountData( accountData )
    self.AccountList = accountData.list
    self.curAccountIndex = 0

    if self.curAccount ~= nil then
        self.curAccount:removeFromParent()
        self.curAccount = nil
    end

    if #self.AccountList <=0 then
        self:setVisible(false)
        return
    end
    self:setVisible(true)

    self:upDataAccountlayer()
end

function HallNotice:upDataAccountlayer(  )
    print("---#self.AccountList="..#self.AccountList)
    local delaytime = 0
    if self.curAccountIndex == 0 then
        delaytime = 0
        self.curAccountIndex = 1
    elseif self.curAccountIndex > #self.AccountList then
        self.curAccountIndex = 1
        delaytime = self.delayList 
    else
        delaytime = self.delayEvery 
    end
    print("--00000000--------onClickmsw---delaytime="..delaytime)
    local message = self.AccountList[self.curAccountIndex]
    local clipsize = self.panel_clip:getContentSize();
    if self.curAccount ~= nil then
        self.curAccount:removeFromParent()
    end
    self.curAccount = cc.Label:createWithSystemFont("", "Arial", 30)
    self.curAccount:setColor(cc.c3b(146,62,13))
    if message ~= nil then
        self.curAccount:setString(message)
        print("-----message="..message)
    end   
    self.curAccount:setAnchorPoint(cc.p(0, 0.5))
    local sizeAnnoun = self.curAccount:getContentSize()
    self.curAccount:setPosition(cc.p(clipsize.width,clipsize.height/2))
    self.panel_clip:addChild(self.curAccount)

    local delayAct = cc.DelayTime:create(delaytime)
    local dis = sizeAnnoun.width + clipsize.width
    local callfun1 = cc.CallFunc:create(function ( ... )
        self:setVisible(true)
    end)
    local moveby = cc.MoveBy:create(dis/self.AccountSpeed,cc.p(-dis,0))
    local callfun = cc.CallFunc:create(function ( ... )
        self.curAccountIndex = self.curAccountIndex +1
        self:setVisible(false)
        self.curAccount:removeFromParent()
        self.curAccount = nil
        self:upDataAccountlayer()
    end)
    local seq = cc.Sequence:create(delayAct,callfun1,moveby,callfun)
    self.curAccount:runAction(seq)
end

return HallNotice;