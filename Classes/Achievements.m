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

#define kAchievements @"Achievements"
#define kScores @"Scores"

static bool isAuthenticated = NO;
static NSMutableDictionary *cachedAchievements = nil;
static NSString *cachePath = nil;
static NSTimer *timer = nil;

@implementation Achievements

+ (BOOL) isAuthenticated {
  return isAuthenticated;
}

+ (void) login {
  cachePath = [NSString stringWithFormat:@"%@/CachedAchievements.plist", 
               [[AlephOneAppDelegate sharedAppDelegate] applicationDocumentsDirectory] ];
  [cachePath retain];
  if ( [[NSFileManager defaultManager] fileExistsAtPath:cachePath] ) {
    cachedAchievements = [NSMutableDictionary dictionaryWithContentsOfFile:cachePath];
  } else {
    cachedAchievements = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          [NSMutableDictionary dictionaryWithCapacity:2], kAchievements,
                          [NSMutableDictionary dictionaryWithCapacity:2], kScores, nil];
                          
  }
  [cachedAchievements retain];
  
#if defined(USE_GAMECENTER)
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

#endif
}



+ (void)uploadAchievements {
#if defined(USE_GAMECENTER)
  MLog(@"Uploading" );
  NSMutableDictionary *achievements = [cachedAchievements objectForKey:kAchievements];
  for ( GKAchievement *achievement in [achievements objectEnumerator] ) {
    [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
      if (error == nil) {
        // Remove it from the list!
        MLog (@"Successfully reported achievement %@ with progress: %f", achievement.identifier, achievement.percentComplete );
        [achievements removeObjectForKey:achievement.identifier];
      } else {
        MLog ( @"Failed to report achievement: %@", achievement.identifier );
      }
    }];
  }
  NSMutableDictionary *scores = [cachedAchievements objectForKey:kScores];
  for ( GKScore *score in [scores objectEnumerator] ) {
    [score reportScoreWithCompletionHandler:^(NSError *error) {
      if (error == nil) {
        // Remove it from the list!
        MLog (@"Successfully reported score %@ with value: %d", score.category, score.value );
        [scores removeObjectForKey:score.category];
      } else {
        MLog ( @"Failed to report score: %@", score.category );
#if defined(A1DEBUG)
        [scores removeObjectForKey:score.category];
#endif        
      }
      [cachedAchievements writeToFile:cachePath atomically:YES];
    }];
  }
#endif
}

+ (void)reportAchievement:(NSString*)identifier progress:(float)percent {
  GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier: identifier] autorelease];
  if ( achievement ) {
    achievement.percentComplete = percent;
      NSMutableDictionary *dict = [cachedAchievements objectForKey:kAchievements];
    [dict setObject:achievement forKey:achievement.identifier];
    [cachedAchievements writeToFile:cachePath atomically:YES];
  } else {
    MLog ( @"Couldn't create achievement for %@", identifier );
  }
}

+ (void)reportScore:(NSString*)identifier value:(int64_t)reportedScore {
  GKScore *score = [[[GKScore alloc] initWithCategory:identifier] autorelease];
  if ( score ) {
    score.value = reportedScore;
    NSMutableDictionary *dict = [cachedAchievements objectForKey:kScores];
    [dict setObject:score forKey:score.category];
    [cachedAchievements writeToFile:cachePath atomically:YES];
  } else {
    MLog ( @"Couldn't create achievement for %@", identifier );
  }
}


@end
