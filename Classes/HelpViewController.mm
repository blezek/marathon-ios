    //
//  HelpViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 11/19/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import "HelpViewController.h"
#import "AlephOneAppDelegate.h"
#import "GameViewController.h"

@implementation HelpViewController
@synthesize scrollView;
- (IBAction)done {
  [[AlephOneAppDelegate sharedAppDelegate].game closeHelp:self];
}
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  int kNumImages = 8;
  CGFloat kScrollObjHeight = scrollView.bounds.size.height;
  CGFloat kScrollObjWidth = scrollView.bounds.size.width;
  
  // load all the images from our bundle and add them to the scroll view
  NSUInteger i;
  for (i = 1; i <= kNumImages; i++) {
    NSString *imageName = [NSString stringWithFormat:@"help%d.png", i];
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
 
    // setup each frame to a default height and width, it will be properly placed when we call "updateScrollList"
    CGRect rect = imageView.frame;
    rect.size.height = kScrollObjHeight;
    rect.size.width = kScrollObjWidth;
    imageView.frame = rect;
    imageView.tag = i;  // tag our images for later use when we place them in serial fashion
    [scrollView addSubview:imageView];
    [imageView release];
  }
  UIImageView *view = nil;
  NSArray *subviews = [scrollView subviews];
    
  // reposition all image subviews in a horizontal serial fashion
  CGFloat curXLoc = 0;
  for (view in subviews) {
    if ([view isKindOfClass:[UIImageView class]] && view.tag > 0) {
      CGRect frame = view.frame;
      frame.origin = CGPointMake(curXLoc, 0);
      view.frame = frame;
      
      curXLoc += (kScrollObjWidth);
    }
  }
    
  // set the content size so it can be scrollable
  [scrollView setContentSize:CGSizeMake((kNumImages * kScrollObjWidth), [scrollView bounds].size.height)];
 
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
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
