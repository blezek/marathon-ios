     //
//  NewGameViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 8/24/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import "NewGameViewController.h"
#import "GameViewController.h"
#include "preferences.h"
#include "map.h"
#import "Effects.h"

@implementation NewGameViewController
@synthesize easyButton;
@synthesize normalButton;
@synthesize hardButton;
@synthesize nightmareButton;
@synthesize startLevelSlider;
@synthesize startLevelLabel;
@synthesize pledge;
@synthesize startLevelView;

static vector<entry_point> levels;


#pragma mark Actions

- (IBAction)start:(id)control {
  NSLog ( @"Start!" );
  [[GameViewController sharedInstance] beginGame];
}
- (IBAction)cancel:(id)control {
  NSLog ( @"Cancel" );
  [[GameViewController sharedInstance] cancelNewGame];
}
- (IBAction)setDifficulty:(id)control {
  if ( control == easyButton ) { player_preferences->difficulty_level = _easy_level; }
  if ( control == normalButton ) { player_preferences->difficulty_level = _normal_level; }
  if ( control == hardButton ) { player_preferences->difficulty_level = _major_damage_level; }
  if ( control == nightmareButton ) { player_preferences->difficulty_level = _total_carnage_level; }
  [self start:control];
}

- (IBAction)setEntryLevel:(id)control {
  int index = (int)self.startLevelSlider.value;
  
  [[NSUserDefaults standardUserDefaults] setInteger:levels[index].level_number forKey:kEntryLevelNumber];
  self.startLevelLabel.text = [NSString stringWithFormat:@"%d. %s", levels[self.startLevelSlider.value].level_number, levels[self.startLevelSlider.value].level_name];
}

#pragma mark -
#pragma mark View Controller Methods

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/*
- (void)viewDidLoad {
    [super viewDidLoad];
  CGAffineTransform transform = self.view.transform;
  
  CGRect bounds = CGRectMake(0, 0, 1024, 768);
  CGPoint center = CGPointMake(bounds.size.height / 2.0, bounds.size.width / 2.0);
  // Set the center point of the view to the center point of the window's content area.
  self.view.center = center;
  // Rotate the view 90 degrees around its new center point.
  transform = CGAffineTransformRotate(transform, (M_PI / 2.0));
  
  self.view.transform = transform;
  self.view.bounds = CGRectMake(0, 0, 1024, 768);
}
 */

- (void)appear {
  /*
  self.pledge.layer.cornerRadius = 20.0;
  self.pledge.layer.borderColor = [[UIColor grayColor] CGColor];
  self.pledge.layer.borderWidth = 1;
   */
  // Get levels
  levels.clear();
  /* Everything!
  const int32 AllPlayableLevels = _single_player_entry_point |
  _multiplayer_carnage_entry_point |
  _multiplayer_cooperative_entry_point |
  _kill_the_man_with_the_ball_entry_point |
  _king_of_hill_entry_point |
  _rugby_entry_point |
  _capture_the_flag_entry_point;
   */
  const int32 AllPlayableLevels = _single_player_entry_point;
  
  if (!get_entry_points(levels, AllPlayableLevels)) {
    entry_point dummy;
    dummy.level_number = 0;
    strcpy(dummy.level_name, "Untitled Level");
    levels.push_back(dummy);
  }
  self.startLevelSlider.minimumValue = 0;
  self.startLevelSlider.maximumValue = levels.size() - 1;
  self.startLevelSlider.value = 0;
  int level = [[NSUserDefaults standardUserDefaults] integerForKey:kEntryLevelNumber];
  for ( int i = 0; i < levels.size(); i++ ) {
    MLog ( @"Level %d : %s", levels[i].level_number, levels[i].level_name );
    if ( levels[i].level_number == level ) {
      self.startLevelSlider.value = (float)i;
    }
  }
  [self setEntryLevel:nil];
  BOOL show = [[NSUserDefaults standardUserDefaults] boolForKey:kHaveVidmasterMode] 
           && [[NSUserDefaults standardUserDefaults] boolForKey:kUseVidmasterMode];
  self.pledge.hidden = !show;
  self.startLevelSlider.hidden = !show;
  self.startLevelLabel.hidden = !show;
  self.startLevelView.hidden = !show;
  
  [self.startLevelSlider setThumbImage:[UIImage imageNamed:@"SliderTab"] forState:UIControlStateNormal];
  [self.startLevelSlider setThumbImage:[UIImage imageNamed:@"SliderTab"] forState:UIControlStateSelected];
  [self.startLevelSlider setThumbImage:[UIImage imageNamed:@"SliderTab"] forState:UIControlStateHighlighted];
  [self.startLevelSlider setMaximumTrackImage:[UIImage imageNamed:@"SliderGreyTrack"] forState:UIControlStateNormal];
  [self.startLevelSlider setMinimumTrackImage:[UIImage imageNamed:@"SliderWhiteTrack"] forState:UIControlStateNormal];
  
  /*CAAnimation *group = [Effects appearAnimation];
  for ( UIView *v in self.view.subviews ) {
    [v.layer removeAllAnimations];
    [v.layer addAnimation:group forKey:nil];
  }*/
	
	[Effects appearRevealingView:self.view];
	/*
	self.view.layer.transform = CATransform3DMakeScale(100.0,0.0,1.0);
	[UIView animateWithDuration:1.5
												delay:0.0
											options: UIViewAnimationOptionCurveEaseInOut
									 animations:^{
										 self.view.layer.transform = CATransform3DMakeScale(1,1,1);
									 }
									 completion:^(BOOL finished){
										 [self.view setHidden:NO];
									 }];
*/
  
  
}  

- (void)disappear {
	[Effects disappearHidingView:self.view];
}  

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Overriden to allow any orientation.
  return ( interfaceOrientation == UIInterfaceOrientationLandscapeRight );
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
