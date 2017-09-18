local SNBombUI = class("SNBombUI")

function SNBombUI.create(layer)
    local obj = SNBombUI.new();
    obj:init(layer);
    return obj;
end

function SNBombUI:init(layer)
    --核弹提示
    self.tips = cc.Sprite:create("battle/nuclear/nuclear_tips_2.png");
    local seq = cc.Sequence:create(cc.FadeTo:create(0.32, 255), cc.FadeTo:create(0.32, 204), cc.DelayTime:create(0.32));
    self.tips:setOpacity(0);
    self.tips:runAction(cc.RepeatForever:create(seq));
    self.tips:setName("launcherTips")
    layer:addChild(self.tips);
    self.tips:setVisible(false)
    

    self.layer = layer;
end


function SNBombUI:readyLaunch()
    local chairId = FishGI.gameScene.playerManager:getMyChairId()
    local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale();
    local pos = cc.p(FishCD.posTab[chairId].x*scaleX_, FishCD.posTab[chairId].y*scaleY_+164);
    if self.tips ~= nil then
        self.tips:setVisible(true)
        self.tips:setPosition(pos);
    end
end

function SNBombUI:cancelLaunch()
    self.tips:setVisible(false)
end

function SNBombUI:launch(pos, killCallFunc, dataValue)
    local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale();
    local winSize = cc.Director:getInstance():getWinSize();

    local rotate = require("ui/battle/bomb/uisbomb1").create()
    local rotateEffect = rotate.root
    rotateEffect.animation = rotate["animation"]
    rotateEffect:runAction(rotate["animation"])
    rotateEffect.animation:play("rotate", false);
    rotateEffect:setPosition(pos);
    self.layer:addChild(rotateEffect, 100);

    local bomb = require("ui/battle/bomb/uisbomb2").create()
    local bombEffect = bomb.root
    bombEffect.animation = bomb["animation"]
    bombEffect:runAction(bomb["animation"])
    bombEffect:setPosition(pos);
    local function frameEvent( frameEventName)
        if frameEventName:getEvent() == "down_end" then
            bombEffect:setVisible(false);
            bombEffect:runAction(cc.RemoveSelf:create());
        end
    end
    bombEffect["animation"]:clearFrameEventCallFunc()
    bombEffect["animation"]:setFrameEventCallFunc(frameEvent)
    bombEffect:setVisible(false)

    self.layer:addChild(bombEffect, 100);

    local function frameEvent0( frameEventName)
        if frameEventName:getEvent() == "playbomb" then
            rotateEffect:runAction(cc.RemoveSelf:create());
            bombEffect:setVisible(true)
            bombEffect.animation:play("light_down", false);
            FishGI.AudioControl:playEffect("sound/bomb_01.mp3")
            killCallFunc(dataValue);
        end
    end
    rotateEffect["animation"]:clearFrameEventCallFunc()
    rotateEffect["animation"]:setFrameEventCallFunc(frameEvent0)    

end

local MNBombUI = class("MNBombUI")
function MNBombUI.create(layer)
    local obj = MNBombUI.new();
    obj:init(layer);
    return obj;
end

function MNBombUI:init(layer)
    --核弹提示
    self.tips = cc.Sprite:create("battle/nuclear/nuclear_tips.png");
    local seq = cc.Sequence:create(cc.FadeTo:create(0.32, 255), cc.FadeTo:create(0.32, 204), cc.DelayTime:create(0.32));
    self.tips:setOpacity(0);
    self.tips:runAction(cc.RepeatForever:create(seq));
    self.tips:setName("launcherTips")
    layer:addChild(self.tips);
    self.tips:setVisible(false)

    self.layer = layer;
end

function MNBombUI:readyLaunch()
    local chairId = FishGI.gameScene.playerManager:getMyChairId()
    local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale();
    local pos = cc.p(FishCD.posTab[chairId].x*scaleX_, FishCD.posTab[chairId].y*scaleY_+164);
    if self.tips ~= nil then
        self.tips:setVisible(true)
        self.tips:setPosition(pos);
    end
end

function MNBombUI:cancelLaunch()
    self.tips:setVisible(false)
end

function MNBombUI:launch(pos, killCallFunc, dataValue)
    local isFlipX = (pos.x > FishCD.BASE_WIN_SIZE.width/2 and true or false);
    local winSize = cc.Director:getInstance():getWinSize();
    local plane = require("ui/battle/bomb/uimbomb1").create()
    local planeEffect = plane.root
    planeEffect.animation = plane["animation"]
    planeEffect:runAction(plane["animation"])
    planeEffect.animation:play("plane", false);
    planeEffect:setPosition(cc.p(winSize.width/2, winSize.height/2));
    if isFlipX then
        planeEffect:setScaleX(-1);
    end
    self.layer:addChild(planeEffect, 100);

    local rotate = require("ui/battle/bomb/uimbomb2").create()
    local rotateEffect = rotate.root
    rotateEffect.animation = rotate["animation"]
    rotateEffect:runAction(rotate["animation"])
    rotateEffect.animation:play("rotate", false);
    rotateEffect:setPosition(pos);
    self.layer:addChild(rotateEffect, 100);


    local bomb = require("ui/battle/bomb/uimbombcom").create()
    local bombEffect = bomb.root
    bombEffect.animation = bomb["animation"]
    bombEffect:runAction(bomb["animation"])
    bombEffect.animation:play("bomb", false);
    bombEffect:setPosition(pos);
    local function frameEvent( frameEventName)
        if frameEventName:getEvent() == "down" then
            FishGI.AudioControl:playEffect("sound/bombdown_01.mp3")
        elseif frameEventName:getEvent() == "bomb" then
            bombEffect:setVisible(false);
            FishGI.AudioControl:playEffect("sound/bomb_01.mp3")
            planeEffect:runAction(cc.RemoveSelf:create());
            rotateEffect:runAction(cc.RemoveSelf:create());
            bombEffect:runAction(cc.RemoveSelf:create());
            killCallFunc(dataValue);
            FishGI.GameEffect:bombEffect(pos);
        end
    end
    bombEffect["animation"]:clearFrameEventCallFunc()
    bombEffect["animation"]:setFrameEventCallFunc(frameEvent)
    if isFlipX then
        bombEffect:setScaleX(-1);
    end
    self.layer:addChild(bombEffect, 100);
    print("-------------------------mbomb");
    --mbombEffect:setVisible(false);
end

local BNBombUI = class("BNBombUI")

function BNBombUI.create(layer)
    local obj = BNBombUI.new();
    obj:init(layer);
    return obj;
end

function BNBombUI:init(layer)
    --核弹提示
    self.tips = cc.Sprite:create("battle/nuclear/nuclear_tips_1.png");
    local seq = cc.Sequence:create(cc.FadeTo:create(0.32, 255), cc.FadeTo:create(0.32, 204), cc.DelayTime:create(0.32));
    self.tips:setOpacity(0);
    self.tips:runAction(cc.RepeatForever:create(seq));
    self.tips:setName("launcherTips")
    layer:addChild(self.tips);
    self.tips:setVisible(false)

    self.layer = layer;
end


function BNBombUI:readyLaunch()
    local chairId = FishGI.gameScene.playerManager:getMyChairId()
    local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale();
    local pos = cc.p(FishCD.posTab[chairId].x*scaleX_, FishCD.posTab[chairId].y*scaleY_+164);
    if self.tips ~= nil then
        self.tips:setVisible(true)
        self.tips:setPosition(pos);
    end
end

function BNBombUI:cancelLaunch()
    self.tips:setVisible(false)
end

function BNBombUI:launch(pos, killCallFunc, dataValue)
    local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale();
    local winSize = cc.Director:getInstance():getWinSize();
    --pos.y = winSize.height/2
    FishGI.AudioControl:playEffect("sound/bomb_02.mp3")

    local rotate = require("ui/battle/bomb/uibbomb1").create()
    local rotateEffect = rotate.root
    rotateEffect.animation = rotate["animation"]
    rotateEffect:runAction(rotate["animation"])
    rotateEffect.animation:play("rotate", false);
    rotateEffect:setPosition(pos);
    self.layer:addChild(rotateEffect, 100);
    rotateEffect:setScale(scaleMin_)

    local light = require("ui/battle/bomb/uibbomb3").create()
    local lightEffect = light.root
    lightEffect.animation = light["animation"]
    lightEffect:runAction(light["animation"])
    lightEffect:setPosition(cc.p(pos.x,winSize.height/2));
    self.layer:addChild(lightEffect, 100);
    local function frameEvent1( frameEventName)
        if frameEventName:getEvent() == "light_1" then
            FishGI.AudioControl:playEffect("sound/bomb_03.mp3")
            FishGI.gameScene:shakeBackground(1/15, 20);
            killCallFunc(dataValue);
        elseif frameEventName:getEvent() == "light_2" then
            
        elseif frameEventName:getEvent() == "light_3" then
            FishGI.gameScene:shakeBackground(1/15, 20);
        elseif frameEventName:getEvent() == "light_4" then

        elseif frameEventName:getEvent() == "light_5" then
            FishGI.gameScene:shakeBackground(1/15, 20);
        elseif frameEventName:getEvent() == "down_end" then
            lightEffect:runAction(cc.RemoveSelf:create());
        end
    end
    lightEffect["animation"]:clearFrameEventCallFunc()
    lightEffect["animation"]:setFrameEventCallFunc(frameEvent1)
    lightEffect:setScale(scaleMin_)
    lightEffect:setVisible(false)

    local bomb = require("ui/battle/bomb/uibbomb2").create()
    local bombEffect = bomb.root
    bombEffect.animation = bomb["animation"]
    bombEffect:runAction(bomb["animation"])
    bombEffect:setPosition(cc.p(pos.x,winSize.height/2));
    local function frameEvent( frameEventName)
        if frameEventName:getEvent() == "bomb" then
            bombEffect:setVisible(false);
            lightEffect:setVisible(true)
            lightEffect.animation:play("light_down", false);
            rotateEffect:runAction(cc.RemoveSelf:create());
            bombEffect:runAction(cc.RemoveSelf:create());
        end
    end
    bombEffect["animation"]:clearFrameEventCallFunc()
    bombEffect["animation"]:setFrameEventCallFunc(frameEvent)
    bombEffect:setVisible(false)
    bombEffect:setScale(scaleMin_);

    self.layer:addChild(bombEffect, 100);
    print("-------------------------bbomb");

    local function frameEvent0( frameEventName)
        if frameEventName:getEvent() == "playbomb" then
            bombEffect:setVisible(true)
            bombEffect.animation:play("down", false);
        end
    end
    rotateEffect["animation"]:clearFrameEventCallFunc()
    rotateEffect["animation"]:setFrameEventCallFunc(frameEvent0)
    

end


local SkillBase = import("Game.Skill.NormalSkill.SkillBase")
local SkillNBomb = class("SkillNBomb",SkillBase)

function SkillNBomb:ctor(...)
    self:initListener()
    self:initBg()
    self:openTouchEventListener()
    self.isChose = false
end

--初始化监听器
function SkillNBomb:initListener()
    local eventDispatcher = self:getEventDispatcher()
    local NBombUseResult = cc.EventListenerCustom:create("NBombUseResult", handler(self, self.NBombUseResult))
    eventDispatcher:addEventListenerWithSceneGraphPriority(NBombUseResult, self)
end

function SkillNBomb:initUI(propId)
    if propId == FishCD.SKILL_TAG_BOMB then
        return MNBombUI.create(self);
    elseif propId == FishCD.SKILL_TAG_MISSILE then
        return SNBombUI.create(self);
    elseif propId == FishCD.SKILL_TAG_SUPERBOMB then
        return BNBombUI.create(self);
    end
    
end

--初始化精灵
function SkillNBomb:initBg()

    

end

function SkillNBomb:setPropId(propId)
    self.propId = propId

    self.ui = self:initUI(self.propId);
    if propId == FishCD.SKILL_TAG_BOMB then
        self.bombLv = 2
    elseif propId == FishCD.SKILL_TAG_MISSILE then
        self.bombLv = 1
    elseif propId == FishCD.SKILL_TAG_SUPERBOMB then
        self.bombLv = 3
    end
end

--按键按下的处理
function SkillNBomb:clickCallBack()
    self:getParent():getParent():clearAllbomb()
    local useType = self:judgeUseType()
    if useType == nil then
        return
    end
    self.useType = useType
    if useType == 0 then
        self:onChoseState(true)
        self:useNBomb();
    else
        local isNoticeNBombCost = FishGI.isNoticeNBombCost
        if isNoticeNBombCost then
            local function callback(sender)
                local tag = sender:getTag()
                if tag == 2 then
                    self:onChoseState(true)
                    self:useNBomb();
                    FishGI.isNoticeNBombCost = isNoticeNBombCost
                elseif tag == 4 then
                    isNoticeNBombCost = not isNoticeNBombCost
                    sender:getChildByName("spr_hook"):setVisible(not isNoticeNBombCost)
                end
            end
            local str = FishGF.getChByIndex(800000110);
            FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE_HOOK,str,callback)
            return
        else
            self:onChoseState(true)
            self:useNBomb();
        end
    end
end

--按键是否进入选择状态
function SkillNBomb:onChoseState(islight)
    self.btn:setTouchEnabled(not islight)
    if islight then
        self.btn.parentClasss:setState(1)
    else
        self.btn.parentClasss:setState(0)
    end
end

--进入选择状态
function SkillNBomb:useNBomb()
    self.isChose = true

    self.ui:readyLaunch();
end

--取消选择核弹
function SkillNBomb:cancelUseNBomb()
    self.isChose = false
    
    self.ui:cancelLaunch();
end

--马上取消选择核弹
function SkillNBomb:clearUseNBomb()
    self:cancelUseNBomb()
    self:onChoseState(false)
end

function SkillNBomb:onTouchBegan(touch, event) 
    if self.isChose == false then
        return false
    end
    local touchBeginPos = touch:getLocation()

    local size = self.btn:getContentSize()
    local locationInNode = self.btn:convertToNodeSpace(touchBeginPos)
    local rect = cc.rect(0,0,size.width,size.height)
    if cc.rectContainsPoint(rect,locationInNode) then
        print("-----取消")
        self:cancelUseNBomb();
        self:onChoseState(false)
        return true
    end

    local isTouchBtn = self:getParent():getParent():isTouchBtn(touch)
    if isTouchBtn then
        return true
    end

    FishGI.AudioControl:playEffect("sound/lock_01.mp3")
    
    --适配成1280, 720的位置
    local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale()
    touchBeginPos.x = touchBeginPos.x/scaleX_;
    touchBeginPos.y = touchBeginPos.y/scaleY_
    print("------------prop id:"..self.propId)
    local data = {}
    data.touchBeginPos = touchBeginPos
    data.nPropID = self.propId
    data.useType = self.useType
    data.sendType = "sendNBomb"
    self:sendNetMessage(data)
    
    local function callback( ... )
        print("---local function callback----")
        self:onChoseState(false)
    end
    self:onChoseState(true)
    self:runTimer(callback)

    self:cancelUseNBomb()

    return true
end

function SkillNBomb:onTouchCancelled(touch, event) 

end

--收到申请核弹结果
function SkillNBomb:NBombUseResult(data)
    local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale();
    local data = data._usedata
    if self.propId ~= data.nPropID then
        return
    end
    dump(data);
    if data.isSuccess ~= true then
        self:stopTimer()
        self:onChoseState(false)
        print("---NBombUseResult---isSuccess=failureId")
        return;
    end
    local chairId = FishGI.gameScene.playerManager:getPlayerChairId(data.playerId);
    local dataValue = data;
    dataValue.chairId = chairId;

    --修改鱼币水晶
    local useType = data.useType
    self.playerSelf = FishGI.gameScene.playerManager:getMyData()
    if self.playerSelf == nil then
        return;
    end
    local myPlayerId = self.playerSelf.playerInfo.playerId
    if  data.isSuccess and data.playerId == myPlayerId then
        self:pushDataToPool(useType)
    end

    local function delayKillFishes(param)
        if param.chairId == FishGI.gameScene.playerManager:getMyChairId() then
            local touchBeginPos = cc.p(param.pointX*scaleX_, param.pointY*scaleY_);
            local fishesTab = LuaCppAdapter:getInstance():getNBombKilledFishes(self.bombLv, touchBeginPos);
            local data = {}
            data.sendType = "sendNBombBalst"
            data.nBombId = param.nBombId
            data.fishesTab = fishesTab
            self:sendNetMessage(data)
            --FishGI.gameScene.net:sendNBombBalst(param.nBombId, fishesTab);
        end
    end

    --坐标适配
    
    local pos = cc.p(data.pointX*scaleX_, data.pointY*scaleY_);
    if FishGI.gameScene.playerManager:isAcross(FishGI.gameScene.playerManager:getMyChairId(), chairId) then
        self:launchNBomb(cc.p(FishCD.WIN_SIZE.width-pos.x, FishCD.WIN_SIZE.height-pos.y), delayKillFishes, data);
    else
        self:launchNBomb(pos, delayKillFishes, data);
    end

    if chairId == FishGI.gameScene.playerManager:getMyChairId() then
        local newNBombRate = data.newNBombRate;
        FishGI.eventDispatcher:dispatch("UpdateNBombRate", newNBombRate)
    end
end

--投放核弹           pos 是基于1280 720的坐标
function SkillNBomb:launchNBomb(pos, killCallFunc, dataValue)
    
    
    self.ui:launch(pos, killCallFunc, dataValue);
    
end

return SkillNBomb;