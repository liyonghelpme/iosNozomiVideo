TestScene = {}

function TestScene.create()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
	local bg = CCLayerColor:create(ccc4(0, 0, 255, 255), General.winSize.width, General.winSize.height)
	for i = 0, 11 do
        local land = UI.createSpriteWithFile("images/background/background" .. i .. ".pvr.ccz")
        land:setScale(2)
        screen.autoSuitable(land, {nodeAnchor=General.anchorLeftBottom, x=(i%4)*1024-1536, y=3072-1024-1024*(1+math.floor(i/4))})
        bg:addChild(land, 0)
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local texture = CCTextureCache:sharedTextureCache():addImage("test.pvr.ccz")
    texture:generateMipmap()
    local params = ccTexParams:new_local()
    params.minFilter = 0x2703
    params.magFilter = 0x2601
    params.wrapS = 0x812F
    params.wrapT = 0x812F
    texture:setTexParameters(params)
    local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
    cache:addSpriteFramesWithFile("test.plist")
    
    for i=-1, 5 do
	    local sprite = UI.createAnimateWithSpritesheet(1, "test_", 14, {plist="test.plist"})
	    sprite:setScale((i+3)/4)
	    screen.autoSuitable(sprite, {nodeAnchor=General.anchorCenter, x=156+i*100, y=400})
	    bg:addChild(sprite)
	    
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	    local sprite = UI.createSpriteWithFile("111.png", CCSizeMake(360, 360))
	    screen.autoSuitable(sprite, {nodeAnchor=General.anchorCenter, x=200, y=180})
	    bg:addChild(sprite)
        sprite = UI.createSpriteWithFile("225x225.png", CCSizeMake(360, 360))
	    screen.autoSuitable(sprite, {nodeAnchor=General.anchorCenter, x=600, y=180})
	    bg:addChild(sprite)
	return {view=bg}
end