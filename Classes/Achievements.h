//
//  Achievements.h
//  AlephOne
//
//  Created by Daniel Blezek on 4/7/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>


#define Achievement_Marathon @"marathon"

@interface Achievements : NSObject {

}

+ (void)login;
+ (void)reportAchievement:(NSString*)identifier progress:(float)percent;
+ (void)uploadAchievements;

@end
