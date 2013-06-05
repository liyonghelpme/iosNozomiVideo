//
//  GCHelper.h
//  nozomi
//
//  Created by  stc on 13-2-26.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GCHelper : NSObject {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
}

@property (assign, readonly) BOOL gameCenterAvailable;

+ (GCHelper *)sharedGameCenter;
- (void)authenticationChanged;
- (void)authenticateLocalUser:(UIViewController*) rootController;

@end
