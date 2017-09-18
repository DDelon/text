local LotteryPanel = class("LotteryPanel", cc.load("mvc").ViewBase)

LotteryPanel.isOpen            = false
LotteryPanel.AUTO_RESOLUTION   = false
LotteryPanel.RESOURCE_FILENAME = "ui/battle/lottery/uilotterypanel"
LotteryPanel.RESOURCE_BINDING  = {    
    ["image_lotterypanel_bg"] = { ["varname"] = "image_lotterypanel_bg" },
    ["node_animation"]        = { ["varname"] = "node_animation" }, 
    ["btn_lottery"]           = { ["varname"] = "btn_lottery" ,      ["events"]={["event"]="click",["method"]="onClickOpen"}},
    
    ["node_spr"]              = { ["varname"] = "node_spr" },  
    ["fnt_allcoin"]           = { ["varname"] = "fnt_allcoin" },
    ["bar_LoadingBar"]        = { ["varname"] = "bar_LoadingBar" },
    ["fnt_curNum"]            = { ["varname"] = "fnt_curNum" },
    ["fnt_aimNun"]            = { ["varname"] = "fnt_aimNun" },
    
    ["image_bar_bg"]          = { ["varname"] = "image_bar_bg" },
    ["spr_startlottery"]      = { ["varname"] = "spr_startlottery" },

}

function LotteryPanel:onCreate( ... )
    self:runAction(self.resourceNode_["animation"])
    self.resourceNode_["animation"]:play("LotteryPanel", true);
    self.spr_startlottery:setVisible(false)

    self:openTouchEventListener()
    
    self.node_spr:setVisible(false)
    self.image_lotterypanel_bg:setPositionX(self.image_lotterypanel_bg:getPositionX()-self.image_lotterypanel_bg:getContentSize().width*0.72)

    self.shwTime = tonumber(FishGI.GameConfig:getConfigData("config", tostring(990000021), "data"));
    self.isShow = false



    self.lotteryLv = nil
    self.curKillCount  = 0
    self.aimKillCount = 1
    self.allPoolCoin = 0
    self.resourceNode_["animation"]:pause()
    self.node_animation:setVisible(false)

    self:setIsOpen(false)

    FishGI.eventDispatcher:registerCustomListener("upDataFishCoinPool", self, function(valTab) self:upDataFishCoinPool(valTab) end);

    if bit.band(FUN_SWITCH, 4) == 4 then
        self.btn_lottery:loadTextures("battle/gunupgrade/bl_btn_lottery_1.png", "battle/gunupgrade/bl_btn_lottery_1.png");
    end

end

function LotteryPanel:upDataAimCoin()
    local rewardData = FishGI.GameTableData:getRewardTable()
    local count = #rewardData
    for i=1,count do
        local coin = rewardData[i]["limit"]
        local data2 = rewardData[i+1]
        local coin2 = nil
        if data2 ~= nil then
            coin2 = data2["limit"]
        end
        
        if self.allPoolCoin >= coin and (coin2 == nil or self.allPoolCoin < coin2 ) then
            if coin2 ~= nil then
                self.lotteryLv = coin2 
            else
                self.lotteryLv = self.allPoolCoin *1000
            end
            return self.lotteryLv
        end
    end
end

function LotteryPanel:setAllPoolCoin(allPoolCoin)
    self.allPoolCoin = allPoolCoin
    self.fnt_allcoin:setString(self.allPoolCoin)
    self:setIsOpen(true)
    self.isShow = true
    self:upDataAimCoin()
    self:runAction(cc.Sequence:create(cc.DelayTime:create(self.shwTime),cc.CallFunc:create(function ()
        self:setIsOpen(false)
        self.isShow = false
    end)))
end

function LotteryPanel:setCurKillCount(curKillCount)
    self.curKillCount = tonumber(curKillCount)
    self.fnt_curNum:setString(self.curKillCount)
    self:upDataBar()
end

function LotteryPanel:setAimKillCount(aimKillCount)
    self.aimKillCount = tonumber(aimKillCount)
    self.fnt_aimNun:setString(self.aimKillCount)
    self:upDataBar()
end

function LotteryPanel:upDataBar()
    if self.curKillCount/self.aimKillCount < 1 then
        self.bar_LoadingBar:setPercent(self.curKillCount/self.aimKillCount*100)
        self.resourceNode_["animation"]:pause()
        self.node_animation:setVisible(false)  
        self.image_bar_bg:setVisible(true)  
        self.spr_startlottery:setVisible(false)   
    else
        self.bar_LoadingBar:setPercent(100)
        self.resourceNode_["animation"]:resume()
        self.node_animation:setVisible(true)
        self.image_bar_bg:setVisible(false) 
        self.spr_startlottery:setVisible(true)
        if self.lotteryLv == nil then
            self:setIsOpen(true)
            self.isShow = true
            self:upDataAimCoin()
            self:runAction(cc.Sequence:create(cc.DelayTime:create(self.shwTime),cc.CallFunc:create(function ()
                self:setIsOpen(false)
                self.isShow = false
            end)))
        end
    end
end

function LotteryPanel:onTouchBegan(touch, event)
    if self.isOpen == false then
        return false
    end
    
    local curPos = touch:getLocation()  
    local size = self.image_lotterypanel_bg:getContentSize()
    local locationInNode = self.image_lotterypanel_bg:convertToNodeSpace(curPos)
    local rect = cc.rect(0,0,size.width,size.height)
    if cc.rectContainsPoint(rect,locationInNode) then
        if self.isOpen == false then
            self:setIsOpen(true)
        else
            FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
            --弹出
            self:getParent().uiLotteryLayer:initLayerByCoin()
            self:getParent().uiLotteryLayer:showLayer()
            self:setIsOpen(false)
        end 
        return true
    else 
        if self.isOpen == true and self.isShow == false then
            self:setIsOpen(false)
        end 
    end

    return false
end

function LotteryPanel:onTouchCancelled(touch, event)
 
end

function LotteryPanel:setIsOpen(isOpen )
    self.isOpen = isOpen
    if self.isOpen == true then
        self.node_spr:setVisible(true)
        self.image_lotterypanel_bg:stopAllActions()
        self.image_lotterypanel_bg:runAction(cc.MoveTo:create(0.2,cc.p(0,0)))

    else
        self.image_lotterypanel_bg:stopAllActions()
        self.image_lotterypanel_bg:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,cc.p(-self.image_lotterypanel_bg:getContentSize().width*0.72,0)), 
            cc.CallFunc:create( function() self.node_spr:setVisible(false); end)));
    end
end

function LotteryPanel:onClickOpen( sender )

    self.isShow = false
    self:setIsOpen( not self.isOpen )
end

function LotteryPanel:upDataFishCoinPool(val)
    FishGI.eventDispatcher:dispatch("upDataLotteryLayer", val);
    
    local killRewardFishInDay = val.killRewardFishInDay
    local drawRequireRewardFishCount = val.drawRequireRewardFishCount
    local rewardRate = val.rewardRate

    self:setCurKillCount(killRewardFishInDay)
    self:setAimKillCount(drawRequireRewardFishCount)
    self:setAllPoolCoin(rewardRate)

end

return LotteryPanel;