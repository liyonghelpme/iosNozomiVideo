Dector = class(BuildMould)

function Dector:ctor(bid, setting, isFlag)
    self.isFlag = isFlag
    self.hiddenSupport = true
end


function Dector:getBuildView()
	local bid = self.buildData.bid
	
	if self.isFlag then
	    local build = UI.createSpriteWithFile("images/build/1000/flag5.png")
	    local flag = UI.createAnimateWithSpritesheet(1, "flag" .. bid .. "_", 6, {plist="animate/build/dectors/flag" .. bid .. ".plist"})
	    screen.autoSuitable(flag, {nodeAnchor=General.anchorCenter, x=build:getContentSize().width/2+30, y=115})
	    build:addChild(flag)
	    return build
	else
    	local build = UI.createSpriteWithFrame("build" .. bid .. ".png")
	    return build
    end
end

function Dector:touchTest(x, y)
    if not self.isFlag then
	    return false
	else
	    return isTouchInNode(self.buildView.build, x, y)
	end
end

function Dector:getBuildShadow()
    if not self.isFlag then
	    return self:getShadow("images/shadowCircle.png", -63, 33, 111, 77)
    end
end

function Dector:getChildMenuButs()
	local buts = {}
	local bdata = self.buildData
	if self.buildView.scene.sceneType==SceneTypes.Operation then
		table.insert(buts, {image="images/menuItelSell.png", text=StringManager.getString("buttonSell"), callback=self.sell, callbackParam=self})
	end
	return buts
end
