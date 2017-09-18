local MagicProp = class("MagicProp", cc.load("mvc").ViewBase)

MagicProp.AUTO_RESOLUTION   = 0
MagicProp.RESOURCE_FILENAME = "ui/battle/magicitem/uimagicprop"
MagicProp.RESOURCE_POINT    = "res/battle/magicprop/magicprop_appoint.png"
MagicProp.RESOURCE_BASE     = "res/battle/magicprop/magicproppic/"

MagicProp.RESOURCE_BINDING  = {
    ["scroll_list"]           = { ["varname"] = "scroll_list"  ,         ["nodeType"]="viewlist"   },
    ["img_bg"]                = { ["varname"] = "img_bg" }, 
}

local selRect = {
{-50, -50},
{50, -50},
{50 ,50},
{-50 ,50},
}

local curSelection = 0
local deltlen = 20
local movedelt = {
        cc.p(deltlen, deltlen),
        cc.p(-deltlen, deltlen),
        cc.p(-deltlen, -deltlen),
        cc.p(deltlen , -deltlen),
    }

MagicProp.START_INDEX = 410000000

local sprites = {}

local lockTargets = {}
local targetRect = cc.rect(0, 0, 300, 300)
local curIndex2ChairId = {}
local timestamp = 0

function MagicProp:onCreate()
end

function MagicProp:init()
    self.magicPropInterval = tonumber(FishGI.GameConfig:getConfigData("config", tostring(990000070), "data"))
    self:registerEvent()
    self.animationInstance = require("Game/MagicProp/MagicPlay").create()
    self:initPropItem()
end

function MagicProp:setPlayerId(playerId)
    self.playerId = playerId
end

function MagicProp:initPropItem()
    self.scroll_list:removeAllChildren()
    log("MagicProp:initPropItem: ", #self.animationInstance.magicPropConfigs)
    self.propItems = {}
    for i = 1, #self.animationInstance.magicPropConfigs do
        local propItem = require("Game/MagicProp/MagicPropItem").new()
        propItem:setAnchorPoint(0, 0)
        propItem:setPosition((i - 1)*116 + 58, 58)
        propItem:setContentSize(114, 114)
        self.scroll_list:addChild(propItem)

        self:decorPropUI(propItem, self.animationInstance.propImgs[i], self.animationInstance.magicPropConfigs[i])
        self.propItems[i] = propItem
    end

    self.scroll_list:setInnerContainerSize(cc.size(116 * #self.animationInstance.magicPropConfigs, 116))
    self.scroll_list:setSwallowTouches(false)
    self.scroll_list:setScrollBarEnabled(false)
end

function MagicProp:decorPropUI(propItem, img, config)
    if img then
        propItem:setImageView(img)
    end

    propItem:setDepend(config.unlock_vip, config.cystal_need)

end

function MagicProp:revertDelt(delt)
    return cc.p(-delt.x, -delt.y)
end

function MagicProp:showPropDlg()
    local myPlayerId= FishGI.gameScene.playerManager.selfIndex
    local selfChair=    FishGI.gameScene.playerManager:getPlayerChairId(myPlayerId)

    self:setPosition(self:getChairPos(selfChair).x, self:getChairPos(selfChair).y + 200*self.scaleY_)
    self:setVisible(true)
end

function MagicProp:onTouchBegan(touch, event)
    if not self:getParent():getParent():getParent():isVisible() then
        return false
    end

    local curPos = touch:getLocation()

    if not self:isPosInNode(self.img_bg, curPos)   then return false end
    self.moveDis = cc.p(0,0)
    self.movePos = curPos
    return true
end

function MagicProp:onTouchMoved(touch, event)
    local curPos = touch:getLocation()
    local moceX = math.abs(curPos.x - self.movePos.x)
    local moceY = math.abs(curPos.y - self.movePos.y)
    self.moveDis = cc.p(self.moveDis.x + moceX,self.moveDis.y + moceY)
    self.movePos = curPos
end

function MagicProp:onTouchEnded(touch, event)
    if self.moveDis.x >10 or self.moveDis.y >10 then
        self.moveDis = cc.p(0,0)
        return false
    end
    if not self:getParent():getParent():getParent():isVisible() then
        return false
    end

    local curPos = touch:getLocation()

    if not self:isPosInNode(self.img_bg, curPos)   then  return false end

    for i = 1, #self.animationInstance.propImgs do
        if self:isPosInNode(self.animationInstance.propImgs[i], curPos)  then self:onClickProp(i) break end
    end

    return true
end

function MagicProp:throwProp(propId, playerId)
    self:sendPropMsg(propId, playerId)
    timestamp = os.time()

    self:getParent():getParent():getParent():hideAct()
end

function MagicProp:onClickProp(prop)
    if not self:satisfyPropCondition(prop) then
        return
    end

    self:throwProp(prop, self.playerId)

    log("click on prop:" .. prop)
end

function MagicProp:satisfyPropCondition(prop)    
    local myPlayerId= FishGI.gameScene.playerManager.selfIndex

    local crystalneed = self.animationInstance:getPropCrystal(prop)
    local myCrystalall = FishGMF.getPlayerPropData(myPlayerId, FishCD.PROP_TAG_02)
    local myCrystall = myCrystalall.realCount - myCrystalall.flyingCount - myCrystalall.unSureCount

    if myCrystall < crystalneed then -- 弹出购买水晶
        log("satisfyPropCondition: crystal")
        local function callback(sender)
            local tag = sender:getTag()
            if tag == 2 then
                FishGI.gameScene.uiShopLayer:showLayer()
                FishGI.gameScene.uiShopLayer:setShopType(2)
            end
        end
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,FishGF.getChByIndex(800000087),callback)

        return false
    end

    local unlockVip = self.animationInstance:getPropVipLevel(prop)
    local selfVip = FishGI.gameScene.playerManager:getPlayerByPlayerId(myPlayerId).playerInfo.vip_level

    if selfVip < unlockVip then
        log("satisfyPropCondition: vip_level")
        local function callback(sender)
            local tag = sender:getTag()
            if tag == 2 then
                FishGI.gameScene.uiShopLayer:showLayer()
                FishGI.gameScene.uiShopLayer:setShopType(1)
            end
        end
        local str = FishGF.getChByIndex(800000111)..unlockVip..FishGF.getChByIndex(800000112)
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,str,callback);

        return false
    end

    local current = os.time()
    if current - timestamp < self.magicPropInterval then 
        log("too frequent")
        FishGF.showSystemTip(nil, 800000182, 3)
        return false
    end 


    return true
end

function MagicProp:isPosUP(pos)
	return pos == FishCD.DIRECT.LEFT_UP
			or pos == FishCD.DIRECT.RIGHT_UP
end

function MagicProp:isPosInNode(node, worldPos)
    local bg = node:getContentSize()
    local rect = cc.rect(0, 0, bg.width, bg.height)
    local nodePos = node:convertToNodeSpace(worldPos)

    return cc.rectContainsPoint(rect, nodePos)
end

function MagicProp:isPosInRect(rect, pos)

    return cc.rectContainsPoint(rect, pos)
end

function MagicProp:sendPropMsg(propId, toPlayerId)
    print("sendPropMsg propId: " .. propId)
    print("sendPropMsg toPlayerId: " .. toPlayerId)
    FishGI.gameScene.net:sendMagicProp(propId, toPlayerId)

    local myPlayerId = FishGI.gameScene.playerManager.selfIndex

    local money = self.animationInstance:getPropCrystal(propId)
    FishGMF.isSurePropData(myPlayerId, FishCD.PROP_TAG_02, money, false)
end

function MagicProp:onMagicPropS2C(valTab)
    for k,v in pairs(valTab) do
        print(k,v)
    end

    local money = self.animationInstance:getPropCrystal(valTab.magicpropId)
    local isSuccess = valTab.isSuccess
    if isSuccess then
        FishGMF.addTrueAndFlyProp(valTab.playerId, FishCD.PROP_TAG_02, -money, false)
    end

    FishGMF.isSurePropData(valTab.playerId, FishCD.PROP_TAG_02, money, true)

    local chairFrom =    FishGI.gameScene.playerManager:getPlayerChairId(valTab.playerId)
    local chairTo   =    FishGI.gameScene.playerManager:getPlayerChairId(valTab.toPlayerID)

    log("throw prop :" .. curSelection .. " from " .. tostring(chairFrom) .. " to:"..tostring(chairTo))
    if chairFrom == nil 
        or chairTo == nil then
        return
    end

    self.animationInstance:play(chairFrom, chairTo, valTab.magicpropId)
end

function MagicProp:registerEvent()
    self:openTouchEventListener()

    FishGI.eventDispatcher:registerCustomListener("MaigcPropPlayerLeave", self, function(valTab) self:onPlayerLeave(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("onMagicprop", self, function(valTab) self:onMagicPropS2C(valTab) end);
end

function MagicProp:onPlayerLeave(valTab)
    if not self:isVisible() then
        return
    end

    if curSelection == 0 then
        return
    end

    local playerId = valTab.player.id

    local chairId = valTab.player.chairId
    if chairId ==nil then
        return
    end
    
    for k,v in pairs(curIndex2ChairId) do
        if v == chairId then
            lockTargets[k]:removeFromParent()
        end
    end

end

function MagicProp:initFocusView()
    local points = {}

    for i = 1, 3 do
        local selectPoint = cc.Sprite:create()
        for j = 1, 4 do
            points[j] = cc.Sprite:create(MagicProp.RESOURCE_POINT)
            points[j]:setAnchorPoint(0.5, 0.5)
            points[j]:setRotation(-90*j + 45)
            points[j]:setPosition(selRect[j][1], selRect[j][2])

            local move = {}
            move[#move + 1] = cc.MoveBy:create(0.5, movedelt[j])
            move[#move + 1] = cc.MoveBy:create(0.5, self:revertDelt(movedelt[j]))

            local seq = transition.sequence(move)

            local repeatFor = {}
            repeatFor[#repeatFor + 1] = cc.RepeatForever:create(seq)

            local seq2 = transition.sequence(repeatFor)

            points[j]:runAction(seq2)

            selectPoint:addChild(points[j])
        end
        lockTargets[i] = selectPoint
        lockTargets[i]:retain()
    end
end

function MagicProp:getChairPos(chairId)
    local player = FishGI.gameScene.playerManager:getPlayerByChairId(chairId)
    
    log("EmojiLayer:getChairPos: ", chairId)
    log("FishCD.posTab[chairId]: x", FishCD.posTab[chairId].x, "y",  FishCD.posTab[chairId].y)

    local gameRect = cc.Director:getInstance():getWinSize()
    local y = gameRect.height
    if chairId == FishCD.DIRECT.RIGHT_DOWN or chairId ==FishCD.DIRECT.LEFT_DOWN then
        y = 0
    end

    if player.getCannonPos then
        return cc.p(player:getCannonPos().x, y) 
    end

    return cc.p(FishCD.posTab[chairId].x*self.scaleX_, FishCD.posTab[chairId].y*self.scaleY_)
end


--====================== test ==========================
local test_propId = 1
local to_playerId = 10000

function MagicProp:testPropMsg()
    local propId = test_propId%5
    propId = propId + 1
    print("testPropMsg: " .. propId)
    self:sendPropMsg(propId, to_playerId)
    test_propId = test_propId + 1
    to_playerId = to_playerId + 1
end


local test_playprop = 1
local s1 = FishCD.DIRECT.LEFT_DOWN
local s2 = FishCD.DIRECT.RIGHT_DOWN
local s3 = FishCD.DIRECT.LEFT_UP
local s4 = FishCD.DIRECT.RIGHT_UP


function MagicProp:testPlayProp()
    if test_playprop > 12 then test_playprop = 1
    end

    if test_playprop == 1 then self.animationInstance:playCake(s1, s2)

    elseif test_playprop == 2 then self.animationInstance:playCake(s1, s3)

    elseif test_playprop == 3 then self.animationInstance:playCake(s1, s4)

    elseif test_playprop == 4 then self.animationInstance:playCake(s2, s1)

    elseif test_playprop == 5 then self.animationInstance:playCake(s2, s3)

    elseif test_playprop == 6 then self.animationInstance:playCake(s2, s4)

    elseif test_playprop == 7 then self.animationInstance:playCake(s3, s1)

    elseif test_playprop == 8 then self.animationInstance:playCake(s3, s2)

    elseif test_playprop == 9 then self.animationInstance:playCake(s3, s4)

    elseif test_playprop == 10 then self.animationInstance:playCake(s4, s1)

    elseif test_playprop == 11 then self.animationInstance:playCake(s4, s2)

    elseif test_playprop == 12 then self.animationInstance:playCake(s4, s3)
    end

    test_playprop = test_playprop + 1
end

--====================== test ==========================

return MagicProp