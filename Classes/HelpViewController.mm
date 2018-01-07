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
#import "Tracking.h"

@implementation HelpViewController
@synthesize scrollView, pageControl;
@synthesize leftButton, rightButton;

//DCW for the record, I think using a constant for the number of pages is stupid.
#define kNumImages 5

BOOL Pages[kNumImages];

- (IBAction)done {
  [self cleanupUI];
  [[AlephOneAppDelegate sharedAppDelegate].game closeHelp:self];
}

- (IBAction)internetHelp:(id)sender {
  UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Would go out to the internate"
                                                  delegate:nil
                                         cancelButtonTitle:@"Ok"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:nil];
  as.actionSheetStyle = UIActionSheetStyleDefault;
  [as showInView:self.view];
  [as release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  for ( int i = 0; i < kNumImages; i++ ) {
    Pages[i] = NO;
  }
  pageControlUsed = YES;

  [scrollView setContentMode:UIViewContentModeScaleAspectFill]; //DCW for some reason, this keeps the scrollview at the right aspect ratio.

  [super viewDidLoad];
}
- (void)setupUI {
  
  
  CGFloat kScrollObjHeight = scrollView.bounds.size.height;
  CGFloat kScrollObjWidth = scrollView.bounds.size.width;
  
  // load all the images from our bundle and add them to the scroll view
  NSUInteger i;
  for (i = 1; i <= kNumImages; i++) {
    NSString *imageName = [NSString stringWithFormat:@"help%d.png", i];
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    // setup each frame to a default height and correct-aspect width, it will be properly placed when we call "updateScrollList"
    CGRect rect = imageView.frame;
    if(imageView && rect.size.height) {
      rect.size.width = kScrollObjHeight * (rect.size.width/rect.size.height);//kScrollObjWidth;
    } else {
      rect.size.width = kScrollObjWidth;
    }
    rect.size.height = kScrollObjHeight;
    imageView.frame = rect;
    imageView.tag = i;  // tag our images for later use when we place them in serial fashion
    [scrollView addSubview:imageView];
    [imageView release];
  }
  UIImageView *view = nil;
  NSArray *subviews = [scrollView subviews];
  
  // reposition all image subviews in a vertical serial fashion
  CGFloat curYLoc = 0;
   for (view in subviews) {
     if ([view isKindOfClass:[UIImageView class]] && view.tag > 0) {
     CGRect frame = view.frame;
     frame.origin = CGPointMake(scrollView.bounds.size.width/2 - frame.size.width/2, curYLoc);
     view.frame = frame;
     
     curYLoc += (kScrollObjHeight);
     }
   }
  
  pageControl.numberOfPages = kNumImages;
  
  // set the content size so it can be scrollable
  [scrollView setContentSize:CGSizeMake([scrollView bounds].size.height, (kNumImages * kScrollObjHeight) )];

  [self changePage:nil];
}

- (void)cleanupUI {
  for ( UIView *v in [scrollView subviews] ) {
    [v removeFromSuperview];
  }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
  // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
  // which a scroll event generated from the user hitting the page control triggers updates from
  // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
  if (pageControlUsed)
  {
    // do nothing - the scroll was initiated from the page control, not the user dragging
    return;
  }
	
  // Switch the indicator when more than 50% of the previous/next page is visible
  CGFloat pageWidth = scrollView.frame.size.width;
  int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
  pageControl.currentPage = page;
  [self updateUI];
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
  pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  pageControlUsed = NO;
}

- (void)updateUI {
  if ( Pages[pageControl.currentPage] == NO ) {
    // Just send 1 tracking event...
    Pages[pageControl.currentPage] = YES;
    ////[Tracking trackPageview:[NSString stringWithFormat:@"/help/%d", pageControl.currentPage]];    
  }
  
  if ( pageControl.currentPage == 0 ) {
    self.leftButton.hidden = YES;
  } else {
    self.leftButton.hidden = NO;
  }
  if ( pageControl.currentPage == kNumImages - 1 ) {
    self.rightButton.hidden = YES;
  } else {
    self.rightButton.hidden = NO;
  }
}
  
  
  
- (IBAction)pageRight {
  if ( pageControl.currentPage < kNumImages - 1 ) {
    pageControl.currentPage += 1;
    [self changePage:pageControl];
  }
}

- (IBAction)pageLeft {
  if ( pageControl.currentPage > 0 ) {
    pageControl.currentPage -= 1;
    [self changePage:pageControl];
  }
}  

- (IBAction)changePage:(id)sender
{
  int page = pageControl.currentPage;
	  
	// update the scroll view to the appropriate page
  /*CGRect frame = scrollView.frame;
  frame.origin.x = frame.size.width * page;
  frame.origin.y = 0;*/
   CGRect frame = scrollView.frame;
   frame.origin.y = frame.size.height * page;
   frame.origin.x = 0;
   
   
  [scrollView scrollRectToVisible:frame animated:YES];
  [self updateUI];

	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
  pageControlUsed = YES;
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
  self.scrollView = nil;
  self.pageControl = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
