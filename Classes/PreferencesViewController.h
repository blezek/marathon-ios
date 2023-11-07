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
  
  UIScrollView *prefsScrollView;
  UIView *prefsScrollContents;

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
  UIButton *bloom;
  UIButton *extraFOV;
  UIButton *rendererButton;
  UILabel *rendererNote;
}

@property (nonatomic, retain) IBOutlet UIScrollView *prefsScrollView;
@property (nonatomic, retain) IBOutlet UIView *prefsScrollContents;

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
@property (nonatomic, retain) IBOutlet UIButton *threeDTouchFires;
@property (nonatomic, retain) IBOutlet UILabel *threeDTouchFiresLabel;
@property (nonatomic, retain) IBOutlet UIButton *dPadAction;
@property (nonatomic, retain) IBOutlet UISlider *sfxVolume;
@property (nonatomic, retain) IBOutlet UISlider *musicVolume;
@property (nonatomic, retain) IBOutlet UILabel *musicLabel;
@property (nonatomic, retain) IBOutlet UILabel *filmsDisabled;
@property (nonatomic, retain) IBOutlet UISlider *hSensitivity;
@property (nonatomic, retain) IBOutlet UISlider *vSensitivity;
@property (nonatomic, retain) IBOutlet UISlider *brightness;
@property (nonatomic, retain) IBOutlet UIButton *bloom;
@property (nonatomic, retain) IBOutlet UIButton *extraFOV;
@property (nonatomic, retain) IBOutlet UIButton *rendererButton;
@property (nonatomic, retain) IBOutlet UILabel *rendererNote;



@property (nonatomic, retain) IBOutlet UIButton *hiresTextures;
@property (nonatomic, retain) IBOutlet UILabel *hiresTexturesLabel;
@property (nonatomic, retain) IBOutlet UIButton *vidmasterMode;
@property (nonatomic, retain) IBOutlet UILabel *vidmasterModeLabel;
@property (nonatomic, retain) IBOutlet UIView *settingPrefsView;

+ (void)setAlephOnePreferences:(BOOL)notifySoundManager checkPurchases:(BOOL)check;
- (void)setupUI:(BOOL)inMainMenu;
- (void)setVisualStyleButton;
- (IBAction)updatePreferences:(id)sender;
- (IBAction)closePreferences:(id)sender;
- (IBAction)notifyOfChanges;
- (IBAction)resetAchievements:(id)sender;
-(IBAction) toggleButton:(id)sender;
- (void)appear;
- (void)disappear;

@end
