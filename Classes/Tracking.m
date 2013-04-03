//
//  Tracking.m
//  AlephOne
//
//  Created by Daniel Blezek on 6/2/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "Tracking.h"
#import "Secrets.h"
#import "Prefs.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "LocalyticsSession.h"
#import "TestFlight.h"
#import "GAITracker.h"

@implementation Tracking

+ (void)startup {
  NSError *error;
  MLog(@"Starting tracking" );
  
  // Add some machine info
  size_t size;
  sysctlbyname("hw.machine", NULL, &size, NULL, 0);
  char *machine = malloc(size);
  sysctlbyname("hw.machine", machine, &size, NULL, 0);
  NSString *platform = [NSString stringWithUTF8String:machine];
  free(machine);
  [[LocalyticsSession sharedLocalyticsSession] startSession:LAAccountID];
  [[LocalyticsSession sharedLocalyticsSession] setOptIn:[[NSUserDefaults standardUserDefaults] boolForKey:kUsageData]];
  
}
+ (void)shutdown {
  MLog(@"Stopping tracking");
  [[LocalyticsSession sharedLocalyticsSession] close];
}


+ (void)dispatch {
  MLog(@"Dispatching tracking" );
  if ( [[NSUserDefaults standardUserDefaults] boolForKey:kUsageData] ) {
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
    if ( !result ) {
      MLog(@"Error in trackPageview %@", error);
    }
  }
  return result;
}



@end
