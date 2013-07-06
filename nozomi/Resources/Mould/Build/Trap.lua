Trap = class(Defense)

function Trap:ctor()
	self.hiddenSupport = true
	self.buildContinue = true
end

function Trap:getBuildBottom()
end


function Trap:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local build = UI.createSpriteWithFrame("build" .. bid .. ".png", nil, true)
	
	if bid~=5002 then
		local temp = UI.createSpriteWithFrame("build" .. bid .. "a.png")
		local array = CCArray:create()
		array:addObject(CCFadeOut:create(0.25))
		array:addObject(CCFadeIn:create(0.25))
		temp:runAction(CCRepeatForever:create(CCSequence:create(array)))
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=build:getContentSize().width/2})
		build:addChild(temp, 1)
	end
	return build
end

function Trap:changeNightMode(isNight)
	local bid = self.buildData.bid
	local level = self.buildData.level
	local build = self.buildView.build
	if not build then return end
	if isNight then
	else
	end
end

function Trap:attack(target)
	local build = self.buildView
	local p = {build.view:getPosition()}
	p[1] = p[1] + 2
	p[2] = p[2] + 256
	p[3] = build.scene.SIZEY - p[2]
	local shot = MagicShot.new(self.buildData.extendValue1*self.defenseData.attackSpeed, 180, p[1], p[2], p[3], target, self.buildLevel)
	shot:addToScene(build.scene)
	self.coldTime = self.defenseData.attackSpeed
end

function Trap:enterBattle()
	self.hidden = true
	self.buildView.view:setVisible(false)
end

function Trap:attack(target)
	self.hidden = false
	self.buildView.view:setVisible(true)
	self.coldTime = 1000
	delayCallback(self.defenseData.attackSpeed, self.bomb, self)
end

function Trap:bomb()
    if self.buildView.scene.sceneType==SceneTypes.Zombie or self.buildView.scene.sceneType==SceneTypes.Battle then
    	BattleLogic.costTrap(self.id)
    end
	local build = self.buildView
	local p = {build.view:getPosition()}
	p[2] = p[2] + build.view:getContentSize().height/2
	p[3] = build.scene.SIZEY - p[2]
	local attackValue = self.buildData.extendValue1
	local bid = self.buildData.bid
	local t = getParam("actionTimeBomb", 500)/1000
	local n = 9
	build.deleted = true
	self.deleted = true
	if bid==5001 then
		n=15
		local temp = UI.createSpriteWithFrame("build5001b.png")
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=build.build:getContentSize().width/2})
		build.build:addChild(temp)
	    music.playCleverEffect("music/thunder.mp3")
		delayRemove(0.25, build.view)
	else
		local t = 1.4
		local temp = UI.createAnimateWithSpritesheet(t, "bombNormal_", 13, {plist="animate/effects/normalEffect.plist", isRepeat=false})
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=p[1], y=p[2]})
		build.scene.effectBatch:addChild(temp, p[3])
		delayRemove(t, temp)
		build.view:removeFromParentAndCleanup(true)
	    music.playCleverEffect("music/bomb" .. bid .. ".mp3")
	end
	local bomb = UI.createAnimateWithSpritesheet(t, "bomb" .. self.buildData.bid .. "_", n, {plist="animate/build/traps/bomb" .. self.buildData.bid .. ".plist", isRepeat=false})
	screen.autoSuitable(bomb, {nodeAnchor=General.anchorCenter, x=p[1], y=p[2]})
	build.scene.ground:addChild(bomb, p[3])
	delayRemove(t, bomb)
	
	for _, soldier in pairs(build.scene.soldiers) do
		if not soldier.deleted then
			local x, y = soldier.view:getPosition()
			local dis = build.scene.mapGrid:getGridDistance(x-p[1], y-p[2])
			print(dis,  self.defenseData.damageRange)
			if dis < self.defenseData.damageRange then
			    if bid==5001 then
			        local v = soldier.hitpoints
			        soldier:damage(v)
			        attackValue = attackValue-v
			        if attackValue<=0 then
			            break
			        end
			    else
    				soldier:damage(attackValue)
    		    end
			end
		end
	end
end

function Trap:getChildMenuButs()
	local buts = {}
	local bdata = self.buildData
	if self.buildView.scene.sceneType==SceneTypes.Operation then
		table.insert(buts, {image="images/menuItelSell.png", text=StringManager.getString("buttonSell"), callback=self.sell, callbackParam=self})
	end
	return buts
end