//
//  Achievements.h
//  AlephOne
//
//  Created by Daniel Blezek on 4/7/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameViewController.h"

#define Achievement_Marathon @"marathon"
#define kSScore @"score"
#define kSLifetimeScore @"Lifetime.Score"
#define kSLifetimeDamage @"Lifetime.Damage"

#define kSCompletionTimeEasy @"Easy.CompletionTime"

#if SCENARIO == 1
#define AchievementPrefix @""
#endif
#if SCENARIO == 2
#define AchievementPrefix @"M2"
#endif
#if SCENARIO == 3
#define AchievementPrefix @"M3"
#endif


@interface Achievements : NSObject {

}

+ (void)login;
+ (void)reportAchievement:(NSString*)identifier progress:(float)percent;
+ (void)reportScore:(NSString*)identifier value:(int64_t)reportedScore;
+ (void)uploadAchievements;
+ (BOOL)isAuthenticated;

@end
