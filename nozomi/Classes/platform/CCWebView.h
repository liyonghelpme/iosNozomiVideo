#ifndef __CCPLATFORM_CCWEBVIEW_H__
#define __CCPLATFORM_CCWEBVIEW_H__

#include "cocos2d.h"
#include "cocos2d_ext.h"

NS_CC_EXT_BEGIN
class CCWebView: public CCObject
{
private:
    int m_luaHandler;
public:
	CCWebView();
	~CCWebView();

	virtual bool init(const char* url, int luaHandler);

	void webViewDidFinishLoad();
    
    bool shouldLoadUrl(const char* url);
    
public:
    static CCWebView* create(const char* url, int luaHandler);
};
NS_CC_EXT_END

#endif //__CCPLATFORM_CCWEBVIEW_H__