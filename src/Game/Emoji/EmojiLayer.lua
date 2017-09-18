local EmojiLayer = class("EmojiLayer", cc.load("mvc").ViewBase)

EmojiLayer.AUTO_RESOLUTION   = 0
EmojiLayer.RESOURCE_FILENAME = "ui/battle/emoji/uiemoji"
EmojiLayer.START_INDEX = 400000000
EmojiLayer.BASE_PATH = "res/battle/emoji/emojipic/"
EmojiLayer.POP_BGR_PATH = "res/battle/emoji/emoji_popup.png"
EmojiLayer.WIDTH = 500
EmojiLayer.HIGHT = 340
EmojiLayer.XMARGIN = 40
EmojiLayer.BOTTOM_HIGHT = 85

EmojiLayer.DIRECT_UP = 0
EmojiLayer.DIRECT_DOWN = 1

EmojiLayer.EmojiTabTable = {}
EmojiLayer.ITEMW = (500 - EmojiLayer.XMARGIN*2) / 4
EmojiLayer.ITEMH = (340 - EmojiLayer.BOTTOM_HIGHT) / 2

EmojiLayer.FACE_RECT = cc.rect(0, 0, 120, 120)
EmojiLayer.POP_BGR_RECT = cc.rect(0, 0, 152, 138)


local baseX = nil
local baseY = nil
local curPage = 0
local tabCount = 0
local sprites = {}
local subSprites = {}
local animationing = {}
local normal_color = cc.c3b(22, 67, 108)
local clicked_color = cc.c3b(31, 106, 174)
local timestamp = 0

EmojiLayer.RESOURCE_BINDING  = {
    ["Image_11"]            = { ["varname"] = "Image_11" ,         ["events"]={["event"]="click",["method"]="onClick1"}},   
    ["Image_12"]            = { ["varname"] = "Image_12" ,         ["events"]={["event"]="click",["method"]="onClick2"}},  
    ["Image_13"]            = { ["varname"] = "Image_13" ,         ["events"]={["event"]="click",["method"]="onClick3"}},  
    ["Image_14"]            = { ["varname"] = "Image_14" ,         ["events"]={["event"]="click",["method"]="onClick4"}},  
    ["Image_15"]            = { ["varname"] = "Image_15" ,         ["events"]={["event"]="click",["method"]="onClick5"}},  
}

function EmojiLayer:onCreate( ... )
    self.emojiInterval = tonumber(FishGI.GameConfig:getConfigData("config", tostring(990000057), "data"))
    baseX = nil
    baseY = nil
    animationing = {}
    self:loadFaceConfig()

    for k,v in pairs(subSprites) do
        local spr = self:faceSubSprite(k, v)
        self:addChild(spr)
    end

    self:openTouchEventListener()
    
    FishGI.eventDispatcher:registerCustomListener("onEmotionIcon", self, function(valTab) self:onEmotionS2C(valTab) end);
end


function EmojiLayer:faceSubSprite(tab_num, emoji_res)
    log(tab_num, emoji_res)

    local subX = (100 - 110 * 0.65) / 2 + 5
    local subY = (EmojiLayer.BOTTOM_HIGHT - 110 * 0.65) / 2

    local subSprite = cc.Sprite:create(EmojiLayer.BASE_PATH..emoji_res.."_".."00.png");
    subSprite:setAnchorPoint(0, 0)
    subSprite:setScale(0.65)

    log(subX, subY)

    subSprite:setPosition(subX + (tab_num -1) * 95, subY)

    return subSprite
end

function EmojiLayer:initFace(k, emoji_res, isAnimation)
    local spr = self:loadFaceSpr(emoji_res, isAnimation)

    self:initPosition(spr, k)

    return spr
end

function EmojiLayer:loadFaceSpr(emoji_res, isAnimation)    
    local sprite = cc.Sprite:create(EmojiLayer.BASE_PATH..emoji_res.."_".."00.png")

    if isAnimation then

        local frame1 = CCSpriteFrame:create(EmojiLayer.BASE_PATH..emoji_res.."_".."00.png", EmojiLayer.FACE_RECT)
        local frame2 = CCSpriteFrame:create(EmojiLayer.BASE_PATH..emoji_res.."_".."01.png", EmojiLayer.FACE_RECT)
        local animation =CCAnimation:create()

        animation:addSpriteFrame(frame1)
        animation:addSpriteFrame(frame2)
        animation:setDelayPerUnit(0.3)
        local action = CCAnimate:create(animation)

        local move = {}
        move[#move + 1] = cc.Repeat:create(action, 5)
        --move[#move + 1] = cc.CallFunc:create(function(event) 
         --   sprite:removeFromParent()
        --    animationing = nil
       -- end)
  
        local sequence = transition.sequence(move)
        sprite:runAction(sequence)
    end

    return sprite
end

function EmojiLayer:loadFaceBgrSpr(seat)
    if animationing[seat] then
        animationing[seat]:removeFromParent()
        animationing[seat] = nil
    end

    local sprite = cc.Sprite:create(EmojiLayer.POP_BGR_PATH)

    local popupLayer = cc.Sequence:create(cc.ScaleTo:create(0.0, 0.1),
                                          cc.ScaleTo:create(0.25, 1),
                                          cc.ScaleTo:create(0.13, 1, 0.9),
                                          cc.ScaleTo:create(0.12, 1.0), 
                                          cc.ScaleTo:create(2.5, 1.0), 
                                          cc.ScaleTo:create(0.15, 1.1), 
                                          cc.ScaleTo:create(0.1, 0.1), 
                                          cc.CallFunc:create(function(event) 

                                                sprite:removeFromParent()
                                                animationing[seat] = nil

                                                end))
    sprite:setScale(0.0)
    sprite:runAction(popupLayer)
    animationing[seat] = sprite

    return sprite
end


function EmojiLayer:initPosition(spr, k)
    local index = (k - EmojiLayer.START_INDEX) % 8
    if index == 0 then
        index = 8
    end

    if index <= 4 then
        spr:setPosition(EmojiLayer.XMARGIN + EmojiLayer.ITEMW*((index -1)%4) + EmojiLayer.ITEMW/2, EmojiLayer.BOTTOM_HIGHT + EmojiLayer.ITEMH + EmojiLayer.ITEMH/2)
    else
        spr:setPosition(EmojiLayer.XMARGIN + EmojiLayer.ITEMW*((index -1)%4) + EmojiLayer.ITEMW/2, EmojiLayer.BOTTOM_HIGHT + EmojiLayer.ITEMH/2)
    end

end

function EmojiLayer:onTouchBegan(touch, event)
    if not self:isVisible() then
       return 
    end 

    local pos = touch:getLocation();

    log("EmojiLayer", "dsx pos:", pos.x, pos.y)

    local index = self:fromPosToEmojiItemIndex(pos)
    if index ~= 0 then
        self:onClickEmotionItemBegan(index)
        return true
    end

    local subIndex = self:fromPosEmojiSubIndex(pos)
    if subIndex ~= 0 then
        self:onClickSub(subIndex)
        return true
    end

    return true
end

function EmojiLayer:onTouchEnded(touch, event)
    if not self:isVisible() then
       return 
    end 

    local pos = touch:getLocation();

    log("EmojiLayer", "dsx pos:", pos.x, pos.y)

    local index = self:fromPosToEmojiItemIndex(pos)
    if index ~= 0 then
        self:setVisible(false)
        self:onClickEmotionItemEnded(index)
        return true
    end

    local subIndex = self:fromPosEmojiSubIndex(pos)
    if subIndex ~= 0 then
       -- self:setVisible(false)
        return true
    end
    
    self:setVisible(false)
end

function EmojiLayer:fromPosToEmojiItemIndex(pos)
    local index = 0
    for i = 1, 4 do
        if      (pos.x > baseX + EmojiLayer.XMARGIN + EmojiLayer.ITEMW*((i -1)%4)) 
            and (pos.x < baseX + EmojiLayer.XMARGIN + EmojiLayer.ITEMW*((i -1)%4) + EmojiLayer.ITEMW)
            and (pos.y > baseY + EmojiLayer.BOTTOM_HIGHT + EmojiLayer.ITEMH)
            and (pos.y < baseY + EmojiLayer.BOTTOM_HIGHT + EmojiLayer.ITEMH + EmojiLayer.ITEMH) then
            index = i
        end
    end

    for i = 5, 8 do
        if      (pos.x > baseX + EmojiLayer.XMARGIN + EmojiLayer.ITEMW*((i -1)%4)) 
            and (pos.x < baseX + EmojiLayer.XMARGIN + EmojiLayer.ITEMW*((i -1)%4) + EmojiLayer.ITEMW)
            and (pos.y > baseY + EmojiLayer.BOTTOM_HIGHT)
            and (pos.y < baseY + EmojiLayer.BOTTOM_HIGHT + EmojiLayer.ITEMH) then
            index = i
        end
    end

    return index

end

function EmojiLayer:fromPosEmojiSubIndex(pos)
    local subIndex = 0
    for i = 1 , 5 do
        if      (pos.x > baseX + (i - 1)*(EmojiLayer.WIDTH/5)
            and (pos.x < baseX + (i - 1)*(EmojiLayer.WIDTH/5) + 100)
            and (pos.y > baseY + 0)
            and (pos.y < baseY + EmojiLayer.BOTTOM_HIGHT)) then
            subIndex = i
        end
    end

    return subIndex
end

function EmojiLayer:onEmotionS2C(emotion)
    log("show emotion")
    self:setVisible(false)
    if not emotion.isSuccess then
        -- 失败
        return
    end

    -- 扣钱
    
    -- 显示表情    
    log("show emotion")
    self:showEmotion(emotion.playerId, emotion.emoticonId)

end

function EmojiLayer:showFaceDlg(isShow)
    if not isShow then
        self:removeAll(curPage) -- 删除上次的
        self:SetVisible(false)
        return
    end

    if baseX == nil or baseY == nil then
        local x, y = self:getPanelPos()
        baseX = x
        baseY = y
        self:setPosition(baseX, baseY)
        self:showTab(1)
    end

    self:setVisible(isShow)
end

function EmojiLayer:onClickSub(index)
    log("onClickSub: " .. index)
    if index > 5 
        or index > tabCount
        or index == curPage then 
        return 
    end

    self:removeAll(curPage) -- 删除上次的
    self:showTab(index)
end

function EmojiLayer:onClickEmotionItemBegan(index)
    log("EmojiLayer:onClickEmotionItemBegan face: " ..  index)
    log("curPage: " ..  curPage)
    local id = EmojiLayer.START_INDEX + (curPage - 1)*8 + index;  -- 应该用EmojiLayer.EmojiTabTable来取id
    --local id = (curPage - 1)*8 + index;
    
    sprites[id]:setScale(0.9)
    --FishGI.gameScene.net:sendEmotionIcon(id)
end

function EmojiLayer:onClickEmotionItemEnded(index)
    log("EmojiLayer:onClickEmotionItemEnded face: " ..  index)
    local idReal = EmojiLayer.START_INDEX + (curPage - 1)*8 + index;
    local id = (curPage - 1)*8 + index;
    sprites[idReal]:setScale(1)
   
    local current = os.time()
    if current - timestamp < self.emojiInterval then
        --local str = FishGF.getChByIndex(800000181)
        FishGF.showSystemTip(nil, 800000181, 3)
        return 
    end

    timestamp = os.time()
    FishGI.gameScene.net:sendEmotionIcon(id)
end

function EmojiLayer:showTab(index)
    local curImg = self:getImg(index)
    curImg:setColor(clicked_color)

    for k,v in pairs(EmojiLayer.EmojiTabTable[index]) do
        sprites[k] = self:initFace(k, v.emoji_res, false)
        self:addChild(sprites[k])
    end

    curPage = index
end

function EmojiLayer:getImg(index)
    local image 
    if index == 1 then
        image = self.Image_11

    elseif index == 2 then
        image = self.Image_12
            
    elseif index == 3 then
        image = self.Image_13
                
    elseif index == 4 then
        image = self.Image_14
                    
    elseif index == 5 then
        image = self.Image_15

    else 
        image = self.Image_11
    end 

    return image
end

function EmojiLayer:removeAll(tabIndex)
    local tab = EmojiLayer.EmojiTabTable[tabIndex]
    if tab == nil then
        return
    end

    for k, v in pairs(tab) do
        sprites[k]:removeFromParent()
    end

    local lastImg = self:getImg(tabIndex)  -- 删除的时候还原颜色
    lastImg:setColor(normal_color)

    sprites = {}
    curPage = 0
end


function EmojiLayer:getPanelPos()
    local selfId = FishGI.gameScene.playerManager.selfIndex
    local panelSeatId = FishGI.gameScene.playerManager:getPlayerChairId(selfId)

    log("self id: ", selfId)
    log("panelSeatId id: ", panelSeatId)
    local gameRect = cc.Director:getInstance():getWinSize()

    local wDelt = 150
    local hDelt = 150

    local x, y

    if panelSeatId == FishCD.DIRECT.RIGHT_UP then
        x = hDelt.height - hDelt - EmojiLayer.HIGHT
        y = gameRect.width - wDelt - EmojiLayer.WIDTH

    elseif panelSeatId == FishCD.DIRECT.LEFT_UP then
        x = wDelt
        y = hDelt.height - hDelt - EmojiLayer.HIGHT

    elseif panelSeatId == FishCD.DIRECT.RIGHT_DOWN then
        x = gameRect.width - wDelt - EmojiLayer.WIDTH
        y = hDelt

    elseif panelSeatId == FishCD.DIRECT.LEFT_DOWN then
        x = wDelt
        y = hDelt

    end

    return x, y
end


function EmojiLayer:showEmotion(playerId, emotionId)
    local id = EmojiLayer.START_INDEX + emotionId
    local chairId = FishGI.gameScene.playerManager:getPlayerChairId(playerId);

    if chairId == nil then
        return
    end

    local bgr = self:loadFaceBgrSpr(chairId)

    local sprite
    for k,v in pairs(EmojiLayer.EmojiTabTable) do
        for k1,v1 in pairs(v) do
            if id == k1 then
                sprite = self:loadFaceSpr(v1.emoji_res, true)
                local rect = bgr:getTextureRect()
                sprite:setPosition(rect.width /2, rect.height /2)
            end
        end
    end

    local deltX = math.abs(self:getChairPos(FishCD.DIRECT.LEFT_DOWN).x - 384*self.scaleX_)
    local deltY = math.abs(self:getChairPos(FishCD.DIRECT.LEFT_DOWN).y - 108*self.scaleY_)

    local x
    local y
        bgr:setAnchorPoint(0.72, 0.91)

    if chairId == FishCD.DIRECT.RIGHT_UP then
        x = self:getChairPos(chairId).x - deltX
        y = self:getChairPos(chairId).y - deltY

    elseif chairId == FishCD.DIRECT.LEFT_UP then
        x = self:getChairPos(chairId).x + deltX
        y = self:getChairPos(chairId).y - deltY
        sprite:setRotationSkewY(180)
        bgr:setRotationSkewY(180)

    elseif chairId == FishCD.DIRECT.RIGHT_DOWN then
        x = self:getChairPos(chairId).x - deltX
        y = self:getChairPos(chairId).y + deltY
        sprite:setRotationSkewX(180)
        bgr:setRotationSkewX(180)

    elseif chairId == FishCD.DIRECT.LEFT_DOWN then
        x = self:getChairPos(chairId).x + deltX
        y = self:getChairPos(chairId).y + deltY
        sprite:setRotation(180)
        bgr:setRotation(180)
    end

    bgr:setPosition(x, y)

    bgr:addChild(sprite)

	local layer = FishGI.gameScene
	if FishGI.FRIEND_ROOM_STATUS ~= 0 then
		layer = FishGI.gameScene.uiMainLayer
	end
    layer:addChild(bgr, FishCD.ORDER_GAME_emotion)
end

function EmojiLayer:getChairPos(chairId)
    local player = FishGI.gameScene.playerManager:getPlayerByChairId(chairId)
    
    log("EmojiLayer:getChairPos: ", chairId)
    log("FishCD.posTab[chairId]: x", FishCD.posTab[chairId].x, "y",  FishCD.posTab[chairId].y)

    return cc.p(FishCD.posTab[chairId].x*self.scaleX_, FishCD.posTab[chairId].y*self.scaleY_)
end

function EmojiLayer:loadFaceConfig()

    local i = 1
    local last_tab_num = nil
    local tab = {}
    repeat
        local tab_num = FishGI.GameConfig:getConfigData("emoji", tostring(EmojiLayer.START_INDEX + i), "tab_num")

        if 0 == string.len(tab_num) then -- not table value
            EmojiLayer.EmojiTabTable[last_tab_num] = tab
            tab = {}

            break
        end

        tab_num = tonumber(tab_num)
        if last_tab_num ~= nil -- do tab change
            and last_tab_num ~= tab_num then
            
            EmojiLayer.EmojiTabTable[last_tab_num] = tab
            tab = {}
        end

        local line = {}
        local crystal_need = tonumber(FishGI.GameConfig:getConfigData("emoji", tostring(EmojiLayer.START_INDEX + i), "crystal_need"))
        local last_time = tonumber(FishGI.GameConfig:getConfigData("emoji", tostring(EmojiLayer.START_INDEX + i), "last_time"))
        local emoji_res = FishGI.GameConfig:getConfigData("emoji", tostring(EmojiLayer.START_INDEX + i), "emoji_res")
        local unlock_vip = tonumber(FishGI.GameConfig:getConfigData("emoji", tostring(EmojiLayer.START_INDEX + i), "unlock_vip"))

        line["id"] = EmojiLayer.START_INDEX + i
        line["tab_num"] = tab_num
        line["crystal_need"] = crystal_need
        line["last_time"] = last_time
        line["emoji_res"] = emoji_res
        line["unlock_vip"] = unlock_vip

        tab[line.id] = line

        if last_tab_num == nil 
            or last_tab_num ~= tab_num then
            subSprites[tab_num] = emoji_res
        end

        last_tab_num = tab_num
        i = i + 1

    until false

    tabCount = last_tab_num
end

return EmojiLayer;