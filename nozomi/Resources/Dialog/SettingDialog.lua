require "Dialog.FeedbackDialog"

SettingDialog = {}

function SettingDialog.onAbout()
    display.showDialog(AboutDialog.new(), true)
    --display.showDialog(SNSDialog.new(), true)
end

function SettingDialog.onFeedback()
    display.showDialog(FeedbackDialog.new(), true)
end

function SettingDialog.create()
	local temp, bg = nil
    bg = UI.createButton(CCSizeMake(503, 438), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
    screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_DIALOG_CLEVER})
	UI.setShowAnimate(bg)
    temp = UI.createSpriteWithFile("images/dialogItemSettingSeperator.png",CCSizeMake(447, 2))
    screen.autoSuitable(temp, {x=26, y=163})
    bg:addChild(temp)
    temp = UI.createButton(CCSizeMake(133, 48), SettingDialog.onAbout, {image="images/buttonGreenB.png", text=StringManager.getString("buttonAbout"), fontSize=20, fontName=General.font3})
    screen.autoSuitable(temp, {x=157, y=116, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createButton(CCSizeMake(133, 48), SettingDialog.onFeedback, {image="images/buttonGreenB.png", text=StringManager.getString("buttonFeedback"), fontSize=20, fontName=General.font3})
    screen.autoSuitable(temp, {x=346, y=116, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    
    temp = UI.createSwitch(CCSizeMake(133, 48), UserSetting.changeMusicState, UserSetting.musicOn)
    screen.autoSuitable(temp, {x=343, y=335, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelMusic"), General.font3, 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
    screen.autoSuitable(temp, {x=97, y=332, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    
    temp = UI.createSwitch(CCSizeMake(133, 48), UserSetting.changeSoundState, UserSetting.soundOn)
    screen.autoSuitable(temp, {x=343, y=274, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelSound"), General.font3, 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
    screen.autoSuitable(temp, {x=97, y=274, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    --[[
    temp = UI.createSwitch(CCSizeMake(133, 48), UserSetting.changeNightMode, UserSetting.nightMode)
    screen.autoSuitable(temp, {x=343, y=213, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    --]]
    local function changeNightMode()
        display.pushNotice(UI.createNotice(StringManager.getString("noticeUnlockFunction")))
    end
    temp = UI.createSwitch(CCSizeMake(133, 48), changeNightMode, UserSetting.nightMode)
    screen.autoSuitable(temp, {x=343, y=213, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelNightMode"), General.font3, 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
    screen.autoSuitable(temp, {x=97, y=213, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    
    temp = UI.createLabel(StringManager.getString("titleSetting"), General.font3, 28, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=252, y=407, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createButton(CCSizeMake(42, 42), display.closeDialog, {image="images/buttonClose.png"})
    screen.autoSuitable(temp, {x=471, y=408, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    if General.useGameCenter then
        temp = UI.createSpriteWithFile("images/gamecenterIcon.png",CCSizeMake(56, 56))
        screen.autoSuitable(temp, {x=22, y=29})
        bg:addChild(temp)
        temp = UI.createLabel(StringManager.getString("labelGameCenter"), General.font1, 13, {colorR = 0, colorG = 0, colorB = 0, size=CCSizeMake(390, 40), align=kccTextAlignmentLeft})
        screen.autoSuitable(temp, {x=95, y=53, nodeAnchor=General.anchorLeft})
        bg:addChild(temp)
	end
	return bg
end