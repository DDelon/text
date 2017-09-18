local showLayerData = class("showLayerData", nil)

function showLayerData.create()
    local data = showLayerData.new();
    data:init();
    return data;
end

function showLayerData:init()
    
end

function showLayerData:showLayer(layer,parent,opacity)
    if layer["isShow"] then
        return 
    end
    layer:setVisible(true)
    layer["isShow"] = true

    if opacity == nil then
        opacity = 255
    end

    local curlayer = layer
    if layer.panel ~= nil then
        curlayer = layer.panel
    elseif layer:getChildByName("panel") ~= nil then 
        curlayer = layer:getChildByName("panel")
    elseif layer.resourceNode_ ~= nil and layer.resourceNode_["panel"] ~= nil then 
        curlayer = layer.resourceNode_["panel"]
    end

    if curlayer["layerScale"] == nil then
        curlayer["layerScale"] = curlayer:getScale()
    end

    curlayer:stopAllActions()
    curlayer:setVisible(true)
    curlayer:setOpacity(255)

    FishGI.showLayerData:showGrayBgByLayer(curlayer,opacity)

	if layer.layerType == "Shop" then
        local tab = FishGI.WebUserData:getFirstRechargeInfo();
        layer:initWithTab(tab);
    end
	
    local curScale = curlayer["layerScale"]
    curlayer:setScale(0.2*curScale)
    curlayer:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15,1.1*curScale),cc.ScaleTo:create(0.05,0.95*curScale),cc.ScaleTo:create(0.05,1*curScale)))

    local childList = curlayer:getChildren()
    for k,v in pairs(childList) do
        self:disposeLayerShow(v,true,false,false)
    end
    --self:disposeLayerShow(curlayer,true,false,true)
end

function showLayerData:hideLayer(layer,isRemove,isScale,allActTime)  
    --print("--hideLayer---")
    layer["isShow"] = false

    local curlayer = layer
    if layer.panel ~= nil then
        curlayer = layer.panel
    elseif layer:getChildByName("panel") ~= nil then 
        curlayer = layer:getChildByName("panel")
    elseif layer.resourceNode_ ~= nil and layer.resourceNode_["panel"] ~= nil then 
        curlayer = layer.resourceNode_["panel"]
    end

    local actTime = 0.15
    if allActTime ~= nil then
        actTime = allActTime
    end
    if curlayer["layerScale"] == nil then
        curlayer["layerScale"] = curlayer:getScale()
    end
    local curScale = curlayer["layerScale"]
    
    curlayer:stopAllActions()
    curlayer:setOpacity(255)
    curlayer:runAction(cc.FadeTo:create( actTime,0))

    if isScale == nil or isScale == true then
        curlayer:runAction(cc.ScaleTo:create(actTime,0.3*curScale))
    end
    
    FishGI.showLayerData:hideGrayBgByLayer(curlayer)

    isRemove = isRemove or false
    if isRemove then
        curlayer:runAction(cc.Sequence:create(cc.DelayTime:create(actTime + 0.01),cc.CallFunc:create(function (... )
            layer:setVisible(false)
            layer:removeFromParent()
        end)))
    else
        curlayer:runAction(cc.Sequence:create(cc.DelayTime:create(actTime + 0.01),cc.CallFunc:create(function (... )
            layer:setVisible(false)
        end)))
    end

    local childList = curlayer:getChildren()
    for k,v in pairs(childList) do
        self:disposeLayerShow(v,false,isRemove,true,actTime)
    end

end

function showLayerData:showLayerByNoAct(layer,parent,opacity)  
     if opacity == nil then
        opacity = 255
    end

    if layer["isShow"] then
        return
    end
    layer["isShow"] = true
    layer:setVisible(true)
    local curlayer = layer
    if layer.panel ~= nil then
        curlayer = layer.panel
    elseif layer:getChildByName("panel") ~= nil then 
        curlayer = layer:getChildByName("panel")
    elseif layer.resourceNode_ ~= nil and layer.resourceNode_["panel"] ~= nil then 
        curlayer = layer.resourceNode_["panel"]
    end
    curlayer:stopAllActions()
    curlayer:setVisible(true)
    curlayer:setOpacity(255)

    if curlayer["layerScale"] == nil then
        curlayer["layerScale"] = curlayer:getScale()
    end
    curlayer:setScale(curlayer["layerScale"])

    FishGI.showLayerData:showGrayBgByLayer(curlayer,opacity)

    local childList = curlayer:getChildren()
    for k,v in pairs(childList) do
        self:disposeLayerShow(v,true,false,false)
    end

end

function showLayerData:hideLayerByNoAct(layer,isRemove,parent)  
    layer["isShow"] = false

    FishGI.showLayerData:hideGrayBgByLayer(layer)
    layer:stopAllActions()

    isRemove = isRemove or false
    if isRemove then
        layer:removeFromParent()
    else
        layer:setVisible(false)
    end

    local childList = layer:getChildren()
    for k,v in pairs(childList) do
        self:disposeLayerShow(v,false,isRemove,true)
    end

end

function showLayerData:disposeLayerShow(node,iShow,isRemove,isAct,allActTime)
    if node.nodeType == "cocosStudio" then
        self:playLayerIsShow(node,iShow,isRemove,isAct,allActTime)
    elseif node.nodeType == "viewlist" then
        local childViewList = node:getChildren()
        for k2,v2 in pairs(childViewList) do
            self:playLayerIsShow(v2,iShow,isRemove,isAct,allActTime)
        end
    end
end

function showLayerData:playLayerIsShow(node,iShow,isRemove,isAct,allActTime)
    if iShow then
        if isAct then
            self:showLayer(node,nil,0)
        else
            self:showLayerByNoAct(node,nil,0)
        end        
    else
        if isAct then
            self:hideLayer(node,isRemove,false,allActTime)
        else
            self:hideLayerByNoAct(node,isRemove,false)
        end
    end
end

function showLayerData:showGrayBgByLayer(layer,opacity)
    if opacity ~= nil and opacity == 0 then
        return
    end
    local parent = layer:getParent()

    local gray_bg = parent:getChildByName("gray_bg")
    if gray_bg ~= nil  then
        gray_bg:setVisible(true)
        gray_bg:setLocalZOrder(layer:getLocalZOrder()-1) 
        gray_bg:setScale(2)
    else
        gray_bg = cc.Scale9Sprite:create("common/layerbg/com_pic_graybg.png");
        gray_bg:setScale9Enabled(true);
        local size = cc.Director:getInstance():getWinSize();
        gray_bg:setContentSize(size);
        --gray_bg:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
        gray_bg:setPosition(cc.p(0,0))
        parent:addChild(gray_bg,layer:getLocalZOrder()-1);
        gray_bg:setScale(2)
        gray_bg:setName("gray_bg")
    end

    gray_bg:setOpacity(opacity)

end

function showLayerData:hideGrayBgByLayer(layer)
    local parent = layer:getParent()
    local gray_bg = parent:getChildByName("gray_bg")
    if gray_bg ~= nil  then
        gray_bg:setVisible(false)
    end
end

return showLayerData;