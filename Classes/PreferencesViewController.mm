    //
//  PreferencesViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 10/13/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import "PreferencesViewController.h"
#import "AlephOneAppDelegate.h"
#include "preferences.h"
#include "Mixer.h"
#import "GameKit/GameKit.h"
#import "Tracking.h"
@implementation PreferencesViewController

@synthesize tapShoots;
@synthesize secondTapShoots;
@synthesize sfxVolume;
@synthesize musicVolume;
@synthesize hSensitivity;
@synthesize vSensitivity;
@synthesize musicLabel;
@synthesize crosshairs;
@synthesize brightness;
@synthesize autoCenter;
@synthesize filmsDisabled;
@synthesize vidmasterModeLabel, vidmasterMode;
@synthesize hiresTexturesLabel, hiresTextures;
@synthesize screenView;

- (IBAction)closePreferences:(id)sender {
  // Save the back to defaults
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];


  [defaults setBool:[self.tapShoots isOn] forKey:kTapShoots];
  if ( [self.tapShoots isOn] != [defaults boolForKey:kTapShoots] ) {
    [ Tracking trackEvent:@"settings" action:kTapShoots label:@"" value:[self.tapShoots isOn]];
  }
  [defaults setBool:[self.crosshairs isOn] forKey:kCrosshairs];
  if ( [self.crosshairs isOn] != [defaults boolForKey:kCrosshairs] ) {
    [ Tracking trackEvent:@"settings" action:kCrosshairs label:@"" value:[self.crosshairs isOn]];
  }
  [defaults setBool:[self.secondTapShoots isOn] forKey:kSecondTapShoots];
  if ( [self.secondTapShoots isOn] != [defaults boolForKey:kSecondTapShoots] ) {
    [ Tracking trackEvent:@"settings" action:kSecondTapShoots label:@"" value:[self.secondTapShoots isOn]];
  }
  [defaults setBool:[self.autoCenter isOn] forKey:kAutocenter];
  if ( [self.autoCenter isOn] != [defaults boolForKey:kAutocenter] ) {
    [ Tracking trackEvent:@"settings" action:kAutocenter label:@"" value:[self.autoCenter isOn]];
  }
  [defaults setBool:[self.vidmasterMode isOn] forKey:kUseVidmasterMode];
  if ( [self.vidmasterMode isOn] != [defaults boolForKey:kUseVidmasterMode] ) {
    [ Tracking trackEvent:@"settings" action:kUseVidmasterMode label:@"" value:[self.vidmasterMode isOn]];
  }
  [defaults setBool:[self.hiresTextures isOn] forKey:kUseTTEP];
  if ( [self.hiresTextures isOn] != [defaults boolForKey:kUseTTEP] ) {
    [ Tracking trackEvent:@"settings" action:kUseTTEP label:@"" value:[self.hiresTextures isOn]];
  }
  
  [defaults setFloat:self.sfxVolume.value forKey:kSfxVolume];
  if ( self.sfxVolume.value != [defaults floatForKey:kSfxVolume] ) {
    [ Tracking trackEvent:@"settings" action:kSfxVolume label:@"" value: self.sfxVolume.value ];
  }
  [defaults setFloat:self.musicVolume.value forKey:kMusicVolume];
  if ( self.musicVolume.value != [defaults floatForKey:kMusicVolume] ) {
    [ Tracking trackEvent:@"settings" action:kMusicVolume label:@"" value: self.musicVolume.value ];
  }
  [defaults setFloat:self.hSensitivity.value forKey:kHSensitivity];
  if ( self.hSensitivity.value != [defaults floatForKey:kHSensitivity] ) {
    [ Tracking trackEvent:@"settings" action:kHSensitivity label:@"" value: self.hSensitivity.value ];
  }
  [defaults setFloat:self.brightness.value forKey:kGamma];
  if ( self.brightness.value != [defaults floatForKey:kGamma] ) {
    [ Tracking trackEvent:@"settings" action:kGamma label:@"" value: self.brightness.value ];
  }
  [defaults setFloat:self.hSensitivity.value forKey:kHSensitivity];
  if ( self.hSensitivity.value != [defaults floatForKey:kHSensitivity] ) {
    [ Tracking trackEvent:@"settings" action:kHSensitivity label:@"" value: self.hSensitivity.value ];
  }
  [defaults setFloat:self.vSensitivity.value forKey:kVSensitivity];
  if ( self.vSensitivity.value != [defaults floatForKey:kVSensitivity] ) {
    [ Tracking trackEvent:@"settings" action:kVSensitivity label:@"" value: self.vSensitivity.value ];
  }
  
  [defaults synchronize];
  [PreferencesViewController setAlephOnePreferences:YES checkPurchases:inMainMenu];
  [[GameViewController sharedInstance] updateReticule:-1];

  [[AlephOneAppDelegate sharedAppDelegate].game closePreferences:sender];
  
  // Crosshairs are set in the UI layer, not by the engine
  // Crosshairs_SetActive([defaults boolForKey:kCrosshairs]);
  Crosshairs_SetActive(NO);

}


- (void)setupUI:(BOOL)inMainMenuFlag {
  inMainMenu = inMainMenuFlag;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  self.tapShoots.on = [defaults boolForKey:kTapShoots];
  self.crosshairs.on = [defaults boolForKey:kCrosshairs];
  self.autoCenter.on = [defaults boolForKey:kAutocenter];
  self.secondTapShoots.on = [defaults boolForKey:kSecondTapShoots];
  self.sfxVolume.value = [defaults floatForKey:kSfxVolume];
  self.musicVolume.value = [defaults floatForKey:kMusicVolume];
  self.hSensitivity.value = [defaults floatForKey:kHSensitivity];
  self.vSensitivity.value = [defaults floatForKey:kVSensitivity];
  self.brightness.value = [defaults floatForKey:kGamma];
#if SCENARIO == 1
  self.musicLabel.hidden = NO;
  self.musicVolume.hidden = NO;
#endif
  self.hiresTexturesLabel.hidden = YES;
  self.hiresTextures.hidden = YES;
  self.hiresTextures.on = [defaults boolForKey:kUseTTEP];
  self.vidmasterModeLabel.hidden = YES;
  self.vidmasterMode.hidden = YES;
  self.vidmasterMode.on = [defaults boolForKey:kUseVidmasterMode];  
#if defined(A1DEBUG)
  self.hiresTexturesLabel.hidden = !inMainMenu || ![defaults boolForKey:kHaveTTEP];
  self.hiresTextures.hidden = !inMainMenu || ![defaults boolForKey:kHaveTTEP];
  self.hiresTextures.on = [defaults boolForKey:kUseTTEP];
  self.vidmasterModeLabel.hidden = ![defaults boolForKey:kHaveVidmasterMode];
  self.vidmasterMode.hidden = ![defaults boolForKey:kHaveVidmasterMode];
  self.vidmasterMode.on = [defaults boolForKey:kUseVidmasterMode];
  
#endif

  for ( UIView *view in self.view.subviews ) {
    if ( view.tag == 1000 ) {
#if defined(A1DEBUG)
      view.hidden = NO;
#else
      view.hidden = YES;
#endif
    }
  }
  // The BG for M2 is too bright, activate the screens
  self.screenView.hidden = YES;
#if SCENARIO == 2
  self.screenView.hidden = NO;
#endif
}

- (IBAction)updatePreferences:(id)sender {
  [PreferencesViewController setAlephOnePreferences:YES checkPurchases:inMainMenu];
}

- (IBAction)resetAchievements:(id)sender {
  [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
    if ( error != nil ) {
      MLog(@"Failed to reset achievements: %@", error );
    } else {
      MLog(@"Achievements reset!" );
    }
  }];
}

- (IBAction)notifyOfChanges {
}

+ (void)setAlephOnePreferences:(BOOL)notifySoundManager checkPurchases:(BOOL)check{
  MLog ( @"Set preferences from device back to engine" );
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  sound_preferences->music = ceil ( (double)[defaults floatForKey:kMusicVolume] * (NUMBER_OF_SOUND_VOLUME_LEVELS-1) );
  sound_preferences->volume = ceil ( (double)[defaults floatForKey:kSfxVolume] * (NUMBER_OF_SOUND_VOLUME_LEVELS-1) );
  float sens;
  sens = [defaults floatForKey:kVSensitivity];
  if ( sens < 0.1 ) { sens = 0.1; }
  input_preferences->sens_vertical = _fixed ( sens * FIXED_ONE );
  sens = [defaults floatForKey:kHSensitivity];
  if ( sens < 0.1 ) { sens = 0.1; }
  input_preferences->sens_horizontal = _fixed ( sens * FIXED_ONE );
  
  // Auto center
  if ( [defaults boolForKey:kAutocenter] ) {
    input_preferences->modifiers &= ~_inputmod_dont_auto_recenter;
  } else {
    input_preferences->modifiers |= _inputmod_dont_auto_recenter;
  }
  // Never autocenter
  input_preferences->modifiers |= _inputmod_dont_auto_recenter;

#if defined(A1DEBUG)
  // Always autocenter, so we can do films
  input_preferences->modifiers &= ~_inputmod_dont_auto_recenter;
#endif
  
  if ( notifySoundManager ) {
    // Sound ranges from 0-255, but is stored in 8 levels... go figure... 
    if ( Mixer::instance()->MusicPlaying() ) {
      Mixer::instance()->SetMusicChannelVolume ( ceil ( [defaults floatForKey:kMusicVolume] * MAXIMUM_SOUND_VOLUME ) );
    }
    Mixer::instance()->SetVolume ( ceil ( [defaults floatForKey:kSfxVolume] * MAXIMUM_SOUND_VOLUME ) );
  }
  if ( check ) {
    [[AlephOneAppDelegate sharedAppDelegate].purchases performSelector:@selector(checkPurchases) withObject:nil afterDelay:0.0];
  }
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
