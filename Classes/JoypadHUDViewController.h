//
//  JoypadHUDViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 7/21/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HUDViewController.h"
#import "JoypadManager.h"
#import "AlertPrompt.h"
#import "AlertView.h"

@class JoypadManager;

@interface JoypadHUDViewController : HUDViewController <JoypadManagerDelegate,UIAlertViewDelegate> {
  JoypadManager *joypadManager;
  NSArray *buttonMap;
}

@property (nonatomic,retain) UIAlertView *alert;
-(void)connectToDevice;
-(void)connectByIP:(NSString*)ip;
@end
