TestScene = {}

function TestScene.create()
	local bg = CCLayerColor:create(ccc4(0, 0, 255, 255), General.winSize.width, General.winSize.height)
	print(os.clock())
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
	for i = 0, 3 do
        local land = UI.createSpriteWithFile("images/background/background" .. i .. ".png")
        screen.autoSuitable(land, {nodeAnchor=General.anchorLeftTop, x=(i%2)*2044, y=3072 - 2044*math.floor(i/2)})
        land:setScale(2)
        bg:addChild(land, 0)
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB8888)
	print(os.clock())
	CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
	return {view=bg}
end