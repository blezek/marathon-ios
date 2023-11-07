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
  scaleY.duration = 0.4;
  scaleY.fromValue = [NSNumber numberWithFloat:0.01];
  scaleY.toValue = [NSNumber numberWithFloat:1.0];
  
  CABasicAnimation *scaleX = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
  scaleX.duration = 0.4;
  scaleX.fromValue = [NSNumber numberWithFloat:10.0];
  scaleX.toValue = [NSNumber numberWithFloat:1.0];
  
  CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
  opacity.duration = 0.4;
  opacity.toValue = [NSNumber numberWithFloat:1.0];
  opacity.fromValue = [NSNumber numberWithFloat:0.0];
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.animations = [NSArray arrayWithObjects:scaleX, scaleY, opacity, nil];
  group.duration = 0.41;
  group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
 
  return group;
}

+ (float) disappearDuration { return 0.65; }
+ (CAAnimation*) disappearAnimation {
  CABasicAnimation *scaleY = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
  scaleY.duration = 0.4;
  scaleY.toValue = [NSNumber numberWithFloat:0.01];
  scaleY.fromValue = [NSNumber numberWithFloat:1.0];
  
  CABasicAnimation *scaleX = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
  scaleX.duration = 0.4;
  scaleX.toValue = [NSNumber numberWithFloat:10.0];
  scaleX.fromValue = [NSNumber numberWithFloat:1.0];
  
  CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
  opacity.duration = 0.3;
  opacity.toValue = [NSNumber numberWithFloat:0.0];
  opacity.beginTime = 0.1;
  
  CABasicAnimation *blank = [CABasicAnimation animationWithKeyPath:@"opacity"];
  blank.duration = 5.0;
  blank.beginTime = 0.4;
  blank.fromValue = [NSNumber numberWithFloat:0.0];
  blank.toValue = [NSNumber numberWithFloat:0.0];
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.animations = [NSArray arrayWithObjects:scaleX, scaleY, opacity, blank, nil];
  group.duration = 2.0;
  group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	
		//DCW: Set these 2 properties to prevent view from re-appearing after animation, due to behavior change after arm7.
	//[group setRemovedOnCompletion:NO];
	//[group setFillMode:kCAFillModeForwards];
	
  return group;
}  

	//DCW: animation with hidden completion needed on latest iOS.
+ (void)disappearHidingView:(UIView*)enclosingView {
	
	[UIView animateWithDuration:0.5
												delay:0.0
											options: UIViewAnimationOptionCurveEaseInOut
									 animations:^{
										 enclosingView.layer.transform = CATransform3DMakeScale(100.0,0.1,1.0); //Don't choose 0 for y, otherwise view will instantly vanish.
										 enclosingView.layer.opacity = 0;
									 }
									 completion:^(BOOL finished){
										 [enclosingView setHidden:YES];
									 }];
}

	//DCW: animation with completion needed on latest iOS.
+ (void)	appearRevealingView:(UIView*)enclosingView {
	
	enclosingView.layer.transform = CATransform3DMakeScale(100.0,0.1,1.0);
	enclosingView.layer.opacity = 0.0;
	[enclosingView setHidden:NO];
	[UIView animateWithDuration:0.5
												delay:0.0
											options: UIViewAnimationOptionCurveEaseInOut
									 animations:^{
										 enclosingView.layer.transform = CATransform3DMakeScale(1,1,1);
										 enclosingView.layer.opacity = 1;
									 }
									 completion:^(BOOL finished){
										 enclosingView.layer.opacity = 1;
										 enclosingView.layer.transform = CATransform3DMakeScale(1,1,1);
									 }];
}

+ (void)disappearWithDelay:(UIView*)enclosingView {
  
  [UIView animateWithDuration:0.5
                        delay:0.5
                      options: UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     enclosingView.layer.transform = CATransform3DMakeScale(1,1,1); //Don't choose 0 for y, otherwise view will instantly vanish.
                   }
                   completion:^(BOOL finished){
                     [enclosingView setHidden:YES];
                   }];
}


@end
