#import <UIKit/UIKit.h>

#import "platform/CCWebView.h"

@interface CCWebView_iosImpl : NSObject<UIWebViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    cocos2d::extension::CCWebView	*mLayerView;
	UIView		*mIosView;
	UIWebView	*mWebView;
    UIToolbar   *mToolbar;
    UIBarButtonItem *mBackButton;
    
    NSURLRequest    *urlRequest;
    NSURLConnection *urlConnection;
    BOOL authenticated;
}

-(void) addWebView : (cocos2d::extension::CCWebView *)layerView withUrl:(const char*) cstringUrl;

-(void) closeWebView: (id)sender;

@end