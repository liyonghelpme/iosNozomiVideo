--node 总大小
--每个子图 0 1 2 对应的位置 buildSprite
--plist文件 名字 0.png 1.png

--原始图片大小 width height
--plist 文件名称
--建筑物编号 buildId
--建筑图片编号 
--多个子图的编号 和位置 pic
local simpleJson = require "Util.SimpleJson"
function MakeNode(width, height, pic, plistName, buildId, packId)
    --[[
    print("MakeNode ")
    print(width, height, simpleJson:encode(pic))
    print(plistName)
    print(buildId)
    print(packId)
    --]]
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistName)

    local back = CCNode:create()
    back:setContentSize(CCSizeMake(width, height))
    --back:setAnchorPoint(ccp(0.5, 1.0))
    for k, v in pairs(pic) do
        local temp = CCSprite:createWithSpriteFrameName("buildSprite"..buildId.."_"..packId.."_"..k..".png")
        temp:setAnchorPoint(ccp(0, 0))

        --print(k, simpleJson:encode(v), temp)
        temp:setPosition(ccp(v[1], v[2]))
        back:addChild(temp)
    end

    return back
end
