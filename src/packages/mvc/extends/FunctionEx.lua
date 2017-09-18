--[[
* @brief 全局变量 扩展
--]]
local Ex = gg or {}

-- 注册返回键回调函数
function Ex.RegisterKeyBackEvent(regobj,onkeyBackCallback)
    local listener = cc.EventListenerKeyboard:create()
    local function onKeyReleased(keyCode, event)        
        if keyCode == cc.KeyCode.KEY_BACK then          
           onkeyBackCallback()
        end
    end 
   listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
   local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
   eventDispatcher:addEventListenerWithSceneGraphPriority(listener,regobj)
end

--是否是整数
function Ex.IsInteger(number)
    return math.floor(number)==number
end

--返回 RMB 单位 如有余数精确到小数点后两位
function Ex.MoneyBaseUnit(money,base)
    local function fn(m,b)
        local number = tonumber( string.format("%.2f",(m/b)))
        local flnum = math.floor(number)
        if  flnum > number then
            return flnum
        else
            return number
        end
    end
    if money>=base then
        return fn(money,base) 
    else
        return tostring(money)
    end
end

function Ex.MoneyUnit(money)
    if money>=100000000 then
        return Ex.MoneyBaseUnit(money,100000000).."亿"
    elseif money>=10000000 then
        return Ex.MoneyBaseUnit(money,10000000).."千万"
    elseif money>=1000000 then
        return Ex.MoneyBaseUnit(money,1000000).."百万"
    elseif money>=10000 then
        return Ex.MoneyBaseUnit(money,10000).."万"
    elseif money>=1000 then
        return Ex.MoneyBaseUnit(money,1000).."千"
    else
        return tostring(money)
    end
end

--取精确小数点后位数 的数字 
function Ex.GetPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end
    n = n or 0;
    n = math.floor(n)
    local fmt = '%.' .. n .. 'f'
    local nRet = tonumber(string.format(fmt, nNum))
    return nRet;
end

-- 获取房间模式
function Ex.GetRoomMode(roomtype)
    return Helper.And(roomtype,ROOM_TYPE_SIT_MODE_MASK);
end

function Ex.GetRoomLevel(roomtype)
    return Helper.RShift(Helper.And(roomtype,ROOM_TYPE_LEVEL_MASK),22);
end
  --VIP升级时间，单位：秒
local VIPEXP = {150*3600,550*3600,1550*3600,3050*3600,6050*3600,13050*3600};
function Ex.GetVipLevel(vipvalue)   
    if not vipvalue or vipvalue==0 then
        return 0,0,0;   
    end
    local lv=1
    for i=1,#VIPEXP do
        lv=i
        if vipvalue< VIPEXP[i] then
           break
        end
    end
    local minexp= 0
    if lv>1 then
        minexp=VIPEXP[lv-1]
    end
    return lv,minexp,VIPEXP[lv]
end

-- 获取荣誉等级
local HONOREXP = {36000,324000,612000,900000,2700000,5580000,10980000,22500000,51300000};
function Ex.GetHonorLevel( honorvalue )
    if not honorvalue or honorvalue == 0 then
        return 1,0,HONOREXP[1];   
    end
    local lv = 1
    for i = 1 , #HONOREXP do
        lv = i
        if honorvalue < HONOREXP[i] then
           break
        end
    end
    local minexp = 0
    if lv > 1 then
        minexp = HONOREXP[lv-1]
    end
    return lv,minexp,HONOREXP[lv]
end

-- 获取大厅版本号
function Ex.GetHallVerison()
  return table.concat(HALL_WEB_VERSION,".")
   -- local tmpstr=HALL_WEB_VERSION[1]
   --    for i=2,#HALL_WEB_VERSION do
   --       tmpstr=tmpstr.."."..HALL_WEB_VERSION[i]
   --    end
   --    return tmpstr
end

-- 获取地区码
function Ex.GetRegionCode()  

end

-- 获取短昵称
function Ex.GetShortNickName(nickname,len)
    len=len or 13
    if nickname and string.len(nickname)>len then 
        return string.sub(nickname,1,len-3).."..."
    else
        return nickname
    end
end

-- 颜色值转换 0x to rgb
function  Ex.ConvertColor(xstr)
    local toTen = function (v)
        return tonumber("0x" .. v)
    end

    local b = string.sub(xstr, -2, -1) 
    local g = string.sub(xstr, -4, -3) 
    local r = string.sub(xstr, -6, -5)

    local red = toTen(r)
    local green = toTen(g)
    local blue = toTen(b)
    if red and green and blue then 
        return cc.c4b(red, green, blue, 255)
    end
end

-- 截图函数
function Ex.CaptureNode(node)
    local size=node:getContentSize() 
    local rtx = cc.RenderTexture:create(size.width, size.height,cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888,gl.DEPTH24_STENCIL8_OES)
    rtx:begin()
    node:visit()
    rtx:endToLua()
    local photo_texture = rtx:getSprite():getTexture()
    local captureSprite = cc.Sprite:createWithTexture(photo_texture) 
    captureSprite:setFlippedY(true) 
    return captureSprite
end

-- 传入DrawNode对象，画圆角矩形
function Ex.DrawNodeRoundRect(drawNode, rect, borderWidth, radius, color, fillColor)
    -- segments表示圆角的精细度，值越大越精细
    local segments    = 100
    local origin      = cc.p(rect.x, rect.y)
    local destination = cc.p(rect.x + rect.width, rect.y - rect.height)
    local points      = {}
    -- 算出1/4圆
    local coef     = math.pi / 2 / segments
    local vertices = {}

    for i=0, segments do
      local rads = (segments - i) * coef
      local x    = radius * math.sin(rads)
      local y    = radius * math.cos(rads)

      table.insert(vertices, cc.p(x, y))
    end
    local tagCenter      = cc.p(0, 0)
    local minX           = math.min(origin.x, destination.x)
    local maxX           = math.max(origin.x, destination.x)
    local minY           = math.min(origin.y, destination.y)
    local maxY           = math.max(origin.y, destination.y)
    local dwPolygonPtMax = (segments + 1) * 4
    local pPolygonPtArr  = {}
    -- 左上角
    tagCenter.x = minX + radius;
    tagCenter.y = maxY - radius;
    for i=0, segments do
      local x = tagCenter.x - vertices[i + 1].x
      local y = tagCenter.y + vertices[i + 1].y

      table.insert(pPolygonPtArr, cc.p(x, y))
    end
    -- 右上角
    tagCenter.x = maxX - radius;
    tagCenter.y = maxY - radius;
    for i=0, segments do
      local x = tagCenter.x + vertices[#vertices - i].x
      local y = tagCenter.y + vertices[#vertices - i].y

      table.insert(pPolygonPtArr, cc.p(x, y))
    end
    -- 右下角
    tagCenter.x = maxX - radius;
    tagCenter.y = minY + radius;

    for i=0, segments do
      local x = tagCenter.x + vertices[i + 1].x
      local y = tagCenter.y - vertices[i + 1].y

      table.insert(pPolygonPtArr, cc.p(x, y))
    end
    -- 左下角
    tagCenter.x = minX + radius;
    tagCenter.y = minY + radius;

    for i=0, segments do
      local x = tagCenter.x - vertices[#vertices - i].x
      local y = tagCenter.y - vertices[#vertices - i].y

      table.insert(pPolygonPtArr, cc.p(x, y))
    end

    if fillColor == nil then
      fillColor = cc.c4f(0, 0, 0, 0)
    end
    drawNode:drawPolygon(pPolygonPtArr, #pPolygonPtArr, fillColor, borderWidth, color)
    return drawNode
end

--[[
* @brief 分页函数
* @parm t 需要分页的表
* @parm eleCount 每页的元素数
* @parm isKv 返回的表是否为键值对的形式
]]
function Ex.ArrangePage( t , eleCount , isKv )

   if not t or not eleCount then
        return
    end

    -- 计算分页数
    local page = math.ceil( gg.TableSize(t) / eleCount)

    -- 分页大表
    local pageTable = {}

    for i = 1 , page do
        
        -- 创建分页表
        local eleTable = {}
        local j = 1
        for k , v in pairs(t) do
            
            if i == math.ceil( j / eleCount) then
         
                if isKv then
                  eleTable[ k ] = v
                else
                  table.insert( eleTable , v )
                end
            end
            j = j + 1
        end
        table.insert( pageTable , eleTable )
    end

    return pageTable

end

--[[
* @brief 1像素线处理函数
* @parm line 线对象
* @parm isvertical 是否是竖方向的线
]]
function Ex.LineHandle( line , isvertical )

    if not line then
        return
    end

    


end