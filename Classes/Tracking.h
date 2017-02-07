//
//  Tracking.h
//  AlephOne
//
//  Created by Daniel Blezek on 6/2/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Tracking : NSObject {
    
}

+ (void)dispatch;
+ (BOOL)trackEvent:(NSString*)category
            action:(NSString *)action
             label:(NSString *)label
             value:(NSInteger)value;
+ (BOOL)trackPageview:(NSString *)pageURL;
+ (void)startup;
+ (void)shutdown;
+ (void)tagEvent:(NSString *)event attributes:(NSDictionary *)attributes;
+ (void)tagEvent:(NSString *)event;
@end
