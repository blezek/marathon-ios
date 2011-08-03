//
//  PauseViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 10/13/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundedView.h"

@interface PauseViewController : UIViewController <UIActionSheetDelegate> {
  UILabel *statusLabel;
}

@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
- (IBAction) resume:(id)sender;
- (IBAction) gotoMenu:(id)sender;
- (IBAction) help:(id)sender;
- (IBAction) gotoPreferences:(id)sender;
- (IBAction) shieldCheat:(id)sender;
- (IBAction) invincibilityCheat:(id)sender;
- (IBAction) ammoCheat:(id)sender;
- (IBAction) saveCheat:(id)sender;
- (IBAction) weaponsCheat:(id)sender;
- (IBAction) connectToJoypad:(id)sender;
- (IBAction)setup;

@end
