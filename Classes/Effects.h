//
//  Effects.h
//  AlephOne
//
//  Created by Daniel Blezek on 12/18/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface Effects : NSObject {

}

+ (CAAnimation*) appearAnimation;
+ (float) appearDuration;

+ (CAAnimation*) disappearAnimation;
+ (float) disappearDuration;

	//DCW
+ (void)disappearHidingView:(UIView*)enclosingView;
+ (void)appearRevealingView:(UIView*)enclosingView;
+ (void)disappearWithDelay:(UIView*)enclosingView;

@end
