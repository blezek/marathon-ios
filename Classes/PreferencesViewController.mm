    //
//  PreferencesViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 10/13/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import "PreferencesViewController.h"
#import "AlephOneAppDelegate.h"

@implementation PreferencesViewController

@synthesize tapShoots;
@synthesize secondTapShoots;
@synthesize sfxVolume;
@synthesize musicVolume;
@synthesize hSensitivity;
@synthesize vSensitivity;

- (IBAction)closePreferences:(id)sender {
  
  // Save the back to defaults
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setBool:[self.tapShoots isOn] forKey:kTapShoots];
  [defaults setBool:[self.secondTapShoots isOn] forKey:kSecondTapShoots];
  [defaults setFloat:self.sfxVolume.value forKey:kSfxVolume];
  [defaults setFloat:self.musicVolume.value forKey:kMusicVolume];
  [defaults setFloat:self.hSensitivity.value forKey:kHSensitivity];
  [defaults setFloat:self.vSensitivity.value forKey:kVSensitivity];
  [defaults synchronize];
  [[AlephOneAppDelegate sharedAppDelegate].game closePreferences:sender];
}


- (void)setupUI {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  self.tapShoots.on = [defaults boolForKey:kTapShoots];
  self.secondTapShoots.on = [defaults boolForKey:kSecondTapShoots];
  self.sfxVolume.value = [defaults floatForKey:kSfxVolume];
  self.musicVolume.value = [defaults floatForKey:kMusicVolume];
  self.hSensitivity.value = [defaults floatForKey:kHSensitivity];
  self.vSensitivity.value = [defaults floatForKey:kVSensitivity];
}

+ (void)setAlephOnePreferences {
  MLog ( @"Set preferences from device back to engine" );
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
