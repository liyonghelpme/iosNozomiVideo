Clan = class(BuildMould)

function Clan:ctor(bid, setting)
    self.level0shadow = true
end

--function Clan:addBuildInfo(bg, addInfoItem)
--	return 0
--end

--function Clan:addBuildUpgrade(bg, addUpgradeItem)
--	local bdata = self.buildData
--	local maxData = StaticData.getMaxLevelData(bdata.bid)
--	local nextLevel = StaticData.getBuildData(bdata.bid, bdata.level+1)
	
--	addUpgradeItem(bg, 1, bdata.extendValue1, nextLevel.extendValue1, maxData.extendValue1, "Camp")
--	return 1
--end

--function Clan:addChildMenuButs(buts)
--	if UserData.clan~=0 then
--		table.insert(buts, {image="images/menuItemRequest.png", text="Request troops", callback=self.requestTroops, callbackParam=self})
--	end
--	table.insert(buts, {image="images/menuItemLeague.png", text="League", callback=display.showDialog, callbackParam=ClanDialog})
--end

--function Clan:requestTroops()
--	network.httpRequest("http://uhz000738.chinaw3.com:8004/request", doNothing, {params={uid=UserData.userId, cid=UserData.clan, name=UserData.userName, space=10}})
--	EventManager.sendMessage("EVENT_OTHER_OPERATION", {type="Add", key="donate"})
--end

function Clan:getBuildView()
	local bid = self.buildData.bid
	local level = self.buildData.level
	
	local build  = UI.createSpriteWithFile("images/build/" .. bid .. "/league" .. level .. ".png")





	return build
end

function Clan:changeNightMode(isNight)
	local bid = self.buildData.bid
	local build = self.buildView.build
	if self.buildLevel<3 or not build then return end
	if isNight then
		local ox = build:getContentSize().width/2

        local sp = {nodeAnchor=General.anchorBottom, x=ox, y=49}
        
		local light = UI.createSpriteWithFile("images/build/" .. bid .. "/leagueLight3.png")
		screen.autoSuitable(light, sp)
		build:addChild(light, 10, TAG_LIGHT)
	else
		local light = build:getChildByTag(TAG_LIGHT)
		if light then
			light:removeFromParentAndCleanup(true)
		end
	end
end

function Clan:getLevel0Build()
	local gsize = self.buildData.gridSize
	local temp = UI.createSpriteWithFile("images/build/2/league0.png")
	screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=138, y=getParam("buildViewOffy2", 0)})

    local build = temp

	return temp
end

function Clan:rebuilt()
    display.pushNotice(UI.createNotice(StringManager.getString("noticeUnlockFunction")))
end

function Clan:getBuildShadow()
    return self:getShadow("images/shadowGrid.png", -106, 23, 212, 163)
end
