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
#include <sys/types.h>
#include <sys/sysctl.h>
#import "LocalyticsSession.h"
#import "TestFlight.h"

@implementation Tracking

+ (void)startup {
  NSError *error;
  MLog(@"Starting tracking" );
  [[GANTracker sharedTracker] startTrackerWithAccountID:GAAccountID
                                         dispatchPeriod:-1
                                               delegate:nil];
  
  // Add some machine info
  size_t size;
  sysctlbyname("hw.machine", NULL, &size, NULL, 0);
  char *machine = malloc(size);
  sysctlbyname("hw.machine", machine, &size, NULL, 0);
  NSString *platform = [NSString stringWithUTF8String:machine];
  free(machine);
  if (![[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                       name:@"platform"
                                                      value:platform
                                                      scope:kGANSessionScope
                                                  withError:&error]) {
    NSLog(@"error in platform");
  }
  if (![[GANTracker sharedTracker] setCustomVariableAtIndex:2
                                                       name:@"systemVersion"
                                                      value:[UIDevice currentDevice].systemVersion
                                                      scope:kGANSessionScope
                                                  withError:&error]) {
    NSLog(@"error in systemVersion");
  }
  if (![[GANTracker sharedTracker] setCustomVariableAtIndex:3
                                                       name:@"marathonVersion"
                                                      value:A1_RELEASE_STRING
                                                      scope:kGANSessionScope
                                                  withError:&error]) {
    NSLog(@"error in systemVersion");
  }
  [[LocalyticsSession sharedLocalyticsSession] startSession:LAAccountID];
  [[LocalyticsSession sharedLocalyticsSession] setOptIn:[[NSUserDefaults standardUserDefaults] boolForKey:kUsageData]];
  
}
+ (void)shutdown {
  MLog(@"Stopping tracking");
  [[GANTracker sharedTracker] stopTracker];
  [[LocalyticsSession sharedLocalyticsSession] close];
}


+ (void)dispatch {
  MLog(@"Dispatching tracking" );
  if ( [[NSUserDefaults standardUserDefaults] boolForKey:kUsageData] ) {
    [[GANTracker sharedTracker] dispatch];
    [[LocalyticsSession sharedLocalyticsSession] upload];
  }
}


+ (void)tagEvent:(NSString *)event {
  [self tagEvent:event attributes:nil];
}
   
+ (void)tagEvent:(NSString *)event attributes:(NSDictionary *)attributes {
  if ( [[NSUserDefaults standardUserDefaults] boolForKey:kUsageData] ) {
    if ( attributes == nil ) {
      [[LocalyticsSession sharedLocalyticsSession] tagEvent:event];
    } else {
      [[LocalyticsSession sharedLocalyticsSession] tagEvent:event attributes:attributes];
    }
  }
}

+ (BOOL)trackEvent:(NSString*)category
            action:(NSString *)action
             label:(NSString *)label
             value:(NSInteger)value {
  BOOL ret = YES;
  /*
   for ( id key in [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] keyEnumerator] ) {
   MLog(@"Defaults[%@] = %@", key, [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] objectForKey:key]);
   }
  */
  if ( [[NSUserDefaults standardUserDefaults] boolForKey:kUsageData] ) {
    NSError *error;
    ret = [[GANTracker sharedTracker] trackEvent:category
                                           action:action 
                                            label:label
                                            value:value
                                        withError:&error];
    if ( !ret ) {
      MLog(@"Error in trackEvent: %@", error);
    }
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
