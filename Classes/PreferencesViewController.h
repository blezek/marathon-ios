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
  UITextField *login;
  UITextField *password;
  UIButton *tapShoots;
  UIButton *alwaysRun;
  UIButton *smoothMouselook;
  UIButton *crosshairs;
  UIButton *autoCenter;
  UIButton *secondTapShoots;
  UISlider *sfxVolume;
  UISlider *musicVolume;
  UISlider *hSensitivity;
  UISlider *vSensitivity;
  UISlider *brightness;
  UILabel *hiresTexturesLabel;
  UIButton *hiresTextures;
  UILabel *vidmasterModeLabel;
  UIButton *vidmasterMode;
  UILabel *musicLabel;
  UILabel *filmsDisabled;
  UIView *screenView;
}

@property (nonatomic, retain) IBOutlet UITextField *login;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UIButton *tapShoots;
@property (nonatomic, retain) IBOutlet UIButton *alwaysRun;
@property (nonatomic, retain) IBOutlet UIButton *smoothMouselook;
@property (nonatomic, retain) IBOutlet UIButton *autoCenter;
@property (nonatomic, retain) IBOutlet UIButton *crosshairs;
@property (nonatomic, retain) IBOutlet UIButton *onScreenTrigger;
@property (nonatomic, retain) IBOutlet UIButton *hiLowTapsAltFire;
@property (nonatomic, retain) IBOutlet UIButton *gyroAiming;
@property (nonatomic, retain) IBOutlet UIButton *tiltTurning;
@property (nonatomic, retain) IBOutlet UIButton *secondTapShoots;
@property (nonatomic, retain) IBOutlet UISlider *sfxVolume;
@property (nonatomic, retain) IBOutlet UISlider *musicVolume;
@property (nonatomic, retain) IBOutlet UILabel *musicLabel;
@property (nonatomic, retain) IBOutlet UILabel *filmsDisabled;
@property (nonatomic, retain) IBOutlet UISlider *hSensitivity;
@property (nonatomic, retain) IBOutlet UISlider *vSensitivity;
@property (nonatomic, retain) IBOutlet UISlider *brightness;

@property (nonatomic, retain) IBOutlet UIButton *hiresTextures;
@property (nonatomic, retain) IBOutlet UILabel *hiresTexturesLabel;
@property (nonatomic, retain) IBOutlet UIButton *vidmasterMode;
@property (nonatomic, retain) IBOutlet UILabel *vidmasterModeLabel;
@property (nonatomic, retain) IBOutlet UIView *settingPrefsView;

+ (void)setAlephOnePreferences:(BOOL)notifySoundManager checkPurchases:(BOOL)check;
- (void)setupUI:(BOOL)inMainMenu;
- (IBAction)updatePreferences:(id)sender;
- (IBAction)closePreferences:(id)sender;
- (IBAction)notifyOfChanges;
- (IBAction)resetAchievements:(id)sender;
-(IBAction) toggleButton:(id)sender;
- (void)appear;
- (void)disappear;

@end
