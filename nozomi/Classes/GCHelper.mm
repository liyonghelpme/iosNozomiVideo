//
//  GCHelper.m
//  nozomi
//
//  Created by  stc on 13-2-26.
//
//

#import "GCHelper.h"
#import "CCUserDefault.h"

@implementation GCHelper

@synthesize gameCenterAvailable;

#pragma mark Initialization

static GCHelper* instance = nil;
+ (GCHelper *) sharedGameCenter {
    if (!instance){
        instance = [[GCHelper alloc] init];
    }
    return instance;
}

- (BOOL)isGameCenterAvailable {
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (void)authenticationChanged {
    if ([GKLocalPlayer localPlayer].isAuthenticated != userAuthenticated){
        userAuthenticated = !userAuthenticated;
        if (userAuthenticated){
            cocos2d::CCUserDefault::sharedUserDefault()->setStringForKey("username", [[GKLocalPlayer localPlayer].playerID UTF8String]);
            cocos2d::CCUserDefault::sharedUserDefault()->setStringForKey("nickname", [[GKLocalPlayer localPlayer].alias UTF8String]);
            NSLog(@"Player ID: %@", [GKLocalPlayer localPlayer].playerID);
        }
    }
}

- (id)init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            userAuthenticated = FALSE;
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
        }
    }
    return self;
}

#pragma mark User functions

- (void)authenticateLocalUser:(UIViewController*) rootController {
    if (!gameCenterAvailable) return;
    
    NSLog(@"AVALAIBLE");
    GKLocalPlayer * player = [GKLocalPlayer localPlayer];
    if (player.isAuthenticated == NO) {
        player.authenticateHandler = ^(UIViewController* controller, NSError *error){
            if (controller != nil)
            {
                [rootController presentViewController:controller animated:YES completion:nil];
            }
            else if (error != nil)
            {
                NSLog(@"Error msg:%@", [error localizedDescription]);
            }
        };
    }
}

@end
