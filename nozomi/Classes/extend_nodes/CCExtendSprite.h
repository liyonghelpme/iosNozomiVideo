#ifndef __CAESARS_NODE_CCEXTENDSPRITE_H__
#define __CAESARS_NODE_CCEXTENDSPRITE_H__

#include "cocos2d_ext_const.h"
#include "sprite_nodes/CCSprite.h"

#include "extend_shader/CCHSVShaderHandler.h"

NS_CC_EXT_BEGIN
class CCExtendSprite : public CCSprite, public CCHSVShaderProtocol
{
private:
	CCHSVShaderHandler* m_pHSVHandler;
public:
	static CCExtendSprite* create(const char* pszFileName);
	static CCExtendSprite* createWithSpriteFrameName(const char* pszSpriteFrameName);
	static void recurSetColor(CCNode* baseNode, const ccColor3B& color);
	static void recurSetGray(CCNode* baseNode);
public:
    CCExtendSprite(void);
    ~CCExtendSprite(void);

	virtual bool initWithFile(const char* pszFileName);
	virtual bool initWithSpriteFrame(CCSpriteFrame* pSpriteFrame);

	virtual bool isAlphaTouched(CCPoint nodePoint);

	virtual void setHueOffset(int offset, bool recur);
	virtual void setSatOffset(int offset, bool recur);
	virtual void setValOffset(int offset, bool recur);
	virtual void setHSVParentOffset(int hoff, int soff, int voff);

	virtual void addChild(CCNode *child, int zOrder, int tag);
};

NS_CC_EXT_END

#endif //__CAESARS_NODE_CCEXTENDSPRITE_H__