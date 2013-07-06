//
//  CCNative.mm
//  nozomi
//
//  Created by  stc on 13-5-4.
//
//

#include "platform/CCNative.h"
#include "platform/ios/IAPHelper.h"
#include "support/CCNotificationCenter.h"

NS_CC_EXT_BEGIN

void CCNative::openURL(const char *url)
{
    NSString *urlStr = [NSString stringWithCString:url encoding:NSASCIIStringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}

void CCNative::postNotification(int duration, const char *content)
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification!=nil){
        NSLog(@">> support local notification");
        NSDate *dt = [NSDate new];
        notification.fireDate=[dt dateByAddingTimeInterval:duration];
        [dt release];
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.alertBody = [NSString stringWithCString:content encoding:NSUTF8StringEncoding];
        notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber+1;
        notification.alertAction = @"Ok";
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        [notification autorelease];
    }
}

void CCNative::clearLocalNotification()
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

void CCNative::buyProductIdentifier(const char *productId)
{
    //CCNotificationCenter::sharedNotificationCenter()->postNotification("EVENT_BUY_SUCCESS");
    [[IAPHelper sharedHelper] buyProductIdentifier:[NSString stringWithCString:productId encoding:NSUTF8StringEncoding]];
}

NS_CC_EXT_END