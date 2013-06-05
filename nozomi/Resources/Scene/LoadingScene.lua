require "data.TipsData"
require "Dialog.WaitAttackDialog"

LoadingScene = class(NormalChangeDelegate)

function LoadingScene:ctor(fromScene, toScene)
    local bg = self.view
	local temp = nil
    temp = UI.createSpriteWithFile("images/loadingBack.png")
    screen.autoSuitable(temp, {screenAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
    bg:addChild(temp)
    
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/loadingBack.png")
    
    temp = UI.createSpriteWithFile("images/loadingTitle.png",CCSizeMake(530, 306))
    screen.autoSuitable(temp, {screenAnchor=General.anchorTop, scaleType=screen.SCALE_NORMAL, x=-22, y=63})
    bg:addChild(temp)
    
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/loadingTitle.png")
    
    temp = UI.createSpriteWithFile("images/tipsBg.png",CCSizeMake(518, 67))
    screen.autoSuitable(temp, {screenAnchor=General.anchorBottom, scaleType=screen.SCALE_NORMAL, x=0, y=8})
    bg:addChild(temp)
    local temp1 = UI.createLabel(TipsData.getTip(), General.font1, 18, {colorR = 255, colorG = 255, colorB = 255, size=CCSizeMake(506, 50)})
    screen.autoSuitable(temp1, {x=259, y=28, nodeAnchor=General.anchorCenter})
    temp:addChild(temp1)
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/tipsBg.png")
    
    temp = UI.createSpriteWithFile("images/loadingProcessBack.png",CCSizeMake(283, 25))
    screen.autoSuitable(temp, {screenAnchor=General.anchorBottom, scaleType=screen.SCALE_NORMAL, y=62})
    bg:addChild(temp)
    local filler = UI.createSpriteWithFile("images/loadingProcessFiller.png",CCSizeMake(279, 20))
    screen.autoSuitable(filler, {x=2, y=3})
    temp:addChild(filler)
    UI.registerAsProcess(filler, self)
    self.filler = filler
    self:setPercent(0)
    
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/loadingProcessBack.png")
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/loadingProcessFiller.png")
    
    local infoLabel = UI.createLabel(StringManager.getString("labelLoading"), General.font4, 20, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(infoLabel, {x=142, y=25, nodeAnchor=General.anchorCenter})
    temp:addChild(infoLabel)
    self.valueLabel = infoLabel
    
    self.loadMax = 0
    self.loadPercent = 0
    
    self:readyToLoad()
    
    music.playBackgroundMusic("music/operation.mp3")
end

function LoadingScene:readyToLoad()
    if UserData.userId then 
        self.loadMax = self.loadMax+50
        self.loadPercent = self.loadMax
        return self:requestData()
    end
    local username = CCUserDefault:sharedUserDefault():getStringForKey("username")
    if username and username~="" then
        self.loadMax = self.loadMax+30
        network.httpRequest("login", self.requestSelfId, {isPost=true, params={username=username, nickname=CCUserDefault:sharedUserDefault():getStringForKey("nickname")}}, self)
    else
        delayCallback(1, self.readyToLoad, self)
    end
end

function LoadingScene:requestData()
    network.httpRequest("getData", self.requestSelfData, {params={uid=UserData.userId, login=1}}, self)
end

function LoadingScene:requestSelfId(isSuc, result)
    if isSuc then
        local r = json.decode(result)
        if r.code==0 then
            self.loadMax = self.loadMax+20
            UserData.userId = r.uid
	        self:requestData()
        end
    end
end
    
function LoadingScene:setPercent(percent)
    UI.setProcess(self.filler, self, percent/100)
end

function LoadingScene:enterAnimate()
    self.animateTime = timer.getTime()+0.3
    self.loadPercent = 100
    self:setPercent(100)
end

function LoadingScene:updateOthers(diff)
    if self.loadState>=8 then
        self.loadPercent=squeeze(self.loadPercent+math.random(10), 0, 100)
    else
        self.loadPercent = squeeze(self.loadState*7, 0, 100)
    end
    self:setPercent(self.loadPercent)
end

function LoadingScene:requestSelfData(isSuc, result)
    if isSuc then
        local data = json.decode(result)
        if data.attackTime then
            if not display.isDialogShow() then
                display.showDialog(WaitAttackDialog.new(data.attackTime))
            end
            delayCallback(squeeze(data.attackTime, 5, 30), self.requestData, self)
        else
            self.loadMax = self.loadMax+30
            self.toScene.initInfo = data
        end
    end
end