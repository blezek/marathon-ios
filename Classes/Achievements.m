//
//  Achievements.m
//  AlephOne
//
//  Created by Daniel Blezek on 4/7/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "Achievements.h"
#import "AlephOneAppDelegate.h"
#import "GameKit/GameKit.h"
static bool isAuthenticated = NO;
static NSMutableArray *cachedAchievements = nil;
static NSString *cachePath = nil;
static NSTimer *timer = nil;

@implementation Achievements

+ (void) login {
  cachePath = [NSString stringWithFormat:@"%@/CachedAchievements.plist", 
               [[AlephOneAppDelegate sharedAppDelegate] applicationDocumentsDirectory] ];
  [cachePath retain];
  cachedAchievements = [NSMutableArray arrayWithCapacity:0];
  [cachedAchievements retain];
  if ( [[NSFileManager defaultManager] fileExistsAtPath:cachePath] ) {
    NSArray *temp = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
    for ( id obj in temp ) {
      [cachedAchievements addObject:obj];
    }
  }
  
  GKLocalPlayer *player = [GKLocalPlayer localPlayer];
  [player authenticateWithCompletionHandler:^(NSError *error) {
    if (player.isAuthenticated) {
      // Fetch existing achievements
      MLog(@"Authenticated w/GameCenter" );
      isAuthenticated = YES;
      [Achievements uploadAchievements];
    } else {
      MLog (@"Error authenticating player: %@", error );
    }
    
  }];
  timer = [NSTimer timerWithTimeInterval:60 target:[AlephOneAppDelegate sharedAppDelegate] selector:@selector(uploadAchievements) userInfo:nil repeats:YES];
}



+ (void)uploadAchievements {
  MLog(@"Uploading" );
  for ( GKAchievement *achievement in cachedAchievements ) {
    [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
      if (error == nil) {
        // Remove it from the list!
        MLog (@"Successfully reported achievement %@ with progress: %f", achievement.identifier, achievement.percentComplete );
        [cachedAchievements removeObject:achievement];
        [NSKeyedArchiver archiveRootObject:cachedAchievements toFile:cachePath];
      } else {
        MLog ( @"Failed to report achievement: %@", error );
      }
    }];
  }
}



+ (void)reportAchievement:(NSString*)identifier progress:(float)percent {
  GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier: identifier] autorelease];
  if ( achievement ) {
    achievement.percentComplete = percent;
    [cachedAchievements addObject:achievement];
    [Achievements uploadAchievements];
  } else {
    MLog ( @"Couldn't create achievement for %@", identifier );
  }
}


@end
