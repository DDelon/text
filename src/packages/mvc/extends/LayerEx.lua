
local Layer = cc.Layer

-- 创建半透明黑色遮罩
function Layer:createMark()
    return cc.LayerColor:create(cc.c4b(0,0,0,120))
end

-- 返回 监听
function Layer:registerKeybackEvent(onKeybackCallback)
    local listener = cc.EventListenerKeyboard:create()
    local function onKeyReleased(keyCode, event)    	
    	if keyCode == cc.KeyCode.KEY_BACK then    		
           onKeybackCallback()
        end
    end 
   listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
   local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
   eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self)
   return self
end
