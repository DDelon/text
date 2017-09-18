
local Check = class("Check", cc.load("mvc").ViewBase)

Check.AUTO_RESOLUTION   = false
Check.RESOURCE_FILENAME = "ui/hall/check/uicheck"
Check.RESOURCE_BINDING  = {  
    ["panel"]            = { ["varname"] = "panel" },
    ["btn_close"]        = { ["varname"] = "btn_close" ,         ["events"]={["event"]="click",["method"]="onClickClose"}},   
    ["btn_check"]        = { ["varname"] = "btn_check" ,         ["events"]={["event"]="click",["method"]="onClickCheck"}},   
    
    ["image_next"]       = { ["varname"] = "image_next" },
    
    ["fnt_curpercent"]   = { ["varname"] = "fnt_curpercent" }, 
    
    ["image_allstar_bg"] = { ["varname"] = "image_allstar_bg" },      
    ["spr_star"]         = { ["varname"] = "spr_star" },  

}


function Check:onCreate( ... )
    --初始化
    self:init()

end

--游戏初始化
function Check:init()
    --奖品数据
    local checkAward = tostring(FishGI.GameConfig:getConfigData("config", tostring(990000040), "data"));
    self.awardTab = FishGF.strToVec3(checkAward..";")

    --初始化星星
    self.dayNum = tonumber(FishGI.GameConfig:getConfigData("config", tostring(990000045), "data"));
    for i=1,self.dayNum do
        local node = self.image_allstar_bg:getChildByName("node_star_"..i)
        self:setNodeisCheck(node,false)
        local node_box = node:getChildByName("node_box")
        if node_box ~= nil then
            local btn_lookaward = node_box:getChildByName("panel"):getChildByName("btn_lookaward")
            local node_award = node_box:getChildByName("panel"):getChildByName("node_award")
            local text_award = node_award:getChildByName("text_award")
            local image_award_bg = node_award:getChildByName("image_award_bg")
            if i < 24 then
                text_award:setScale(1/0.85)
                image_award_bg:setScale(1/0.85)
            end
            local str = nil
            for k,val in pairs(self.awardTab) do
                if i == val.x then
                    str = FishGF.getChByIndex(800000113)..val.z..FishGF.getPropUnitByID(val.y)
                    text_award:setString(str)
                    node_box["propId"] = val.y
                    break
                end
            end
            node_award:setVisible(false)
            local function callback( sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    node_award:stopAllActions()
                    node_award:runAction(cc.Sequence:create(cc.Show:create(),cc.DelayTime:create(1.5),cc.Hide:create()))
                end
            end
            btn_lookaward:addTouchEventListener(callback)
        end
    end

    self.starPosX = self.spr_star:getPositionX()
    self.starPosY = self.spr_star:getPositionY()
    self:setSignInDays(0)

    --添加触摸监听
    self:openTouchEventListener()
    
    self:setCurCheck(0)
end

function Check:onTouchBegan(touch, event)
    if self:isVisible() then
         return true  
    end

    return false
end

function Check:onClickClose( sender )
    self:hideLayer()
end

--设置总的签到日期
function Check:setCurCheck(signInDays)
--    print("---------signInDays="..signInDays)
    if self.dayNum < signInDays or signInDays < 0 then
        return
    end
    self:setSignInDays(signInDays)

    for i=1,self.dayNum do
        local node = self.image_allstar_bg:getChildByName("node_star_"..i)
        if i <= signInDays then
            self:setNodeisCheck(node,true,i)
        else
            self:setNodeisCheck(node,false,i)
        end
        
    end
    
end

--设置该签到星星是否已签到
function Check:setNodeisCheck(node,isCheck,days)
    local image_line = node:getChildByName("image_line")
    local btn_star = node:getChildByName("btn_star")
    local node_box = node:getChildByName("node_box")
    if isCheck then
        image_line:setColor(cc.c3b(21,17,198))
        btn_star:setBright(true)
    else
        image_line:setColor(cc.c3b(255,255,255))
        btn_star:setBright(false)
    end

    if node_box ~= nil then
        local light = node_box:getChildByName("panel"):getChildByName("spr_light")
        local spr_box_open = node_box:getChildByName("panel"):getChildByName("spr_box_open")
        local spr_prop_1 = node_box:getChildByName("panel"):getChildByName("spr_prop_1")
        local spr_prop_2 = node_box:getChildByName("panel"):getChildByName("spr_prop_2")
        spr_prop_1:setVisible(false)
        spr_prop_2:setVisible(false)
        if isCheck then
            local spr_prop = node_box:getChildByName("panel"):getChildByName("spr_prop_"..node_box["propId"])
            spr_prop:setVisible(true)
            if days ~= nil and days == self.dayNum then
                node_box.animation:play("bigbx", false)
            else
                node_box.animation:play("open_prop_1", false)
            end
            light:stopAllActions()
            light:setVisible(false)
        else
            local isShake = false
            if self.hasSignToday == false and self.signInDays + 1 == days then
                isShake = true
            end
            if days ~= nil and days == self.dayNum then
                if isShake then
                    node_box.animation:play("bigbxdd", true)
                else
                    node_box.animation:play("close_big_prop", false)
                end 
            else
                if isShake then
                    node_box.animation:play("bxdd", true)
                else
                    node_box.animation:play("colse", false)
                end
            end

            light:runAction(cc.RepeatForever:create(cc.RotateBy:create(1,FishCD.LIGHT_SPEED)))
            light:setVisible(true)
        end
    end
end

--签到回调
function Check:onClickCheck( sender )
    self:setIsChexk(true)
    FishGI.hallScene.net.roommanager:sendSignIn();
end

--设置按键--是否签到
function Check:setIsChexk( isCheck )
    local spr_word_check = self.btn_check:getChildByName("spr_word_check")
    local spr_word_yqd = self.btn_check:getChildByName("spr_word_yqd")

    if isCheck then
        self.btn_check:setEnabled(false)
        --self.btn_check:setBright(false)
        spr_word_check:setVisible(false)
        spr_word_yqd:setVisible(true)
    else
        self.btn_check:setEnabled(true)
        --self.btn_check:setBright(true)
        spr_word_check:setVisible(true)
        spr_word_yqd:setVisible(false)
    end

end

--开始签到动画
function Check:checkToday( data )
    local newSignInDays = data.newSignInDays
    if self.dayNum < newSignInDays or newSignInDays < 0 then
        return
    end

    local props = data.props
    local seniorProps = data.seniorProps
    local propId = data.propId
    local propCount = data.propCount

    for k,val in pairs(data.props) do
        if val ~= nil and val.propId ~= nil then
            FishGMF.addTrueAndFlyProp(FishGI.myData.playerId,val.propId,val.propCount,false)
            FishGMF.setAddFlyProp(FishGI.myData.playerId,val.propId,val.propCount,false)
        end
    end

    for k,val in pairs(data.seniorProps) do
        if val ~= nil and val.propId ~= nil then
            FishGMF.refreshSeniorPropData(FishGI.myData.playerId,val,8,0)
        end
    end

    local nodeStar = self.image_allstar_bg:getChildByName("node_star_"..newSignInDays)
    local moveto = cc.MoveTo:create(0.5,cc.p(nodeStar:getPositionX(),nodeStar:getPositionY()))
    local callFun = cc.CallFunc:create(function ( ... )
        FishGI.AudioControl:playEffect("sound/getprop_01.mp3")
        self:setNodeisCheck(nodeStar,true,newSignInDays)
        self:setSignInDays(self.signInDays + 1)
        if propCount ~= nil and propCount >0 then
            FishGI.AudioControl:playEffect("sound/congrat_01.mp3",false)
            local message = FishGF.getChByIndex(800000075)..propCount..FishGF.getPropUnitByID(propId)
            FishGF.showSystemTip(message,nil,2)
            self.spr_star:setVisible(false)
            
            --播放特效
            for k,val in pairs(props) do
                local propTab = {}
                propTab.playerId = FishGI.myData.playerId
                propTab.propId = val.propId
                propTab.propCount = val.propCount
                propTab.isRefreshData = true
                propTab.isJump = true
                propTab.firstPos = self:getFirstPos(nodeStar)
                propTab.dropType = "normal"
                propTab.isShowCount = false
                FishGI.GameEffect:playDropProp(propTab)
            end

            for k,val in pairs(seniorProps) do
                local propTab = {}
                propTab.playerId = FishGI.myData.playerId
                propTab.propId = val.propId
                propTab.propCount = 1
                propTab.isRefreshData = true
                propTab.isJump = true
                propTab.firstPos = self:getFirstPos(nodeStar)
                propTab.dropType = "normal"
                propTab.isShowCount = false
                propTab.seniorPropData = val
                FishGI.GameEffect:playDropProp(propTab)
            end

        else
            self.spr_star:setOpacity(0)
            local time = 0.8
            local swq = cc.Spawn:create(cc.ScaleTo:create(time,1.4),cc.FadeTo:create(time,255))
            local swq2 = cc.Spawn:create(cc.ScaleTo:create(time,1.7),cc.FadeTo:create(time,0))
            local seq2 = cc.Sequence:create(swq,swq2)
            self.spr_star:runAction(seq2)
        end
    end)
    local seq = cc.Sequence:create(moveto,callFun)
    local speedAct = cc.EaseSineOut:create(seq)
    self.spr_star:setOpacity(255)
    self.spr_star:runAction(speedAct)

end

--得到飞行道具的初始位置
function Check:getFirstPos( nodeStar )
    local child = nodeStar
    if child == nil then
        return nil
    end 
    local pos = cc.p(child:getPositionX(),child:getPositionY())
    pos = self.image_allstar_bg:convertToWorldSpace(pos)

    return pos
end

--设置签到天数，并更新底部信息
function Check:setSignInDays( signInDays )
    self.signInDays = signInDays
    local str = self.signInDays.."&"..self.dayNum
    self.fnt_curpercent:setString(str)
    local nextAward = nil
    for k,val in ipairs(self.awardTab) do
        if signInDays < val.x then
            nextAward = val
            break
        end
    end

    if nextAward ~= nil then
        self.image_next:setVisible(true)
        local spr_prop = self.image_next:getChildByName("spr_prop")
        local filename = string.format("hall/hall_pic_prop_%d.png",nextAward.y)
        spr_prop:initWithFile(filename)

        local fnt_nextaward = self.image_next:getChildByName("fnt_nextaward")
        fnt_nextaward:setString(nextAward.z)
    else
        self.image_next:setVisible(false)
    end

end

--初始接收玩家消息
function Check:receiveData( data )
    local hasSignToday = data.hasSignToday
    local signInDays = data.signInDays
    self.hasSignToday = hasSignToday
    self:setCurCheck(signInDays)
    self:setIsChexk(hasSignToday)
    self.spr_star:setVisible(not hasSignToday)
end

--签到结果
function Check:receiveCheckData( data )
    local isSuccess = data.isSuccess
    local propId = 0
    local propCount = 0
    for k,val in pairs(data.props) do
        if val ~= nil and val.propId ~= nil then
            propId = val.propId
            propCount = val.propCount
        end
    end

    if data.seniorProps == nil then
        data.seniorProps = {}
    end
    for k,val in pairs(data.seniorProps) do
        if val ~= nil and val.propId ~= nil then
            propId = val.propId
            propCount = propCount + 1
        end
    end

    local newSignInDays = data.newSignInDays
    if not isSuccess then
        self:setIsChexk(false)
        return
    end
    self.hasSignToday =true
    data.propId = propId
    data.propCount = propCount
    self:checkToday(data)


end

return Check;