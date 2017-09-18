local Exchange = class("Exchange", cc.load("mvc").ViewBase)

Exchange.AUTO_RESOLUTION   = false
Exchange.RESOURCE_FILENAME = "ui/hall/exchange/uiexchange"
Exchange.RESOURCE_BINDING  = {
    ["panel"]          = { ["varname"] = "panel" },
    ["btn_close"]      = { ["varname"] = "btn_close" ,         ["events"]={["event"]="click",["method"]="onClickclose"}},   
    
    ["tf_phone"]       = { ["varname"] = "tf_phone"  },
    
    ["btn_sure"]       = { ["varname"] = "btn_sure" ,      ["events"]={["event"]="click",["method"]="onClicksure"}},
    
    ["img_count_bg"]   = { ["varname"] = "img_count_bg"  },
    ["text_cur_count"] = { ["varname"] = "text_cur_count"  },
    ["text_aim_count"] = { ["varname"] = "text_aim_count"  },
    
    ["text_money"]     = { ["varname"] = "text_money"  },
    
}

function Exchange:onCreate( ... )
    self.phoneid = nil

    self:initWinEditBox("tf_phone")
    self.tf_phone:setPlaceHolder(FishGF.getChByIndex(800000187))

    self:openTouchEventListener()
    
    local data = tostring(FishGI.GameConfig:getConfigData("config", tostring(990000068), "data"));
    local tab = FishGF.strSplit(data..";", ";")
    if tab ~= nil then
        self.aimCount = tonumber(tab[1])
        self.money = tonumber(tab[2])
        self.text_aim_count:setString("/"..FishGF.changePropUnitByID(FishCD.PROP_TAG_12,self.aimCount,true))
        self.text_money:setString(FishGF.changePropUnitByID(FishCD.PROP_TAG_12,self.money*100,true))
    end
    self.curCount = 0
    self:upDataCountShow()
end
function Exchange:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function Exchange:initEditBoxStr(str)
    self.tf_phone:setString(str);
end

function Exchange:onClickclose( sender )
    self:hideLayer()
end

function Exchange:isCanExChange(  )
    if self.curCount < self.aimCount then
        local str = string.format(FishGF.getChByIndex(800000209), tostring((self.aimCount-self.curCount)/100))
        FishGF.showSystemTip(str,800000209,1)
        return false
    end
    return true
end

function Exchange:onClicksure( sender )
    print("-------Exchange----onClicksure-------")
    local phoneid = self.tf_phone:getString()

    -- 验证
    if FishGF.checkPhone( phoneid ) then
        --发送验证
        print("---Exchange:onClicksure---sendInfo---")
        local function callback(sender)
            local tag = sender:getTag()
            if tag == 2 then
                self.phoneid = phoneid
                local data = {
                    phoneNo = phoneid,
                    appId = APP_ID,
                    appKey = APP_KEY,
                    channelId = CHANNEL_ID,
                    version = table.concat(HALL_APP_VERSION,"."),
                    areaCode = REGION_CODE,
                    token = FishGI.hallScene.net:getSession(),
                }
                FishGI.hallScene.net.roommanager:sendReceivePhoneFare(data)
            end
        end
        local str = string.format(FishGF.getChByIndex(800000211), tostring(phoneid))
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,str,callback)

    end
end

function Exchange:setMyPropCount(showCount)
    self.curCount = showCount
    local countStr = FishGF.changePropUnitByID(FishCD.PROP_TAG_12,showCount,true)
    self.text_cur_count:setString(countStr)
    self:upDataCountShow()
end

function Exchange:upDataCountShow()
    local cur_count_height = self:child("node_money"):getChildByName("img_bg_3"):getContentSize().height
    local cur_count_Width = self.text_cur_count:getContentSize().width
    local aim_count_Width = self.text_aim_count:getContentSize().width
    local all_width = cur_count_Width + aim_count_Width
    self.img_count_bg:setContentSize(cc.size(all_width + 20,cur_count_height))

    local dis = cur_count_Width - all_width/2
    self.text_cur_count:setPositionX(dis)
    self.text_aim_count:setPositionX(dis)

end

--兑换结果
function Exchange:onReceivePhoneFare( data )
    print("-----------self.phoneid="..self.phoneid)
    print("-------Exchange----onReceivePhoneFare-------")
    FishGF.waitNetManager(false,nil,"Exchange")
    if data.success then
        local playerId = FishGI.myData.playerId
        FishGMF.addTrueAndFlyProp(playerId,FishCD.PROP_TAG_12,-self.aimCount,true)

        self:hideLayer()

        --local str = string.format(FishGF.getChByIndex(800000212), tostring(self.phoneid))
        local str = data.errorString
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,str,nil)
        self.phoneid = nil
        
    else
        --local msg = FishGF.getChByIndex(800000141)
        local msg = data.errorString
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,msg,nil)
    end

end


return Exchange;