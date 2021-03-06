--------------------------------------------------------------
-- This file was automatically generated by Cocos Studio.
-- Do not make changes to this file.
-- All changes will be lost.
--------------------------------------------------------------

local luaExtend = require "LuaExtend"

-- using for layout to decrease count of local variables
local layout = nil
local localLuaFile = nil
local innerCSD = nil
local innerProject = nil
local localFrame = nil

local Result = {}
------------------------------------------------------------
-- function call description
-- create function caller should provide a function to 
-- get a callback function in creating scene process.
-- the returned callback function will be registered to 
-- the callback event of the control.
-- the function provider is as below :
-- Callback callBackProvider(luaFileName, node, callbackName)
-- parameter description:
-- luaFileName  : a string, lua file name
-- node         : a Node, event source
-- callbackName : a string, callback function name
-- the return value is a callback function
------------------------------------------------------------
function Result.create(callBackProvider)

local result={}
setmetatable(result, luaExtend)

--Create Node
local Node=cc.Node:create()
Node:setName("Node")

--Create light_zz_1
local light_zz_1 = cc.Sprite:create("battle/friend/effect/friendprop_4_light_1.png")
light_zz_1:setName("light_zz_1")
light_zz_1:setTag(24)
light_zz_1:setCascadeColorEnabled(true)
light_zz_1:setCascadeOpacityEnabled(true)
light_zz_1:setScaleX(5.0000)
light_zz_1:setScaleY(5.0000)
light_zz_1:setOpacity(0)
layout = ccui.LayoutComponent:bindLayoutComponent(light_zz_1)
layout:setSize({width = 180.0000, height = 172.0000})
layout:setLeftMargin(-90.0000)
layout:setRightMargin(-90.0000)
layout:setTopMargin(-86.0000)
layout:setBottomMargin(-86.0000)
light_zz_1:setBlendFunc({src = 1, dst = 771})
Node:addChild(light_zz_1)

--Create light_qs_1_2
local light_qs_1_2 = cc.Sprite:create("battle/friend/effect/friendprop_6_light_1.png")
light_qs_1_2:setName("light_qs_1_2")
light_qs_1_2:setTag(25)
light_qs_1_2:setCascadeColorEnabled(true)
light_qs_1_2:setCascadeOpacityEnabled(true)
light_qs_1_2:setPosition(-0.0043, 0.0025)
light_qs_1_2:setScaleX(0.0100)
light_qs_1_2:setScaleY(0.0100)
light_qs_1_2:setRotationSkewY(-0.0006)
light_qs_1_2:setOpacity(0)
light_qs_1_2:setColor({r = 187, g = 0, b = 255})
layout = ccui.LayoutComponent:bindLayoutComponent(light_qs_1_2)
layout:setSize({width = 278.0000, height = 276.0000})
layout:setLeftMargin(-139.0043)
layout:setRightMargin(-138.9957)
layout:setTopMargin(-138.0025)
layout:setBottomMargin(-137.9975)
light_qs_1_2:setBlendFunc({src = 1, dst = 771})
Node:addChild(light_qs_1_2)

--Create fnt
local fnt = ccui.TextBMFont:create()
fnt:setFntFile("fnt/shop_num.fnt")
fnt:setString([[-20]])
fnt:setLayoutComponentEnabled(true)
fnt:setName("fnt")
fnt:setTag(118)
fnt:setCascadeColorEnabled(true)
fnt:setCascadeOpacityEnabled(true)
fnt:setPosition(-70.0000, 80.0000)
fnt:setOpacity(0)
layout = ccui.LayoutComponent:bindLayoutComponent(fnt)
layout:setSize({width = 66.0000, height = 32.0000})
layout:setLeftMargin(-103.0000)
layout:setRightMargin(37.0000)
layout:setTopMargin(-96.0000)
layout:setBottomMargin(64.0000)
Node:addChild(fnt)

--Create friend_bullet_2
local friend_bullet_2 = cc.Sprite:create("battle/friend/friend_bullet.png")
friend_bullet_2:setName("friend_bullet_2")
friend_bullet_2:setTag(119)
friend_bullet_2:setCascadeColorEnabled(true)
friend_bullet_2:setCascadeOpacityEnabled(true)
friend_bullet_2:setPosition(-21.0040, 19.8684)
friend_bullet_2:setScaleX(0.4000)
friend_bullet_2:setScaleY(0.4000)
layout = ccui.LayoutComponent:bindLayoutComponent(friend_bullet_2)
layout:setPositionPercentX(-0.3182)
layout:setPositionPercentY(0.6209)
layout:setPercentWidth(1.6970)
layout:setPercentHeight(3.5000)
layout:setSize({width = 112.0000, height = 112.0000})
layout:setLeftMargin(-77.0040)
layout:setRightMargin(31.0040)
layout:setTopMargin(-43.8684)
layout:setBottomMargin(-36.1316)
friend_bullet_2:setBlendFunc({src = 1, dst = 771})
fnt:addChild(friend_bullet_2)

--Create Animation
result['animation'] = ccs.ActionTimeline:create()
  
result['animation']:setDuration(90)
result['animation']:setTimeSpeed(1.0000)

--Create PositionTimeline
local PositionTimeline = ccs.Timeline:create()

localFrame = ccs.PositionFrame:create()
localFrame:setFrameIndex(0)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setX(0.0000)
localFrame:setY(0.0000)
PositionTimeline:addFrame(localFrame)

localFrame = ccs.PositionFrame:create()
localFrame:setFrameIndex(10)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setX(0.0000)
localFrame:setY(0.0000)
PositionTimeline:addFrame(localFrame)

localFrame = ccs.PositionFrame:create()
localFrame:setFrameIndex(50)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setX(0.0000)
localFrame:setY(0.0000)
PositionTimeline:addFrame(localFrame)

localFrame = ccs.PositionFrame:create()
localFrame:setFrameIndex(60)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setX(0.0000)
localFrame:setY(0.0000)
PositionTimeline:addFrame(localFrame)

result['animation']:addTimeline(PositionTimeline)
PositionTimeline:setNode(light_zz_1)

--Create ScaleTimeline
local ScaleTimeline = ccs.Timeline:create()

localFrame = ccs.ScaleFrame:create()
localFrame:setFrameIndex(0)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setScaleX(5.0000)
localFrame:setScaleY(5.0000)
ScaleTimeline:addFrame(localFrame)

localFrame = ccs.ScaleFrame:create()
localFrame:setFrameIndex(10)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setScaleX(1.0000)
localFrame:setScaleY(1.0000)
ScaleTimeline:addFrame(localFrame)

localFrame = ccs.ScaleFrame:create()
localFrame:setFrameIndex(50)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setScaleX(1.0000)
localFrame:setScaleY(1.0000)
ScaleTimeline:addFrame(localFrame)

localFrame = ccs.ScaleFrame:create()
localFrame:setFrameIndex(60)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setScaleX(1.0000)
localFrame:setScaleY(1.0000)
ScaleTimeline:addFrame(localFrame)

result['animation']:addTimeline(ScaleTimeline)
ScaleTimeline:setNode(light_zz_1)

--Create RotationSkewTimeline
local RotationSkewTimeline = ccs.Timeline:create()

localFrame = ccs.RotationSkewFrame:create()
localFrame:setFrameIndex(0)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setSkewX(0.0000)
localFrame:setSkewY(0.0000)
RotationSkewTimeline:addFrame(localFrame)

localFrame = ccs.RotationSkewFrame:create()
localFrame:setFrameIndex(10)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setSkewX(30.0000)
localFrame:setSkewY(30.0000)
RotationSkewTimeline:addFrame(localFrame)

localFrame = ccs.RotationSkewFrame:create()
localFrame:setFrameIndex(50)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setSkewX(150.0000)
localFrame:setSkewY(150.0000)
RotationSkewTimeline:addFrame(localFrame)

localFrame = ccs.RotationSkewFrame:create()
localFrame:setFrameIndex(60)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setSkewX(180.0000)
localFrame:setSkewY(180.0000)
RotationSkewTimeline:addFrame(localFrame)

result['animation']:addTimeline(RotationSkewTimeline)
RotationSkewTimeline:setNode(light_zz_1)

--Create AlphaTimeline
local AlphaTimeline = ccs.Timeline:create()

localFrame = ccs.AlphaFrame:create()
localFrame:setFrameIndex(0)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setAlpha(0)
AlphaTimeline:addFrame(localFrame)

localFrame = ccs.AlphaFrame:create()
localFrame:setFrameIndex(10)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setAlpha(255)
AlphaTimeline:addFrame(localFrame)

localFrame = ccs.AlphaFrame:create()
localFrame:setFrameIndex(50)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setAlpha(255)
AlphaTimeline:addFrame(localFrame)

localFrame = ccs.AlphaFrame:create()
localFrame:setFrameIndex(60)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setAlpha(0)
AlphaTimeline:addFrame(localFrame)

result['animation']:addTimeline(AlphaTimeline)
AlphaTimeline:setNode(light_zz_1)

--Create FileDataTimeline
local FileDataTimeline = ccs.Timeline:create()

localFrame = ccs.TextureFrame:create()
localFrame:setFrameIndex(10)
localFrame:setTween(false)
localFrame:setTextureName("battle/friend/effect/friendprop_4_light_1.png")
FileDataTimeline:addFrame(localFrame)

localFrame = ccs.TextureFrame:create()
localFrame:setFrameIndex(50)
localFrame:setTween(false)
localFrame:setTextureName("battle/friend/effect/friendprop_4_light_1.png")
FileDataTimeline:addFrame(localFrame)

result['animation']:addTimeline(FileDataTimeline)
FileDataTimeline:setNode(light_zz_1)

--Create BlendFuncTimeline
local BlendFuncTimeline = ccs.Timeline:create()

result['animation']:addTimeline(BlendFuncTimeline)
BlendFuncTimeline:setNode(light_zz_1)

--Create PositionTimeline
local PositionTimeline = ccs.Timeline:create()

localFrame = ccs.PositionFrame:create()
localFrame:setFrameIndex(50)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setX(-0.0043)
localFrame:setY(0.0025)
PositionTimeline:addFrame(localFrame)

localFrame = ccs.PositionFrame:create()
localFrame:setFrameIndex(60)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setX(-0.0043)
localFrame:setY(0.0025)
PositionTimeline:addFrame(localFrame)

localFrame = ccs.PositionFrame:create()
localFrame:setFrameIndex(80)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setX(-0.0043)
localFrame:setY(0.0025)
PositionTimeline:addFrame(localFrame)

localFrame = ccs.PositionFrame:create()
localFrame:setFrameIndex(90)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setX(-0.0043)
localFrame:setY(0.0025)
PositionTimeline:addFrame(localFrame)

result['animation']:addTimeline(PositionTimeline)
PositionTimeline:setNode(light_qs_1_2)

--Create ScaleTimeline
local ScaleTimeline = ccs.Timeline:create()

localFrame = ccs.ScaleFrame:create()
localFrame:setFrameIndex(50)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setScaleX(0.0100)
localFrame:setScaleY(0.0100)
ScaleTimeline:addFrame(localFrame)

localFrame = ccs.ScaleFrame:create()
localFrame:setFrameIndex(60)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setScaleX(1.8000)
localFrame:setScaleY(1.8000)
ScaleTimeline:addFrame(localFrame)

localFrame = ccs.ScaleFrame:create()
localFrame:setFrameIndex(80)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setScaleX(1.8000)
localFrame:setScaleY(1.8000)
ScaleTimeline:addFrame(localFrame)

localFrame = ccs.ScaleFrame:create()
localFrame:setFrameIndex(90)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setScaleX(0.0100)
localFrame:setScaleY(0.0100)
ScaleTimeline:addFrame(localFrame)

result['animation']:addTimeline(ScaleTimeline)
ScaleTimeline:setNode(light_qs_1_2)

--Create RotationSkewTimeline
local RotationSkewTimeline = ccs.Timeline:create()

localFrame = ccs.RotationSkewFrame:create()
localFrame:setFrameIndex(50)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setSkewX(0.0000)
localFrame:setSkewY(-0.0006)
RotationSkewTimeline:addFrame(localFrame)

localFrame = ccs.RotationSkewFrame:create()
localFrame:setFrameIndex(60)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setSkewX(90.0000)
localFrame:setSkewY(89.9994)
RotationSkewTimeline:addFrame(localFrame)

localFrame = ccs.RotationSkewFrame:create()
localFrame:setFrameIndex(80)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setSkewX(270.0000)
localFrame:setSkewY(269.9994)
RotationSkewTimeline:addFrame(localFrame)

localFrame = ccs.RotationSkewFrame:create()
localFrame:setFrameIndex(90)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setSkewX(360.0000)
localFrame:setSkewY(359.9994)
RotationSkewTimeline:addFrame(localFrame)

result['animation']:addTimeline(RotationSkewTimeline)
RotationSkewTimeline:setNode(light_qs_1_2)

--Create CColorTimeline
local CColorTimeline = ccs.Timeline:create()

localFrame = ccs.ColorFrame:create()
localFrame:setFrameIndex(50)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setColor({r = 187, g = 0, b = 255})
CColorTimeline:addFrame(localFrame)

localFrame = ccs.ColorFrame:create()
localFrame:setFrameIndex(60)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setColor({r = 203, g = 68, b = 255})
CColorTimeline:addFrame(localFrame)

localFrame = ccs.ColorFrame:create()
localFrame:setFrameIndex(80)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setColor({r = 192, g = 22, b = 255})
CColorTimeline:addFrame(localFrame)

localFrame = ccs.ColorFrame:create()
localFrame:setFrameIndex(90)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setColor({r = 187, g = 0, b = 255})
CColorTimeline:addFrame(localFrame)

result['animation']:addTimeline(CColorTimeline)
CColorTimeline:setNode(light_qs_1_2)

--Create AlphaTimeline
local AlphaTimeline = ccs.Timeline:create()

localFrame = ccs.AlphaFrame:create()
localFrame:setFrameIndex(50)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setAlpha(0)
AlphaTimeline:addFrame(localFrame)

localFrame = ccs.AlphaFrame:create()
localFrame:setFrameIndex(60)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setAlpha(255)
AlphaTimeline:addFrame(localFrame)

localFrame = ccs.AlphaFrame:create()
localFrame:setFrameIndex(80)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setAlpha(153)
AlphaTimeline:addFrame(localFrame)

localFrame = ccs.AlphaFrame:create()
localFrame:setFrameIndex(90)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setAlpha(0)
AlphaTimeline:addFrame(localFrame)

result['animation']:addTimeline(AlphaTimeline)
AlphaTimeline:setNode(light_qs_1_2)

--Create PositionTimeline
local PositionTimeline = ccs.Timeline:create()

localFrame = ccs.PositionFrame:create()
localFrame:setFrameIndex(10)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setX(-70.0000)
localFrame:setY(80.0000)
PositionTimeline:addFrame(localFrame)

localFrame = ccs.PositionFrame:create()
localFrame:setFrameIndex(15)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setX(-18.3763)
localFrame:setY(80.0000)
PositionTimeline:addFrame(localFrame)

localFrame = ccs.PositionFrame:create()
localFrame:setFrameIndex(80)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setX(30.0000)
localFrame:setY(80.0000)
PositionTimeline:addFrame(localFrame)

localFrame = ccs.PositionFrame:create()
localFrame:setFrameIndex(90)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setX(40.0000)
localFrame:setY(80.0000)
PositionTimeline:addFrame(localFrame)

result['animation']:addTimeline(PositionTimeline)
PositionTimeline:setNode(fnt)

--Create ScaleTimeline
local ScaleTimeline = ccs.Timeline:create()

localFrame = ccs.ScaleFrame:create()
localFrame:setFrameIndex(10)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setScaleX(1.0000)
localFrame:setScaleY(1.0000)
ScaleTimeline:addFrame(localFrame)

localFrame = ccs.ScaleFrame:create()
localFrame:setFrameIndex(15)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setScaleX(1.0000)
localFrame:setScaleY(1.0000)
ScaleTimeline:addFrame(localFrame)

localFrame = ccs.ScaleFrame:create()
localFrame:setFrameIndex(80)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setScaleX(1.0000)
localFrame:setScaleY(1.0000)
ScaleTimeline:addFrame(localFrame)

localFrame = ccs.ScaleFrame:create()
localFrame:setFrameIndex(90)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setScaleX(0.5000)
localFrame:setScaleY(0.5000)
ScaleTimeline:addFrame(localFrame)

result['animation']:addTimeline(ScaleTimeline)
ScaleTimeline:setNode(fnt)

--Create RotationSkewTimeline
local RotationSkewTimeline = ccs.Timeline:create()

localFrame = ccs.RotationSkewFrame:create()
localFrame:setFrameIndex(10)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setSkewX(0.0000)
localFrame:setSkewY(0.0000)
RotationSkewTimeline:addFrame(localFrame)

localFrame = ccs.RotationSkewFrame:create()
localFrame:setFrameIndex(15)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setSkewX(0.0000)
localFrame:setSkewY(0.0000)
RotationSkewTimeline:addFrame(localFrame)

localFrame = ccs.RotationSkewFrame:create()
localFrame:setFrameIndex(80)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setSkewX(0.0000)
localFrame:setSkewY(0.0000)
RotationSkewTimeline:addFrame(localFrame)

localFrame = ccs.RotationSkewFrame:create()
localFrame:setFrameIndex(90)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setSkewX(360.0000)
localFrame:setSkewY(360.0000)
RotationSkewTimeline:addFrame(localFrame)

result['animation']:addTimeline(RotationSkewTimeline)
RotationSkewTimeline:setNode(fnt)

--Create AlphaTimeline
local AlphaTimeline = ccs.Timeline:create()

localFrame = ccs.AlphaFrame:create()
localFrame:setFrameIndex(10)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setAlpha(0)
AlphaTimeline:addFrame(localFrame)

localFrame = ccs.AlphaFrame:create()
localFrame:setFrameIndex(15)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setAlpha(255)
AlphaTimeline:addFrame(localFrame)

localFrame = ccs.AlphaFrame:create()
localFrame:setFrameIndex(80)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setAlpha(255)
AlphaTimeline:addFrame(localFrame)

localFrame = ccs.AlphaFrame:create()
localFrame:setFrameIndex(90)
localFrame:setTween(true)
localFrame:setTweenType(0)
localFrame:setAlpha(0)
AlphaTimeline:addFrame(localFrame)

result['animation']:addTimeline(AlphaTimeline)
AlphaTimeline:setNode(fnt)
--Create Animation List
local curseani = {name="curseani", startIndex=0, endIndex=90}
result['animation']:addAnimationInfo(curseani)

result['root'] = Node
return result;
end

return Result

