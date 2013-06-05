HistoryDialog = {}

local function beginReplay(suc, result)
    if suc then
        local data = json.decode(result)
        --({seed=, data=ReplayLogic.buildData, cmdList=ReplayLogic.cmdList})
        ReplayLogic.randomSeed = data.seed
        ReplayLogic.buildData = data.data
        ReplayLogic.cmdList = data.cmdList
        ReplayLogic.isZombie = false
    	display.pushScene(ReplayScene.new(), PreBattleScene)
    	UserStat.stat(UserStatType.HISTORY_VIDEO)
    end
end

local function onVideo(info)
    network.httpRequest("getReplay", beginReplay, {params={uid=UserData.uid, vid=info.videoId}})
end

local function revergeGetData(isSuc, result)
    local mainScene = display.getCurrentScene(1)
    if isSuc and display.getCurrentScene()==mainScene then
        local data = json.decode(result)
        if data.code~=0 then
            display.pushNotice(UI.createNotice(StringManager.getString("noticeRevergeFail" .. data.code)))
        else
	        mainScene:updateLogic(300)
	        BattleLogic.isReverge = 1
    		BattleLogic.enemyID = HistoryDialog.revergeId
            UserData.enemyID = HistoryDialog.revergeId
            local scene = BattleScene.new()
            scene.initInfo = data
            display.pushScene(scene, PreBattleScene)
        end
    end
    HistoryDialog.revergeId = nil
end

local function onReverge(info)
    if info.id>0 and not HistoryDialog.revergeId then
        local scene = display.getCurrentScene()
        if BattleLogic.checkBattleEnable(scene, onReverge) then
            HistoryDialog.revergeId = info.id
            BattleLogic.revergeItem = info
            network.httpRequest("reverge", revergeGetData, {params={uid=UserData.userId, eid=info.id}})
    	end
    end
end

local function updateHistoryCell(bg, scrollView, info)
	local temp, temp1
	temp1 = {}
	if info.score>0 then
		temp1[1] = UI.createSpriteWithFile("images/dialogItemHistoryCellA.png",CCSizeMake(827, 171))
		temp1[2] = UI.createSpriteWithFile("images/dialogItemHistoryWin.png",CCSizeMake(237, 32))
		temp1[3] = UI.createLabel(StringManager.getString("defenseWin"), General.font1, 15, {colorR = 0, colorG = 0, colorB = 0})
	else
		temp1[1] = UI.createSpriteWithFile("images/dialogItemHistoryCellB.png",CCSizeMake(827, 171))
		temp1[2] = UI.createSpriteWithFile("images/dialogItemHistoryLose.png",CCSizeMake(237, 32))
		temp1[3] = UI.createLabel(StringManager.getString("defenseLose"), General.font1, 15, {colorR = 0, colorG = 0, colorB = 0})
	end
	screen.autoSuitable(temp1[1], {x=0, y=0})
	bg:addChild(temp1[1])
	screen.autoSuitable(temp1[2], {x=582, y=130})
	bg:addChild(temp1[2])
	screen.autoSuitable(temp1[3], {x=701, y=146, nodeAnchor=General.anchorCenter})
	bg:addChild(temp1[3])
	
	temp = UI.createSpriteWithFile("images/dialogItemStoreLight.png",CCSizeMake(93, 104))
	screen.autoSuitable(temp, {x=592, y=-14})
	bg:addChild(temp)
	
	info.clan = "Caesars"
	if info.clan then
		temp = UI.createLabel(info.clan, General.font1, 15, {colorR = 90, colorG = 81, colorB = 74})
		screen.autoSuitable(temp, {x=31, y=123, nodeAnchor=General.anchorLeft})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/leagueIconB.png",CCSizeMake(20, 22))
		screen.autoSuitable(temp, {x=10, y=112})
		bg:addChild(temp)
	end
	--time
	temp = UI.createLabel(StringManager.getFormatString("timeAgo", {time=StringManager.getTimeString(timer.getTime()-info.time)}), General.font1, 13, {colorR = 42, colorG = 40, colorB = 39})
	screen.autoSuitable(temp, {x=563, y=19, nodeAnchor=General.anchorRight})
	bg:addChild(temp)
	-- percent
	temp = UI.createLabel(info.percent .. "%", General.font1, 15, {colorR = 0, colorG = 0, colorB = 0})
	screen.autoSuitable(temp, {x=618, y=113, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	if info.stars>0 then
		for i=1, 3 do
			local t=0
			if i>info.stars then t=1 end
			temp = UI.createSpriteWithFile("images/battleStar" .. t .. ".png",CCSizeMake(20, 20))
			screen.autoSuitable(temp, {x=566+i*21, y=86})
			bg:addChild(temp)
		end
	end
	
	temp = UI.createSpriteWithFile("images/dialogItemHistorySeperator.png",CCSizeMake(2, 154))
	screen.autoSuitable(temp, {x=575, y=9})
	bg:addChild(temp)
	
	-- name
	temp = UI.createLabel(info.name, General.font3, 18, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=10, y=146, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	local w = temp:getContentSize().width * temp:getScaleX()
	temp = UI.createSpriteWithFile("images/chatRoomItemVisit.png",CCSizeMake(30, 31))
	screen.autoSuitable(temp, {nodeAnchor=General.anchorLeft, x=10+w, y=146})
	bg:addChild(temp)
	UI.registerVisitIcon(bg, scrollView, HistoryDialog.dialogBack, info.id, temp)
	
	-- resources
	temp = UI.createSpriteWithFile("images/food.png",CCSizeMake(19, 26))
	screen.autoSuitable(temp, {x=13, y=10})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/oil.png",CCSizeMake(20, 22))
	screen.autoSuitable(temp, {x=156, y=10})
	bg:addChild(temp)
	--temp = UI.createSpriteWithFile("images/special.png",CCSizeMake(30, 29))
	--screen.autoSuitable(temp, {x=291, y=4})
	--bg:addChild(temp)
	temp = UI.createLabel(tostring(info.food), General.font4, 18, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
	screen.autoSuitable(temp, {x=35, y=22, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	temp = UI.createLabel(tostring(info.oil), General.font4, 18, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
	screen.autoSuitable(temp, {x=180, y=22, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	--temp = UI.createLabel(tostring(info.special), General.font4, 18, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
	--screen.autoSuitable(temp, {x=325, y=22, nodeAnchor=General.anchorLeft})
	--bg:addChild(temp)
	
	-- score
	temp = UI.createLabel(info.score, General.font4, 25, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
	screen.autoSuitable(temp, {x=623, y=38, nodeAnchor=General.anchorRight})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/score.png",CCSizeMake(25, 29))
	screen.autoSuitable(temp, {x=628, y=23})
	bg:addChild(temp)
	
	temp = UI.createLabel(info.uscore, General.font4, 17, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
	screen.autoSuitable(temp, {x=533, y=147, nodeAnchor=General.anchorRight})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/score.png",CCSizeMake(20, 23))
	screen.autoSuitable(temp, {x=542, y=134})
	bg:addChild(temp)
	
	if info.videoId>0 then
    	temp = scrollView:createButton(CCSizeMake(150, 50), onVideo, {callbackParam=info, image="images/buttonGreenB.png", text=StringManager.getString("buttonVideo"), fontSize=20, fontName=General.font3})
    	screen.autoSuitable(temp, {x=740, y=96, nodeAnchor=General.anchorCenter})
    	bg:addChild(temp)
    else
		temp = UI.createLabel(StringManager.getString("labelVideoOver"), General.font1, 15, {colorR = 115, colorG = 113, colorB = 115})
		screen.autoSuitable(temp, {x=740, y=94, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
	end
	if info.revenged then
		temp = UI.createLabel(StringManager.getString("labelRevergeOver"), General.font1, 15, {colorR = 115, colorG = 113, colorB = 115})
		screen.autoSuitable(temp, {x=740, y=38, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
	else
		temp = scrollView:createButton(CCSizeMake(150, 50), onReverge, {callbackParam=info, image="images/buttonEnd.png", text=StringManager.getString("buttonReverge"), fontSize=20, fontName=General.font3})
		screen.autoSuitable(temp, {x=740, y=40, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
	end
	
	local items = info.items
	for i=1, #items do
		local item = items[i]
		local cell = CCNode:create()
		cell:setContentSize(CCSizeMake(48, 63))
		screen.autoSuitable(cell, {x=51*i-39, y=41})
		bg:addChild(cell)
		
		temp = UI.createSpriteWithFile("images/dialogItemBattleResultItemA.png",CCSizeMake(48, 63))
		screen.autoSuitable(temp, {x=0, y=0})
		cell:addChild(temp)
		
		if item[1]>0 then
    		SoldierHelper.addSoldierHead(cell, item[1], 0.42)
    		temp = UI.createStar(item[3], 10, 8)
    		screen.autoSuitable(temp, {x=2, y=4})
    		cell:addChild(temp)
    	else
    	    temp = UI.createSpriteWithFile("images/zombieTombIcon.png",CCSizeMake(24, 47))
            screen.autoSuitable(temp, {x=12, y=3})
            cell:addChild(temp)
    	end
		
		temp = UI.createLabel("x" .. item[2], General.font4, 15, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=4, y=56, nodeAnchor=General.anchorLeft})
		cell:addChild(temp)
		
	end
	
end

function HistoryDialog.show()
	local temp, bg = nil
	bg = UI.createButton(CCSizeMake(890, 650), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
	screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_DIALOG_CLEVER})
	
	UI.setShowAnimate(bg)
	HistoryDialog.dialogBack = bg
	-- 30 25 175
	
	local scrollView = UI.createScrollViewAuto(CCSizeMake(891, 525), false, {offx=30, offy=1, disy=4, size=CCSizeMake(827, 171), infos=UserData.historys, cellUpdate=updateHistoryCell})
	screen.autoSuitable(scrollView.view, {nodeAnchor=General.anchorLeftTop, x=0, y=547})
	bg:addChild(scrollView.view)
	
	temp = UI.createLabel(StringManager.getString("labelEnemys"), General.font2, 15, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=77, y=554, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelBattleResult"), General.font2, 15, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=690, y=554, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("titleBattleLog"), General.font3, 34, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=445, y=604, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createButton(CCSizeMake(54, 53), display.closeDialog, {image="images/buttonClose.png"})
	screen.autoSuitable(temp, {x=845, y=606, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	
	display.showDialog({view=bg}, true)
	
	EventManager.sendMessage("EVENT_NOTICE_BUTTON", {name="mail"})
end