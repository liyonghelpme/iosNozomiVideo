require "Mould.SceneObj"
FallGoods = {}

do
	FallGoods.create = function(gid, scene, setting)
		local gx, gy=0
		while true do
			gx = 2+math.random(88)
			gy = 5+math.random(37)
			if gx%2==gy%2 and not scene.mapGrid.checkGridUsed(gx, gy, 1, 1) then
				break
			end
		end
		local position = scene.mapGrid.convertToPosition(gx, gy, 1, 1)
		local obj = UI.createSpriteWithFile("images/goods/goods" .. gid .. ".png")
		
		screen.autoSuitable(obj, {nodeAnchor=General.anchorBottom, x=position.posX, y=position.posY+216})
		obj:setScale(0.5)
		obj:runAction(CCEaseBounceOut:create(CCMoveBy:create(getParam("fallTime")/1000, CCPointMake(0, -200))))
		scene.fallNum=scene.fallNum+1
		
		local shadow = UI.createSpriteWithFile("images/goodsShadow.png")
		screen.autoSuitable(shadow, {nodeAnchor=General.anchorCenter, x=position.posX, y=position.posY+16})
		scene.ground:addChild(shadow, 1120-position.posY)
		
		local function pickFallObj()
			EventManager.sendMessage("EVENT_PICKFLY", {gain={silver=60, exp=200}, obj=obj})
			obj:removeFromParentAndCleanup(true)
			shadow:removeFromParentAndCleanup(true)
			scene.mapGrid.setGridUse(false, gx, gy)
			scene.fallNum = scene.fallNum-1
		end
		SceneObj.registerSceneObj(obj, scene, {gridPosX=gx, gridPosY=gy, gridSizeX=1, gridSizeY=1}, pickFallObj)
		
		scene.ground:addChild(obj, 1120-position.posY)
	end
end