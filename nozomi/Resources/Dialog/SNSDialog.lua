SNSDialog = class()

function SNSDialog:share()
    local text = self.shareText
    print("begin")
    SNS.weibo:request("https://api.weibo.com/2/statuses/update.json",{status=text, visible=2})
    
	UserStat.stat(UserStatType.SHARE)
end

function SNSDialog:ctor()
    local temp, bg = nil
    bg = UI.createButton(CCSizeMake(720, 526), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
    screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_DIALOG_CLEVER})
    self.view = bg
	UI.setShowAnimate(bg)
    
    temp = UI.createSpriteWithFile("images/dialogItemBlood.png",CCSizeMake(292, 222))
    screen.autoSuitable(temp, {x=400, y=50})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/featureShadow.png",CCSizeMake(192, 74))
    screen.autoSuitable(temp, {x=53, y=70})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/guideNpc2.png",CCSizeMake(180, 310))
    screen.autoSuitable(temp, {x=56, y=98})
    bg:addChild(temp)
    if UserData.level>2 then
        temp = UI.createButton(CCSizeMake(135, 61), self.share, {callbackParam=self, image="images/buttonGreen.png", text=StringManager.getString("buttonShare"), fontSize=26, fontName=General.font3})
        screen.autoSuitable(temp, {x=449, y=134, nodeAnchor=General.anchorCenter})
        bg:addChild(temp)
    else
        temp = UI.createButton(CCSizeMake(135, 61), display.closeDialog, {image="images/buttonGreen.png", text=StringManager.getString("buttonYes"), fontSize=26, fontName=General.font3})
        screen.autoSuitable(temp, {x=449, y=134, nodeAnchor=General.anchorCenter})
        bg:addChild(temp)
    end
    self.shareText = StringManager.getFormatString("labelShareNozomi", {level=UserData.level})
    temp = UI.createLabel(self.shareText, General.font1, 25, {colorR = 75, colorG = 66, colorB = 46, size=CCSizeMake(400, 120), align=kCCTextAlignmentLeft})
    screen.autoSuitable(temp, {x=475, y=276, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    --[[
    temp = UI.createLabel(StringManager.getString("tipsNozomiEscape"), General.font1, 20, {colorR = 75, colorG = 66, colorB = 46})
    screen.autoSuitable(temp, {x=274, y=51, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    --]]
    
    temp = UI.createLabel(StringManager.getString("titleSNS"), General.font3, 30, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=360, y=489, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
	temp = UI.createButton(CCSizeMake(47, 46), display.closeDialog, {image="images/buttonClose.png"})
	screen.autoSuitable(temp, {x=683, y=492, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
end