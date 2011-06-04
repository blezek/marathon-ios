//
//  Tracking.m
//  AlephOne
//
//  Created by Daniel Blezek on 6/2/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "Tracking.h"
#import "Secrets.h"
#import "GANTracker.h"
#import "Prefs.h"



@implementation Tracking

+ (void)startup {
  MLog(@"Starting tracking" );
  [[GANTracker sharedTracker] startTrackerWithAccountID:GAAccountID
                                         dispatchPeriod:-1
                                               delegate:nil];
  
}
+ (void)shutdown {
  MLog(@"Stopping tracking");
  [[GANTracker sharedTracker] stopTracker];
}


+ (void)dispatch {
  MLog(@"Dispatching tracking" );
  if ( [[NSUserDefaults standardUserDefaults] boolForKey:kUsageData] ) {
    [[GANTracker sharedTracker] dispatch];
  }
}

+ (BOOL)trackEvent:(NSString*)category
            action:(NSString *)action
             label:(NSString *)label
             value:(NSInteger)value {
  BOOL ret = YES;
  if ( [[NSUserDefaults standardUserDefaults] boolForKey:kUsageData] ) {
    NSError *error;
    ret = [[GANTracker sharedTracker] trackEvent:category
                                           action:action 
                                            label:label
                                            value:value
                                        withError:&error];
  }
  return ret;
}
+ (BOOL)trackPageview:(NSString *)pageURL {
  BOOL result = YES;
  if ( [[NSUserDefaults standardUserDefaults] boolForKey:kUsageData] ) {
    NSError *error;
    result = [[GANTracker sharedTracker] trackPageview:pageURL withError:&error];
    if ( !result ) {
      MLog(@"Error in trackPageview %@", error);
    }
  }
  return result;
}



@end
