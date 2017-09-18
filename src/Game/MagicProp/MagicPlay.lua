local MagicPlay = class("MagicPlay", nil)

MagicPlay.BASE_PATH = "res/battle/magicprop/magicproppic/"

MagicPlay.magicPropConfigs = {}
local start_index = 410000000
local yMargin = 100

MagicPlay.HAMMER	= 1
MagicPlay.EGG 		= 2
MagicPlay.CAKE 		= 3
MagicPlay.GUN 		= 4
MagicPlay.PULLDOWN 	= 5

local RightWard = 1
local UpWard = 2
local LeftWard = 3
local DownWard = 4
local RightupWard = 5
local LeftdownWard = 6
local RightdownWard = 7
local LeftupWard = 8

local directAngel = {
}

-----------------------------------------------------------------

function MagicPlay:create()
    local MagicPlay = MagicPlay.new();
	MagicPlay:init()
    return MagicPlay;
end


function MagicPlay:init()
	local scaleX, scaleY = FishGF.getCurScale()
	self.scaleX_ = scaleX
	self.scaleY_ = scaleY

	self.img_rect = cc.rect(0, 0, 300, 300)

	MagicPlay.magicPropConfigs = {}
	self:initData()
	self:initRotateAngle()
end

-----------------------------------------------------------------
-- from, to: seatId FishCD.DIRECT.LEFT_DOWN ...
function MagicPlay:playHammer(from, to)
	log("playHammer")
	self:play(from, to, MagicPlay.HAMMER)
end

function MagicPlay:playEgg(from, to)
	log("playEgg")
	self:play(from, to, MagicPlay.EGG)
end

function MagicPlay:playCake(from, to)
	log("playCake")
	self:play(from, to, MagicPlay.CAKE)
end

function MagicPlay:playBiuBiu(from, to)
	log("playGun")
	self:play(from, to, MagicPlay.GUN)
end

function MagicPlay:playPullDown(from, to)
	log("playPullDown")
	self:play(from, to, MagicPlay.PULLDOWN)
end

function MagicPlay:play(from, to, propId)
	log("play")

	self:playAnimation(from, to, propId)
end

---------------------------------------------------
function MagicPlay:playAnimation(from, to, propId)
	local dbPara = MagicPlay.magicPropConfigs[propId]
	local revert = false

	if propId == MagicPlay.GUN then
		revert = not self:isPosRight(from)
		self:doPlayGun(from, to, dbPara.magicprop_res, self.img_rect, revert)
		return

	elseif propId == MagicPlay.EGG then
		self:doPlayEgg(from, to, dbPara.magicprop_res, self.img_rect, isRevert, {360, 0.5}, 7)
		return

	elseif propId == MagicPlay.CAKE then
		self:doPlayCake(from, to, dbPara.magicprop_res, self.img_rect)
		return

	elseif propId == MagicPlay.HAMMER then 
		revert = self:isPosRight(from)
		self:doPlayHammer(from, to, dbPara.magicprop_res, self.img_rect, revert)
		return
	elseif propId == MagicPlay.PULLDOWN then
		self:doPlayPullDown(from, to, dbPara.magicprop_res, self.img_rect, false, nil, 12)
		return
	end

	--self:doPlay(from, to, dbPara.magicprop_res, rect, revert)

end

function MagicPlay:createAction(headName, istart, iFrmes, rect, frameRate)	
    local animation = cc.Animation:create()
    for i = istart, istart + iFrmes - 1 do
    	log(MagicPlay.BASE_PATH..headName.."_" .. i ..".png")
    	local frame = cc.SpriteFrame:create(MagicPlay.BASE_PATH..headName.."_" .. i ..".png", rect)
    	animation:addSpriteFrame(frame)
    end
    animation:setDelayPerUnit(frameRate)

    local action = cc.Animate:create(animation)

    return action
end

function MagicPlay:animateDecor(spr, from, to, funAfterMove, action, delayTime, funcEnd)
	log("from: ", self:getTargetPos(from).x, self:getTargetPos(from).y, "to: ", self:getTargetPos(to).x, self:getTargetPos(to).y)
    local move = {}
    move[#move + 1] = cc.MoveTo:create(0.5, self:getTargetPos(to))
    move[#move + 1] = cc.CallFunc:create(funAfterMove)
    move[#move + 1] = cc.Repeat:create(action, 1)
    if delayTime then
    	move[#move + 1] = cc.DelayTime:create(delayTime)
	end
    move[#move + 1] = cc.CallFunc:create(funcEnd)
  
    local sequence = transition.sequence(move)

	spr:setPosition(self:getTargetPos(from))
	spr:runAction(sequence)
end

function MagicPlay:rotationDecor(spr, rotation)
	local rotate = {}
    rotate[#rotate + 1] = cc.RotateBy:create(rotation[2], rotation[1])

    local seq = transition.sequence(rotate)
	spr:runAction(seq)
end

function MagicPlay:doPlayEgg(from, to, headName, rect, isRevert, rotation, iFrmes)

	local angle = self:getAngle(from, to)	
	local sprite_bgr = cc.Sprite:create()
	local sprite = self:loadPropSpr(headName, 0)
	local action = self:createAction(headName, 1, iFrmes, rect, 0.1)

	
    self:animateDecor(sprite_bgr, 
    					from, to, 
    					function ( ... ) sprite:removeFromParent()  FishGI.AudioControl:playEffect("sound/magicprop02.mp3") end, 
    					action,
    					1.5 ,
    					function(...) sprite_bgr:removeFromParent() end)

	if isRevert then sprite_bgr:setRotationSkewY(180) end

	if rotation then self:rotationDecor(sprite, rotation) end


	sprite_bgr:addChild(sprite)

	local layer = FishGI.gameScene
	if FishGI.FRIEND_ROOM_STATUS ~= 0 then
		layer = FishGI.gameScene.uiMainLayer
	end
	layer:addChild(sprite_bgr, FishCD.ORDER_GAME_magicprop)
end

function MagicPlay:doPlayPullDown(from, to, headName, rect, isRevert, rotation, iFrmes)

	local angle = self:getAngle(from, to)	
	local sprite_bgr = cc.Sprite:create()
	local sprite = self:loadPropSpr(headName, 0)
	local action = self:createAction(headName, 1, iFrmes, rect, 0.1)

	 
    self:animateDecor(sprite_bgr, 
    					from, to, 
    					function ( ... ) sprite:removeFromParent()  FishGI.AudioControl:playEffect("sound/magicprop05.mp3")end, 
    					action,
    					1.5 ,
    					function(...) sprite_bgr:removeFromParent() end)

	if isRevert then sprite_bgr:setRotationSkewY(180) end

	if rotation then self:rotationDecor(sprite, rotation) end


	sprite_bgr:addChild(sprite)

	local layer = FishGI.gameScene
	if FishGI.FRIEND_ROOM_STATUS ~= 0 then
		layer = FishGI.gameScene.uiMainLayer
	end
	layer:addChild(sprite_bgr, FishCD.ORDER_GAME_magicprop)
end

function MagicPlay:doPlayGun(from, to, headName, rect, revert)
	log("doPlayGun")
	local shooter 		= cc.Sprite:create()
	local shootlayer 	= cc.Sprite:create()
	local target  		= cc.Sprite:create()

	local fireAction = self:createFireAction(headName, 3, rect, 0.05)
	local bulletAction = self:createBulletAction(headName, 10, rect, 0.15)

	FishGI.AudioControl:playEffect("sound/magicprop04.mp3") 
	local angle = self:getAngle(from, to)
	if revert then 
		shooter:setRotationSkewY(-180)
		shootlayer:setRotation(-angle)
	else
		shootlayer:setRotation(180 - angle)
	end

	log("angle: " .. angle)
	log("revert: " .. tostring(revert))

	self:decorFireAnimate(shooter, fireAction)

	self:decorBulletAnimate(target, bulletAction)

	shootlayer:addChild(shooter)
	shootlayer:setPosition(self:getTargetPos(from))
	target:setPosition(self:getTargetPos(to))

	local layer = FishGI.gameScene
	if FishGI.FRIEND_ROOM_STATUS ~= 0 then
		layer = FishGI.gameScene.uiMainLayer
	end

	layer:addChild(shootlayer, FishCD.ORDER_GAME_magicprop)
	layer:addChild(target, FishCD.ORDER_GAME_magicprop)
end

function MagicPlay:doPlayCake(from, to, headName, rect)
	log("doPlayEgg")
	local sprite_bgr = cc.Sprite:create()
	local sprite = self:loadPropSpr(headName, 0)

	local action1 = self:createAction(headName, 1, 7, rect, 0.1)
	local action2 = self:createAction(headName, 8, 3, rect, 0.1)

	local actions = {}
	actions[#actions + 1] = action1
	actions[#actions + 1] = cc.Repeat:create(action2, 7)

	
	local action = transition.sequence(actions)

    self:animateDecor(sprite_bgr, 
    					from, to, 
    					function ( ... ) sprite:removeFromParent() FishGI.AudioControl:playEffect("sound/magicprop03.mp3")  end, 
    					action,
    					nil ,
    					function(...) sprite_bgr:removeFromParent() end)

	sprite_bgr:addChild(sprite)

	local layer = FishGI.gameScene
	if FishGI.FRIEND_ROOM_STATUS ~= 0 then
		layer = FishGI.gameScene.uiMainLayer
	end

	layer:addChild(sprite_bgr, FishCD.ORDER_GAME_magicprop)

end

function MagicPlay:doPlayHammer(from, to, headName, rect, isRevert)
	log("doPlayHammer")
	local angle = self:getAngle(from, to)	
	local sprite_bgr = cc.Sprite:create()
	local sprite = self:loadPropSpr(headName, 0)

	local action1 = self:createAction(headName, 1, 2, rect, 0.1)
	local action2 = self:createAction(headName, 3, 5, rect, 0.1)
	local action3 = self:createAction(headName, 8, 2, rect, 0.1)
	local action4 = self:createAction(headName, 9, 4, rect, 0.1)
	local action5 = self:createAction(headName, 13, 1, rect, 0.1)

	local actions = {}
	actions[#actions + 1] = action1
	actions[#actions + 1] = cc.Repeat:create(action2, 3)
	actions[#actions + 1] = action3
	actions[#actions + 1] = cc.Repeat:create(action4, 3)
	actions[#actions + 1] = action5

	
	local action = transition.sequence(actions)

    self:animateDecor(sprite_bgr, 
    					from, to, 
    					function ( ... ) sprite:removeFromParent() FishGI.AudioControl:playEffect("sound/magicprop01.mp3") end, 
    					action,
    					nil ,
    					function(...) sprite_bgr:removeFromParent() end)

	if isRevert then sprite_bgr:setRotationSkewY(180) end

	--if rotation then self:rotationDecor(sprite, rotation) end

	sprite_bgr:addChild(sprite)

	local layer = FishGI.gameScene
	if FishGI.FRIEND_ROOM_STATUS ~= 0 then
		layer = FishGI.gameScene.uiMainLayer
	end
	layer:addChild(sprite_bgr, FishCD.ORDER_GAME_magicprop)

end

function MagicPlay:decorFireAnimate(shooter, fireAction)
	self:docorRepeat(shooter, fireAction, 10)
end

function MagicPlay:decorBulletAnimate(target, bulletAction)
	self:docorRepeat(target, bulletAction, 1, 1.5)
end

function MagicPlay:docorRepeat(sprite, action, times, delay)
	local act = {}
    act[#act + 1] = cc.Repeat:create(action, times)
    if delay then
    		act[#act + 1] = cc.DelayTime:create(delay)
    	end

    act[#act + 1] = cc.CallFunc:create(function ( ... )

    									sprite:removeFromParent()

    									end)

    local seq = transition.sequence(act)
	sprite:runAction(seq)
end

function MagicPlay:createFireAction(headName, iFrmes, rect, fireDuration)
	return self:createAction(headName, 0, iFrmes, rect, fireDuration)
end

function MagicPlay:createBulletAction(headName, iFrmes, rect, fireDuration)
	return self:createAction(headName, 3, iFrmes, rect, fireDuration)
end

-----------------------------------------------------------------------------------
function MagicPlay:getAngelBetweenPos(posFrom, posTo)

	local scalePosFrom 	= 	cc.p(posFrom.x * self.scaleX_, posFrom.y * self.scaleY_)
	local scalePosTo 	= 	cc.p(posTo.x * self.scaleX_, posTo.y * self.scaleY_)

	-- 去掉偏移影响
	local posDst = cc.p(scalePosTo.x - scalePosFrom.x, scalePosTo.y - scalePosFrom.y)

	return (cc.pGetAngle(cc.p(0, 0), posDst)/math.pi) * 180
end

function MagicPlay:getTargetPos(pos)
	local y = math.abs(FishCD.posTab[pos].y - yMargin)
	if self:isPosUP(pos) then
		y = y + 30   -- 威力需求: 上面与边距增加5
	end

	return self:toScaledPos(FishCD.posTab[pos].x , y)
end

function MagicPlay:toScaledPos(x, y)
	return cc.p(x * self.scaleX_, y * self.scaleY_)
end

function MagicPlay:isPosRight(pos)
	return pos == FishCD.DIRECT.RIGHT_DOWN
			or pos == FishCD.DIRECT.RIGHT_UP
end

function MagicPlay:isPosUP(pos)
	return pos == FishCD.DIRECT.LEFT_UP
			or pos == FishCD.DIRECT.RIGHT_UP
end

function MagicPlay:isARightofB(xA, xB) return xA > xB end

function MagicPlay:isALeftofB(xA, xB) return xA < xB end

function MagicPlay:isXEqual(xA, xB) return xA == xB end

function MagicPlay:isYEqual(yA, yB) return yA == yB end

function MagicPlay:isATopofB(yA, yB) return yA > yB end

function MagicPlay:isABottomofB(yA, yB) return yA < yB end

---------------------------------------------------------------------------------
function MagicPlay:getAngle(from, to)
	local direction
	local posFrom = FishCD.posTab[from]
	local posTo 	= FishCD.posTab[to]

	if self:isXEqual(posFrom.x, posTo.x) then

		if self:isATopofB(posFrom.y, posTo.y) then direction = DownWard

		elseif self:isABottomofB(posFrom.y, posTo.y) then direction = UpWard
		end

	elseif self:isARightofB(posFrom.x, posTo.x) then

		if self:isYEqual(posFrom.y, posTo.y) then direction = LeftWard

		elseif self:isATopofB(posFrom.y, posTo.y) then direction = LeftdownWard

		elseif self:isABottomofB(posFrom.y, posTo.y) then direction = LeftupWard
		end

	elseif self:isALeftofB(posFrom.x, posTo.x) then

		if self:isYEqual(posFrom.y, posTo.y) then direction = RightWard
		
		elseif self:isATopofB(posFrom.y, posTo.y) then direction = RightdownWard

		elseif self:isABottomofB(posFrom.y, posTo.y) then direction = RightupWard
		end

	end

	log("direction: " .. direction)

	return directAngel[direction]
end

------------------------------------------------------------------------------------
function MagicPlay:loadPropSpr(headName, index)
    local sprite = cc.Sprite:create(MagicPlay.BASE_PATH .. headName .. "_" .. index .. ".png")
    return sprite
end

function MagicPlay:initData()
	log("MagicPlay:initData")
	local i = 1
	self.propImgs = {}
    repeat
		log("MagicPlay:initData: " .. tostring(i))
        local id 			= FishGI.GameConfig:getConfigData("magicprop", tostring(start_index + i), "id")
        if string.len(id) == 0 then
            break;
        end

        local cystal 		= FishGI.GameConfig:getConfigData("magicprop", tostring(start_index + i), "crystal_need")
        local unlockvip 	= FishGI.GameConfig:getConfigData("magicprop", tostring(start_index + i), "unlock_vip")
        local magicprop_res = FishGI.GameConfig:getConfigData("magicprop", tostring(start_index + i), "magicprop_res")

        local line = {}

        line.id = tonumber(id)
        line.cystal_need = tonumber(cystal)
        line.unlock_vip = tonumber(unlockvip)
        line.magicprop_res = magicprop_res

        MagicPlay.magicPropConfigs[#MagicPlay.magicPropConfigs + 1] = line
        self:initPropUI(magicprop_res, i)
        i = i + 1
    until false
end

function MagicPlay:getPropCrystal(propId)
	for k,v in pairs(MagicPlay.magicPropConfigs) do
		if v.id == (start_index + propId) then
			return v.cystal_need
		end
	end
end

function MagicPlay:getPropVipLevel(propId)
	for k,v in pairs(MagicPlay.magicPropConfigs) do
		if v.id == (start_index + propId) then
			return v.unlock_vip
		end
	end
end

function MagicPlay:initPropUI(magicprop_res, i)
    local propImg = cc.Sprite:create(MagicPlay.BASE_PATH .. magicprop_res .. ".png")

    propImg:setAnchorPoint(0, 0)
    propImg:setPosition(0, 0)

    log("MagicPlay.propImgs: " .. tostring(#self.propImgs))
    self.propImgs[#self.propImgs + 1] = propImg
end



--[[
local RightWard = 1
local UpWard = 2
local LeftWard = 3
local DownWard = 4
local RightupWard = 5
local LeftdownWard = 6
local RightdownWard = 7
local LeftupWard = 8
]]

--[[
FishCD.posTab = {};
FishCD.posTab[FishCD.DIRECT.LEFT_UP]       = cc.p(332.43, 720);
FishCD.posTab[FishCD.DIRECT.LEFT_DOWN]     = cc.p(332.43, 0);
FishCD.posTab[FishCD.DIRECT.RIGHT_UP]      = cc.p(945.05, 720);
FishCD.posTab[FishCD.DIRECT.RIGHT_DOWN]    = cc.p(945.05, 0);
]]

function MagicPlay:initRotateAngle()

	directAngel[RightWard] 		= self:getAngelBetweenPos(FishCD.posTab[FishCD.DIRECT.LEFT_DOWN]	, FishCD.posTab[FishCD.DIRECT.RIGHT_DOWN])

	directAngel[UpWard] 		= self:getAngelBetweenPos(FishCD.posTab[FishCD.DIRECT.LEFT_DOWN]	, FishCD.posTab[FishCD.DIRECT.LEFT_UP])

	directAngel[LeftWard] 		= self:getAngelBetweenPos(FishCD.posTab[FishCD.DIRECT.RIGHT_DOWN], FishCD.posTab[FishCD.DIRECT.LEFT_DOWN])

	directAngel[DownWard] 		= self:getAngelBetweenPos(FishCD.posTab[FishCD.DIRECT.LEFT_UP]	, FishCD.posTab[FishCD.DIRECT.LEFT_DOWN])

	directAngel[RightupWard] 	= self:getAngelBetweenPos(FishCD.posTab[FishCD.DIRECT.LEFT_DOWN]	, FishCD.posTab[FishCD.DIRECT.RIGHT_UP])

	directAngel[LeftdownWard] 	= self:getAngelBetweenPos(FishCD.posTab[FishCD.DIRECT.RIGHT_UP]	, FishCD.posTab[FishCD.DIRECT.LEFT_DOWN])

	directAngel[RightdownWard] 	= self:getAngelBetweenPos(FishCD.posTab[FishCD.DIRECT.LEFT_UP]	, FishCD.posTab[FishCD.DIRECT.RIGHT_DOWN])

	directAngel[LeftupWard] 	= self:getAngelBetweenPos(FishCD.posTab[FishCD.DIRECT.RIGHT_DOWN], FishCD.posTab[FishCD.DIRECT.LEFT_UP])
end


return MagicPlay