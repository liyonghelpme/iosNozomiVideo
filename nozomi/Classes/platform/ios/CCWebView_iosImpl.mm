#include "CCWebView_iosImpl.h"
#include "EAGLView.h"

@implementation CCWebView_iosImpl

- (id) init{
	self = [super init];
	if (self){
	}
	return self;
}

- (void) dealloc{
    [mBackButton release];
    [mToolbar release];
	[mWebView release];
	[mIosView release];
	[super dealloc];
}

- (void) addWebView : (cocos2d::extension::CCWebView *)layerView withUrl:(const char*) cstringUrl
{
	mLayerView = layerView;
    mLayerView->retain();
    authenticated = NO;
	//cocos2d::CCSize size = mLayerView->getContentSize();
    CGSize size = [[EAGLView sharedEGLView] size];
	mIosView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.height, size.width)];
	mWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, size.height, size.width * 0.9)];
	mWebView.delegate = self;
	NSString *baseUrl = [NSString stringWithCString:cstringUrl encoding:NSUTF8StringEncoding];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    urlRequest = request;
    [urlRequest retain];
	[mWebView loadRequest:request];
    [mWebView setUserInteractionEnabled:NO];
    mToolbar = [UIToolbar new];
    [mToolbar setFrame:CGRectMake(0, size.width * 0.9, size.height, size.width * 0.1)];
    mToolbar.barStyle = UIBarStyleBlackOpaque;
    
    mBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(closeWebView:)];
    
    [mToolbar setItems:[NSArray arrayWithObjects:mBackButton, nil] animated:YES];
    [mIosView addSubview:mToolbar];
	[mIosView addSubview:mWebView];
    [[EAGLView sharedEGLView] addSubview:mIosView];
}

- (void) closeWebView: (id)sender
{
    mWebView.delegate = nil;
    [mToolbar removeFromSuperview];
	[mWebView removeFromSuperview];
	[mIosView removeFromSuperview];
    mLayerView->release();
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [mWebView setUserInteractionEnabled:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"Error msg: %@", [error localizedDescription]);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *urlString = [request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    bool ck = mLayerView->shouldLoadUrl([urlString UTF8String]);
    if (ck==true){
        //if ([urlString rangeOfString:@"https"].location==0 && authenticated==NO) {
        //    urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:selfstartImmediately:YES];
        //    return NO;
        //}
        return YES;
    }
    [self closeWebView:nil];
    return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    if([challenge previousFailureCount] == 0){
        authenticated = YES;
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        
        // WHY ADD this?
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
    else{
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", html);
    [html release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    authenticated = YES;
    [mWebView loadRequest: urlRequest];
    //[urlConnection cancel];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}
@end