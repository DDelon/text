local GameEffect = class("GameEffect",nil)

function GameEffect.create()
    local data = GameEffect.new();
    data:init();
    return data;
end

function GameEffect:init()
    self.playerData = {}
end

function GameEffect:initGameEff()
    self.scaleX_,self.scaleY_,self.scaleMin_  = FishGF.getCurScale()

    --加载发财了特效
    local  megawin = cc.Director:getInstance():getRunningScene():getChildByName("megawin")
    if megawin == nil then
        local uimegawin = require("ui/battle/gameeffect/uimegawin").create()
        self.megawin = uimegawin.root
        self.megawin.fnt_coin = uimegawin["fnt_coin"]
        self.megawin.node_score = uimegawin["node_score"]
        self.megawin.partical_coin = uimegawin["partical_coin"]
        self.megawin.animation = uimegawin["animation"]
        self.megawin:setName("megawin")
        self.megawin:runAction(self.megawin.animation)
        self.megawin.animation:clearFrameEventCallFunc()  
        self.megawin.animation:setFrameEventCallFunc(function(frameEventName)
            if frameEventName:getEvent() == "moveEnd" then
                FishGF.print("-----------megawin = moveEnd-------")
                self.megawin:setVisible(false)
            end
        end)

        cc.Director:getInstance():getRunningScene():addChild(self.megawin,FishCD.ORDER_LAYER_VIRTUAL)
        --self.megawin:setVisible(false)
        self.megawin:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
        self.megawin.partical_coin:setAutoRemoveOnFinish(false)
    end

    --加载发财了特效
    local  windfall = cc.Director:getInstance():getRunningScene():getChildByName("windfall")
    if windfall == nil then
        local uiwindfall = require("ui/battle/gameeffect/uiwindfall").create()
        self.windfall = uiwindfall.root
        self.windfall.fnt_coin = uiwindfall["fnt_coin"]
        self.windfall.node_score = uiwindfall["node_score"]
        self.windfall.partical_coin = uiwindfall["partical_coin"]
        self.windfall.animation = uiwindfall["animation"]
        self.windfall:setName("windfall")
        self.windfall:runAction(self.windfall.animation)
        self.windfall.animation:clearFrameEventCallFunc()  
        self.windfall.animation:setFrameEventCallFunc(function(frameEventName)
            if frameEventName:getEvent() == "moveEnd" then
                FishGF.print("-----------windfall = moveEnd-------")
                self.windfall:setVisible(false)
                FishGI.isPlayEffect = false
            end
        end)

        cc.Director:getInstance():getRunningScene():addChild(self.windfall,FishCD.ORDER_LAYER_VIRTUAL)
        self.windfall:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
        self.windfall.partical_coin:setAutoRemoveOnFinish(false)
    end

    --加载boss来临
    local  bossCome = cc.Director:getInstance():getRunningScene():getChildByName("bossCome")
    if bossCome == nil then
        local uiBossCome = require("ui/battle/uibosscome").create()
        self.bossCome = uiBossCome.root
        self.bossCome.animation = uiBossCome["animation"]
        cc.Director:getInstance():getRunningScene():addChild(self.bossCome,FishCD.ORDER_LAYER_VIRTUAL)
        self.bossCome:setName("bossCome")
        --self.bossCome:setVisible(false)
        self.bossCome:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
        self.bossCome:runAction(uiBossCome["animation"])
        uiBossCome["animation"]:clearFrameEventCallFunc()  
        local function frameEvent( frameEventName)
            if frameEventName:getEvent() == "remove" then
                print("-----------bossComming = remove-------")
                --FishGI.showLayerData:hideGrayBgByLayer()
                self.bossCome:setVisible(false)
            end
        end
        uiBossCome["animation"]:setFrameEventCallFunc(frameEvent)

        self.bossCome.animation:play("bosscome", false);

    end

    --加载鱼潮来临
    local  fishGroup = cc.Director:getInstance():getRunningScene():getChildByName("fishGroup")
    if fishGroup == nil then
        local uiFishGroup = require("ui/battle/uifishgroupcome").create()
        self.fishGroup = uiFishGroup.root
        self.fishGroup.animation = uiFishGroup["animation"]
        cc.Director:getInstance():getRunningScene():addChild(self.fishGroup,FishCD.ORDER_LAYER_VIRTUAL)
        self.fishGroup:setName("fishGroup")
        self.fishGroup:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
        --self.fishGroup:setVisible(false)
        self.fishGroup:runAction(uiFishGroup["animation"])
        uiFishGroup["animation"]:clearFrameEventCallFunc() 
        local function frameEvent( frameEventName)
            if frameEventName:getEvent() == "moveEnd" then
                print("-----------fishGroupCome = moveEnd-------")
                --FishGI.showLayerData:hideGrayBgByLayer()
                self.fishGroup:setVisible(false)
            end
        end
        uiFishGroup["animation"]:setFrameEventCallFunc(frameEvent)
        self.fishGroup.animation:play("fishgroupcome", false);
    end

    --玩家升级特效
    local  levelUp = cc.Director:getInstance():getRunningScene():getChildByName("levelUp")
    if levelUp == nil then
        local uiLevelUp = require("ui/battle/uilevelup").create()
        self.levelUp = uiLevelUp.root
        self.levelUp.animation = uiLevelUp["animation"]
        cc.Director:getInstance():getRunningScene():addChild(self.levelUp,FishCD.ORDER_LAYER_VIRTUAL + 1)
        self.levelUp:setName("levelUp")
        self.levelUp:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
        --self.levelUp:setVisible(false)
        self.levelUp:runAction(uiLevelUp["animation"])

        --添加触摸监听
        local function onTouchBegan( touch, event)
            if self.levelUp:isVisible() then
                return true
            end
            return false
        end
        local listener = cc.EventListenerTouchOneByOne:create();
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN);   
        local eventDispatcher = self.levelUp:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.levelUp) 

        self.levelUp.animation:play("upact",false)
    end

    --
    local winSize = cc.Director:getInstance():getWinSize();
    local shade = require("ui/battle/friend/uifriendzhezhao").create()
    shade.img_bg:setColor(cc.c3b(255, 255, 255))
    local shadeEffect = shade.root
    shadeEffect.animation = shade["animation"]
    shadeEffect:setName("FireEffect")
    shadeEffect:setPosition(cc.p(winSize.width/2, winSize.height/2))
    shadeEffect:runAction(shade["animation"])
    shadeEffect.animation:play("shadeani", false);
    shadeEffect:setVisible(false);
    cc.Director:getInstance():getRunningScene():addChild(shadeEffect, 1000,4321)

    local word = require("ui/battle/friend/uifriendskill").create()
    local wordEffect = word.root
    wordEffect.animation = word["animation"]
    wordEffect:setName("WordEffect")
    wordEffect:runAction(word["animation"])
    wordEffect.animation:play("wordani", false);
    wordEffect:setVisible(false);
    cc.Director:getInstance():getRunningScene():addChild(wordEffect, 1000,4322)

    --杀死变倍率boss
    local  bossRateCahnge = cc.Director:getInstance():getRunningScene():getChildByName("bossRateCahnge")
    if bossRateCahnge == nil then
        self.bossRateCahnge = require("Game/BossRateChange/BossRateChange").create()
        cc.Director:getInstance():getRunningScene():addChild(self.bossRateCahnge,FishCD.ORDER_LAYER_VIRTUAL)
        self.bossRateCahnge:setName("bossRateCahnge")
        --self.bossCome:setVisible(false)
        self.bossRateCahnge:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    end
    self.bossRateCahnge:setScale(self.scaleMin_)

end

function GameEffect:closeAllSchedule()
    if self.bossRateCahnge ~= nil then
        self.bossRateCahnge:closeAllSchedule()
    end
    
end
--预先播放一次
function GameEffect:hideEffect()
    local megawin = cc.Director:getInstance():getRunningScene():getChildByName("megawin")
    if megawin ~= nil then
        megawin:setVisible(false)
    end
    local windfall = cc.Director:getInstance():getRunningScene():getChildByName("windfall")
    if windfall ~= nil then
        windfall:setVisible(false)
    end
    local bossCome = cc.Director:getInstance():getRunningScene():getChildByName("bossCome")
    if bossCome ~= nil then
        bossCome:setVisible(false)
    end 
    local fishGroup = cc.Director:getInstance():getRunningScene():getChildByName("fishGroup")
    if fishGroup ~= nil then
        fishGroup:setVisible(false)
    end 
    local levelUp = cc.Director:getInstance():getRunningScene():getChildByName("levelUp")
    if levelUp ~= nil then
        levelUp:setVisible(false)
    end 

    local bossRateCahnge = cc.Director:getInstance():getRunningScene():getChildByName("bossRateCahnge")
    if bossRateCahnge ~= nil then
        bossRateCahnge:setVisible(false)
    end 

end

--玩家升级
function GameEffect:playerLevelUp(valTab) 
    FishGF.print("--------playerLevelUp---")
    
    local playerId = valTab.playerId
    local newGrade = valTab.newGrade
    local dropFishIcon = valTab.dropFishIcon
    local newFishIcon = valTab.newFishIcon
    local dropCrystal = valTab.dropCrystal
    local newCrystal = valTab.newCrystal
    local dropProps = valTab.dropProps
    local dropSeniorProps = valTab.dropSeniorProps

    local levelUp = cc.Director:getInstance():getRunningScene():getChildByName("levelUp")    
     if levelUp == nil then
        --初始化特效
        FishGI.GameEffect:initGameEff() 
    end
    
    if self.levelUp.rewardArr ~= nil then
        FishGI.GameEffect:levelUpFlyCallBack()
    end

    local Image_lv_numbg = self.levelUp:getChildByName("Image_lv_numbg")
    local fnt_level = Image_lv_numbg:getChildByName("fnt_level")    
    fnt_level:setString(newGrade)

    -- --奖励的物品
    local dropCount = 0
    local rewardArr  ={}
    if dropFishIcon ~= nil and dropFishIcon > 0 then
        local propItem = require("hall/Bag/Bagitem").create()
        local result = propItem:setItemData(1 , 1)
        if result then
            dropCount = dropCount +1
            rewardArr[dropCount] = propItem
            rewardArr[dropCount]:setDropItemData(1,dropFishIcon)
            self.levelUp:addChild(rewardArr[dropCount])
            rewardArr[dropCount]:setTag(1)
            rewardArr[dropCount]["propId"] = 1
            rewardArr[dropCount]["propCount"] = dropFishIcon

            --加入鱼币缓存
            FishGMF.setAddFlyProp(playerId,1,dropFishIcon,false)
        end
    end
    
    if dropCrystal ~= nil and dropCrystal > 0 then
        local propItem = require("hall/Bag/Bagitem").create()
        local result = propItem:setItemData(1,1)
        if result then
            dropCount = dropCount +1
            rewardArr[dropCount] = propItem
            rewardArr[dropCount]:setDropItemData(2,dropCrystal)
            self.levelUp:addChild(rewardArr[dropCount])
            rewardArr[dropCount]:setTag(2)
            rewardArr[dropCount]["playerId"] = playerId
            rewardArr[dropCount]["propId"] = 2
            rewardArr[dropCount]["propCount"] = dropCrystal
        end

        --加入水晶缓存
        FishGMF.setAddFlyProp(playerId,2,dropCrystal,false)
    end

    for k,val in pairs(dropProps) do
        if val ~= nil and val.propCount > 0 then
            dropCount = dropCount +1
            local propItem = require("hall/Bag/Bagitem").create()
            local result = propItem:setItemData(1,1)
            rewardArr[dropCount] = propItem
            rewardArr[dropCount]:setDropItemData(val.propId,val.propCount)
            self.levelUp:addChild(rewardArr[dropCount])
            rewardArr[dropCount]:setTag(val.propId)
            rewardArr[dropCount]["playerId"] = playerId
            rewardArr[dropCount]["propId"] = val.propId
            rewardArr[dropCount]["propCount"] = val.propCount

            --加入道具缓存
            FishGMF.setAddFlyProp(playerId,val.propId,val.propCount,false)
        end
    end

    --得到高级道具
    for k,val in pairs(dropSeniorProps) do
        if val ~= nil then
            dropCount = dropCount +1
            local propItem = require("hall/Bag/Bagitem").create()
            local result = propItem:setItemData(1,1)
            rewardArr[dropCount] = propItem
            rewardArr[dropCount]:setDropItemData(val.propId,1)
            self.levelUp:addChild(rewardArr[dropCount])
            rewardArr[dropCount]:setTag(val.propId)
            rewardArr[dropCount]["playerId"] = playerId
            rewardArr[dropCount]["propId"] = val.propId
            rewardArr[dropCount]["propCount"] = 1
            rewardArr[dropCount]["seniorPropData"] = val
        end
    end

    local dis = 130
    for i=1,#rewardArr do
        rewardArr[i]:setPositionY( -30)
        rewardArr[i]:setVisible(false)
        rewardArr[i]:setScale(0)
        if dropCount%2 == 0 then
            local posX = -dis/2 -dis*( dropCount/2 - 1) + 130*(i-1)
            rewardArr[i]:setPositionX(posX)
            rewardArr[i]["posX"] = posX
        else
            local posX = -dis*(math.floor(dropCount/2)) + 130*(i-1)
            rewardArr[i]:setPositionX(posX)
            rewardArr[i]["posX"] = posX
        end
        rewardArr[i]["firstPos"] = {}
        rewardArr[i]["firstPos"] = self.levelUp:convertToWorldSpace(cc.p(rewardArr[i]:getPositionX(),rewardArr[i]:getPositionY()))
    end

    self.levelUp.rewardArr = rewardArr
    --确定按键
    local function sureCallBack(sender)
        print("-------levelUp-----hidehideAct--")
        FishGI.GameEffect:levelUpFlyCallBack()
    end

    local btn_sure = self.levelUp:getChildByName("btn_sure")
    btn_sure:onClickScaleEffect(sureCallBack)

    local function isPalyEffect()
        print("-------levelUp-----hidehideAct--")
        if FishGI.isPlayEffect then
            print("--------------isPlayEffect == true--------")
            self.levelUp:setVisible(false)
            local seqDelay2 = cc.Sequence:create(cc.DelayTime:create(5.5),cc.CallFunc:create(function ( ... )
                print("--------------isPlayEffect == true----callBack----")
                self.levelUp:setVisible(true)
                self.levelUp.animation:play("upact",false)
                FishGI.AudioControl:playEffect("sound/lvup_01.mp3")
            end))
            seqDelay2:setTag(111111)
            self.levelUp:runAction(seqDelay2)
        else
            self.levelUp:setVisible(true)
            self.levelUp.animation:play("upact",false)
            FishGI.AudioControl:playEffect("sound/lvup_01.mp3")
        end
    end

    self.levelUp:setVisible(false)
    local seqDelay = cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ( ... )
        isPalyEffect()
    end))
    seqDelay:setTag(111112)
    self.levelUp:runAction(seqDelay)


    self.levelUp.animation:clearFrameEventCallFunc()  
    self.levelUp.animation:setFrameEventCallFunc(function(frameEventName)
        if frameEventName:getEvent() == "actend" then
            FishGF.print("-----------levelUp = actend-------")
            if self.levelUp.rewardArr == nil then
                return 
            end
            self.levelUp:stopActionByTag(10001)
            for i=1,#self.levelUp.rewardArr do
                self.levelUp.rewardArr[i]:setVisible(true)
                self.levelUp.rewardArr[i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*(i -1)),cc.ScaleTo:create(0.3,1)))
            end
            local seq = cc.Sequence:create(cc.DelayTime:create(3),
                        cc.CallFunc:create(
                            function ( ... ) 
                                FishGI.GameEffect:levelUpFlyCallBack()
                            end))
            seq:setTag(10001)
            self.levelUp:runAction(seq)
        end
    end)
end

--玩家升级回调
function GameEffect:levelUpFlyCallBack() 
    print("-------11111----propArrFlyAct---")
    self.levelUp:stopActionByTag(10001)
    self.levelUp:stopActionByTag(111111)
    self.levelUp:stopActionByTag(111112)
    self.levelUp:setVisible(false)
    local rewardArr = self.levelUp.rewardArr
    if rewardArr == nil then
        return 
    end
    for i=1,#rewardArr do
        local item = rewardArr[i]
        if item == nil then
            return
        end

        local propTab = {}
        propTab.playerId = item["playerId"]
        propTab.propId = item["propId"]
        propTab.propCount = item["propCount"]
        propTab.isRefreshData = true
        propTab.isJump = false
        propTab.firstPos = item["firstPos"]
        propTab.dropType = "normal"
        propTab.isShowCount = false
        propTab.seniorPropData = item["seniorPropData"]
        FishGI.GameEffect:playDropProp(propTab)
    end
    for k,val in pairs(rewardArr) do
        val:removeFromParent()
    end
    self.levelUp.rewardArr = nil
end

--掉落东西
function GameEffect:dropThings(valTab) 
        --掉落钻石
    local dropCrystal = valTab.dropCrystal
    local dropPos = {};
    dropPos.x = valTab.posX;
    dropPos.y = valTab.posY;

    local dropCount = 0
    if  dropCrystal ~= nil and dropCrystal > 0 then
        dropCount = dropCount +1
        local propTab = {}
        propTab.playerId = valTab.playerId
        propTab.propId = FishCD.PROP_TAG_02
        propTab.propCount = dropCrystal
        propTab.isRefreshData = true
        propTab.isJump = true
        propTab.firstPos = dropPos
        propTab.dropType = "normal"
        propTab.isShowCount = true
        propTab.delayTime = 0.8
        FishGI.GameEffect:playDropProp(propTab)
    end

    --掉落道具
    local dropProps = valTab.dropProps
    if dropProps ~= nil then
        for k,val in pairs(dropProps) do
            dropPos.x = dropPos.x + 100
            dropCount = dropCount +1
            local propTab = {}
            propTab.playerId = valTab.playerId
            propTab.propId = val.propId
            propTab.propCount = val.propCount
            propTab.isRefreshData = true
            propTab.isJump = true
            propTab.firstPos = dropPos
            propTab.dropType = valTab.dropType
            propTab.isShowCount = false
            propTab.delayTime = 0.8
            FishGI.GameEffect:playDropProp(propTab)
        end
    end

    --掉落高级道具
    local dropSeniorProps = valTab.dropSeniorProps
    if dropSeniorProps ~= nil then
        for k,val in pairs(dropSeniorProps) do
            dropPos.x = dropPos.x + 100
            dropCount = dropCount +1
            local propTab = {}
            propTab.playerId = valTab.playerId
            propTab.propId = val.propId
            propTab.propCount = 1
            propTab.isRefreshData = true
            propTab.isJump = true
            propTab.firstPos = dropPos
            propTab.dropType = "normal"
            propTab.isShowCount = false
            propTab.seniorPropData = val
            propTab.delayTime = 0.8
            FishGI.GameEffect:playDropProp(propTab)
        end
    end

end

--爆炸特效
function GameEffect:bombEffect(pos)
    local effectLayer = cc.Director:getInstance():getRunningScene():getChildByTag(FishCD.TAG.EFFECT_LAYER_TAG);
    local bombSprite = cc.Sprite:create("battle/effect/boomeffect01_00.png");
    bombSprite:setScale(2.5);
    bombSprite:setPosition(pos)
    local animation = cc.Animation:create();
    for key = 1, 8 do
        local filename = "battle/effect/boomeffect01_0"..key..".png";
        animation:addSpriteFrameWithFile(filename);
    end
    animation:setDelayPerUnit(1/12);
    bombSprite:runAction(cc.Sequence:create(cc.Animate:create(animation), cc.RemoveSelf:create()));
    effectLayer:addChild(bombSprite, 100);

    FishGI.gameScene:shakeBackground(1/15, 20);
end

function GameEffect:bossComming(valTab) 
    if FishGI.SERVER_STATE == 2 then
        return
    end

    FishGI.AudioControl:playEffect("sound/bossalert_01.mp3",false)
    FishGI.isBossComing = true
    FishGI.AudioControl:playLayerBgMusic()

    local mScore = valTab["score"]
    local id = valTab["id"] - 100000000
    print("---mScore="..mScore.."---id="..id)
    if mScore == 0 then
        mScore = "www"
    end
    local bossCome = cc.Director:getInstance():getRunningScene():getChildByName("bossCome")    
     if bossCome == nil then
        --初始化特效
        FishGI.GameEffect:initGameEff() 
    end
    self.bossCome:setVisible(true)

    local fnt_Rate = self.bossCome:getChildByName("fnt_Rate")
    fnt_Rate:setString(mScore)
    local bossName = self.bossCome:getChildByName("spr_bosscome")
    bossName:initWithFile("battle/bosscome/title_pic_"..id..".png")
    bossName:setVisible(false)

    self.bossCome:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ( ... )
        -- body
        bossName:setVisible(true)
        self.bossCome.animation:play("bosscome", false);
    end)))

end

function GameEffect:bossLeave(valTab) 
    print("-----------------bossLeave-------------------------")
    FishGI.isBossComing = false
    FishGI.AudioControl:playLayerBgMusic()
end

function GameEffect:bossRateChange(dataTab) 
    print("-----------------bossRateChange-------------------------")
    local bossEndRate = dataTab.bossEndRate
    --local delayTime = dataTab.delayTime
    local playerId = dataTab.playerId
    --print("---bossEndRate="..bossEndRate.."---delayTime="..delayTime)

    local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(playerId)
    local chairId = player.playerInfo.chairId
    local pos = player:getCannonPos()
    if chairId < 3 then
        pos.y = pos.y + 130*self.scaleY_
    else
        pos.y = pos.y - 130*self.scaleY_
    end

    if bossEndRate == 0 then
        bossEndRate = "0000"
    end
    local bossRateCahnge = cc.Director:getInstance():getRunningScene():getChildByName("bossRateCahnge")    
     if bossRateCahnge == nil then
        --初始化特效
        FishGI.GameEffect:initGameEff() 
    end
    bossRateCahnge:setCppData(dataTab)
    bossRateCahnge:setVisible(true)
    bossRateCahnge:setPosition(cc.p(pos.x,pos.y))
    bossRateCahnge:stopActionByTag(11011)
    bossRateCahnge:playAct( bossEndRate )


end

function GameEffect:fishGroupCome(valTab) 
    FishGI.AudioControl:playEffect("sound/music_fishgroup.mp3",false)

    local fishGroup = cc.Director:getInstance():getRunningScene():getChildByName("fishGroup")    
     if fishGroup == nil then
        --初始化特效
        FishGI.GameEffect:initGameEff() 
    end
    self.fishGroup:setVisible(true)

    self.fishGroup.animation:play("fishgroupcome", false);

end

--解锁炮倍特效
function GameEffect:playGunUpGrade(data)                        
    local playerId = data.playerId             
    local chairId = data.chairId 
    local moneyCount = data.moneyCount  
    local showType = data.showType  

    local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale()
    -- local endPos = {}
    -- endPos.x= FishCD.aimPosTab[chairId].x*scaleX_
    -- endPos.y= FishCD.aimPosTab[chairId].y*scaleY_

    local endPos = nil
    if FishGI.GAME_STATE == 2 then
        endPos = FishGF.getHallPropAimByID(FishCD.PROP_TAG_01)
        node:setLocalZOrder(FishCD.ORDER_LAYER_TRUE)
    else
        endPos = FishGI.gameScene.playerManager:getPlayerPos(playerId)
    end

    local gunUpGrade = cc.Director:getInstance():getRunningScene():getChildByName(showType)
    local upTime = 0
    if gunUpGrade == nil then
        local uiGunUpGrade = require("ui/battle/gameeffect/uichangeguneff").create()
        gunUpGrade = uiGunUpGrade.root
        gunUpGrade.fnt_coin = uiGunUpGrade["fnt_coin"]
        gunUpGrade.text_word_1 = uiGunUpGrade["text_word_1"]
        gunUpGrade.text_word_2 = uiGunUpGrade["text_word_2"]
        gunUpGrade.image_bg = uiGunUpGrade["image_bg"]
        gunUpGrade:setName(showType)
        cc.Director:getInstance():getRunningScene():addChild(gunUpGrade,FishCD.ORDER_GAME_prop)
        gunUpGrade.image_bg:setOpacity(255)
        gunUpGrade:setOpacity(0)
        upTime = 0.16
        local seq = cc.Sequence:create(cc.ScaleTo:create(upTime/2,1.2),cc.ScaleTo:create(upTime/2,1))
        local fade = cc.FadeTo:create(upTime,255)
        local spawn = cc.Spawn:create(seq,fade)
        gunUpGrade:runAction(spawn)
    end
    gunUpGrade:setPosition(cc.p(endPos.x,endPos.y + 20*scaleY_))

    if showType == "gunUpGrade" then
        gunUpGrade.text_word_1:setString(FishGF.getChByIndex(800000164))
        gunUpGrade.text_word_2:setString(FishGF.getPropUnitByID(1))
    elseif showType == "almInfo" then
        gunUpGrade.text_word_1:setString(FishGF.getChByIndex(800000075))
        gunUpGrade.text_word_2:setString(FishGF.getChByIndex(800000165).."("..data.lectCount.."/"..data.totalCount..")")
    end
    gunUpGrade.fnt_coin:setString(moneyCount)
    gunUpGrade.text_word_2:setPositionX(gunUpGrade.fnt_coin:getContentSize().width)
    local sizeText1 = gunUpGrade.text_word_1:getContentSize().width
    local sizeText2 = gunUpGrade.text_word_2:getContentSize().width
    local sizeFnt = gunUpGrade.fnt_coin:getContentSize().width
    local sizeX = sizeText1 + sizeText2 + sizeFnt
    gunUpGrade.image_bg:setContentSize(cc.size(sizeX*0.6,gunUpGrade.image_bg:getContentSize().height))
    gunUpGrade.fnt_coin:setPositionX(sizeText1 *0.6)

    --消失动画
    local hideTime = 0.16
    local seqHide = cc.Sequence:create(cc.ScaleTo:create(hideTime/2,1.2),cc.ScaleTo:create(hideTime/2,1))
    local fadeHide = cc.FadeTo:create(hideTime,0)
    local spawnHide = cc.Spawn:create(seqHide,fadeHide)

    local airDelayTime = 1.68
    local endAct = cc.Sequence:create(cc.DelayTime:create(upTime+airDelayTime),spawnHide,cc.Hide:create())

    if upTime == 0 then
        gunUpGrade:stopAllActions()
        gunUpGrade:setOpacity(255)
        gunUpGrade:setScale(1)
    end
    gunUpGrade:setVisible(true)
    gunUpGrade:runAction(endAct)

end

--发财了特效
function GameEffect:propMegaWin(dataTab, soundEffect)
    local score = dataTab.score
    local isShowScore = dataTab.isShowScore
    if isShowScore == nil then
        isShowScore = true
    end
    local delayTime = dataTab.delayTime
    if delayTime == nil then
        delayTime = 1
    end

    local megawin = cc.Director:getInstance():getRunningScene():getChildByName("megawin")    
     if megawin == nil then
        --初始化特效
        FishGI.GameEffect:initGameEff() 
    end
    self.megawin.fnt_coin:setString(score)
    if not self.megawin:isVisible() then
        self.megawin:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.CallFunc:create(function ( ... )
            FishGI.AudioControl:playEffect(soundEffect,false)
            self.megawin:setVisible(true)
            if isShowScore then
                self.megawin.node_score:setVisible(true)
                self.megawin.partical_coin:setVisible(true)
            else
                self.megawin.node_score:setVisible(false)
                self.megawin.partical_coin:setVisible(true)         
            end
            self.megawin.animation:play("bigrich",false)
            self.megawin.partical_coin:resetSystem()
        end)))
    end
end

--天降横财特效
function GameEffect:propWindfall(dataTab, soundEffect)
    FishGI.isPlayEffect = true
    local score = dataTab.score
    local isShowScore = dataTab.isShowScore
    if isShowScore == nil then
        isShowScore = true
    end
    local delayTime = dataTab.delayTime
    if delayTime == nil then
        delayTime = 1
    end

    local windfall = cc.Director:getInstance():getRunningScene():getChildByName("windfall")    
     if windfall == nil then
        --初始化特效
        FishGI.GameEffect:initGameEff() 
    end
    self.windfall.fnt_coin:setString(score)
    

    if not self.windfall:isVisible() then
        self.windfall:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.CallFunc:create(function ( ... )
            FishGI.AudioControl:playEffect(soundEffect,false)
            self:jumpingNumber(self.windfall.fnt_coin, 4,score, 0, nil)    
            self.windfall:setVisible(true)
            if isShowScore then
                self.windfall.node_score:setVisible(true)
                self.windfall.partical_coin:setVisible(true)
            else
                self.windfall.node_score:setVisible(false)
                self.windfall.partical_coin:setVisible(true)         
            end
            self.windfall.animation:play("bigrich",false)
            self.windfall.partical_coin:resetSystem()
        end)))
    end
end


---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------不带GameEffect自身的特效-------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

--开始转盘抽奖
function GameEffect.startRotateByEndRotate(layer,node,endRotate,valTabData)
    print("---startRotateByEndRotate----")
    if node == nil then
        return
    end

    local props = valTabData.props
    local seniorProps = valTabData.seniorProps
    local propId = valTabData.propId
    local propCount = valTabData.propCount
    local playerId = valTabData.playerId
    local angleCell = node.angleCell

    if node.rollingID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(node.rollingID )
    end
    local curIndex = 0
    local scheduler = cc.Director:getInstance():getScheduler()  
    node.rollingID = scheduler:scheduleScriptFunc(function(dt)
        local rotate = node:getRotation()
        local index = math.floor(rotate/angleCell)
        if index ~= curIndex then
            FishGI.AudioControl:playEffect("sound/rolling_01.mp3")
            curIndex = index
        end
    end,0.02,false) 

    node:stopAllActions()
    local count = 3
    local sp = FishCD.DIAL_SPEED
    local constantCount = 3
    local constantSpeed = cc.RotateBy:create(constantCount*360/sp,constantCount*360)
    local speedAct = cc.EaseExponentialOut:create(cc.RotateTo:create((count*360 + endRotate)/(sp -500 ),(count*360 + endRotate)))

    --获得道具亮一下效果
    local callFun1 = cc.CallFunc:create(function ( ... )
        --layer:playGetAward()
        layer.spr_cur_award:setVisible(true)
        --BreakPoint()
        if layer.animation ~= nil then
            layer.animation:play("getaward",false)
        else
            print("--------layer.animation == nil-----")
        end
        
    end)

    local callFun = cc.CallFunc:create(function ( ... )
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(node.rollingID )
        node.rollingID = nil
        FishGI.AudioControl:playEffect("sound/congrat_01.mp3",false)

        --抽奖结果显示
        layer:setDialEnd(true)
        layer:hideLayer() 

        local uiDialend = require("ui/hall/dial/uidialend").create()
        local dialEnd = uiDialend.root
        layer:getParent():addChild(dialEnd,FishCD.ORDER_LAYER_TRUE)
        dialEnd:setName("dialEnd")
        dialEnd:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))

        FishGI.showLayerData:showLayerByNoAct(dialEnd)

        dialEnd.animation = uiDialend["animation"]
        dialEnd:runAction(uiDialend["animation"])
        dialEnd.animation:play("show",false)

        uiDialend["text_leavenotice"]:setString(FishGF.getChByIndex(800000083))
        uiDialend["spr_light"]:runAction(cc.RepeatForever:create(cc.RotateBy:create(1,FishCD.LIGHT_SPEED)))
        local shell = uiDialend["node_prop"]
        dialEnd.shell = shell
        dialEnd.node_bg = uiDialend["node_bg"]
        local shellopen = shell:getChildByName("spr_shell_open")
        local fnt_prop_count = shellopen:getChildByName("fnt_prop_count")
        fnt_prop_count:setString(FishGF.changePropUnitByID(propId,propCount,false))
        local spr_prop = shellopen:getChildByName("spr_prop")
        spr_prop:initWithFile("common/prop/"..FishGI.GameTableData:getItemTable(propId).res)

        shell.animation:play("open", false);
        local isTouch = false
        local function onTouchBegan(touch, event)
            if isTouch then
                return
            end
            isTouch = true
            FishGI.hallScene:isShowVIPDail()
            FishGI.showLayerData:hideLayer(dialEnd,true) 

            for k,val in pairs(props) do
                print("-------------------val.propId="..val.propId.."--val.propCount="..val.propCount)
                local propTab = {}
                propTab.playerId = playerId
                propTab.propId = val.propId
                propTab.propCount = val.propCount
                propTab.isRefreshData = true
                propTab.isJump = false
                propTab.firstPos = cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2)
                propTab.dropType = "normal"
                propTab.isShowCount = false
                FishGI.GameEffect:playDropProp(propTab)       
            end

            for k,val in pairs(seniorProps) do
                local propTab = {}
                propTab.playerId = playerId
                propTab.propId = val.propId
                propTab.propCount = 1
                propTab.isRefreshData = true
                propTab.isJump = false
                propTab.firstPos = cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2)
                propTab.dropType = "normal"
                propTab.isShowCount = false
                propTab.seniorPropData = val
                FishGI.GameEffect:playDropProp(propTab)
            end

            return true
        end

        local listener = cc.EventListenerTouchOneByOne:create();
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN);   
        local eventDispatcher = dialEnd:getEventDispatcher() -- 得到事件派发器
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, dialEnd) -- 将监听器注册到派发器中
    end)

    node:runAction(cc.Sequence:create(constantSpeed,speedAct,callFun1,cc.DelayTime:create(0.5+40/60),callFun))

end

--小金币旋转飞行动画         ---获取道具的数量，初始位置，终点位置，父节点，回调函数
function GameEffect.coinFlyAct(dataTab,parent,callback)
    local propCount = dataTab.propCount
    local firstPos = dataTab.firstPos
    local endPos = dataTab.endPos
    local moveTime = 1

    if parent == nil then
        parent = cc.Director:getInstance():getRunningScene()
    end

    local node = cc.Node:create()
    if FishGI.GAME_STATE == 2 then
        parent:addChild(node,FishCD.ORDER_LAYER_TRUE + 10)
    else
        parent:addChild(node,FishCD.ORDER_GAME_prop)
    end
    
    node:setPosition(cc.p(firstPos.x,firstPos.y))

    --生产小金币
    local dis = 20
    for i=1,propCount do
        local mSprite = cc.Sprite:create();
        mSprite:setPositionX(-dis+ (i-1)*dis*propCount)
        node:addChild(mSprite);

        local animation = cc.Animation:create()
        local N = math.random(1,9)
        for i=1,10 do
            local key = math.mod((i + N),10);
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("game_coin%d_0%d.png", 1, key)) 
            if frame then
                animation:addSpriteFrame(frame)
            end
        end
        animation:setDelayPerUnit(1/20);
        local animate = cc.Animate:create(animation)
        mSprite:runAction(cc.RepeatForever:create(animate))
        mSprite:runAction(cc.MoveTo:create(moveTime,cc.p(0,0)))
    end

    if callback == nil then
        callback = function ( ... )     
        end
    end
    local callfun = cc.CallFunc:create(callback)
    local callfun2 = cc.CallFunc:create(function ( ... )
        print("------------------propFlyActEnd--")
        FishGI.AudioControl:playEffect("sound/getprop_01.mp3")
    end)

    local speedAct = cc.EaseExponentialIn:create(cc.MoveTo:create(moveTime,endPos))
    local scalect = cc.ScaleTo:create(moveTime,0.7)
    local swAct = cc.Spawn:create(speedAct,scalect)
    node:runAction(cc.Sequence:create(swAct,callfun2,callfun,cc.RemoveSelf:create()))

end

--灯炮闪烁
function GameEffect.lampBlink( light,delayTime )
    light:setOpacity(0)
    local seq = cc.Sequence:create(cc.DelayTime:create(delayTime),cc.CallFunc:create(function ( ... )
        light:stopAllActions()
        local seqAct = cc.Sequence:create(
            cc.FadeTo:create(0.25,255),
            cc.DelayTime:create(0.25),
            cc.FadeTo:create(0.25,0),
            cc.DelayTime:create(0.25))
        light:runAction(cc.RepeatForever:create(seqAct))
    end))
    light:runAction(seq)
end

--生产泡泡粒子
function GameEffect.createBubble(bubbleType)
    local emitter = nil
    if bubbleType == 1 then     --大厅泡泡
        emitter = cc.ParticleSystemQuad:create("battle/effect/effect_paopao_01.plist")  
        emitter:setAutoRemoveOnFinish(false)  
    elseif bubbleType == 2 then     --游戏内泡泡
        emitter = cc.ParticleSystemQuad:create("battle/effect/effect_paopao_01.plist")  
        emitter:setAutoRemoveOnFinish(false)  
    end

    return emitter
end

--数字跳动
function GameEffect.nodeJump(node)
    node:stopAllActions();
    node:setScale(1);
    node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.7), cc.ScaleTo:create(0.3, 1)));
end

--遮罩效果
function GameEffect.skillShadeEffect(color, callfunc)
    local shadeEffect = cc.Director:getInstance():getRunningScene():getChildByTag(4321);
    local function frameEvent( frameEventName)
        if frameEventName:getEvent() == "playend" then
            shadeEffect:setVisible(false)
            callfunc()
        end
    end
    
    shadeEffect:setVisible(false);
    shadeEffect:getChildByName("img_bg"):setColor(color)
    shadeEffect.animation:stop()
    shadeEffect["animation"]:clearFrameEventCallFunc()
    shadeEffect.animation:play("shadeani", false)
    shadeEffect["animation"]:setFrameEventCallFunc(frameEvent)
    return shadeEffect
end

--技能文字效果
function GameEffect.skillWordEffect(picPath, lightPic, pos, callfunc)
    local wordEffect = cc.Director:getInstance():getRunningScene():getChildByTag(4322);
    wordEffect:setPosition(pos)
    local function frameEvent( frameEventName)
        if frameEventName:getEvent() == "playeffect" then
            wordEffect:setVisible(false)
            callfunc()
        end
    end
    wordEffect:setVisible(true);
    wordEffect:getChildByName("text_1"):setTexture(picPath)
    wordEffect:getChildByName("text_2"):setTexture(picPath)
    wordEffect:getChildByName("light_1"):setTexture(lightPic)
    wordEffect:getChildByName("light_2"):setTexture(lightPic)
    wordEffect.animation:stop()
    wordEffect["animation"]:clearFrameEventCallFunc()
    wordEffect.animation:play("wordani", false)
    wordEffect["animation"]:setFrameEventCallFunc(frameEvent)
    return wordEffect
end

--朋友场技能效果
function GameEffect.friendSkillEffect(templatePath, aniName, loopPlay, pos, zorder, callfunc)
    print("pos x:"..pos.x.." pos y:"..pos.y)
    local template = require(templatePath).create()
    local effect = template.root
    effect.animation = template["animation"]
    effect:setName(aniName)
    effect:setPosition(pos)
    effect:runAction(template["animation"])
    effect.animation:play(aniName, loopPlay)
    if not loopPlay then 
        local function frameEvent(frameEventName)
            if frameEventName:getEvent() == "playcannoneffect" then
                effect:removeFromParent();
                callfunc();
                
            end
        end
        effect.animation:setFrameEventCallFunc(frameEvent)
    end 
    --cc.Director:getInstance():getRunningScene():addChild(effect, zorder);
    return effect
end

function GameEffect.createUseTargetEffet(callfunc)
    local selRect = {
        {0, 0},
        {100, 0},
        {100 ,100},
        {0 ,100},
    }

    local deltlen = 20
    local movedelt = {
        cc.p(deltlen, deltlen),
        cc.p(-deltlen, deltlen),
        cc.p(-deltlen, -deltlen),
        cc.p(deltlen , -deltlen),
    }
    local myPlayerId= FishGI.gameScene.playerManager.selfIndex
    local selfChair = FishGI.gameScene.playerManager:getPlayerChairId(myPlayerId)

    local function createPoint(tag, pos, size, callback)
        local selectPoint = ccui.Button:createInstance()
        selectPoint:setScale9Enabled(true);
        selectPoint:setSwallowTouches(false);
        selectPoint:setContentSize(size)
        selectPoint:setAnchorPoint(cc.p(0.5,0.5))
        selectPoint:setTag(tag)
        selectPoint:setPosition(pos)
        selectPoint:addTouchEventListener(callback);
        for j = 1, 4 do
            local point = cc.Sprite:create("res/battle/magicprop/magicprop_appoint.png")
            point:setAnchorPoint(0.5, 0.5)
            point:setRotation(-90*j + 45)
            point:setPosition(selRect[j][1], selRect[j][2])


            local move = {}
            move[#move + 1] = cc.MoveBy:create(0.5, movedelt[j])
            move[#move + 1] = cc.MoveBy:create(0.5, cc.p(-movedelt[j].x, -movedelt[j].y))

            local seq = transition.sequence(move)

            local repeatFor = {}
            repeatFor[#repeatFor + 1] = cc.RepeatForever:create(seq)

            local seq2 = transition.sequence(repeatFor)

            point:runAction(seq2)

            selectPoint:addChild(point)
        end
        return selectPoint;
    end

    local function selectCallback(pSender, eventName)
        if eventName == ccui.TouchEventType.ended then
            
            local chairId = pSender:getTag();
            local playerId = FishGI.gameScene.playerManager:getPlayerByChairId(chairId).playerInfo.playerId
            print("touch end position:"..pSender:getTag().." playerId:"..playerId)
            cc.Director:getInstance():getRunningScene():removeChildByTag(8888);
            callfunc(playerId);
        end
    end

    local function cancelSelectLayerCallback(pSender, eventName)
        if eventName == ccui.TouchEventType.ended then
            pSender:removeFromParent();
        end
    end

    --创建选择技能对象层
    local function createSelectLayer(callback)
		local winSize = cc.Director:getInstance():getWinSize()
        local layer = ccui.Button:createInstance();
        layer:setAnchorPoint(cc.p(0, 0))
        layer:setPosition(cc.p(0, (selfChair == 1 or selfChair == 2 and 35 or -35)))
        layer:setScale9Enabled(true);
        layer:addTouchEventListener(callback);
        layer:setContentSize(winSize);
        for chairId = FishCD.DIRECT.LEFT_DOWN, FishCD.DIRECT.LEFT_UP do
            local delup = 0
            if chairId == FishCD.DIRECT.LEFT_UP or chairId == FishCD.DIRECT.RIGHT_UP then
                delup = 100;
            end
            print("cur chair id:"..chairId.." main chairId:"..selfChair)
            local player = FishGI.gameScene.playerManager:getPlayerByChairId(chairId)
            if player == nil then
                print("player is nil")
            end
            if player and chairId ~= selfChair then
                --不是自己
                local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale();
                local posChair = FishCD.posTab[chairId];
                local size = cc.size(100, 100);
                local curPos = player:getCannonPos();
				curPos.y = ((chairId == 1 or chairId == 2) and 75*scaleY_ or winSize.height-75*scaleY_);
                local point = createPoint(chairId, curPos, size, selectCallback);
                print("x:"..curPos.x.." y:"..curPos.y)
                layer:addChild(point, chairId);
            end
        end
        return layer;
    end

    local scene = cc.Director:getInstance():getRunningScene();
    scene:addChild(createSelectLayer(cancelSelectLayerCallback), 1000, 8888);
end

function GameEffect.createLockAni(pointNum, startPos, endPos, callback)
    local layer = ccui.Button:createInstance();
    layer:setAnchorPoint(cc.p(0.5, 0.5));
    layer:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2, cc.Director:getInstance():getWinSize().height/2))
    layer:setScale9Enabled(true);
    layer:setContentSize(cc.Director:getInstance():getWinSize());
    layer:addTouchEventListener(callback);

    --锁定目标的环
    local lockRange = cc.Sprite:create("battle/friend/effect/light_sd_1.png");
    lockRange:runAction(cc.RepeatForever:create(cc.RotateBy:create(4,360)));
    lockRange:setPosition(endPos)
    layer:addChild(lockRange, 1, 1001);
    --箭头
    local lockArrow = cc.Sprite:create("battle/friend/effect/light_sd_3.png");
    lockArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.13,0.8),cc.ScaleTo:create(0.87,1))))
    lockArrow:setPosition(endPos)
    layer:addChild(lockArrow, 1, 1002);

    --点
    for key = 1, pointNum do
        local chainPoint = cc.Sprite:create("battle/friend/effect/light_sd_2.png");
        local posX = startPos.x + (endPos.x - startPos.x)/(pointNum + 2)*(key+1);
        local posY = startPos.y + (endPos.y - startPos.y)/(pointNum + 2)*(key+1);
        chainPoint:setPosition(cc.p(posX, posY));
        layer:addChild(chainPoint, 1, 2000+key);
    end
    

    return layer;
end

function GameEffect.updateLockPos(lock, pointNum, startPos, endPos)
    if lock == nil then
        return
    end
    local lockRange = lock:getChildByTag(1001);
    local lockArrow = lock:getChildByTag(1002);
    for key = 1, pointNum do
        local chainPoint = lock:getChildByTag(2000+key);
        if chainPoint == nil then
            break;
        else
            
            local posX = startPos.x + (endPos.x - startPos.x)/(pointNum + 2)*(key+1);
            local posY = startPos.y + (endPos.y - startPos.y)/(pointNum + 2)*(key+1);
            chainPoint:setPosition(cc.p(posX, posY));
        end
    end

    lockRange:setPosition(endPos)
    lockArrow:setPosition(endPos)

end

function GameEffect.updateLockAim(lock)
    if lock == nil then
        return
    end
    local lockRange = lock:getChildByTag(1001);
    local lockArrow = lock:getChildByTag(1002);

    lockArrow:stopAllActions();
    lockArrow:setScale(1.8);
    lockArrow:setOpacity(255*0.3);

    local scaleAct1 = cc.ScaleTo:create(0.13,0.9)
    local OpacityAct1 = cc.FadeTo:create(0.13,255)
    local spawnAct1 = cc.Spawn:create(scaleAct1,OpacityAct1)

    local act2 = cc.ScaleTo:create(0.03,1)
    local rotate = cc.RotateBy:create(0.16,80)

    local endAct = cc.CallFunc:create(function ( ... )
        lockRange:stopAllActions();
        lockRange:runAction(cc.RepeatForever:create(cc.RotateBy:create(4,360)))
        lockArrow:stopAllActions()
        local seq = cc.Sequence:create(cc.ScaleTo:create(0.13,0.8),cc.ScaleTo:create(0.87,1))
        lockArrow:runAction(cc.RepeatForever:create(seq))
    end)
    lockArrow:runAction(rotate)
    lockArrow:runAction(cc.Sequence:create(spawnAct1,act2,endAct))
end

--掉落
function GameEffect:playDropProp(dataTab) 
    local playerId = dataTab.playerId
    local propId = dataTab.propId
    local propCount = dataTab.propCount
    local isRefreshData = dataTab.isRefreshData
    local isJump = dataTab.isJump
    local firstPos = dataTab.firstPos

    local dropType = dataTab.dropType
    local isShowCount = dataTab.isShowCount
    local parent = dataTab.parent
    local endPos = dataTab.endPos

    local seniorPropData = dataTab.seniorPropData
    if seniorPropData ~= nil and next(seniorPropData) ~= nil then
        dataTab.propId = seniorPropData.propId
        dataTab.propCount = 1
    end

    dataTab.node = self:createDropProp(dataTab)
    if dataTab.node == nil then
        return
    end
    self:propRunAct(dataTab)
end

--创建道具
function GameEffect:createDropProp(dataTab) 
    local playerId = dataTab.playerId
    local propId = dataTab.propId
    local propCount = dataTab.propCount
    local isShowCount = dataTab.isShowCount
    local dropType = dataTab.dropType
    local parent = dataTab.parent


    if parent == nil then
        parent = cc.Director:getInstance():getRunningScene()
        if dataTab.dropType ~= nil and dataTab.dropType == "friend" then
            parent = FishGI.gameScene.uiMainLayer
        end
    end
    local node = cc.Node:create()
    if FishGI.GAME_STATE == 2 then
        parent:addChild(node,FishCD.ORDER_LAYER_TRUE + 10)
    else
        parent:addChild(node,FishCD.ORDER_GAME_prop)
    end

    local propname = ""
    if dataTab.dropType ~= nil and dataTab.dropType == "friend" then 
        propname = "battle/friend/"..FishGI.GameConfig:getConfigData("friendprop", tostring(420000000 + propId -FishCD.FRIEND_INDEX ), "friendprop_res")
    else
        propname = "common/prop/"..FishGI.GameTableData:getItemTable(propId).res
    end 
    local propSpr = cc.Sprite:create(propname)
    if propSpr == nil then
        return nil
    end

    node:addChild(propSpr,2000)

    if isShowCount ~= nil and isShowCount == true then
        --数量底框
        local countFrame = cc.Scale9Sprite:create("common/layerbg/com_num_bg.png");
        countFrame:setPosition(cc.p(propSpr:getContentSize().width/2,-4));
        countFrame:setScale9Enabled(true);
        countFrame:setCapInsets({x = 23, y = 20, width = 1, height = 1})
        countFrame:setContentSize(cc.size(116, 40));
        propSpr:addChild(countFrame);
        --数量
        local count = cc.LabelTTF:create(FishGF.getPropUnitByID(propId).."x"..propCount, "Arial", 24);
        count:setColor(cc.c3b(255, 233, 128));
        count:setPosition(cc.p(countFrame:getContentSize().width/2, countFrame:getContentSize().height/2));
        countFrame:addChild(count);
    end

    local light = cc.Sprite:create("common/com_pic_light.png")
    node:addChild(light,1)
    light:setScale(1.4)
    light:setOpacity(255*0.5)
    light:runAction(cc.RepeatForever:create(cc.RotateBy:create(1,FishCD.LIGHT_SPEED)))
    --light:setBlendFunc({src = 770, dst = 1})

    return node
end

function GameEffect:jumpingNumber(widget, total_time,count, curCoin, callback)    
    widget:setString(math.floor(curCoin))
    local deltCoin = count - curCoin
    local period = 0
    
    self.sid = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt)
        period = period + dt
        if period >= total_time then
            widget:setString(math.floor(count))
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.sid)
            if callback ~= nil then
                callback()
            end
            return 
        end

        local percent = (period)/total_time
        local delt = math.floor(deltCoin*percent)
        widget:setString(curCoin + delt)
    end, 0, false)
end


--掉落道具，水晶动画
function GameEffect:propRunAct(dataTab) 
    local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale()
    local node = dataTab.node
    local playerId = dataTab.playerId
    local propId = dataTab.propId
    local propCount = dataTab.propCount
    local isRefreshData = dataTab.isRefreshData
    local isJump = dataTab.isJump
    local seniorPropData = dataTab.seniorPropData
    local delayTime = dataTab.delayTime

    local firstPos = dataTab.firstPos
    node:setPosition(cc.p(firstPos.x,firstPos.y))

    local endPos = dataTab.endPos

    if endPos == nil then
        if FishGI.GAME_STATE == 2 then
            endPos = FishGF.getHallPropAimByID(propId)
        else
            endPos = FishGI.gameScene.playerManager:getPlayerPos(playerId)
        end
    end

    
    local callback = function ( ... )  end
    if isRefreshData then
        callback = function ( ... )
            --print("--------1-----data-----propFlyActEnd--")
            --清除缓存
            if seniorPropData == nil then
                FishGMF.setAddFlyProp(playerId,propId,propCount,true)
            else
                FishGMF.refreshSeniorPropData(playerId,seniorPropData,6,0)
            end
            
            if FishGI.GAME_STATE == 2 and propId == 2001 then   --刷新VIP经验
                FishGI.hallScene.net.roommanager:sendDataGetInfo();
            elseif FishGI.GAME_STATE == 2 and propId == 2002 then   --刷新月卡
                FishGI.hallScene.net.roommanager:sendDataGetInfo();
            end
        end
    end

    local callfunData = cc.CallFunc:create(function ( ... )
        --print("---------0----data-----propFlyActEnd--")
        callback()
    end)

    local callfunSound = cc.CallFunc:create(function ( ... )
        --print("-------------sound-----propFlyActEnd--")
        FishGI.AudioControl:playEffect("sound/getprop_01.mp3")
    end)

    local JumpTime = 0
    local moveTime = 1
    local frontDelayTime = 0
    if isJump ~= nil and isJump == true then --跳出来
        if delayTime == nil then
            delayTime = 0
        end
        node:setScale(0.3)
        node:setVisible(false)

        node:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.Show:create(),cc.ScaleTo:create(0.54,1)))
        node:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.MoveBy:create(0.21,cc.p(0,88))))
        node:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime + 0.21),cc.MoveBy:create(0.20,cc.p(0,-103))))
        node:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime + 0.41),cc.MoveBy:create(0.13,cc.p(0,27))))

        frontDelayTime = delayTime + 0.41 + 0.13 + 0.6
        
    else --直接出现
        if delayTime == nil then
            delayTime = 0.4
        end
        frontDelayTime = delayTime
    end
    --print("-------------frontDelayTime="..frontDelayTime)
    local speedAct = cc.EaseExponentialIn:create(cc.MoveTo:create(moveTime,cc.p(endPos.x,endPos.y)))
    local spawnAct = cc.Spawn:create(speedAct,cc.ScaleTo:create(moveTime,0.6))
    local allAct = cc.Sequence:create(cc.DelayTime:create(frontDelayTime),spawnAct,callfunSound,cc.DelayTime:create(0.03),callfunData,cc.RemoveSelf:create())

    node:runAction(allAct)

end



return GameEffect;