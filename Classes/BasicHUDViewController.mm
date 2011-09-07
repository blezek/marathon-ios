//
//  BasicHUDViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 7/19/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "BasicHUDViewController.h"


@implementation BasicHUDViewController
@synthesize lookView, movePadView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      // Custom initialization
      [self.movePadView setup];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  self.lookView.primaryFire = self.primaryFireKey;
  self.lookView.secondaryFire = self.secondaryFireKey;
  [self.movePadView setup];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
  self.lookView = nil;
  self.movePadView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
