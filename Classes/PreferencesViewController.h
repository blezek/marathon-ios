//
//  PreferencesViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 10/13/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PreferencesViewController : UIViewController {
  BOOL inMainMenu;
  UISwitch *tapShoots;
  UISwitch *crosshairs;
  UISwitch *autoCenter;
  UISwitch *secondTapShoots;
  UISlider *sfxVolume;
  UISlider *musicVolume;
  UISlider *hSensitivity;
  UISlider *vSensitivity;
  UISlider *brightness;
  UILabel *hiresTexturesLabel;
  UISwitch *hiresTextures;
  UILabel *vidmasterModeLabel;
  UISwitch *vidmasterMode;
  UILabel *musicLabel;
  UILabel *filmsDisabled;
}

@property (nonatomic, retain) IBOutlet UISwitch *tapShoots;
@property (nonatomic, retain) IBOutlet UISwitch *autoCenter;
@property (nonatomic, retain) IBOutlet UISwitch *crosshairs;
@property (nonatomic, retain) IBOutlet UISwitch *secondTapShoots;
@property (nonatomic, retain) IBOutlet UISlider *sfxVolume;
@property (nonatomic, retain) IBOutlet UISlider *musicVolume;
@property (nonatomic, retain) IBOutlet UILabel *musicLabel;
@property (nonatomic, retain) IBOutlet UILabel *filmsDisabled;
@property (nonatomic, retain) IBOutlet UISlider *hSensitivity;
@property (nonatomic, retain) IBOutlet UISlider *vSensitivity;
@property (nonatomic, retain) IBOutlet UISlider *brightness;

@property (nonatomic, retain) IBOutlet UISwitch *hiresTextures;
@property (nonatomic, retain) IBOutlet UILabel *hiresTexturesLabel;
@property (nonatomic, retain) IBOutlet UISwitch *vidmasterMode;
@property (nonatomic, retain) IBOutlet UILabel *vidmasterModeLabel;

+ (void)setAlephOnePreferences:(BOOL)notifySoundManager checkPurchases:(BOOL)check;
- (void)setupUI:(BOOL)inMainMenu;
- (IBAction)updatePreferences:(id)sender;
- (IBAction)closePreferences:(id)sender;
- (IBAction)notifyOfChanges;
- (IBAction)resetAchievements:(id)sender;

@end
