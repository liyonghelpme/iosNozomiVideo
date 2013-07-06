ErrorDialog = class()

function ErrorDialog:ctor(title, text, buttonText)
	local temp, bg = nil
	bg = UI.createButton(CCSizeMake(443, 279), doNothing, {image="images/dialogBgC.png", priority=display.DIALOG_PRI-2, nodeChangeHandler = doNothing})
	screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_DIALOG_CLEVER})
	UI.setShowAnimate(bg)
	
	self.isAlert = true
	
    local btext = buttonText or StringManager.getString("buttonYes")
    temp = UI.createButton(CCSizeMake(169, 76), PauseLogic.restart, {priority=display.DIALOG_BUTTON_PRI-2, image="images/buttonGreen.png", text=btext, fontSize=25, fontName=General.font3})
    screen.autoSuitable(temp, {x=222, y=66, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
	temp = UI.createLabel(title, General.font3, 25, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=222, y=233, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	
    temp = UI.createLabel(text, General.font1, 18, {colorR = 75, colorG = 66, colorB = 46, size=CCSizeMake(386, 60)})
    screen.autoSuitable(temp, {x=222, y=167, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
	
	self.view = bg
end