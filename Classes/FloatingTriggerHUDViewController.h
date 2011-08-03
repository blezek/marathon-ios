//
//  FloatingTriggerHUDViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 7/28/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HUDViewController.h"
#import "FloatingTriggerLookView.h"
#import "MovePadView.h"

@interface FloatingTriggerHUDViewController : HUDViewController {
    
}
@property (nonatomic,retain) IBOutlet FloatingTriggerLookView* lookView;
@property (nonatomic,retain) IBOutlet MovePadView* movePadView;

@end
