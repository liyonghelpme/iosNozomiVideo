//
//  nozomiAppController.h
//  nozomi
//
//  Created by  stc on 13-1-30.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//

@class RootViewController;

@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate,UIApplicationDelegate> {
    UIWindow *window;
    RootViewController    *viewController;
    UIBackgroundTaskIdentifier  bgTask;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *viewController;
@property (nonatomic) UIBackgroundTaskIdentifier bgTask;

@end

