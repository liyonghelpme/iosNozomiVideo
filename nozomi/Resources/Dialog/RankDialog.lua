RankDialog = class(ClanDialog)

local function updateRankCell(bg, scrollView, info)
--[[
    local img = "images/dialogItemRankCellBg.png"
	if info.uid == UserData.userId then
	    img = "images/dialogItemRankCellBgB.png"
	    info.name = UserData.userName
	end
	local temp = UI.createSpriteWithFile(img, CCSizeMake(820, 59))
	screen.autoSuitable(temp, {x=0, y=0})
	bg:addChild(temp)
	--]]

    local imageFile = "images/dialogItemLeagueA.png"
    if info.uid==UserData.userId then
        imageFile = "images/dialogItemLeagueA2.png"
    end
    local temp = UI.createSpriteWithFile(imageFile,CCSizeMake(986, 58))
    screen.autoSuitable(temp) --, {x=17, y=362})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/dialogItemRankScoreBg.png",CCSizeMake(156, 41))
    screen.autoSuitable(temp, {x=823, y=10})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/score.png",CCSizeMake(37, 42))
    screen.autoSuitable(temp, {x=934, y=10})
    bg:addChild(temp)
    temp = UI.createLabel(tostring(info.score), General.font4, 23, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
    screen.autoSuitable(temp, {x=888, y=31, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/dialogItemHistorySeperator.png",CCSizeMake(2, 55))
    screen.autoSuitable(temp, {x=115, y=2})
    bg:addChild(temp)
	local rgb = RANK_COLOR[info.rank] or {255, 255, 255}
    temp = UI.createLabel(info.rank .. ".", General.font4, 23, {colorR = rgb[1], colorG = rgb[2], colorB = rgb[3], lineOffset=-12})
    screen.autoSuitable(temp, {x=41, y=29, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    --[[
    temp = UI.createSpriteWithFile("images/rankDownIcon.png",CCSizeMake(17, 18))
    screen.autoSuitable(temp, {x=99, y=384})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("999+"), General.font1, 13, {colorR = 179, colorG = 41, colorB = 46})
    screen.autoSuitable(temp, {x=95, y=376, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    
    
	if info.lastRank and info.lastRank>0 then
	    local rankChange = info.rank - info.lastRank
	    if rankChange==0 then
            temp = UI.createSpriteWithFile("images/rankEqualIcon.png",CCSizeMake(16, 13))
            screen.autoSuitable(temp, {x=85, y=21})
            bg:addChild(temp)
	    elseif rankChange<0 then
            temp = UI.createSpriteWithFile("images/rankUpIcon.png",CCSizeMake(17, 18))
            screen.autoSuitable(temp, {x=84, y=32})
            bg:addChild(temp)
            rankChange = math.abs(rankChange)
            if rankChange>999 then rankChange=999 end
            temp = UI.createLabel(tostring(rankChange), General.font1, 13, {colorR = 109, colorG = 130, colorB = 44})
            screen.autoSuitable(temp, {x=91, y=17, nodeAnchor=General.anchorCenter})
            bg:addChild(temp)
	    else
    	    temp = UI.createSpriteWithFile("images/rankDownIcon.png",CCSizeMake(17, 18))
            screen.autoSuitable(temp, {x=84, y=25})
            bg:addChild(temp)
            if rankChange>999 then rankChange=999 end
            temp = UI.createLabel(tostring(rankChange), General.font1, 13, {colorR = 179, colorG = 41, colorB = 46})
            screen.autoSuitable(temp, {x=91, y=17, nodeAnchor=General.anchorCenter})
            bg:addChild(temp)
	    end
	end
    --]]
	if info.clan then
        temp = UI.createLabel(info.clan, General.font5, 15, {colorR = 90, colorG = 81, colorB = 74})
        screen.autoSuitable(temp, {x=154, y=14, nodeAnchor=General.anchorLeft})
        bg:addChild(temp)
        temp = UI.createSpriteWithFile("images/leagueIcon/" .. info.icon .. ".png",CCSizeMake(20, 22))
        screen.autoSuitable(temp, {x=132, y=3})
        bg:addChild(temp)
	end
    temp = UI.createLabel(info.name, General.font6, 18, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=134, y=34, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
	local w = temp:getContentSize().width * temp:getScaleX()
	if info.uid~=UserData.userId then
    	temp = UI.createSpriteWithFile("images/chatRoomItemVisit.png",CCSizeMake(26, 26))
    	screen.autoSuitable(temp, {x=136+w, y=22})
    	bg:addChild(temp)
    	UI.registerVisitIcon(bg, scrollView, info.dialog.view, info.uid, temp)
    end
end

function RankDialog:addRankScroll(bg)
	if self.deleted then return end
	local tag = 101
	local c = bg:getChildByTag(tag)
	if c then
		c:removeFromParentAndCleanup(true)
	end
	
	for _, info in ipairs(self.rankInfos) do
		info.bg = bg
		info.dialog = self
		--info.clan = StringManager.getString("defaultLeague")
	end
	--local scrollView = UI.createScrollViewAuto(CCSizeMake(830, 536), false, {offx=5, offy=4, disy=8, size=CCSizeMake(820, 59), infos=self.rankInfos, cellUpdate=updateRankCell})
	--screen.autoSuitable(scrollView.view, {x=28, y=26})
	--bg:addChild(scrollView.view, 0, tag)
	
    local scrollView = UI.createScrollViewAuto(CCSizeMake(996, 656), false, {offx=5, offy=4, disy=10, size=CCSizeMake(986, 58), infos=self.rankInfos, cellUpdate=updateRankCell})
    screen.autoSuitable(scrollView.view, {nodeAnchor=General.anchorLeftBottom, x=12, y=26})
    bg:addChild(scrollView.view)
end

local function createRankTab(setting)
    if setting.tabType==1 then
        return setting.handler:createLeagueRankTab()
    else
        return setting.handler:createRankTab()
    end
end

function RankDialog:initTabView(tabs, changeTab)
    local tabTitles = {StringManager.getString("tabRankLeagues"), StringManager.getString("titleRank")}
	
    for i=1, #tabTitles do
        temp = UI.createSpriteWithFile("images/leagueTab0.png",CCSizeMake(200, 77))
        screen.autoSuitable(temp, {x=-71+i*209, y=679})
        self.view:addChild(temp)
        tabs[i] = temp
	    simpleRegisterButton(temp, {priority=display.DIALOG_BUTTON_PRI, callback=changeTab, callbackParam=i})

        temp = UI.createLabel(StringManager.getString(tabTitles[i]), General.font3, 24, {colorR = 255, colorG = 255, colorB = 255})
        screen.autoSuitable(temp, {x=29+209*i, y=722, nodeAnchor=General.anchorCenter})
        self.view:addChild(temp)
        self.tabview.addTab({create=createRankTab, tabType=i, handler=self})
    end
end

function RankDialog:createLeagueRankTab()
    local bg = CCTouchLayer:create(display.DIALOG_PRI, true)
    bg:setContentSize(CCSizeMake(1020, 765))
    
    temp = UI.createSpriteWithFile("images/dialogBackLeagueWeek.png",CCSizeMake(986, 204))
    screen.autoSuitable(temp, {x=17, y=503})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelCaesarsCup"), General.font3, 22, {colorR = 254, colorG = 203, colorB = 55})
    screen.autoSuitable(temp, {x=443, y=564, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    temp = UI.createLabel("---", General.font3, 21, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=508, y=533, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelTimeCount"), General.font3, 17, {colorR = 255, colorG = 170, colorB = 172})
    screen.autoSuitable(temp, {x=499, y=534, nodeAnchor=General.anchorRight})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelCaesarsCupIntro"), General.font1, 17, {colorR = 7, colorG = 7, colorB = 139, size=CCSizeMake(290, 60), align=kCCTextAlignmentLeft})
    screen.autoSuitable(temp, {x=848, y=626, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    
	network.httpRequest("getLeagueRank", self.getLeagueRankData, {callbackParam=bg, params={uid=UserData.userId}}, self)

    return bg
end

local function showLeagueView(info)
    info.dialog:showLeagueTab(info)
end

local function updateRankClanCell(bg, scrollView, info)
    local imageFile = "images/dialogItemLeagueA.png"
    if info.clan==UserData.clan then
        imageFile = "images/dialogItemLeagueA2.png"
    end
    local temp = UI.createSpriteWithFile(imageFile,CCSizeMake(986, 58))
    screen.autoSuitable(temp) --, {x=17, y=362})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/dialogItemRankScoreBg.png",CCSizeMake(156, 41))
    screen.autoSuitable(temp, {x=823, y=10})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/score.png",CCSizeMake(37, 42))
    screen.autoSuitable(temp, {x=934, y=10})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/leagueIcon/" .. info.icon .. ".png",CCSizeMake(39, 44))
    screen.autoSuitable(temp, {x=128, y=7})
    bg:addChild(temp)
    temp = UI.createLabel(info.name, General.font6, 25, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=176, y=27, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    temp = UI.createLabel(tostring(info.score), General.font4, 23, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
    screen.autoSuitable(temp, {x=888, y=31, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelVisitClan"), General.font1, 15, {colorR = 125, colorG = 123, colorB = 121})
    screen.autoSuitable(temp, {x=470, y=14, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelMembers"), General.font1, 18, {colorR = 90, colorG = 81, colorB = 74})
    screen.autoSuitable(temp, {x=721, y=43, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createLabel(info.members .. "/50", General.font1, 19, {colorR = 0, colorG = 0, colorB = 0})
    screen.autoSuitable(temp, {x=721, y=22, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/dialogItemHistorySeperator.png",CCSizeMake(2, 55))
    screen.autoSuitable(temp, {x=115, y=2})
    bg:addChild(temp)
	local rgb = RANK_COLOR[info.rank] or {255, 255, 255}
    temp = UI.createLabel(info.rank .. ".", General.font4, 23, {colorR = rgb[1], colorG = rgb[2], colorB = rgb[3], lineOffset=-12})
    screen.autoSuitable(temp, {x=41, y=29, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    --[[
    temp = UI.createSpriteWithFile("images/rankDownIcon.png",CCSizeMake(17, 18))
    screen.autoSuitable(temp, {x=99, y=384})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("999+"), General.font1, 13, {colorR = 179, colorG = 41, colorB = 46})
    screen.autoSuitable(temp, {x=95, y=376, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    --]]
    scrollView:addChildTouchNode(bg, showLeagueView, info, {nodeChangeHandler=doNothing})
end

function RankDialog:getLeagueRankData(isSuc, result, view)
    if isSuc and not self.deleted then
        local data = json.decode(result)
        if data==None or #data==0 then return end
    	local infos = {}
    	local isNew = true
    	for i=1, #data do
    	    local info = data[i]
    	    --`id`, icon, score, `type`, name, `desc`, members, `min`
    	    local item = {dialog=self, rank=i, clan=info[1], icon=info[2], score=info[3], type=info[4], name=info[5], desc=info[6], members=info[7], min=info[8]}
        	table.insert(infos, item)
    	end
    	
        local scrollView = UI.createScrollViewAuto(CCSizeMake(996, 470), false, {offx=5, offy=4, disy=10, size=CCSizeMake(986, 58), infos=infos, cellUpdate=updateRankClanCell})
        screen.autoSuitable(scrollView.view, {nodeAnchor=General.anchorLeftBottom, x=12, y=26})
        view:addChild(scrollView.view)
    end
end

function RankDialog:createRankTab()
    local bg = CCTouchLayer:create(display.DIALOG_PRI, true)
    bg:setContentSize(CCSizeMake(1020, 765))
	network.httpRequest(network.scoreUrl .. "getUserRank", self.getRankData, {callbackParam=bg, params={uid=UserData.userId, score=UserData.userScore}}, self)

    return bg
end

function RankDialog:getRankData(isSuc, result, view)
    if isSuc and not self.deleted then
        local data = json.decode(result)
        
        if data==None or #data==0 then return end
    	local infos = {}
    	local isNew = true
    	for i=1, #data do
    	    local info = data[i]
    	    local item = {uid=info[1], score=info[2], lastRank=info[3], name=info[4], icon=info[5], clan=info[6]}
    	    if info[7] then
    	        if isNew then
    	            isNew = false
    	            table.insert(infos, {isNewLine = true, offy=16})
    	        end
    	        item.rank = info[7]
    	    else
    	        item.rank = i
        	end
        	table.insert(infos, item)
    	end
    	self.rankInfos = infos
    	self:addRankScroll(view)
    end
end