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

+ (void) login {
  cachePath = [NSString stringWithFormat:@"%@/CachedAchievements.plist", 
               [[AlephOneAppDelegate sharedAppDelegate] applicationDocumentsDirectory] ];
  [cachePath retain];
  if ( [[NSFileManager defaultManager] fileExistsAtPath:cachePath] ) {
    cachedAchievements = [NSMutableDictionary dictionaryWithContentsOfFile:cachePath];
  } else {
    cachedAchievements = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          [NSMutableArray arrayWithCapacity:2], kAchievements,
                          [NSMutableArray arrayWithCapacity:2], kScores, nil];
                          
  }
  [cachedAchievements retain];
  
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
  for ( GKAchievement *achievement in [cachedAchievements objectForKey:kAchievements] ) {
    [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
      if (error == nil) {
        // Remove it from the list!
        MLog (@"Successfully reported achievement %@ with progress: %f", achievement.identifier, achievement.percentComplete );
        [[cachedAchievements objectForKey:kAchievements] removeObject:achievement];
        [cachedAchievements writeToFile:cachePath atomically:YES];
      } else {
        MLog ( @"Failed to report achievement: %@", error );
      }
    }];
  }
  for ( GKScore *score in [cachedAchievements objectForKey:kScores] ) {
    [score reportScoreWithCompletionHandler:^(NSError *error) {
      if (error == nil) {
        // Remove it from the list!
        MLog (@"Successfully reported score %@ with value: %d", score.category, score.value );
        [[cachedAchievements objectForKey:kScores] removeObject:score];
        [cachedAchievements writeToFile:cachePath atomically:YES];
      } else {
        MLog ( @"Failed to report score: %@", error );
      }
    }];
  }
}

+ (void)reportAchievement:(NSString*)identifier progress:(float)percent {
  GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier: identifier] autorelease];
  if ( achievement ) {
    achievement.percentComplete = percent;
    [[cachedAchievements objectForKey:kAchievements] addObject:achievement];
    [cachedAchievements writeToFile:cachePath atomically:YES];
    [Achievements uploadAchievements];
  } else {
    MLog ( @"Couldn't create achievement for %@", identifier );
  }
}

+ (void)reportScore:(NSString*)identifier value:(int64_t)reportedScore {
  GKScore *score = [[[GKScore alloc] initWithCategory:identifier] autorelease];
  if ( score ) {
    score.value = reportedScore;
    [[cachedAchievements objectForKey:kScores] addObject:score];
    [cachedAchievements writeToFile:cachePath atomically:YES];
    [Achievements uploadAchievements];
  } else {
    MLog ( @"Couldn't create achievement for %@", identifier );
  }
}


@end
