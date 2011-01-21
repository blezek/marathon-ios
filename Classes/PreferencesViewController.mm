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

- (IBAction)closePreferences:(id)sender {
  
  // Save the back to defaults
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setBool:[self.tapShoots isOn] forKey:kTapShoots];
  [defaults setBool:[self.crosshairs isOn] forKey:kCrosshairs];
  [defaults setBool:[self.secondTapShoots isOn] forKey:kSecondTapShoots];
  [defaults setFloat:self.sfxVolume.value forKey:kSfxVolume];
  [defaults setFloat:self.musicVolume.value forKey:kMusicVolume];
  [defaults setFloat:self.hSensitivity.value forKey:kHSensitivity];
  [defaults setFloat:self.brightness.value forKey:kGamma];
  [defaults setFloat:self.hSensitivity.value forKey:kHSensitivity];
  [defaults setFloat:self.vSensitivity.value forKey:kVSensitivity];
  [defaults setBool:[self.autoCenter isOn] forKey:kAutocenter];
  [defaults synchronize];
  [PreferencesViewController setAlephOnePreferences:YES];
  [[AlephOneAppDelegate sharedAppDelegate].game closePreferences:sender];
  Crosshairs_SetActive([defaults boolForKey:kCrosshairs]);

}


- (void)setupUI {
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
  [self notifyOfChanges];
}

- (IBAction)updatePreferences:(id)sender {
  [PreferencesViewController setAlephOnePreferences:YES];
}
- (IBAction)notifyOfChanges {
  if ( self.autoCenter.on ) {
    self.filmsDisabled.hidden = YES;
  } else {
    self.filmsDisabled.hidden = NO;
  }
}



+ (void)setAlephOnePreferences:(BOOL)notifySoundManager {
  MLog ( @"Set preferences from device back to engine" );
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  sound_preferences->music = ceil ( (double)[defaults floatForKey:kMusicVolume] * (NUMBER_OF_SOUND_VOLUME_LEVELS-1) );
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
  
  SoundManager::instance()->SetParameters(*sound_preferences);

  MLog ( @"Music: %d", sound_preferences->music );
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
