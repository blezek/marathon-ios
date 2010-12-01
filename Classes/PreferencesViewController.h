//
//  PreferencesViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 10/13/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PreferencesViewController : UIViewController {
  UISwitch *tapShoots;
  UISwitch *secondTapShoots;
  UISlider *sfxVolume;
  UISlider *musicVolume;
  UISlider *hSensitivity;
  UISlider *vSensitivity;
}

@property (nonatomic, retain) IBOutlet UISwitch *tapShoots;
@property (nonatomic, retain) IBOutlet UISwitch *secondTapShoots;
@property (nonatomic, retain) IBOutlet UISlider *sfxVolume;
@property (nonatomic, retain) IBOutlet UISlider *musicVolume;
@property (nonatomic, retain) IBOutlet UISlider *hSensitivity;
@property (nonatomic, retain) IBOutlet UISlider *vSensitivity;

+ (void)setAlephOnePreferences;
- (void)setupUI;
- (IBAction)updatePreferences:(id)sender;
- (IBAction)closePreferences:(id)sender;

@end
