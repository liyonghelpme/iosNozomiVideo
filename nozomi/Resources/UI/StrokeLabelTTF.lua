StrokeLabelTTF = {}
local CLASS_LIST={CCLabelTTF, CCSprite, CCNode}
StrokeLabelTTF.__index=function(t, k)
    if StrokeLabelTTF[k] then
        return StrokeLabelTTF[k]
    end
    local CClassFunc
    for i=1, 3 do
        if CLASS_LIST[i][k] then
            CClassFunc = CLASS_LIST[i][k]
            break
        end
    end
    local function nk(self, ...)
        return CClassFunc(self.label, ...)
    end
    StrokeLabelTTF[k] = nk
    return nk
end

local TAG_SHADOW=101

--直接给CCLabelTTF 字体 添加阴影 大小 和 颜色
function StrokeLabelTTF.new(label, shadowSize, shadowColor)
    local self = {label=label, shadowSize=shadowSize, shadowColor=shadowColor}
    setmetatable(self, StrokeLabelTTF)
    --self.__index = StrokeLabelTTF
    local rt = self:createShadow(label, shadowSize, shadowColor)
    label:addChild(rt, -1, TAG_SHADOW)
    return self
end

function StrokeLabelTTF:setString(text)
    self.label:setString(text)
    self.label:removeChildByTag(TAG_SHADOW)
    local rt = self:createShadow(label, shadowSize, shadowColor)
    label:addChild(rt, -1, TAG_SHADOW)
end

--CCLabelTTF  阴影大小size 阴影颜色ccc3
--返回CCRenderTexture 直接添加到Font 上 
function StrokeLabelTTF:createShadow(label, size, cor)
    local texture = label:getTexture()
    local cs = texture:getContentSize()
    local anchorPoint = label:getAnchorPoint()

    local rt = CCRenderTexture:create(cs.width+size*2, cs.height+size*2, kTexture2DPixelFormat_RGBA8888)
    local originalPos = label:getPosition()
    local originalColor = label:getColor()
    local originalScaleX = label:getScaleX()
    local originalScaleY = label:getScaleY()
    local originalVisibility = label:isVisible()
    local originalBlend = label:getBlendFunc()

    label:setColor(cor)
    label:setScale(1)
    label:setVisible(true)
    local blendFunc = ccBlendFunc:new()
    blendFunc.src = 0x0302
    blendFunc.dst = 1
    label:setBlendFunc(blendFunc)

    local bottomLeft = ccp(
                            cs.width*anchorPoint.x+size, 
                                cs.height*anchorPoint.y+size)
    local positionOffset = ccp(cs.width/2, cs.height/2)
    rt:begin()
    --根据字体大小 调整迭代的次数 22 号字体迭代8次
    for  i = 0, 360, 45 do
        label:setPosition(ccp(
                        bottomLeft.x+math.sin(i*0.0174533)*size, 
                        bottomLeft.y+math.cos(i*0.0174533)*size))
        label:visit()
    end
    rt:endToLua()

    label:setPosition(originalPos)
    label:setColor(originalColor)
    label:setBlendFunc(originalBlend)
    label:setVisible(originalVisibility)
    
    label:setScaleX(originalScaleX)
    label:setScaleY(originalScaleY)

    rt:setPosition(positionOffset)
    return rt
end

function StrokeLabelTTF:test()
    local label = CCLabelTTF:create("Hello World", "Arial", 22)
    label = StrokeLabelTTF:createFont(label, 2, ccc3(15, 15, 15))
    label:setPosition(ccp(200, 200))
    return label
end