--
-- Author: Your Name
-- Date: 2016-09-13 20:29:19
--
local Widget = ccui.Widget

local function onclick_ (obj,callback)
    obj:addTouchEventListener(function(sender, state) 
        if state == 2 then
            callback(sender,state)
        end  
    end)
    return obj
end

-- 无效果点击事件  1变暗 2 缩放 0 or nil 无效果
function Widget:onClick(callback,effect)
    if 1==effect then
        return self:onClickDarkEffect(callback)
    elseif 2==effect then
        return self:onClickScaleEffect(callback)
    else
        return onclick_(self,callback)
    end	
end

-- 按钮缩放效果点击事件
function Widget:onClickScaleEffect(callbackEnd, callbackBegin, callbackMove, callbackCancel)
	self:addTouchEventListener(function(sender, state) 
        if state == 0 then    --began
            if sender["curScale"] == nil then
                sender["curScale"] = sender:getScale() or 1
            end
        	sender.scale_=sender["curScale"] or 1
            sender:setScale(sender.scale_*0.95)
            if callbackBegin then
                callbackBegin(sender,state)
            end
        elseif state == 1 then  --moved
            if callbackMove then
                callbackMove(sender,state)
            end
        elseif state == 2 then  --end
            sender:setScale(sender.scale_*1.0)	
            callbackEnd(sender,state)

            -- 播放点击音效
            FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
        else    --cancel
            sender:setScale(sender.scale_*1.0)
            if callbackCancel then
                callbackCancel(sender,state)
            end
        end
      
    end)
    return self
end

-- 变暗效果点击事件
function Widget:onClickDarkEffect(callbackEnd, callbackBegin, callbackMove, callbackCancel)
	self:addTouchEventListener(function(sender, state)
        local event = {x = 0, y = 0}
        if state == 0 then 
           sender:setColor({r = 200, g = 200, b = 200})
           if callbackBegin then
                callbackBegin(sender,state)
            end
        elseif state == 1 then      
            if callbackMove then
                callbackMove(sender,state)
            end      	
        elseif state == 2 then
            sender:setColor({r = 255, g = 255, b = 255})	
            callbackEnd(sender,state)
            -- 播放点击音效
            FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
        else
            sender:setColor({r = 255, g = 255, b = 255})
            if callbackCancel then
                callbackCancel(sender,state)
            end	
        end      
        
    end)
    return self
end