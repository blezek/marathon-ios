//
//  Statistics.h
//  AlephOne
//
//  Created by Daniel Blezek on 4/11/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlephOneAppDelegate.h"

@interface Statistics : NSObject {
  NSMutableDictionary *stats;
  NSArray *index;
}

- (id)init;
- (void)loadStats;
- (void)saveStats;
- (void)updateLifetimeKills:(int[])kills withMultiplier:(float)multiplier;
- (void)updateLifetimeScore:(int64_t)delta;
- (void)uploadStats;
- (void)downloadStats;

@property (retain, nonatomic) NSMutableDictionary *stats;
@property (retain, nonatomic) NSArray *index;

@end
