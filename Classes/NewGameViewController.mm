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
@implementation NewGameViewController

#pragma mark Actions

- (IBAction)start:(id)control {
  NSLog ( @"Start!" );
  [[GameViewController sharedInstance] beginGame];
  [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)cancel:(id)control {
  NSLog ( @"Cancel" );
  [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)setDifficulty:(UISegmentedControl*)control {
  NSLog ( @"Set Difficulty: %d", [control selectedSegmentIndex] );
  player_preferences->difficulty_level = [control selectedSegmentIndex];
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
