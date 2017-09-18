cc.exports.FishGF = {}

FishGF.DEBUG = true
FishGF.debugLayer = nil;
function FishGF.print(msg)
    if FishGF.DEBUG then
        LuaCppAdapter:getInstance():debugLog(msg);
    else
        print(msg)
    end
end

--得到登录类型，内网，外网，是否秘籍。。。
function FishGF.getLoginType()
    local dataTab = {}
    dataTab.funName = "getLoginType"
    local loginType = LuaCppAdapter:getInstance():luaUseCppFun(dataTab)["loginType"];
    return tonumber(loginType)
end

function FishGF.HandleLineV(...)
    local args={...}
    -- 线处理
    local winSize = cc.Director:getInstance():getWinSize()
    local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    for _,v in ipairs(args) do
       v:setScaleX( winSize.width / framesize.width  )
    end 
end

--
function FishGF.getHallVerison()
    return table.concat(HALL_WEB_VERSION, ".")
end

function FishGF.spriteToGray(sprite)
    
    local grayvsh = "attribute vec4 a_position; \n attribute vec2 a_texCoord; \n attribute vec4 a_color; \n varying vec4 v_fragmentColor;\n varying vec2 v_texCoord;\n void main(void) \n { \n gl_Position = CC_PMatrix * a_position;\n v_fragmentColor = a_color;\n v_texCoord = a_texCoord;\n }";
    local grayfsh = "varying vec4 v_fragmentColor;\n varying vec2 v_texCoord;\n void main()\n {\n vec4 v_orColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);\n float gray = dot(v_orColor.rgb, vec3(0.099, 0.387, 0.114));\n gl_FragColor = vec4(gray, gray, gray, v_orColor.a);\n }";
    
    local p = cc.GLProgram:createWithByteArrays(grayvsh, grayfsh);
    --local p = cc.GLProgramCache:getInstance():getGLProgram("ShaderUIGrayScale");
    p:link();  
    p:updateUniforms();  
    sprite:setGLProgram(p);
    p:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION);  
    p:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD);  


end

function FishGF.grayToNormal(sprite)
    local p = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP");
    sprite:setGLProgram(p);
end

function FishGF.openRankWeb(url, scene)
    local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale()
    local webLayerColor = cc.Layer:create();
    webLayerColor:setTag(FishCD.TAG.RANK_WEB_TAG)
    scene:addChild(webLayerColor, FishCD.RANK_LAYER);
    local returnBt = ccui.Button:create("hall/rank/rank_btn_top_0.png", "hall/rank/rank_btn_top_1.png");
    
    returnBt:setScale9Enabled(true);
    returnBt:setContentSize(cc.size(100, 46));
    returnBt:setPosition(cc.p(90*scaleX_, (FishCD.BASE_WIN_SIZE.height-28)*scaleY_));
    webLayerColor:addChild(returnBt, 1003);
    local returnTitle = cc.Sprite:create("hall/rank/rank_pic_fh.png");
    returnTitle:setPosition(cc.p(returnBt:getContentSize().width/2, returnBt:getContentSize().height/2+2));
    returnBt:addChild(returnTitle);

    local titleBg = ccui.Scale9Sprite:create("hall/rank/rank_pic_topbg.png");
    titleBg:setContentSize(cc.size(FishCD.BASE_WIN_SIZE.width*scaleX_, 54*scaleY_));
    titleBg:setPosition(cc.p(FishCD.BASE_WIN_SIZE.width*scaleX_/2, FishCD.BASE_WIN_SIZE.height-28));
    webLayerColor:addChild(titleBg, 1002);

    local title = cc.Sprite:create("hall/rank/rank_pic_phb.png");
    title:setPosition(cc.p(titleBg:getContentSize().width/2, titleBg:getContentSize().height/2));
    titleBg:addChild(title);
    webLayerColor:addChild(FishGF.openWebPage(url), 1001);


    local function closeWeb(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            scene:removeChild(webLayerColor);
        end
    end

    returnBt:addTouchEventListener(closeWeb);
end

function FishGF.openWebPage(url)
    local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale()
    local webview = ccexp.WebView:create();
    local size = cc.size(FishCD.BASE_WIN_SIZE.width*scaleX_, (FishCD.BASE_WIN_SIZE.height-54)*scaleY_)
    
    webview:setScalesPageToFit(true);
    webview:loadURL(url);
    webview:setContentSize(size);
    webview:setPosition(cc.p(FishCD.WIN_SIZE.width/2, FishCD.WIN_SIZE.height/2-27));
    return webview;

    
end

function FishGF.ClassEx(clsname,fncreate)
    local cls;
    local function _create() 
        local obj = fncreate();
        for k,v in pairs(cls) do
            obj[k] = v;
        end
        return obj;
    end
    cls = class(clsname, _create)
    return cls;
end

function FishGF.setLodingEnd()
    FishGI.loading_sp = 2
    FishGI.isloadingEnd = true
end

--得到当前应该缩放的比例
function FishGF.getCurScale()
    local scaleX_ = 1
    local scaleY_ = 1
    local scaleMin_ = 0   
    local cfg_ds= CC_DESIGN_RESOLUTION
    if cfg_ds.autoscale == "FIXED_WIDTH" then
        scaleY_= display.height/cfg_ds.height
    elseif cfg_ds.autoscale == "FIXED_HEIGHT" then
        scaleX_= display.width/cfg_ds.width
    end
    
    scaleMin_ = scaleX_
    if scaleMin_ > scaleY_ then
        scaleMin_ = scaleY_
    end

    return scaleX_,scaleY_,scaleMin_
end

--转换到1280*760下的角度
function FishGF.getStandardAngle(angle)
    local StandardAngle = nil
    local cfg_ds= CC_DESIGN_RESOLUTION
    if cfg_ds.autoscale == "FIXED_WIDTH" then
        local scaleY_= display.height/cfg_ds.height
        StandardAngle = math.deg(math.atan(math.tan(math.rad(angle))/scaleY_))  
    elseif cfg_ds.autoscale == "FIXED_HEIGHT" then
        local scaleX_= display.width/cfg_ds.width   
        StandardAngle = math.deg(math.atan(math.tan(math.rad(angle))*scaleX_))  
    end 
    if angle > 90 then
        StandardAngle = 180 + StandardAngle
    end

    return StandardAngle
end

--转换到当前分辨率下的角度
function FishGF.getCustomAngle(angle)
    local angle = tonumber(angle)
    local CustomAngle = nil
    local cfg_ds= CC_DESIGN_RESOLUTION
    if cfg_ds.autoscale == "FIXED_WIDTH" then
        local scaleY_= display.height/cfg_ds.height
        CustomAngle = math.deg(math.atan(math.tan(math.rad(angle))*scaleY_))  
    elseif cfg_ds.autoscale == "FIXED_HEIGHT" then
        local scaleX_= display.width/cfg_ds.width   
        CustomAngle = math.deg(math.atan(math.tan(math.rad(angle))/scaleX_))  
    end 
    if angle > 90 then
        CustomAngle = 180 + CustomAngle
    end

    return CustomAngle
end

--设置当前登录的账号
function FishGF.setAccountAndPassword(account,password,isVisitor)
    FishGI.account = account;
    FishGI.password = password;
    FishGI.isVisitor = isVisitor
end

function FishGF.getAccountAndPassword()
    return (FishGI.account),(FishGI.password),(FishGI.isVisitor)
end

--通过索引得到中文
function FishGF.getChByIndex(index)
    return FishGI.GameConfig:getLanguageFromBin("language", index);
end

--通过id得到道具的中文单位
function FishGF.getPropUnitByID(ID,isCh)
    local str = "" 
    if ID == 1 then
        str = FishGF.getChByIndex(800000098)
    elseif ID == 2 then
        str = FishGF.getChByIndex(800000099)
    elseif ID == 12 then
        if isCh == nil or isCh == true then
            str = FishGF.getChByIndex(800000210)
        else
            str = "y"
        end
    elseif ID == 4 then


    end

    return str
end

--转化道具
function FishGF.changePropUnitByID(propId,propCount,isCh)
    propId = tonumber(propId)
    propCount = tonumber(propCount)
    local str = propCount
    if propId == 1 then
        --str = str..FishGF.getChByIndex(800000098)
    elseif propId == 2 then
        --str = str..FishGF.getChByIndex(800000099)
    elseif propId == 12 then
        if isCh == nil or isCh == true then
            str = (str/100)..FishGF.getChByIndex(800000210)
        else
            str = (str/100).."y"
        end
    elseif propId == 4 then
    end
    return str
end

--大厅中通过id得到道具的目标点 
function FishGF.getHallPropAimByID(ID)
    local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale()
    local pos = cc.p(0,0)
    if ID == 1 then
        pos = cc.p(617.55*scaleX_,677.88*scaleY_)
    elseif ID == 2 then
        pos = cc.p(927.51*scaleX_,681.43*scaleY_)
    else
        pos = cc.p(66.26*scaleX_,71*scaleY_)
    end

    return pos
end

--显示系统消息提示框
function FishGF.showMessageLayer(messageType,strMsg,callback,scene,strHook)
    local curScene = (scene == nil and cc.Director:getInstance():getRunningScene() or scene);
    if curScene == nil or type(curScene) == "number" then
        return
    end
    
    local noticeType = curScene:getChildByName("MessageDialog")
    if noticeType == nil then
        noticeType = require("Message/MessageDialog").create()
        noticeType:setData(messageType,strMsg,callback,strHook)
        noticeType:setName("MessageDialog")
        curScene:addChild(noticeType,FishCD.ORDER_SYSTEM_MESSAGE)
        noticeType:showLayer() 
        noticeType:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    else
        noticeType:setData(messageType,strMsg,callback,strHook)
        if not noticeType["isShow"] then
            noticeType:showLayer() 
        end
    end
end

--显示系统退出提示框
function FishGF.showExitMessage(strMsg,callback)
    local curScene = cc.Director:getInstance():getRunningScene()
    if curScene == nil or type(curScene) == "number" then
        return
    end
    local ExitMessage = curScene:getChildByName("ExitMessage")
    if ExitMessage == nil then
        ExitMessage = require("Message/MessageDialog").create()
        ExitMessage:setData(FishCD.MODE_MIDDLE_OK_CLOSE,strMsg,callback)
        ExitMessage:setName("ExitMessage")
        curScene:addChild(ExitMessage,FishCD.ORDER_SYSTEM_MESSAGE+1)
        ExitMessage:showLayer() 
        ExitMessage:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    else
        ExitMessage:setData(FishCD.MODE_MIDDLE_OK_CLOSE,strMsg,callback)
        if not ExitMessage["isShow"] then
            ExitMessage:showLayer() 
        end
    end
end

--显示小的系统提示框 --弹框
function FishGF.showToast(str)
    FishGF.showMessageLayer(FishCD.MODE_MIN_OK_ONLY,str,nil)
end

--系统小提示 --一句话提示 
function FishGF.showSystemTip(message,keyId,delaytime)
    local time = (delaytime == nil and 10 or delaytime)
    local systemTipBg = nil
    if message == nil and keyId ~= nil then
        message = FishGF.getChByIndex(keyId)
    end

    if keyId ~= nil then
        systemTipBg = cc.Director:getInstance():getRunningScene():getChildByTag(keyId)
    end
    
    if systemTipBg ~= nil then
        systemTipBg:stopAllActions()
        systemTipBg:setOpacity(255)
        systemTipBg:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.FadeTo:create(0.5,0),cc.RemoveSelf:create()))
    else
        systemTipBg = cc.Scale9Sprite:create("common/layerbg/com_pic_infobg.png");
        systemTipBg:setPosition(cc.p(systemTipBg:getContentSize().width/2,0));
        systemTipBg:setScale9Enabled(true);
        systemTipBg:setCapInsets({x = 42, y = 26, width = 1, height = 1})
        if keyId ~= nil then
            systemTipBg:setTag(keyId)
        end

        cc.Director:getInstance():getRunningScene():addChild(systemTipBg,FishCD.ORDER_GAME_MESSAGE);
        systemTipBg:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))

        local tip = cc.LabelTTF:create(message, "Arial", 32);
        tip:setColor(cc.c3b(255, 255,255));
        local size = tip:getContentSize()
        --print("---size.width="..size.width.."---size.height="..size.height)
        systemTipBg:setContentSize(cc.size(size.width+50,52));
        systemTipBg:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.FadeTo:create(0.5,0),cc.RemoveSelf:create()))

        tip:setPosition(cc.p(systemTipBg:getContentSize().width/2, systemTipBg:getContentSize().height/2));
        systemTipBg:addChild(tip);    
        systemTipBg:setScale(0.75)   
        --tip:setScale(1/0.7)   
    end
end

--等待框
function FishGF.waitNetManager(isAdd,message,waitId)
    if message == nil then
        message = FishGF.getChByIndex(800000178)
    end

    local swallowLayer = FishGF.getSwallowLayer()
    local textLab = swallowLayer:getChildByName("textLab")
    textLab:setString(message);

    if isAdd then
        FishGF.addSwallowLayer(waitId)
    else
        FishGF.delSwallowLayer(waitId)
    end
    FishGF.updataSwallowLayer(swallowLayer)
end

--创建等待框
function FishGF.getSwallowLayer()
    if cc.Director:getInstance():getRunningScene() == nil then
        return nil
    end
    local swallowLayer = cc.Director:getInstance():getRunningScene():getChildByName("swallowLayer_list")
    if swallowLayer == nil then
        local size = cc.Director:getInstance():getWinSize();
        swallowLayer = ccui.Button:create("common/layerbg/com_pic_graybg.png");
        swallowLayer:setScale9Enabled(true);
        swallowLayer:setContentSize(size);
        swallowLayer:setName("swallowLayer_list")
        swallowLayer:setPosition(cc.p(size.width/2, size.height/2));
        cc.Director:getInstance():getRunningScene():addChild(swallowLayer, 2001, FishCD.TAG.WAIT_NET_CALLBACK);

        local rotateSpr = cc.Sprite:create("common/com_pic_loading_circle.png")
        swallowLayer:addChild(rotateSpr)
        rotateSpr:setPosition(cc.p(size.width/2,size.height/2))
        rotateSpr:runAction(cc.RepeatForever:create(cc.RotateBy:create(2,360)))
        
        local textLab = cc.Label:createWithSystemFont("", "Arial", 24)
        textLab:setColor(cc.c3b(144,222,84))
        swallowLayer:addChild(textLab)
        textLab:setName("textLab")
        textLab:setPosition(cc.p(size.width/2,size.height/2- rotateSpr:getContentSize().height*2/3))
    end
    return swallowLayer
end

--创建等待框
function FishGF.addSwallowLayer(waitId)
    if FishGI.waitNetlist == nil then
        FishGI.waitNetlist = {}
        FishGI.waitNetlist.noIdCount = 0
        FishGI.waitNetlist.Idlist = {}
    end
    if waitId ~= nil then
        table.insert( FishGI.waitNetlist.Idlist, waitId)
    else
        FishGI.waitNetlist.noIdCount = FishGI.waitNetlist.noIdCount + 1
        waitId = ""
    end

    local IdCount,noIdCount = FishGF.getWaitListSize()
    FishGF.print("----------------add---------IdCount="..IdCount.."----------noIdCount="..noIdCount.."--------------"..waitId)
end

--删除等待框
function FishGF.delSwallowLayer(waitId)
    if FishGI.waitNetlist == nil then
        FishGI.waitNetlist = {}
        FishGI.waitNetlist.noIdCount = 0
        FishGI.waitNetlist.Idlist = {}
    end
    local isExist = false
    if waitId ~= nil then
        for k,v in pairs(FishGI.waitNetlist.Idlist) do
            if v == waitId then
                FishGI.waitNetlist.Idlist[k] = nil
                isExist = true
                break
            end
        end
    else
        if FishGI.waitNetlist.noIdCount > 0 then
            FishGI.waitNetlist.noIdCount = FishGI.waitNetlist.noIdCount - 1
            isExist = true
            waitId = ""
        end
    end
    
    if not isExist then
        FishGF.print("------------delSwallowLayer-------not Exist----------")
    end

    local IdCount,noIdCount = FishGF.getWaitListSize()
    FishGF.print("----------------del---------IdCount="..IdCount.."----------noIdCount="..noIdCount.."--------------"..waitId)

end

--清除等待框
function FishGF.clearSwallowLayer(noDelList)
    print("------------clearSwallowLayer-----------------")
    if FishGI.waitNetlist ~= nil then
        FishGI.waitNetlist = {}
        FishGI.waitNetlist.noIdCount = 0
        FishGI.waitNetlist.Idlist = {}
    end

    --保存不要删除的等待框（如充值）
    local newList = {}
    if noDelList ~= nil then
        for k1,val1 in pairs(noDelList) do
            for k2,val2 in pairs(FishGI.waitNetlist.Idlist) do
                if val1 == val1 then
                    table.insert( newList, val1)
                end
            end
        end
    end
    FishGI.waitNetlist.Idlist = newList

    local swallowLayer = FishGF.getSwallowLayer()
    if swallowLayer ~= nil then
        FishGF.updataSwallowLayer(swallowLayer)
    end

    -- local swallowLayer = FishGF.getSwallowLayer()
    -- if swallowLayer ~= nil then
    --     swallowLayer:setVisible(false)
    --     swallowLayer:stopActionByTag(FishCD.OVER_TIME_ACT_TAG)
    -- end
end

--超时处理
function FishGF.waitOverTime()
    local IdCount,noIdCount,waitId = FishGF.getWaitListSize()

    if noIdCount > 0 then
        FishGF.waitNetManager(false)
        return
    end

    if IdCount > 0 then
        local swallowLayer = FishGF.getSwallowLayer()
        swallowLayer:stopActionByTag(FishCD.OVER_TIME_ACT_TAG)
        swallowLayer:setVisible(false)
        FishGF.clearSwallowLayer()
        FishGF.createCloseSocketNotice(FishGF.getChByIndex(800000036)..".","waitOverTime")
        FishGF.print("-----------------waitOverTime--------------waitId="..waitId)
    else
        swallowLayer:stopActionByTag(FishCD.OVER_TIME_ACT_TAG)
        --没等待超时
        FishGF.print("------------超时处理---------")
    end
end

--更新等待框界面
function FishGF.updataSwallowLayer(swallowLayer)
    swallowLayer:stopActionByTag(FishCD.OVER_TIME_ACT_TAG)
    local IdCount,noIdCount = FishGF.getWaitListSize()
    if IdCount > 0 or noIdCount > 0 then
        swallowLayer:setVisible(true)
        local function overTimeFunc()
            FishGF.waitOverTime()
        end
        local delayTimeAct = cc.Sequence:create(cc.DelayTime:create(FishCD.OVER_TIME), cc.CallFunc:create(overTimeFunc));
        delayTimeAct:setTag(FishCD.OVER_TIME_ACT_TAG);
        swallowLayer:runAction(delayTimeAct);     
    else
        swallowLayer:setVisible(false)
    end

end

--得到等待消息列表大小
function FishGF.getWaitListSize()
    local IdCount = 0
    local waitId = ""
    for k,v in pairs(FishGI.waitNetlist.Idlist) do
        if v ~= nil then
            IdCount = IdCount + 1
            waitId = v
        end
    end

    local noIdCount = FishGI.waitNetlist.noIdCount
    return IdCount,noIdCount,waitId
end

--断线提醒
function FishGF.createCloseSocketNotice(str,index)
    if index ~= nil then
        FishGF.print("--------------createCloseSocketNotice-------index="..index)
    end
    local curScene = cc.Director:getInstance():getRunningScene();
    local sceneName = curScene.sceneName
    local function callback(sender)
        local tag = sender:getTag()
        if tag == 0 then
            if sceneName == "login" then
                if FishGI.hallScene~= nil and FishGI.hallScene.net ~= nil and FishGI.hallScene.net.CloseSocket ~= nil then
                    FishGI.hallScene.net:CloseSocket();
                end
                curScene.view:changeAccount();              
            elseif sceneName == "hall" then
                FishGI.hallScene.net:CloseSocket();
                FishGI.eventDispatcher:removeAllListener();
                FishGI.mainManagerInstance:createLoginManager();
            elseif sceneName == "game" then
                FishGI.gameScene.net:ExitRoom()
                FishGI.gameScene:exitGame();
                FishGI.hallScene.net:CloseSocket();
                FishGI.eventDispatcher:removeAllListener();
                FishGI.mainManagerInstance:createLoginManager();
            end
        end
    end
    if str == nil then
        str = FishGF.getChByIndex(800000036)
    end
    FishGF.showMessageLayer(FishCD.MODE_MIN_OK_ONLY,str,callback);

end

function FishGF.getRotateDegreeRadians(dstPos, srcPos)
    local dirVector = cc.p(dstPos.x-srcPos.x, dstPos.y-srcPos.y);
    local norVector = cc.pNormalize(dirVector);
    local radians = math.atan2(norVector.y, -norVector.x);
    local degree = math.deg(radians);
    return degree, radians;
end

function FishGF.strSplit(str, sign)
    local front = 1;
    local back = 1;
    local len = string.len(str);
    local resultTab = {};
    while true do
        back = string.find(str, sign, front);
        local val = string.sub(str,front,back-1);
        if back == nil then
            back = 0
        end
        front = back+1;
        table.insert(resultTab, val);
        if front >= len then
            break;
        end
    end
    return resultTab;
end

function FishGF.strToVec3(str)
    local front = 1;
    local back = 1;
    local len = string.len(str);
    local pointTab = {};


    while true do
        back = string.find(str, ",", front);
        local valx = string.sub(str,front,back-1);
        front = back+1;
        back = string.find(str, ",", front);
        local valy = string.sub(str,front,back-1);
        front = back+1;
        back = string.find(str, ";", front);
        local valz = string.sub(str,front,back-1);
        front = back+1;
        table.insert(pointTab, cc.vec3(tonumber(valx), tonumber(valy), tonumber(valz)));
        if back >= len then
            break;
        end
    end
    
    return pointTab;
end
function FishGF.strToVec2(str)
    local front = 1;
    local back = 1;
    local len = string.len(str);
    local pointTab = {};


    while true do
        back = string.find(str, ",", front);
        local valx = string.sub(str,front,back-1);
        front = back+1;
        back = string.find(str, ";", front);
        local valy = string.sub(str,front,back-1);
        front = back+1;
        table.insert(pointTab, cc.p(tonumber(valx), tonumber(valy)));
        if back >= len then
            break;
        end
    end

    return pointTab;
end

--排序 type:0 >从大到小, 1 <从小到大, 2 >=, 3 <=
function FishGF.sortByKey(valTable,key,type)
    local function comps(a,b)
        local ida = tonumber(a[key])
        local idb = tonumber(b[key])
        if type == 0 and ida > idb then
            return true
        elseif type == 1 and ida < idb then
            return true
        elseif type == 2 and ida >= idb then
            return true
        elseif type == 3 and ida <= idb then
            return true
        end
        return false
    end
    table.sort(valTable,comps);
end

--裁剪时间到分钟 2017-04-20 15:30:26类型
function FishGF.clipTime(sendTime)   
    local str = sendTime

    local front = 1;
    local back = 1;
    local back2 = 1;
    local len = string.len(str);
    back = string.find(str, ":", front);
    if back == nil then
        return ""
    end

    local val1 = string.sub(str,back + 1,len);

    back2 = string.find(val1, ":", front);
    if back2 == nil then
        return ""
    end
    local val = string.sub(str,front,back+back2-1);
    if val == nil then
        val = ""
    end
    return val
end

-- 得到裁剪区域
function FishGF.GetClippNode(rect, radius)
  local clippNode = cc.ClippingNode:create();
  local drawNode = cc.DrawNode:create();

  local segments = 100
  local origin = cc.p(rect.x, rect.y)
  local destination = cc.p(rect.x + rect.width, rect.y + rect.height)
  local points = { }

  local coef = math.pi / 2 / segments
  local vertices = { }

  for i = 0, segments do
    local rads =(segments - i) * coef
    local x = radius * math.sin(rads)
    local y = radius * math.cos(rads)

    table.insert(vertices, cc.p(x, y))
  end

  local tagCenter = cc.p(0, 0)
  local minX = math.min(origin.x, destination.x)
  local maxX = math.max(origin.x, destination.x)
  local minY = math.min(origin.y, destination.y)
  local maxY = math.max(origin.y, destination.y)
  local dwPolygonPtMax =(segments + 1) * 4
  local pPolygonPtArr = { }

  tagCenter.x = minX + radius;
  tagCenter.y = maxY - radius;

  for i = 0, segments do
    local x = tagCenter.x - vertices[i + 1].x
    local y = tagCenter.y + vertices[i + 1].y

    table.insert(pPolygonPtArr, cc.p(x, y))
  end

  tagCenter.x = maxX - radius;
  tagCenter.y = maxY - radius;

  for i = 0, segments do
    local x = tagCenter.x + vertices[#vertices - i].x
    local y = tagCenter.y + vertices[#vertices - i].y

    table.insert(pPolygonPtArr, cc.p(x, y))
  end

  tagCenter.x = maxX - radius;
  tagCenter.y = minY + radius;

  for i = 0, segments do
    local x = tagCenter.x + vertices[i + 1].x
    local y = tagCenter.y - vertices[i + 1].y

    table.insert(pPolygonPtArr, cc.p(x, y))
  end

  tagCenter.x = minX + radius;
  tagCenter.y = minY + radius;

  for i = 0, segments do
    local x = tagCenter.x - vertices[#vertices - i].x
    local y = tagCenter.y - vertices[#vertices - i].y

    table.insert(pPolygonPtArr, cc.p(x, y))
  end

  drawNode:drawPolygon(pPolygonPtArr, #pPolygonPtArr, cc.c4f(0, 0, 0, 0), 1, cc.c4f(0, 1, 0, 1))
  clippNode:setStencil(drawNode);

  return clippNode;
end

function FishGF.getFormatTimeBySeconds(seconds)
    local second  = 0
    local minute = 0
    local clock = 0

    second = seconds % 60
    minute = ((seconds - second) / 60)%60
    clock = math.floor(seconds / 3600) 

    local time = string.format("%02d:%02d:%02d",clock,minute,second)
    return time;
end

function FishGF.getPosWithDirectTag(directTag)
    if directTag == cc.exports.Direct.LEFT_DOWN then
        --左下
        return cc.p(cc.exports.gameSceneInstance.visibleSize.width/4, cc.exports.gameSceneInstance.visibleSize.height*0.1);
    elseif directTag == cc.exports.Direct.RIGHT_DOWN then
        --右下
        return cc.p(cc.exports.gameSceneInstance.visibleSize.width*3/4, cc.exports.gameSceneInstance.visibleSize.height*0.1);
    elseif directTag == cc.exports.Direct.LEFT_UP then
        --左上
        return cc.p(cc.exports.gameSceneInstance.visibleSize.width/4, cc.exports.gameSceneInstance.visibleSize.height*0.9);
    elseif directTag == cc.exports.Direct.RIGHT_UP then
        --右上
        return cc.p(cc.exports.gameSceneInstance.visibleSize.width*3/4, cc.exports.gameSceneInstance.visibleSize.height*0.9);
    end
end

function FishGF.coordinateTransform(pos, isTransform)
    local winSize = cc.Director:getInstance():getWinSize();
    if isTransform then
        return cc.vec3(tonumber(winSize.width-pos.x), tonumber(winSize.height-pos.y), tonumber(pos.z));
    else
        return cc.vec3(tonumber(pos.x), tonumber(pos.y), tonumber(pos.z));
    end
    
end

--延时执行
function FishGF.delayExcute(time, func, data)
    local function tempFunc()
        func(data);
    end
    local scene = cc.Director:getInstance():getRunningScene();
    local seq = cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create(tempFunc));

    scene:runAction(seq);
end

--判断手机号是否符合
function FishGF.checkPhone( phone )

    -- 验空
    if phone == nil then
        FishGF.showToast(FishGF.getChByIndex(800000224))
        return false
    end

    if #phone <= 0 then
        FishGF.showToast(FishGF.getChByIndex(800000224))
        return false
    end

    -- 验证长度
    if #phone ~= 11 then
        FishGF.showToast(FishGF.getChByIndex(800000225))
        return false
    end

    -- 验证是否是纯数字
    local isN = tonumber(phone);
    if not isN then
        FishGF.showToast(FishGF.getChByIndex(800000225))
        return false
    end

    return true
end

--[[
* @brief 密码格式检查
* @param password 身份证号
* @return false:不合法
]]
function FishGF.checkPassword( password )

    -- 验空
    if password == nil then

        FishGF.showToast(FishGF.getChByIndex(800000226))
        return false
    end

    if #password <= 0 then

        FishGF.showToast(FishGF.getChByIndex(800000226))
        return false
    end

    if #password <6 or #password >16 then

        FishGF.showToast(FishGF.getChByIndex(800000227))
        return false
    end

    return true
end

--[[
* @brief 账号格式检查
* @param account 身份证号
* @return false:不合法
]]
function FishGF.checkAccount( account )

    -- 验空
    if account == nil then

        FishGF.showToast(FishGF.getChByIndex(800000228))
        return false
    end

    if #account <= 0 then

        FishGF.showToast(FishGF.getChByIndex(800000228))
        return false
    end

    if #account <6 or #account >16 then

        FishGF.showToast(FishGF.getChByIndex(800000229))
        return false
    end

    return true
end

function FishGF.checkNickName( nick )

    -- 验空
    if nick == nil then

        FishGF.showToast(FishGF.getChByIndex(800000194))
        return false
    end

    if #nick <= 0 then

        FishGF.showToast(FishGF.getChByIndex(800000194))
        return false
    end

    if #nick < 6 or #nick >18 then

        FishGF.showToast(FishGF.getChByIndex(800000195))
        return false
    end

    return true
end

--[[
* @brief 验证码格式检查
* @param code 验证码
* @return false:不合法
]]
function FishGF.checkCode( code )

    -- 验空
    if code == nil then

        FishGF.showToast(FishGF.getChByIndex(800000230))
        return false
    end

    if #code <= 0 then

        FishGF.showToast(FishGF.getChByIndex(800000230))
        return false
    end

    -- 验证长度
    if #code ~= 4 then

        FishGF.showToast(FishGF.getChByIndex(800000231))
        return false
    end

    -- 验证是否是纯数字
    local isN = tonumber(code);
    if not isN then
        FishGF.showToast(FishGF.getChByIndex(800000231))
        return false
    end

    return true
end

--判断房间号是否正确
function FishGF.checkRoomNo( roomNo )

    -- 验空
    if roomNo == nil then
        FishGF.showToast(FishGF.getChByIndex(800000235))
        return false
    end

    if #roomNo <= 0 then

        FishGF.showToast(FishGF.getChByIndex(800000235))
        return false
    end

    -- 验证是否是纯数字
    local isN = tonumber(roomNo);
    if not isN then
        FishGF.showToast(FishGF.getChByIndex(800000237))
        return false
    end

    -- 验证长度
    if #roomNo ~= 6 then

        FishGF.showToast(FishGF.getChByIndex(800000236))
        return false
    end

    -- if #tostring(isN) ~= #roomNo then
    --     FishGF.showToast(FishGF.getChByIndex(800000238))
    --     return false
    -- end

    return true
end

--绑定手机获取验证码事件
function FishGF.onClickGetCode(btnCode,phoneid,strtype)

    -- 检测用户输入
    if not FishGF.checkPhone(phoneid) then
        return 
    end

    btnCode:setEnabled(false)
    --btnCode:setBright(false)
    local spr_nosend = btnCode:getChildByName("spr_nosend")
    local spr_sendend = btnCode:getChildByName("spr_sendend")
    spr_nosend:setVisible(false)
    spr_sendend:setVisible(true)

    FishGI.Dapi:PullCaptchaSms(
        phoneid,
        Helper.GetDeviceCode(),
        strtype,
        FishGF.getCallback(nil,btnCode))
end

--获取验证码事件回调
function FishGF.getCallback(txtCodeTd,btnCode)
    local callback=function(x)

        if x.status == 0 then
            FishGF.VerCodeShow(nil,btnCode,x.surplus or 60 )
            FishGF.showToast(FishGF.getChByIndex(800000232))
        else
            FishGF.showToast(x.msg)

            btnCode:setEnabled(true)
            --btnCode:setBright(true)
            local spr_nosend = btnCode:getChildByName("spr_nosend")
            local spr_sendend = btnCode:getChildByName("spr_sendend")
            spr_nosend:setVisible(true)
            spr_sendend:setVisible(false)
        end
    end
    return callback
end

--获取验证码倒计时
function FishGF.VerCodeShow(txtCodeTd,btnCode,count )
    print("------count="..count)
    btnCode:setEnabled(false)
    --btnCode:setBright(false)
    local spr_nosend = btnCode:getChildByName("spr_nosend")
    local spr_sendend = btnCode:getChildByName("spr_sendend")
    local text_time = spr_sendend:getChildByName("text_time")
    spr_nosend:setVisible(false)
    spr_sendend:setVisible(true)
    text_time:setString(count)
    text_time["count"] = count
    --重复
    local sequence = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ( ... )
        -- body
        local count = text_time["count"]
        count = count-1
        text_time["count"] = count
        text_time:setString(count)
        if count <=0 then
            spr_sendend:setVisible(false)
            spr_nosend:setVisible(true)
            btnCode:setEnabled(true)
            --btnCode:setBright(true)
            text_time:stopAllActions()
        end

    end))
    text_time:runAction(cc.RepeatForever:create(sequence))

end

--得到自己的坐标
function FishGF.getMyPos()
    local playerSelf = FishGI.gameScene.playerManager:getMyData()
    --local pos = playerSelf.cannon:convertToWorldSpace(cc.p(playerSelf.cannon.posX,playerSelf.cannon.posY))
    local pos = playerSelf:getCannonPos()
    return pos
end

--判断是否充值成功
function FishGF.isRechargeSucceed(newData)
--    print("--------isRechargeSucceed------000---------")
    if FishGI.IS_RECHARGE == 0 then
        return true
    end

    local actTag = 10101
    local curScene = cc.Director:getInstance():getRunningScene()
    curScene:stopActionByTag(actTag)

    local isSuccess = false
    local fishIcon = newData.fishIcon
    local crystal = newData.crystal
    local leftMonthCardDay = newData.leftMonthCardDay


    local myFishIcon = FishGMF.getPlayerPropData(newData.playerId,FishCD.PROP_TAG_01).realCount
    local myCrystal = FishGMF.getPlayerPropData(newData.playerId,FishCD.PROP_TAG_02).realCount
    local myLeftMonthCardDay = FishGI.myData.leftMonthCardDay

    if myFishIcon ~= fishIcon or myCrystal ~= crystal or myLeftMonthCardDay ~= leftMonthCardDay then
        isSuccess = true
    end
    print("--------isRechargeSucceed------1111---------")

    --结果处理
    if isSuccess then
        FishGF.waitNetManager(false,nil,"doPaySDK")
        FishGI.IS_RECHARGE = 0
        FishGI.eventDispatcher:dispatch("BuySuccessCall", resultInfo)
        FishGI.WebUserData:initWithUserId(FishGI.WebUserData:GetUserId())
        if FishGI.PLAYER_STATE == 0 then    --"游客"
            FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000175),nil) 
        else
            FishGF.showSystemTip(nil,800000157,1);
        end
    else
        FishGI.IS_RECHARGE = FishGI.IS_RECHARGE - 1
        if FishGI.IS_RECHARGE <= 0 then
            FishGF.waitNetManager(false,nil,"doPaySDK")
            FishGF.showSystemTip(nil,800000169,1);
            return false
        end

        print("--------isRechargeSucceed------2222---------")
        local seq = cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function ( ... )
             print("--------isRechargeSucceed------333---------")
            if FishGI.GAME_STATE == 2 then
                FishGF.waitNetManager(false,nil,"doPaySDK")
                FishGF.waitNetManager(true,nil,"doPaySDK")
                FishGI.hallScene.net.roommanager:sendDataGetInfo();
            elseif FishGI.GAME_STATE == 3 then
                FishGI.gameScene.net:sendBackFromCharge()
                FishGI.gameScene.net:sendReChargeSucceed()
            end
        end))
        seq:setTag(actTag)
        curScene:runAction(seq)

    end

    return isSuccess

end

--复制
function FishGF.copy(content)
    if device.platform == "android" then
        local luaBridge = require("cocos.cocos2d.luaj");
        local javaClassName = "com.weile.api.NativeHelper";
        local javaMethodName = "copy";
        local javaParams = {
            content
        }
        local javaMethodSig = "(Ljava/lang/String;)V";
        luaBridge.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig);
    elseif device.platform == "ios" then
		local luaoc = require("cocos.cocos2d.luaoc")
		local IOS_CLASS_NAME = "AppController"
		local args = {};
		args.message = "已复制"
		luaoc.callStaticMethod(IOS_CLASS_NAME, "showMessage", args)
		Helper.CopyToClipboard(content);
    end
end

function FishGF.isThirdSdk()
	if CHANNEL_ID ~= CHANNEL_ID_LIST.tencent and CHANNEL_ID ~= CHANNEL_ID_LIST.weile and CHANNEL_ID ~= CHANNEL_ID_LIST.ios then
		return true;
	end
	return false;
end

function FishGF.isThirdSdkLogin()
	return FishGI.GameCenterSdkBase.ChannelInfoList[FishGI.GameCenterSdkBase.ChannelIdList[CHANNEL_ID]][FishGI.GameCenterSdkBase.ChannelInfoIndex.is_need_login]
end

function FishGF.isThirdSdkExit()
	return FishGI.GameCenterSdkBase.ChannelInfoList[FishGI.GameCenterSdkBase.ChannelIdList[CHANNEL_ID]][FishGI.GameCenterSdkBase.ChannelInfoIndex.is_need_exit]
end

--玩家离开提示
function FishGF.playerLeaveNotive(str)
    local function callback(sender)
        local tag = sender:getTag()
        if tag == 2 then
            FishGI.isExitRoom = true;
            if FishGI.FRIEND_ROOM_STATUS ~= 0 then --朋友场
                FishGI.FRIEND_ROOM_STATUS = 0
                FishGI.FRIEND_ROOMID = nil
                local CreatorPlayerId = FishGI.gameScene.playerManager:getCreatorPlayerId()
                if FishGI.SERVER_STATE == 0 and CreatorPlayerId == FishGI.myData.playerId then --解散
                    FishGI.gameScene.net:sendFriendCloseGame()
                    FishGF.doMyLeaveGame(7)
                else 
                    FishGI.gameScene.net:sendFriendLeaveGame()
                    FishGF.doMyLeaveGame(5)
                end 
            else
                FishGI.gameScene:doExitGame()
            end 
        end
    end   
    FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,str,callback)

end 

--玩家离开游戏返回大厅
function FishGF.doMyLeaveGame(leaveType)
    FishGI.FRIEND_ROOM_STATUS = 0
    FishGI.FRIEND_ROOMID = nil
    FishGI.isExitRoom = true
    --FishGI.isEnterBg = true
    FishGI.exitType = leaveType
    FishGI.SERVER_STATE = 0
    
    if FishGI.gameScene ~= nil then
        if FishGI.gameScene.net ~= nil and FishGI.gameScene.net.ExitRoom ~= nil then
            FishGI.gameScene.net:ExitRoom()
        end
        FishGI.gameScene:exitGame();
    end
    
    --移除监听器
    FishGI.eventDispatcher:removeAllListener();
end 

--得到当前公用层
function FishGF.getLayerByName(layerName)
    local layer = nil
    if FishGI.GAME_STATE == 2 then  --大厅
        layer = FishGI.hallScene[layerName]
    elseif FishGI.GAME_STATE == 3 then  --游戏内
        if FishGI.FRIEND_ROOM_STATUS == 0 then 
            layer = FishGI.gameScene[layerName]
        else
            layer = FishGI.gameScene.uiMainLayer[layerName]
        end
    end 
    return layer
end 

--大厅节点的移动隐藏
function FishGF.setNodeIsShow( node,fitstDir,isShow ,moveDis)
    if moveDis == nil then
        moveDis = 200
    end
    local moveTime = 0.3
    local actTag = 10001
    local delayTime = 0
    node:stopActionByTag(actTag)
    local aimX = 0
    local aimY = 0

    if node["firstPosX"] == nil then
        node["firstPosX"] = node:getPositionX()
    end

    if node["firstPosY"] == nil then
        node["firstPosY"] = node:getPositionY()
    end

    if isShow then
        delayTime = moveTime
    end

    if fitstDir == "up" then
        if isShow then
            aimX = node:getPositionX()
            aimY = node["firstPosY"]
        else
            aimX = node:getPositionX()
            aimY = node["firstPosY"] + moveDis
        end
    elseif fitstDir == "down" then
        if isShow then
            aimX = node:getPositionX()
            aimY = node["firstPosY"]
        else
            aimX = node:getPositionX()
            aimY = node["firstPosY"] - moveDis
        end
    elseif fitstDir == "left" then
        if isShow then
            aimX = node["firstPosX"]
            aimY = node:getPositionY()
        else
            aimX = node["firstPosX"] - moveDis
            aimY = node:getPositionY()
        end
    elseif fitstDir == "right" then
        if isShow then
            aimX = node["firstPosX"]
            aimY = node:getPositionY()
        else
            aimX = node["firstPosX"] + moveDis
            aimY = node:getPositionY()
        end
    end

    local act = cc.MoveTo:create(moveTime,cc.p(aimX,aimY))
    local seq = cc.Sequence:create(cc.DelayTime:create(delayTime),act)
    seq:setTag(actTag)
    node:runAction(seq)

    return moveTime
end 

--返回普通场大厅
function FishGF.backToHall( )
    FishGF.print("------FriendRoom:backToHall-返回普通场大厅-----")
    --返回原来的服务器
    if FishGI.FRIEND_ROOM_STATUS ~= 0 then
        FishGI.FRIEND_ROOM_STATUS = 4
        FishGI.FRIEND_ROOMID = nil
        FishGI.isExitRoom = true
        FishGI.hallScene.uiFriendRoom.curType = 0
        FishGI.hallScene.net:dealloc();
        FishGI.loginScene.net:DoAutoLogin();
    end
end

function FishGF.isWifiConnect()
	if device.platform == "android" then
		local luaBridge = require("cocos.cocos2d.luaj");
        local javaClassName = "com.weile.api.GameBaseActivity";
        local javaMethodName = "isNetworkConnected";
        local javaParams = {
        }
        local javaMethodSig = "()Z";
        local isSuccess, isWifi = luaBridge.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig);
		return isWifi;
    else
        return true
	end
end

--更新微信是否打开
function FishGF.UpdataWechat()
    local isOpenWechat = bit.band(FUN_SWITCH, 1)
    --local isOpenWechat = 1
    local isOpenWechatType2 = bit.band(FUN_SWITCH, 8)
    if isOpenWechat == 1 and isOpenWechatType2 == 8 then    
        FishGI.isOpenWechat = false
        print("-------OpenWechat")
        if FishGI.GAME_STATE == 2 then
            FishGI.hallScene.uiCreateSuceed:setWechatIsOpen(false)
        elseif FishGI.GAME_STATE == 3 then
            if FishGI.FRIEND_ROOM_STATUS ~= 0 then
                FishGI.gameScene.uiMainLayer:setWechatIsOpen(false)
            end
        end
    end
end

--判断当前时间是否在2个时间内
function FishGF.isInTwoTime( firstTime,endTime)
    local year = os.date("%Y")
    local month = os.date("%m")
    local day = os.date("%d")
    local curTime = os.time({year=year,month=month,day=day,hour=os.date("%H"), min=os.date("%M"), sec= os.date("%S")})
    
    local firstTimeTab = string.split(firstTime,":")
    local firstTimeSec = os.time({year= year ,month=month,day=day,hour = firstTimeTab[1], min = firstTimeTab[2], sec = firstTimeTab[3]})

    local endTimeTab = string.split(endTime,":")
    local endTimeSec = os.time({year= year ,month=month,day=day,hour = endTimeTab[1], min = endTimeTab[2], sec = endTimeTab[3]})

   if tonumber(curTime) > tonumber(firstTimeSec) and tonumber(curTime) < tonumber(endTimeSec) then
        return true
   end
   return false

end

--  房间号。房间规则。【房主 名称】可空
function FishGF.getInviteLink(roomkey,roomownernick,exttable)
   
    local packagename = "com.tencent.tmgp.weile.buyu"
    local region = REGION_CODE
    local params={
        key=roomkey,
        package=packagename,
        appid=APP_ID,
        channelid=CHANNEL_ID,
        roomowner=roomownernick,
        region=region
    }
    if exttable and type(exttable)=="table" then --扩展参数表
        table.merge(params,exttable)
    end

    local url="http://page." .. WEB_DOMAIN .."/joinRoom?data="..tostring(Helper.Base64Encode(FishGI.Http:BuildQuery(params)))
    printf("InviteHelper getInviteLink url :%s ",url)

    return url
end


-- 代开邀请好友 (点击邀请后调用)
function FishGF.agentInviteFriend(data,roomownernick)
    assert(data, "data nil error ")
    local roomkey = data.roomkey
    if  not roomownernick then
        roomownernick = FishGI.myData.nickName
    end

    local title = tostring(data.name).." "..FishGF.getChByIndex(800000241)..FishGF.getChByIndex(800000218)..tostring(roomkey)
    -- 拼接规则作为分享内容
    local desc = FishGF.getChByIndex(800000294)
    local url= FishGF.getInviteLink(roomkey, roomownernick ,{game=data.name, roomid= data.roomid,gameid = data.gameid,rule=desc})
    --gg.ShareHelper:doShareAppWebType( title, desc, url, 0 )
    FishGI.ShareHelper:doShareAppWebType(title,desc,url,0)

end

--容器视图的渐隐
function FishGF.setViewListIsShow(viewList,isShow,hideTime,delayTime)
    if delayTime == nil then
        delayTime = 0
    end

    local act = cc.Sequence:create(cc.DelayTime:create(delayTime),cc.FadeTo:create(hideTime,0))
    act:setTag(11111)
    local childList = viewList:getChildren()
    for k,val in pairs(childList) do
        local panel = val.panel
        if panel == nil then
            panel = val:getChildByName("panel")
        end
        if panel == nil then
            panel = val
        end        
        if not isShow then
            panel:runAction(act:clone())
        else
            panel:stopActionByTag(11111)
            panel:setOpacity(255)
        end
    end
end

--数字位数过多，进行手动缩放
function FishGF.isScaleByCount(fnt_count,count,fntWidth,showWidth)
    if fnt_count.fntScale == nil  then
        fnt_count.fntScale = fnt_count:getScale()
    end
    if fntWidth ~= nil and showWidth ~= nil then
        local scale = showWidth/fntWidth
        if scale < 1 then
            fnt_count:setScale(scale)
        else
            fnt_count:setScale(fnt_count.fntScale)
        end
        return 
    end

    if #(tostring(count)) > 3 then
        fnt_count:setScale(fnt_count.fntScale*0.85)
    else
        fnt_count:setScale(fnt_count.fntScale)
    end
end

--判断高级道具是否在使用中
function FishGF.isSeniorUsing( seniorData )
    for k,v in pairs(FishCD.TASTE_CANNON) do
        if seniorData.propId == v then
            local stringProp = seniorData.stringProp
            if stringProp ~= nil and stringProp ~= "" and stringProp ~= " " then
                return true
            end
            return false
        end
    end
end

--分解时间
function FishGF.spiltTime( timeStr )
    local resultTab = {}
    local tab1 = string.split(timeStr,"_")
    local dayStr = tab1[1]
    resultTab["dayStr"] = dayStr
    if dayStr ~= nil and  dayStr ~= "" then
        local datTab = string.split(dayStr,"-")
        resultTab["dayTime"] = datTab
    end

    local secStr = tab1[2]
    resultTab["secStr"] = secStr
    if secStr ~= nil and  secStr ~= "" then
        local datTab = string.split(secStr,":")
        resultTab["secTime"] = datTab
    end

    return resultTab

end

--判断是否限时炮台
function FishGF.isLimitCannon( propId )
    for k,v in pairs(FishCD.TASTE_CANNON) do
        if v == propId then
            return true
        end
    end
    return false
end

function FishGF.openPortraitWebView(url, title)
     if device.platform == "android" then     
        -- local javaParams = {appid}
        local luaBridge = require("cocos.cocos2d.luaj");
        local javaClassName = "com.weile.api.NativeHelper";
        local javaMethodName = "openCustomWebView";
        local javaParams = {
            url,
            title
        }
        local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;)V";
        local ok,ret = luaBridge.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig);
    elseif device.platform == "ios" then
        local iosClassName = "AppController";
        local args = {url=url, title=title}
        local ok, ret = luaoc.callStaticMethod(iosClassName, "openPortraitWebView", args)
        if ok then   
        end
    else 
        
    end
end

function FishGF.enterGameCommon(  )
    FishGI.isExitRoom = true
    FishGI.exitType = 1000
    FishGI.hallScene.net:dealloc()

    require("games.gtsp.ConstantDef")("games/gtsp", "games/gtsp")
    local function callbackUpdateLobbyData( appId, appKey, gameId )
        APP_ID = appId
        APP_KEY = appKey
        GAME_ID = gameId
        URLKEY = APP_ID .. APP_KEY .. APP_ID
    end
    SmallGamesGF.setLobbyData(FishGI.SYSTEM_STATE, APP_ID, APP_KEY, GAME_ID, CHANNEL_ID, FishGI.WebUserData:GetWXShareAppId(), callbackUpdateLobbyData)
    SmallGamesGF.setLobbyLoginData(FishGI.serverConfig, FishGI.loginScene.net.loginType, FishGI.loginScene.net.strLoginUserName, 
        FishGI.loginScene.net.userName, FishGI.loginScene.net.password, FishGI.loginScene.net.thirdLoginInfo)

    local luaPayData = {
        android = {
            common = {
                className = "com.weile.pay.PayApi",
                methodName = "doPay",
                methonCallbackResult = "addScriptListener",
            },
            list = {
                Alipay = nil,
                Wechat = nil,
                UnionPay = nil,
                Apple = nil,
                Gcsdk = nil,
            },
        },
        ios = {
            common = {
                className = "AppController",
                methodName = "doPay",
            },
            list = {
                Alipay = nil,
                Wechat = nil,
                UnionPay = nil,
                Apple = nil,
                Gcsdk = nil,
            },
        },
        gcsdk = {
            common = {
                className = "com.weile.gcsdk.GameCenterBase",
                methodName = "doPayForProduct",
                methonCallbackResult = "addScriptListener",
            },
            list = {
                baidu = nil,
                huawei = nil,
                jinli = nil,
                lenvo = nil,
                mi = nil,
                oppo = nil,
                qihu = nil,
                vivo = nil,
                yyb = nil,
            },
        },
    }
    local luaShareData = {
        android = {
            common = {
                className = "com.weile.api.WXShareHelper",
                methodName = "doShareToWX",
                methonCallbackResult = "addScriptListener",
            },
            list = {
                Alipay = nil,
                Wechat = nil,
                UnionPay = nil,
                Apple = nil,
                Gcsdk = nil,
            },
        },
        ios = {
            common = {
                className = "AppController",
                methodName = "doShareToWX",
            },
            list = {
                Alipay = nil,
                Wechat = nil,
                UnionPay = nil,
                Apple = nil,
                Gcsdk = nil,
            },
        },
    }
    SmallGamesGF.setBottomCallData("cocos.cocos2d.luaj", "cocos.cocos2d.luaoc", luaPayData, luaShareData)

    local storeProductDatas = {}
    local storeProductData = {}
    local dataTab = {}
    dataTab.funName = "getShopData"
    local rechargeData = FishGI.GameTableData:getRechargeTable(1)
    local index = 1
    for i=1,#rechargeData do
        if rechargeData[i].recharge_type == 1 or rechargeData[i].recharge_type == 2 then
            storeProductData[index] = clone(SmallGamesGI.StoreProductData)
            storeProductData[index].id = rechargeData[i].id
            storeProductData[index].name = rechargeData[i].recharge_name
            storeProductData[index].num = rechargeData[i].recharge_num
            storeProductData[index].image = rechargeData[i].recharge_res
            storeProductData[index].recharge_res = rechargeData[i].recharge_num
            storeProductData[index].frist_charge = rechargeData[i].frist_change_enable
            storeProductData[index].gift_num = rechargeData[i].gift_num
            storeProductData[index].price = rechargeData[i].recharge
            storeProductData[index].type = rechargeData[i].recharge_type            
            index = index + 1
        end

    end
    storeProductDatas["1"] = storeProductData
    storeProductData.count = index -1
    storeProductDatas.count = 1
    SmallGamesGF.setStoreProductData(storeProductDatas)
end

function FishGF.enterGameGtsp(  )
    FishGF.enterGameCommon()
    SmallGamesGF.start(SmallGamesGI.lobbyList.Buyu, SmallGamesGI.appList.Gtsp)
end

--龟兔赛跑 gtsp
function FishGF.checkUpdate(shortName)
    local info = require("VersionConfig")[shortName]
    local versionPath = cc.FileUtils:getInstance():getWritablePath().."/"..info.FILE_NAME.."version.lua"
    local isExistWritePath = cc.FileUtils:getInstance():isFileExist(versionPath)
	local isExistLocalPath = cc.FileUtils:getInstance():isFileExist(info.FILE_NAME.."version.lua");
    local version = info.VER
    if (isExist or isExistLocalPath) then version = require(info.FILE_NAME.."version.lua") end
    local hotScene = require("Update/UpDateScene").create(info.APP_ID..info.APP_KEY..info.APP_ID, info.APP_ID, info.CHANNEL_ID, version)
    cc.Director:getInstance():pushScene(hotScene)
end