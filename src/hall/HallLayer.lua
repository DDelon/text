
local HallLayer = class("HallLayer", cc.load("mvc").ViewBase)
--local netMsgTab = require("Other.NetMsgType")

HallLayer.AUTO_RESOLUTION   = true
HallLayer.RESOURCE_FILENAME = "ui/hall/uiHallLayer"
HallLayer.RESOURCE_BINDING  = {
    ["spr_hall_bg"]        = { ["varname"] = "spr_hall_bg"  },
    ["node_bg"]            = { ["varname"] = "node_bg"  },
    
    ["node_msw"]           = { ["varname"] = "node_msw"} , 
    ["node_righttop_btn"]  = { ["varname"] = "node_righttop_btn"} ,    
    ["image_option_bg"]    = { ["varname"] = "image_option_bg"  },    
    ["btn_option"]         = { ["varname"] = "btn_option" ,         ["events"]={["event"]="click",["method"]="onClickoption"}}, 
    ["btn_option_exit"]    = { ["varname"] = "btn_option_exit" ,    ["events"]={["event"]="click",["method"]="onClickexit"}}, 
    ["btn_option_service"] = { ["varname"] = "btn_option_service" , ["events"]={["event"]="click",["method"]="onClickservice"}}, 
    ["btn_mail"]           = { ["varname"] = "btn_mail" ,           ["events"]={["event"]="click",["method"]="onClickmail"}}, 
    
    
    ["image_coin_bg"]      = { ["varname"] = "image_coin_bg" }, 
    ["image_diamond_bg"]   = { ["varname"] = "image_diamond_bg" }, 
    ["btn_addcoin"]        = { ["varname"] = "btn_addcoin" ,        ["events"]={["event"]="click",["method"]="onClickcoin"}},
    ["btn_adddiamond"]     = { ["varname"] = "btn_adddiamond" ,     ["events"]={["event"]="click",["method"]="onClickdiamond"}},
    ["fnt_coin"]           = { ["varname"] = "fnt_coin"  },   
    ["fnt_diamond"]        = { ["varname"] = "fnt_diamond"  }, 
    
    ["spr_player_bg"]      = { ["varname"] = "spr_player_bg"  }, 
    ["spr_vip"]            = { ["varname"] = "spr_vip"  },    
    ["text_name"]          = { ["varname"] = "text_name"  },
    ["spr_player_photo"]   = { ["varname"] = "spr_player_photo"  },
    ["btn_player_head_bg"] = { ["varname"] = "btn_player_head_bg" , ["events"]={["event"]="click",["method"]="onClickplayerhead"}}, 
    ["fnt_vipnum"]         = { ["varname"] = "fnt_vipnum"  },
    ["spr_head_edge"]      = { ["varname"] = "spr_head_edge"  },	
    
    ["text_word"]          = { ["varname"] = "text_word"  }, 
    ["image_bg"]           = { ["varname"] = "image_bg"  }, 

}

--背包     = node_btn_1
--任务     = node_btn_2
--签到     = node_btn_3
--排行榜   = node_btn_4
--vip转盘  = node_btn_5
--救济金   = node_btn_6
--锻造     = node_btn_7

--vip特权  = node_btn_8
--月卡     = node_btn_9
--商店     = node_btn_10
--朋友场   = node_btn_11
--赛狗     = node_btn_12

--按键 --用于更换按键图片和绑定函数
HallLayer.HALL_BTN_ARR   = {
    ["node_btn_1"]  = { ["varname"] = "node_btn_1" ,["filename"] = "hall_btn_bag" ,["events"]={["event"]="click",["method"]="onClickbag"}}, 
    ["node_btn_3"]  = { ["varname"] = "node_btn_3" ,["filename"] = "hall_btn_mrqd" , ["events"]={["event"]="click",["method"]="onClickcheck"}}, 
    ["node_btn_4"]  = { ["varname"] = "node_btn_4" ,["filename"] = "hall_btn_phb" , ["events"]={["event"]="click",["method"]="onClickrank"}}, 
    ["node_btn_5"]  = { ["varname"] = "node_btn_5" ,["filename"] = "hall_btn_dailvip" , ["events"]={["event"]="click",["method"]="onClickdailvip"}}, 
    ["node_btn_6"]  = { ["varname"] = "node_btn_6" ,["filename"] = "hall_btn_jjj" , ["events"]={["event"]="click",["method"]="onClickAlm"}}, 
    ["node_btn_7"]  = { ["varname"] = "node_btn_7" ,["filename"] = "hall_btn_dz" , ["events"]={["event"]="click",["method"]="onClickdz"}}, 
    ["node_btn_8"]  = { ["varname"] = "node_btn_8" ,["filename"] = "hall_btn_vip" , ["events"]={["event"]="click",["method"]="onClickvip"}}, 
    ["node_btn_9"]  = { ["varname"] = "node_btn_9" ,["filename"] = "hall_btn_yklb" , ["events"]={["event"]="click",["method"]="onClickYklb"}}, 
    ["node_btn_10"] = { ["varname"] = "node_btn_10" ,["filename"]= "hall_btn_shop" , ["events"]={["event"]="click",["method"]="onClickshop"}}, 
    ["node_btn_2"]  = { ["varname"] = "node_btn_2" ,["filename"]= "hall_btn_rcrw" , ["events"]={["event"]="click",["method"]="onClicktask"}}, 
    ["node_btn_11"] = { ["varname"] = "node_btn_11" ,["filename"]= "hall_btn_pyc" , ["events"]={["event"]="click",["method"]="onClickfriend"}}, 
    ["node_btn_12"] = { ["varname"] = "node_btn_12" ,["filename"]= "hall_btn_game_1" , ["events"]={["event"]="click",["method"]="onClickgame1"}}, 
}

--根据key值排序，更新底部按键位置 
HallLayer.HALL_DOWN_BTN  = {
    [1]  = { ["varname"] = "node_btn_1"}, 
    [2]  = { ["varname"] = "node_btn_4"}, 
    [3]  = { ["varname"] = "node_btn_5"},
    [4]  = { ["varname"] = "node_btn_3"}, 
    [5]  = { ["varname"] = "node_btn_2"}, 
    [6]  = { ["varname"] = "node_btn_7"},   
    [7]  = { ["varname"] = "node_btn_11"}, 
    [8]  = { ["varname"] = "node_btn_12"},   
}

--左边的按键
HallLayer.HALL_LEFT_BTN  = {
    [1]  = { ["varname"] = "node_btn_8"}, 
    [2]  = { ["varname"] = "node_btn_9"}, 
    [3]  = { ["varname"] = "node_btn_10"},   
}


function HallLayer:onCreate( ... )
    self:runAction(self.resourceNode_["animation"])
    self.resourceNode_["animation"]:play("wave_act", true);
    
    self.isOpen = false
    self:initBg()
    self:initBtnArr()
    self:setOptionIsOpen(false)

    -- 头像裁剪
    local size = self.btn_player_head_bg:getContentSize();
    local node = FishGF.GetClippNode(cc.rect(0, 0, size.width, size.width), size.width / 2);
    self.spr_player_bg:addChild(node);
    self.spr_player_photo:setVisible(false)
    node:setPosition(cc.p(self.btn_player_head_bg:getPositionX(),self.btn_player_head_bg:getPositionY()))
    --头像
    self.mFigure = ccui.ImageView:create("common/com_pic_photo_1.png");
    self.mFigure:setContentSize(cc.size(size.width, size.width));
    self.mFigure:setAnchorPoint(cc.p(0, 0));
    self.mFigure:setPosition(cc.p(0, 0));
    node:addChild(self.mFigure, 1, 25);
    --node:setScale(self.scaleMin_)
    self.spr_head_edge:setLocalZOrder(node:getLocalZOrder() + 1)

    self:openTouchEventListener()
end

--初始化背景
function HallLayer:initBg()

    --播放粒子特效文件1  
    local emitter1 = FishGI.GameEffect.createBubble(1) 
    emitter1:setPosition(cc.p(139.52*self.scaleX_,-13.92*self.scaleY_))
    self.node_bg:addChild(emitter1,0)  

    --播放粒子特效文件2
    local emitter2 = FishGI.GameEffect.createBubble(1) 
    emitter2:setPosition(cc.p(967.39*self.scaleX_,-35.27*self.scaleY_))
    self.node_bg:addChild(emitter2,0)

end

--初始化按键
function HallLayer:initBtnArr()
    self.image_option_bg:setVisible(false)
    self.image_coin_bg:setScale(self.scaleMin_)
    self.image_diamond_bg:setScale(self.scaleMin_)
    self.spr_player_bg:setScale(self.scaleMin_)
    self.node_righttop_btn:setScale(self.scaleMin_)
    self.node_righttop_btn:setLocalZOrder(20)

    self.btn_msw = self.node_msw:getChildByName("btn_msw")
    self.btn_msw:onClickScaleEffect(handler(self,self.onClickmsw))
    self.node_msw.animation:play("msw_light", true);
    self.node_msw:setScale(self.scaleMin_)

    local btnCount = 0
    --绑定按键和更换按键图片
    for key,val in pairs(self.HALL_BTN_ARR) do
        local node_btn = self.resourceNode_[key]
        if val.varname and node_btn then
           self[val.varname] = node_btn
        end
        if node_btn ~= nil then
            btnCount = btnCount + 1
            local btn = node_btn:getChildByName("btn")
            btn:loadTextureNormal("hall/btn/"..val.filename..".png",0)
            btn:loadTexturePressed("hall/btn/"..val.filename..".png",0)
            btn:loadTextureDisabled("hall/btn/"..val.filename..".png",0)
            btn:onClickDarkEffect(handler(self,self[val.events.method]))
            node_btn:setScale(self.scaleMin_)
        end
    end

    for i=1,btnCount do
        self:setBtnIsLight(i,false)
    end

    --添加底部按键
    self.downBtnArr = {}
    for key,val in pairs(self.HALL_DOWN_BTN) do
        self.downBtnArr[tonumber(key)] = self[val.varname]
    end
    self["node_btn_7"]:setVisible(false)

    --救济金
    self:initAlm();
    
    self:upDataBtnArrPos()

end

--更新按键位置
function HallLayer:upDataBtnArrPos()
    FishGF.UpdataWechat()
    local count = 0
    for i=1,#self.downBtnArr do
        local node_btn = self.downBtnArr[i]
        if node_btn:isVisible() then
            node_btn:setPositionX((64+count * 118)*self.scaleX_)
            count = count + 1
        end
    end
end

--设置按键是否跳动和亮光圈
function HallLayer:setBtnIsLight(btnId,isLight)  
    local strname = string.format("node_btn_%d",btnId)
    local node_btn = self[strname]
    local btn = node_btn:getChildByName("btn")
    local light = node_btn:getChildByName("spr_light")
    if isLight then
        node_btn:setLocalZOrder(15)
        light:setVisible(true)
        light:runAction(cc.RepeatForever:create(cc.RotateBy:create(1,FishCD.LIGHT_SPEED)))
        node_btn["animation"]:play("jump", true);
    else
        node_btn:setLocalZOrder(3)
        light:stopAllActions()
        light:setVisible(false)
        node_btn["animation"]:play("nojump", false);
    end
end

function HallLayer:openAlmCountDown(seconds)
    self.node_btn_6:setVisible(true);
    local btn = self.node_btn_6:getChildByName("btn")
    btn:setTouchEnabled(false);
    btn:setBright(false);

    local image_bg = self.node_btn_6:getChildByName("image_bg")
    local text_word = image_bg:getChildByName("text_word")
    image_bg:setVisible(true);
    local time = FishGF.getFormatTimeBySeconds(seconds)
    text_word:setString(time);
    local function delayFunc()
        if seconds <= 0 then
            self:canReceiveAlm();
            text_word:stopAllActions()
        else
            seconds = seconds-1;
            text_word:setString(FishGF.getFormatTimeBySeconds(seconds));
        end
    end
    local act = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(delayFunc)));
    act:setTag(11011)
    text_word:stopActionByTag(11011)
    text_word:runAction(act);
end

function HallLayer:canReceiveAlm()
    self.node_btn_6:setVisible(true);
    self:setBtnIsLight(FishCD.HALL_BTN_6,true)
    local btn = self.node_btn_6:getChildByName("btn")
    btn:setTouchEnabled(true);
    local image_bg = self.node_btn_6:getChildByName("image_bg")
    local text_word = image_bg:getChildByName("text_word")
    image_bg:setVisible(false);
end

function HallLayer:initAlm()
    self.node_btn_6:setVisible(false);
    self:setBtnIsLight(FishCD.HALL_BTN_6,false)
    local image_bg = self.node_btn_6:getChildByName("image_bg")
    local text_word = image_bg:getChildByName("text_word")
    text_word:stopAllActions()
end

function HallLayer:isAlmRunning()
    return self.node_btn_6:isVisible();
end

function HallLayer:onTouchBegan(touch, event)
    self:setOptionIsOpen(false)
    return false  
end

--设置右上角按键收取或打开
function HallLayer:setOptionIsOpen( isOpen )
    print("-setOptionIsOpen-----")
    self.isOpen = isOpen
    if self.isOpen then
        self.image_option_bg:setVisible(true)
        self.btn_option:setRotation(180)
    else
        self.image_option_bg:setVisible(false)
        self.btn_option:setRotation(0)
    end

    local redDot = self.node_righttop_btn:getChildByName("spr_dot")
    local isNew = self.btn_option["isNew"]
    if isNew~= nil and isNew == true and not self.isOpen then
        redDot:setVisible(true)
    else
        redDot:setVisible(false)
    end

end

------------------------------------------------------------------------------------------------------
-----------------------------------------------按键回调-----------------------------------------------
------------------------------------------------------------------------------------------------------

function HallLayer:onClickexit( sender )
    self.parent_:buttonClicked("HallLayer", "exit")
end

function HallLayer:onClickdz( sender )
    FishGI.hallScene.uiForgedLayer:showLayer() 
end

function HallLayer:onClickplayerhead( sender )
    FishGI.myData.isActivited = FishGI.WebUserData:isActivited()
    FishGI.myData.isBindPhone = FishGI.WebUserData:isBindPhone()
    FishGI.hallScene.uiPlayerInfo:upDataBtnState(FishGI.myData.isActivited,FishGI.myData.isBindPhone )
    FishGI.hallScene.uiPlayerInfo:showLayer() 
end

function HallLayer:onClickYklb( sender )
    FishGI.hallScene.uiMonthcard:showLayer() 
end

function HallLayer:onClickbag( sender )
    FishGI.hallScene.uiBagLayer:showLayer() 
end

function HallLayer:onClickvip( sender )
    FishGI.hallScene.uiVipRight:upDataLayerByMyVIPLV()
    FishGI.hallScene.uiVipRight:showLayer()
end

function HallLayer:onClickshop( sender )
    FishGI.hallScene.uiShopLayer:showLayer() 
    FishGI.hallScene.uiShopLayer:setShopType(1)
end

function HallLayer:onClickmsw( sender )
    FishGI.hallScene.uiAllRoomView:fastStartGame()
end

function HallLayer:onClickdailvip( sender )
    if FishGI.myData.vip_level > 0 then
        if FishGI.hallScene.uiDialVIP ~= nil then
            FishGI.hallScene.uiDialVIP:initDialAge()
            FishGI.hallScene.uiDialVIP:showLayer()
        end
    else
        FishGF.showSystemTip(nil,800000173,1.5);
    end
end

function HallLayer:onClickoption( sender )
    self.isOpen = not self.isOpen
    self:setOptionIsOpen(self.isOpen)
end

--客服
function HallLayer:onClickservice( sender )
    print("-onClickservice-----")
    local function callback(data)
        local url = data.url;
        cc.Application:getInstance():openURL(url);
    end
    FishGI.Dapi:feedBackUrl(callback)



end

function HallLayer:onClickcoin( sender )
    FishGI.hallScene.uiShopLayer:showLayer() 
    FishGI.hallScene.uiShopLayer:setShopType(1)
end

function HallLayer:onClickdiamond( sender )
    FishGI.hallScene.uiShopLayer:showLayer() 
    FishGI.hallScene.uiShopLayer:setShopType(2)
end

function HallLayer:onClickAlm( sender )
    FishGI.hallScene.net.roommanager:sendApplyAlm();
end

function HallLayer:onClickcheck( sender )
    FishGI.hallScene.uiCheck:showLayer() 
end

function HallLayer:onClickrank( sender )
    FishGF.openRankWeb("https://userapi-fish.weile.com/fish/rank/", FishGI.hallScene);
end

function HallLayer:onClickshare( sender )
    FishGI.hallScene.uiWeChatShare:showLayer() 
end

function HallLayer:onClickmail( sender )
    print("-----HallLayer:onClickmail-------")
    FishGI.hallScene.uiMail:showLayer() 
    FishGI.hallScene.uiMail:closeAllSchedule()
    FishGI.hallScene.uiMail:upDataMailList()

end

function HallLayer:onClicktask( sender )
    print("-----HallLayer:onClicktask-------")
    FishGI.hallScene.taskPanel:onClickShow()
end

function HallLayer:onClickfriend( sender )
    print("-----HallLayer:onClickfriend-------")
        --朋友场
    if FishGI.hallScene.uiAllRoomView:isFriendCanOpen() then
        FishGI.hallScene:setIsToFriendRoom(true)
    else
        FishGF.showToast(FishGF.getChByIndex(800000298))
    end
end

function HallLayer:onClickgame1( sender )
    print("-----HallLayer:onClickgame1-------")
    FishGF.checkUpdate("gtsp")
end

--设置是否返回大厅
function HallLayer:setIsCurShow( isShow )
    if isShow == self.isShow then
        return
    end

    FishGF.setNodeIsShow(self.node_righttop_btn,"right",isShow)
    FishGF.setNodeIsShow(self.node_msw,"down",isShow)

    for k,v in pairs(self.HALL_DOWN_BTN) do
        local name = v.varname
        FishGF.setNodeIsShow(self[name],"down",isShow)
    end

    for k,v in pairs(self.HALL_LEFT_BTN) do
        local name = v.varname
        FishGF.setNodeIsShow(self[name],"left",isShow)
    end
    self.isShow = isShow

end

--得到按键位置
function HallLayer:getBtnPosByIndex( index )
    local node_btn = self["node_btn_"..index]
    local pos = {}
    pos.x = node_btn:getPositionX()
    pos.y = node_btn:getPositionY()
    print("-------node_btn------pos.x="..pos.x.."---------pos.y="..pos.y)
    return pos
end

return HallLayer;