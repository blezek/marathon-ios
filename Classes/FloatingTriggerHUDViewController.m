//
//  FloatingTriggerHUDViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 7/28/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import "FloatingTriggerHUDViewController.h"


@implementation FloatingTriggerHUDViewController
@synthesize lookView, movePadView, actionKeyImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dimActionKey {
  self.actionKeyImageView.alpha = 0.2;
}
- (void)lightActionKey {
  self.actionKeyImageView.alpha = 1.0;
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
 [self.movePadView setup];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
