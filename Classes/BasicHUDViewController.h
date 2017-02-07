//
//  BasicHUDViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 7/19/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HUDViewController.h"
#import "LookView.h"
#import "MovePadView.h"
#import "LookPadView.h" //DCW

@interface BasicHUDViewController : HUDViewController {
  MovePadView *movePadView;
	LookPadView *lookPadView; //DCW

  IBOutlet UIButton* actionKeyImageView;
}

@property (nonatomic,retain) IBOutlet LookView* lookView;
@property (nonatomic,retain) IBOutlet MovePadView* movePadView;
@property (nonatomic,retain) IBOutlet LookPadView* lookPadView; //DCW
@property (nonatomic,retain) IBOutlet UIButton* actionKeyImageView;
@property (nonatomic,retain) IBOutlet UIView* actionBox;
@end
