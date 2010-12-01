//
//  PauseViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 10/13/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PauseViewController : UIViewController {
}

- (IBAction) resume:(id)sender;
- (IBAction) gotoMenu:(id)sender;
- (IBAction) help:(id)sender;
- (IBAction) gotoPreferences:(id)sender;
- (IBAction)shieldCheat:(id)sender;
- (IBAction)invincibilityCheat:(id)sender;
- (IBAction)ammoCheat:(id)sender;
- (IBAction)saveCheat:(id)sender;
- (IBAction)weaponsCheat:(id)sender;

- (IBAction)setup;

@end
