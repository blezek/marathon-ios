//
//  FloatingTriggerLookView.h
//  AlephOne
//
//  Created by Daniel Blezek on 7/28/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HUDViewController.h"

typedef enum TouchMode {
  NotTouching, Looking, PrimaryFire, SecondaryFire
} TouchMode;

@interface FloatingTriggerLookView : UIView {
  TouchMode mode;
  float startingAlpha;
}

@property (nonatomic,retain) IBOutlet HUDViewController *hudViewController;
@property (nonatomic,retain) IBOutlet UIView *primaryFireButton;
@property (nonatomic,retain) IBOutlet UIView *secondaryFireButton;

@property (nonatomic,retain) UITouch *trackingTouch;
@property (nonatomic,retain) UITouch *lookTouch;
@property (nonatomic,retain) UITouch *primaryTouch;
@property (nonatomic,retain) UITouch *secondaryTouch;

- (BOOL)touch:(UITouch*)touch hitView:(UIView*)view;
- (void)updateButtons:(CGPoint)point;
@end
