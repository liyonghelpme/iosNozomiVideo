Action = nil
do
	local PI = 3.14159265358979323846
	-- 用于创建一个移来移去的动画
	local function createVibration(duration, x, y)
		local sactions = CCArray:create()
		sactions:addObject(CCMoveBy:create(duration, CCPointMake(x, y)))
		sactions:addObject(CCMoveBy:create(duration, CCPointMake(-x, -y)))
		return CCRepeatForever:create(CCSequence:create(sactions))
	end
	
	-- 用于创建一个不停缩放的动画
	local function createScaleVibration(duration, scale)
		local sactions = CCArray:create()
		sactions:addObject(CCScaleTo:create(duration, 1 + scale))
		sactions:addObject(CCScaleTo:create(duration, 1))
		return CCRepeatForever:create(CCSequence:create(sactions))
	end
	
	local function sineout(t)
		if t >= 1 then return 1 end
		return math.sin(t*PI/2)
	end
	
	local function sinein(t)
		if t >= 1 then return 1 end
		return 1-math.cos(t*PI/2)
	end
	
	Action = {createScaleVibration = createScaleVibration, createVibration = createVibration; sineout = sineout, sinein = sinein}
	
	-- 直接runAction是因为需要设置旋转角度
	function Action.runGravityMove(node, t, fx, fy, tx, ty, fh, th)
		
		local g = 500
		local t1 = t/2+(th-fh)/(g*t)
		-- 避免数值不符合逻辑
		if t1<0 then
		    t1=0
		    g=-2*(th-fh)/t/t
		elseif t1>t then
		    t1=t
		    g=2*(th-fh)/t/t
		end
		local ox, oy = tx-fx, ty-fy+fh-th
		local H = t1*t1*g/2+fh
		local mx, my = fx+t1/t*ox, fy+t1/t*oy+H-fh
		local array = CCArray:create()
		array:addObject(CCEaseSineOut:create(CCMoveBy:create(t1, CCPointMake(0, H-fh))))
		array:addObject(CCEaseIn:create(CCMoveBy:create(t-t1, CCPointMake(0, th-H)), 2))
		
	    local sarray = CCArray:create()
		sarray:addObject(CCSequence:create(array))
		
		sarray:addObject(CCMoveBy:create(t, CCPointMake(ox, oy)))
		
		--local mx, my = fx+t1/t*ox, fy+t1/t*oy+H-fh
		local baseAngle = node:getRotation()
		local angle1 = 360-math.deg(math.atan2(oy/2+H-fh, ox/2))
		local angle2 = 360-math.deg(math.atan2(oy/2+th-H, ox/2))
		--local angle1 = 270 - math.deg(math.atan2(H-h, (mx-self.initPos[1])/2))
		--local angle2 = 270 - math.deg(math.atan2(-H, (self.targetPos[1]-mx)/2))
		node:setRotation(angle1+baseAngle)
		sarray:addObject(CCRotateTo:create(t, angle2+baseAngle))
		
		node:runAction(CCSpawn:create(sarray))
	end
	
	function Action.runBlinkAction(node)
	    local array = CCArray:create()
	    local n = 2+math.random(7)
	    array:addObject(CCBlink:create(0.15*n, n))
	    array:addObject(CCDelayTime:create(1+math.random()*2))
	    array:addObject(CCCallFuncN:create(Action.runBlinkAction))
	    node:runAction(CCSequence:create(array))
	end
	
	function Action.createFrameAnimate(t, prefix, endNum, setting)
	    setting = setting or {}
	    local beginNum = setting.beginNum or 0
	    local suffix = setting.suffix or ".png"
        local animation = CCAnimation:create()
        for i = beginNum, endNum do
    	    animation:addSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(prefix .. i .. suffix))
    	end
    	
    	if setting.rollback then
    	    local rollnum = setting.rollnum or 0
    	    for i=1, rollnum do
    	        animation:addSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(prefix .. endNum .. suffix))
    	    end
    	    for i=endNum-1, beginNum+1, -1 do
    	        animation:addSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(prefix .. i .. suffix))
    	    end
	    	animation:setDelayPerUnit(t/((endNum-beginNum)*2+rollnum))
	    	animation:setRestoreOriginalFrame(true)
	    else
	    	animation:setDelayPerUnit(t/(endNum-beginNum+1))
	    	animation:setRestoreOriginalFrame(false)
    	end
    	return CCAnimate:create(animation)
	end
end