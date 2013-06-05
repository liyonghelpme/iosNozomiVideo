RankDialog = class()

local function updateRankCell(bg, scrollView, info)
    local img = "images/dialogItemRankCellBg.png"
	if info.uid == UserData.userId then
	    img = "images/dialogItemRankCellBgB.png"
	    info.name = UserData.userName
	end
	local temp = UI.createSpriteWithFile(img, CCSizeMake(820, 59))
	screen.autoSuitable(temp, {x=0, y=0})
	bg:addChild(temp)
	if info.clan then
        temp = UI.createLabel(info.clan, General.font1, 15, {colorR = 90, colorG = 81, colorB = 74})
        screen.autoSuitable(temp, {x=148, y=15, nodeAnchor=General.anchorLeft})
        bg:addChild(temp)
        temp = UI.createSpriteWithFile("images/leagueIconB.png",CCSizeMake(20, 22))
        screen.autoSuitable(temp, {x=126, y=4})
        bg:addChild(temp)
	end
    temp = UI.createLabel(info.name, General.font3, 18, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=126, y=38, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
	local w = temp:getContentSize().width * temp:getScaleX()
	if info.uid~=UserData.userId then
    	temp = UI.createSpriteWithFile("images/chatRoomItemVisit.png",CCSizeMake(26, 26))
    	screen.autoSuitable(temp, {x=128+w, y=28})
    	bg:addChild(temp)
    	UI.registerVisitIcon(bg, scrollView, info.bg, info.uid, temp)
    end
	temp = UI.createSpriteWithFile("images/dialogItemRankScoreBg.png",CCSizeMake(156, 41))
	screen.autoSuitable(temp, {x=656, y=9})
	bg:addChild(temp)
	
	local rgb = RANK_COLOR[info.rank] or {255, 255, 255}
	temp = UI.createLabel(info.rank .. ".", General.font4, 30, {colorR = rgb[1], colorG = rgb[2], colorB = rgb[3], lineOffset=-12})
	screen.autoSuitable(temp, {x=39, y=30, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/score.png",CCSizeMake(37, 42))
	screen.autoSuitable(temp, {x=767, y=9})
	bg:addChild(temp)
	--[[
	temp = UI.createSpriteWithFile("images/exp.png",CCSizeMake(51, 49))
	screen.autoSuitable(temp, {x=111, y=5})
	bg:addChild(temp)
	temp = UI.createLabel(tostring(info.ulevel), General.font4, 18, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
	screen.autoSuitable(temp, {x=137, y=31, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	--]]
	temp = UI.createLabel(tostring(info.score), General.font4, 23, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
	screen.autoSuitable(temp, {x=718, y=30, nodeAnchor=General.anchorCenter})
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
end

function RankDialog:addRankScroll()
	if self.deleted then return end
	local tag = 101
	local bg = self.view
	local c = bg:getChildByTag(tag)
	if c then
		c:removeFromParentAndCleanup(true)
	end
	
	for _, info in ipairs(self.rankInfos) do
		info.bg = bg
		info.clan = StringManager.getString("defaultLeague")
	end
	local scrollView = UI.createScrollViewAuto(CCSizeMake(830, 536), false, {offx=5, offy=4, disy=8, size=CCSizeMake(820, 59), infos=self.rankInfos, cellUpdate=updateRankCell})
	screen.autoSuitable(scrollView.view, {x=28, y=26})
	bg:addChild(scrollView.view, 0, tag)
end

function RankDialog:ctor()
	local temp, bg = nil
	bg = UI.createButton(CCSizeMake(890, 650), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
	screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_DIALOG_CLEVER})
	UI.setShowAnimate(bg)
	
	self.view = bg
	
	temp = UI.createLabel(StringManager.getString("titleRank"), General.font3, 34, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=445, y=604, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	
	temp = UI.createButton(CCSizeMake(55, 53), display.closeDialog, {image="images/buttonClose.png"})
	screen.autoSuitable(temp, {x=845, y=606, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	
	network.httpRequest(network.scoreUrl .. "getUserRank", self.getRankData, {params={uid=UserData.userId, score=UserData.userScore}}, self)
	-- TEST
	-- TEST OVER
	--self:addRankScroll()
end

function RankDialog:getRankData(isSuc, result)
    if isSuc then
        local data = json.decode(result)
        
    	local infos = {}
    	local isNew = true
    	for i=1, #data do
    	    local info = data[i]
    	    if info[5] then
    	        if isNew then
    	            isNew = false
    	            table.insert(infos, {isNewLine = true, offy=16})
    	        end
    	        table.insert(infos, {rank=info[5], name=info[4], uid=info[1], score=info[2], lastRank=info[3]})
    	    else
        		table.insert(infos, {rank=i, name=info[4], uid=info[1], score=info[2], lastRank=info[3]})
        	end
    	end
    	self.rankInfos = infos
    	self:addRankScroll()
    end
end