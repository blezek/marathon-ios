//
//  Effects.m
//  AlephOne
//
//  Created by Daniel Blezek on 12/18/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import "Effects.h"


@implementation Effects

+ (float) appearDuration { return 0.7; }

+ (CAAnimation*) appearAnimation {
  // warp everything in to start
  CABasicAnimation *scaleY = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
  scaleY.duration = 0.7;
  scaleY.fromValue = [NSNumber numberWithFloat:0.01];
  scaleY.toValue = [NSNumber numberWithFloat:1.0];
  
  CABasicAnimation *scaleX = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
  scaleX.duration = 0.7;
  scaleX.fromValue = [NSNumber numberWithFloat:10.0];
  scaleX.toValue = [NSNumber numberWithFloat:1.0];
  
  CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
  opacity.duration = 0.7;
  opacity.toValue = [NSNumber numberWithFloat:1.0];
  opacity.fromValue = [NSNumber numberWithFloat:0.0];
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.animations = [NSArray arrayWithObjects:scaleX, scaleY, opacity, nil];
  group.duration = 1.0;
  group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
 
  return group;
}

+ (float) disappearDuration { return 0.65; }
+ (CAAnimation*) disappearAnimation {
  CABasicAnimation *scaleY = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
  scaleY.duration = 0.8;
  scaleY.toValue = [NSNumber numberWithFloat:0.01];
  scaleY.fromValue = [NSNumber numberWithFloat:1.0];
  
  CABasicAnimation *scaleX = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
  scaleX.duration = .8;
  scaleX.toValue = [NSNumber numberWithFloat:10.0];
  scaleX.fromValue = [NSNumber numberWithFloat:1.0];
  
  CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
  opacity.duration = 0.7;
  opacity.toValue = [NSNumber numberWithFloat:0.0];
  opacity.beginTime = 0.1;
  
  CABasicAnimation *blank = [CABasicAnimation animationWithKeyPath:@"opacity"];
  blank.duration = 1.0;
  blank.beginTime = 0.6;
  blank.fromValue = [NSNumber numberWithFloat:0.0];
  blank.toValue = [NSNumber numberWithFloat:0.0];
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.animations = [NSArray arrayWithObjects:scaleX, scaleY, opacity, blank, nil];
  group.duration = 1.0;
  group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
  
  return group;
}  


@end
