--
-- Author: Your Name
-- Date: 2016-09-14 14:35:48
--
local Node = cc.Node

-- 设置缩放
function Node:scale(scale)
	self:setScale(scale)
	return self
end

-- 设置父容器中相对位置 依赖父容器先调用@addTo添加  父容器需要设置大小
function Node:posByParent(anchor,x,y) 
   	x=x or 0
   	y=y or 0
	local  parent = self:getParent()
   	assert(parent,"parent is nil ")  
   	local size=parent:getContentSize()  
    local pos = cc.p(size.width*anchor.x, size.height*anchor.y)
    pos = cc.pAdd(pos, cc.p(x,y))
    self:setPosition(pos)
    return self
end

-- 设置相对屏幕位置 
function Node:posByScreen(anchor,x,y) 
    x=x or 0
    y=y or 0
    local pos = cc.p(display.width*anchor.x, display.height*anchor.y)
    pos = cc.pAdd(pos, cc.p(x,y))
    self:setPosition(pos)
    return self
end

-- 设置父容器中相对位置 依赖父容器先调用@addTo 父容器需要设置大小
function Node:posByParentX(anchorx,x) 
   	x=x or 0
	local  parent = self:getParent()
   	assert(parent,"parent is nil ")  
   	local size=parent:getContentSize()    
	local xp= size.width*anchorx 
    self:setPositionX(xp+x)
    return self
end

-- 设置父容器中相对位置 依赖父容器先调用@addTo  父容器需要设置大小
function Node:posByParentY(anchory,y) 
   	y=y or 0
	local  parent = self:getParent()
   	assert(parent,"parent is nil ")  
   	local size=parent:getContentSize()
	local yp= size.height*anchory
    self:setPositionY(yp+y)
    return self
end

--  设置相对当前位置偏移坐标
function Node:posBy(x,y)
	local posx,posy= self:getPosition()
    if y then
        self:setPosition(posx+x, posy+y)
    else
        self:setPositionX(posx+x)
    end
    return self  
end

-- 设置控件在父容器位置百分比 父容器大小不能为0 依赖父容器先调用@addTo
function Node:posPercent(x,y) 
	local  parent = self:getParent()
   	assert(parent,"parent is nil ")  
   	local size=parent:getContentSize()   	
    if y then
        self:setPosition(size.width*x, size.height*y)
    else
        self:setPositionX(size.width*x)
    end
    return self
end

-- call only once
function Node:setGray() 
  local glprogram = cc.GLProgram:createWithFilenames("shaders/example_Simple.vsh","shaders/gray.fsh");
  local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(glprogram);
  self:setGLProgramState(glProgramState)
end
