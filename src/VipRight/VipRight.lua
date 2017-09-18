
local VipRight = class("VipRight", cc.load("mvc").ViewBase)

VipRight.AUTO_RESOLUTION   = false
VipRight.RESOURCE_FILENAME = "ui/vipright/uivipright"
VipRight.RESOURCE_BINDING  = {  
    ["panel"]            = { ["varname"] = "panel" },
    ["btn_close"]        = { ["varname"] = "btn_close" ,         ["events"]={["event"]="click",["method"]="onClickClose"}},   
    
    ["image_barbg"]      = { ["varname"] = "image_barbg" },    
    ["bar_vip"]          = { ["varname"] = "bar_vip" },    
    ["fnt_vipexp"]       = { ["varname"] = "fnt_vipexp" },   
    ["text_word"]        = { ["varname"] = "text_word" },  
    ["btn_recharge"]     = { ["varname"] = "btn_recharge" ,         ["events"]={["event"]="click",["method"]="onClickRecharge"}},   
    ["fnt_vip_curnum"]   = { ["varname"] = "fnt_vip_curnum" },  
    ["fnt_vip_aimnum"]   = { ["varname"] = "fnt_vip_aimnum" },  
    
    ["btn_left"]         = { ["varname"] = "btn_left" ,         ["events"]={["event"]="click",["method"]="onClickLeft"}},   
    ["btn_right"]        = { ["varname"] = "btn_right" ,         ["events"]={["event"]="click",["method"]="onClickRight"}},   
    
    ["node_gun"]         = { ["varname"] = "node_gun" }, 
    
    ["node_vipdata"]     = { ["varname"] = "node_vipdata" }, 
    ["spr_maxvip"]       = { ["varname"] = "spr_maxvip" }, 
    
    ["spr_vip"]          = { ["varname"] = "spr_vip" }, 
    
    ["text_notice_word"] = { ["varname"] = "text_notice_word" }, 
    ["node_proplist"]    = { ["varname"] = "node_proplist" }, 
    
    ["btn_get"]          = { ["varname"] = "btn_get" ,         ["events"]={["event"]="click",["method"]="onClickget"}},   

}

function VipRight:onCreate( ... )
    self:init()
    local a = 1
end

function VipRight:init()   
    self.richTextArr = {}
    self.curindex = 1
    self.panel:setSwallowTouches(false)
    self:initView()

    self:upDataLayerByVIPLV(self.curindex)
    self.btn_left:setVisible(false)
    self:setMyCostMoney(0)

    self:openTouchEventListener()

    local function onNodeEvent(event )
        if event == "enter" then
            self:onEnter()
        elseif event == "enterTransitionFinish" then

        elseif event == "exit" then
            self:onExit()
        elseif event == "exitTransitionStart" then

        elseif event == "cleanup" then

        end

    end
    self:registerScriptHandler(onNodeEvent)
    
end

function VipRight:onEnter( )
    FishGI.eventDispatcher:registerCustomListener("GetVipDailyReward", self, function(valTab) self:GetVipDailyReward(valTab) end);
end

function VipRight:initView()
    self.text_notice_word:setString(FishGF.getChByIndex(800000213))

    --数据初始化
    local vipTab = FishGI.GameTableData:getVipTable()
    self.VIPCount = table.nums(vipTab)
end

function VipRight:onTouchBegan(touch, event)
    if self:isVisible() then
         return true  
    end

    return false
end

function VipRight:onClickClose( sender )
    self:hideLayer() 
end

function VipRight:onClickRecharge( sender )
    print("-VipRight-onClickRecharge---")
    FishGF.getLayerByName("uiShopLayer"):setShopType(1)

    self:hideLayer(false) 
    FishGF.getLayerByName("uiShopLayer"):showLayer() 

end

function VipRight:onClickLeft( sender )
    print("-VipRight-onClickLeft---")

    self.curindex = self.curindex - 1
    if self.curindex <= 1 then
        self.btn_left:setVisible(false)
    end
    self.btn_right:setVisible(true)
    self:upDataLayerByVIPLV(self.curindex)
end

function VipRight:onClickRight( sender )

    print("-VipRight-onClickRight---")
    self.curindex = self.curindex + 1
    if self.curindex >= self.VIPCount -1  then
        self.btn_right:setVisible(false)
    end
    self.btn_left:setVisible(true)
    self:upDataLayerByVIPLV(self.curindex)
end

function VipRight:upDataTextWord( )

end

function VipRight:upDataLayer( vipLevelData )
    self.costMoney = vipLevelData.vipExp
    self.vip_level = vipLevelData.vip_level
    self.curindex = self.vip_level
    self.fnt_vip_curnum:setString(vipLevelData.vip_level)
    self.fnt_vip_aimnum:setString(vipLevelData.vip_level+1)

    local str = (self.costMoney/100).."&"..(vipLevelData.next_All_money/100)
    self.fnt_vipexp:setString(str)

    self.bar_vip:setPercent(self.costMoney/vipLevelData.next_All_money*100)
    self.rechargeNum = (vipLevelData.next_All_money - self.costMoney)/100

    local str = FishGF.getChByIndex(800000096)..self.rechargeNum..FishGF.getChByIndex(800000097).."VIP"..(self.vip_level+1)


    if vipLevelData.next_All_money == 0 then
        self.node_vipdata:setVisible(false)
        self.spr_maxvip:setVisible(true)
    else
        self.node_vipdata:setVisible(true)
        self.spr_maxvip:setVisible(false)
    end
    self.text_word:setString(str)

    self:upDataLayerByVIPLV(self.curindex )

    local daily_items_reward = vipLevelData.daily_items_reward
    self:initRewardIsToken(daily_items_reward)

end

--初始化vip每日领取道具
function VipRight:initRewardIsToken( daily_items_reward )
    if #daily_items_reward < 2 then
        self.text_notice_word:setVisible(true)
        self.node_proplist:setVisible(false)
        return
    end

    local propTab = FishGF.strSplit(daily_items_reward..";", ";")

    self.text_notice_word:setVisible(false)
    self.node_proplist:setVisible(true)

    self.proplist = {}
    for i,val in ipairs(propTab) do
        local propData = FishGF.strSplit(val..",", ",")

        local propId = tonumber(propData[1])
        local propCount = tonumber(propData[2])
        local propItem = self:child(string.format("node_prop_%d",i))
        self.proplist[propId] = propItem

        local picSpr = propItem:getChildByName("panel"):getChildByName("spr_item")
        local fntSpr = propItem:getChildByName("panel"):getChildByName("fnt_item_count")
        local res = "common/prop/"..FishGI.GameTableData:getItemTable(propId).res
        picSpr:initWithFile(res);
        fntSpr:setString(propCount)

        local spr_chooseframe = propItem:getChildByName("panel"):getChildByName("spr_chooseframe")
        spr_chooseframe:setVisible(false)
    end

end

function VipRight:setRewardIsToken( vipDailyRewardToken )
    self.vipDailyRewardToken = vipDailyRewardToken
    --按键禁用
    self.btn_get:setVisible(not vipDailyRewardToken)
    self:child("spr_word_yl"):setVisible(vipDailyRewardToken)

    if FishGI.GAME_STATE == 2 then
        if not vipDailyRewardToken and self.node_proplist:isVisible() then
            FishGI.hallScene.view:setBtnIsLight(FishCD.HALL_BTN_8,true)
        else
            FishGI.hallScene.view:setBtnIsLight(FishCD.HALL_BTN_8,false)
        end
    end

end

function VipRight:setMyCostMoney( money )
    self.costMoney = money

    local vipLevelData = FishGI.GameTableData:getVIPByCostMoney(money)

    self.vip_level = vipLevelData.vip_level
    self.curindex = self.vip_level
    self.fnt_vip_curnum:setString(vipLevelData.vip_level)
    self.fnt_vip_aimnum:setString(vipLevelData.vip_level+1)

    local str = (money/100).."&"..(vipLevelData.next_All_money/100)
    self.fnt_vipexp:setString(str)

    self.bar_vip:setPercent(money/vipLevelData.next_All_money*100)
    self.rechargeNum = (vipLevelData.next_All_money - money)/100

    local str = FishGF.getChByIndex(800000096)..self.rechargeNum..FishGF.getChByIndex(800000097).."VIP"..(self.vip_level+1)
    --最高级别
    if vipLevelData.next_All_money == 0 then
        self.node_vipdata:setVisible(false)
        self.spr_maxvip:setVisible(true)
    else
        self.node_vipdata:setVisible(true)
        self.spr_maxvip:setVisible(false)        
    end
    self.text_word:setString(str)

    self:upDataLayerByVIPLV(self.curindex )
end

function VipRight:upDataLayerByMyVIPLV( )
    self:upDataLayerByVIPLV(self.vip_level)
end

function VipRight:upDataLayerByVIPLV( VIPLV )
    if VIPLV <=1 then
        VIPLV = 1
    end
    if VIPLV >= self.VIPCount -1  then
        self.btn_right:setVisible(false)
        self.btn_left:setVisible(true)
    elseif VIPLV <= 1 then
        self.btn_right:setVisible(true)
        self.btn_left:setVisible(false)    
    else
        self.btn_right:setVisible(true)
        self.btn_left:setVisible(true)    
    end
    self.curindex = VIPLV
    local fnt_vip_curnum = self.node_gun:getChildByName("fnt_vip_curnum")
    fnt_vip_curnum:setString(VIPLV)

    local spr_gun_name = self.node_gun:getChildByName("spr_gun_name")
    local gunName = string.format("battle/selectcannon/selectcannon_pic_title_%d.png",(VIPLV))
    spr_gun_name:initWithFile(gunName)

    local spr_gun = self.node_gun:getChildByName("spr_gun")
    spr_gun:initWithFile("battle/cannon/"..FishGI.GameTableData:getGunOutlookTableByVip(VIPLV).cannon_img)
    
    local vipName = string.format("common/vip/vip_badge_%d.png",(VIPLV))
    self.spr_vip:initWithFile(vipName)
    
    --特权
    local dataTab = FishGI.GameTableData:getVipTable(VIPLV).strData
    self:createRightByStrArr(dataTab)

end

function VipRight:createRightByStrArr( wordTab )
    if wordTab == nil then
        return
    end

    for k,child in pairs(self.richTextArr) do
        child:removeFromParent()
    end
    self.richTextArr = {}
    local heightSize = 200/#wordTab
    for i=1,#wordTab do
        local strArr = wordTab[i]  
        local richText = ccui.RichText:create() 
        richText:ignoreContentAdaptWithSize(true) 
        self.richTextArr[i] =  richText
        local dot = cc.Sprite:create("common/vip/vip_pic_dot.png" )  
        dot:setPosition(cc.p(-30,14));
        richText:addChild(dot);
        if strArr ~= nil then
            for j=1,#strArr do
                local color = {}
                local Front = nil
                if j == 2 then
                    color = strArr["numArr"]
                    Front = ccui.RichElementText:create( i+1, cc.c3b(color["r"], color["g"], color["b"]), color["a"], color["word"], "Arial", color["size"] )    
                else
                    Front = ccui.RichElementText:create( i+1, cc.c3b(255, 244, 89), 255, strArr[j], "Arial", 28 )  
                end
                richText:pushBackElement(Front)
            end

        end
        richText:setAnchorPoint(cc.p(0,0.5))
        richText:setPosition(cc.p(73.65,12- (i-1)*heightSize));
        self.panel:addChild(richText);
    end

end

function VipRight:GetVipDailyReward( data )
    print("--------------------GetVipDailyReward")
    local success = data.success
    local props = data.props
    local seniorProps = data.seniorProps

    if not success then
        --领取没成功提示
        return
    end

    FishGI.IS_GET_VIP_REWARD = true
    self:setRewardIsToken(FishGI.IS_GET_VIP_REWARD)
    
    local playerId = FishGI.myData.playerId
    --刷新道具，道具飞行
    for k,val in pairs(props) do
        --更新数据
        FishGMF.addTrueAndFlyProp(playerId,val.propId,val.propCount,false)
        FishGMF.setAddFlyProp(playerId,val.propId,val.propCount,false)

        local propTab = {}
        propTab.playerId = playerId
        propTab.propId = val.propId
        propTab.propCount = val.propCount
        propTab.isRefreshData = true
        propTab.isJump = false
        propTab.firstPos = self:getFirstPosByPropId(val.propId)
        propTab.dropType = "normal"
        propTab.isShowCount = false
        FishGI.GameEffect:playDropProp(propTab)
    end

    if seniorProps == nil then
        seniorProps = {}
    end

    --刷新高级道具，道具飞行
    for k,val in pairs(seniorProps) do
        --更新数据
        FishGMF.refreshSeniorPropData(playerId,val,8,0)

        local propTab = {}
        propTab.playerId = playerId
        propTab.propId = val.propId
        propTab.propCount = 1
        propTab.isRefreshData = true
        propTab.isJump = false
        propTab.firstPos = self:getFirstPosByPropId(val.propId)
        propTab.dropType = "normal"
        propTab.isShowCount = false
        propTab.seniorPropData = val
        FishGI.GameEffect:playDropProp(propTab)

    end

end

--得到飞行道具的初始位置
function VipRight:getFirstPosByPropId( propId )
    local winSize = cc.Director:getInstance():getWinSize();
    local pos = cc.p(winSize.width/2,winSize.height/2)
    local child = self.proplist[propId]
    pos = cc.p(child:getPositionX(),child:getPositionY())
    pos = self.node_proplist:convertToWorldSpace(pos)
    return pos
end

--得到飞行道具的终点位置
function VipRight:getEndPosByPropId( propId )
    local winSize = cc.Director:getInstance():getWinSize();
    local pos = cc.p(0,0)
    if FishGI.GAME_STATE == 3 then
        pos = FishGF.getMyPos()
    elseif FishGI.GAME_STATE == 2 then
        pos = FishGF.getHallPropAimByID(propId)
    end
    return pos
end

--领取回调
function VipRight:onClickget( sender )
    print("onClickget")
    if FishGI.GAME_STATE == 3 then
        FishGI.gameScene.net:sendGetVipDailyReward()
    elseif FishGI.GAME_STATE == 2 then
        FishGI.hallScene.net.roommanager:sendGetVipDailyReward()
    end
    self:hideLayer()
end


return VipRight;