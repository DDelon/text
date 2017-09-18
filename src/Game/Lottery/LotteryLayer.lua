local LotteryLayer = class("LotteryLayer", cc.load("mvc").ViewBase)

LotteryLayer.AUTO_RESOLUTION   = false
LotteryLayer.RESOURCE_FILENAME = "ui/battle/lottery/uilotterylayer"
LotteryLayer.RESOURCE_BINDING  = {    
    ["panel"]                = { ["varname"] = "panel"  }, 
    
    ["text_word_nextreward"] = { ["varname"] = "text_word_nextreward"  },
    ["node_bulb1"]           = { ["varname"] = "node_bulb1"  },
    ["node_bulb2"]           = { ["varname"] = "node_bulb2"  },
    
    ["btn_close"]            = { ["varname"] = "btn_close" ,["events"]={["event"]="click",["method"]="onClickClose"}},  
    
    ["node_coinpool"]        = { ["varname"] = "node_coinpool"  },
    ["spr_curreward"]        = { ["varname"] = "spr_curreward"  },
    ["text_word_pool"]       = { ["varname"] = "text_word_pool"  },
    ["bar_coinpool"]         = { ["varname"] = "bar_coinpool"  },
    ["fnt_poolbar_num"]      = { ["varname"] = "fnt_poolbar_num"  },
    ["btn_startlottery"]     = { ["varname"] = "btn_startlottery" ,["events"]={["event"]="click",["method"]="onClickStartLottery"}},  
    ["spr_word_kscj"]        = { ["varname"] = "spr_word_kscj"  },
    
    
    ["node_killfish"]        = { ["varname"] = "node_killfish"  },
    ["text_word_notice"]     = { ["varname"] = "text_word_notice"  },
    ["bar_killfish_count"]   = { ["varname"] = "bar_killfish_count"  },
    ["fnt_killbar_num"]      = { ["varname"] = "fnt_killbar_num"  },
    ["btn_lookfish"]         = { ["varname"] = "btn_lookfish" ,["events"]={["event"]="click",["method"]="onClickLookFish"}},  
    
    ["node_rewardbtn"]       = { ["varname"] = "node_rewardbtn"  },
    ["btn_reward_1"]         = { ["varname"] = "btn_reward_1" ,["events"]={["event"]="click",["method"]="onClickChangeReward"}},
    ["btn_reward_2"]         = { ["varname"] = "btn_reward_2" ,["events"]={["event"]="click",["method"]="onClickChangeReward"}},
    ["btn_reward_3"]         = { ["varname"] = "btn_reward_3" ,["events"]={["event"]="click",["method"]="onClickChangeReward"}},
    ["btn_reward_4"]         = { ["varname"] = "btn_reward_4" ,["events"]={["event"]="click",["method"]="onClickChangeReward"}},
    ["btn_reward_5"]         = { ["varname"] = "btn_reward_5" ,["events"]={["event"]="click",["method"]="onClickChangeReward"}},
    ["btn_reward_6"]         = { ["varname"] = "btn_reward_6" ,["events"]={["event"]="click",["method"]="onClickChangeReward"}},
    
    
    ["text_word_curreward"]  = { ["varname"] = "text_word_curreward"  },
    ["fnt_curcoin"]          = { ["varname"] = "fnt_curcoin"  },
    
    ["node_sixshell"]        = { ["varname"] = "node_sixshell"  },

}

function LotteryLayer:onCreate( ... )
    self:openTouchEventListener()
    --界面初始化
    self.text_word_nextreward:setString(FishGF.getChByIndex(800000082))
    self.text_word_nextreward:setVisible(false)

    self.text_word_curreward:setString(FishGF.getChByIndex(800000079))
    self.text_word_notice:setString(FishGF.getChByIndex(800000080))
    self.text_word_pool:setString(FishGF.getChByIndex(800000081))

    --灯泡闪动
    FishGI.GameEffect.lampBlink( self.node_bulb1,0 )
    FishGI.GameEffect.lampBlink( self.node_bulb2,0.5 )

    self.tag = 1
    self.allPoolCoin = 100000
    self.curLVCoin = 0
    self.nextLVCoin = FishGI.GameTableData:getRewardTable(2).limit

    self.curKillCount  = 0
    self.aimKillCount = 1


    self:upDataSixShellByKeyId(1)
    self:upDataLayer()

    FishGI.eventDispatcher:registerCustomListener("upDataLotteryLayer", self, function(valTab) self:upDataLotteryLayer(valTab) end);

end

function LotteryLayer:onTouchBegan(touch, event) 
    if not self:isVisible() then
         return false
    end
    return true
end

function LotteryLayer:onTouchCancelled(touch, event)

end

function LotteryLayer:onClickClose( sender )
    self:hideLayer()
end

function LotteryLayer:onClickStartLottery( sender )
    local lockFish = self.btn_startlottery:getChildByName("spr_word_ckjjy")
    local startChose = self.btn_startlottery:getChildByName("spr_word_kscj")
    if lockFish:isVisible() then
        self:onClickLookFish(self)
        return
    end

    local disCoin = self:getDisNextCoin()
    if disCoin > 0 then
        local str = string.format( FishGF.getChByIndex(800000313),disCoin)
        local function callback(sender)
            local tag = sender:getTag()
            if tag == 2 then
                self:changeToStartLottery()
            end
        end
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,str,callback)
    else
        self:changeToStartLottery()
    end
end

function LotteryLayer:changeToStartLottery( sender )
    local propArr = FishGI.GameTableData:getRewardTable(self.tag).prop
    self:getParent().uiLotteryStart:upDataSixShellByKeyId(self.tag,propArr) 
    self:getParent().uiLotteryStart:initToFirst()
    self:hideLayer(false)
    self:getParent().uiLotteryStart:showLayer()
end

function LotteryLayer:onClickLookFish( sender )
    self:getParent().uiFishForm.isFromLottery = "LotteryLayer"

    self:hideLayer(false)
    self:getParent().uiFishForm:showLayer()

end

function LotteryLayer:onClickChangeReward( sender )
    self.tag = sender:getTag()
    print("------onClickChangeReward-----tag="..self.tag)
    self.spr_curreward:initWithFile("battle/lottery/lottery_pic_words_"..self.tag..".png")
    self:upDataSixShellByKeyId(self.tag)

    self.curLVCoin = FishGI.GameTableData:getRewardTable(self.tag).limit
    local data = FishGI.GameTableData:getRewardTable(self.tag + 1)
    if data ~= nil then
        self.nextLVCoin = data["limit"]
    else
        self.nextLVCoin = nil
    end
    self:upDataLayer()
end

function LotteryLayer:initLayerByCoin( )
    self.tag = 1
    for i=1,6 do
        local limitMin = FishGI.GameTableData:getRewardTable(i).limit
        local limitMax = nil 
        if FishGI.GameTableData:getRewardTable(i + 1) ~= nil then
            limitMax = FishGI.GameTableData:getRewardTable(i + 1).limit
        end
        if limitMax == nil or (self.allPoolCoin < limitMax and self.allPoolCoin >= limitMin) then
            self.tag = i
            break
        end
    end

    print("------initLayerByCoin-----tag="..self.tag)
    self.spr_curreward:initWithFile("battle/lottery/lottery_pic_words_"..self.tag..".png")
    self:upDataSixShellByKeyId(self.tag)

    self.curLVCoin = FishGI.GameTableData:getRewardTable(self.tag).limit
    local data = FishGI.GameTableData:getRewardTable(self.tag + 1)
    if data ~= nil then
        self.nextLVCoin = data["limit"]
    else
        self.nextLVCoin = nil
    end
    self:upDataLayer()
end

--得到距离下一级差多少
function LotteryLayer:getDisNextCoin( )
    for i=1,6 do
        local limitMin = FishGI.GameTableData:getRewardTable(i).limit
        if self.allPoolCoin < limitMin then
            return  limitMin - self.allPoolCoin
        end
    end
    return  0

end

function LotteryLayer:setAllPoolCoin( allPoolCoin)
    self.allPoolCoin = allPoolCoin
end

function LotteryLayer:setCurKillCount( kissCount)
    self.curKillCount = kissCount
end

function LotteryLayer:setAimKillCount( aimKissCount)
    self.aimKillCount = aimKissCount
end

function LotteryLayer:upDataLayer( )
    local btnArr = self.node_rewardbtn:getChildren()
    for k,val in pairs(btnArr) do
        local tag = val:getTag()
        if tag == self.tag then
            val:setTouchEnabled(false)
            val:setBright(false)
        else
            val:setTouchEnabled(true)
            val:setBright(true)            
        end
    end

    if self.curKillCount < self.aimKillCount then
        self.node_killfish:setVisible(true)
        self.node_coinpool:setVisible(false)
        self.text_word_nextreward:setVisible(false)
    elseif self.nextLVCoin == nil or self.allPoolCoin < self.nextLVCoin then
        self.node_killfish:setVisible(false)
        self.node_coinpool:setVisible(true)
        self.text_word_nextreward:setVisible(false)  
    elseif self.allPoolCoin >= self.nextLVCoin then
        self.node_killfish:setVisible(false)
        self.node_coinpool:setVisible(false)
        self.text_word_nextreward:setVisible(true)       
    end

    --奖金池更新
    self.fnt_curcoin:setString(self.allPoolCoin)

    --杀鱼节点更新
    self.fnt_killbar_num:setString(self.curKillCount.."&"..self.aimKillCount)
    local per = self.curKillCount/self.aimKillCount*100
    if per >100 then
        per = 100
    end
    self.bar_killfish_count:setPercent(per)

    --奖金池节点更新
    self.fnt_poolbar_num:setString(self.allPoolCoin.."&"..self.curLVCoin)
    local per2 = self.allPoolCoin/self.curLVCoin*100
    local lockFish = self.btn_startlottery:getChildByName("spr_word_ckjjy")
    local startChose = self.btn_startlottery:getChildByName("spr_word_kscj")
    if per2 >= 100 then
        per2 = 100
        startChose:setVisible(true)
        lockFish:setVisible(false)

    else       
        startChose:setVisible(false)
        lockFish:setVisible(true)        
    end
    self.bar_coinpool:setPercent(per2)    

end

function LotteryLayer:upDataSixShellByKeyId( keyId)
    local propArr = FishGI.GameTableData:getRewardTable(keyId).prop
    for i=1,6 do
        local propId = propArr[i].propId
        local propCount = propArr[i].propCount

        local shellName = "node_shell_"..i
        local shell = self.node_sixshell:getChildByName(shellName)

        local shellopen = shell:getChildByName("spr_shell_open")
        local fnt_prop_count = shellopen:getChildByName("fnt_prop_count")
        fnt_prop_count:setString(FishGF.changePropUnitByID(propId,propCount,false))
        local spr_prop = shellopen:getChildByName("spr_prop")
        local res = "common/prop/"..FishGI.GameTableData:getItemTable(propId).res
        spr_prop:initWithFile(res)

        shell.animation:play("open", false);
    end
end

function LotteryLayer:upDataLotteryLayer(val)
    local killRewardFishInDay = val.killRewardFishInDay
    local drawRequireRewardFishCount = val.drawRequireRewardFishCount
    local rewardRate = val.rewardRate
    
    self:setCurKillCount(killRewardFishInDay)
    self:setAimKillCount(drawRequireRewardFishCount)
    self:setAllPoolCoin(rewardRate)
    self:upDataLayer() 
end

return LotteryLayer;