//
//  ProgressViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 10/12/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDColoredProgressView.h"

@interface ProgressViewController : UIViewController {
  PDColoredProgressView *progressView;
  UIView *mainView;
  IBOutlet UIView *hdmAd;
  IBOutlet UIView *vmmAd;
  int currentProgress;
  int total;
}

- (void)startProgress:(int)t;
- (void)progressCallback:(int)d;  
- (void)progressFinished;

@property (nonatomic,retain) IBOutlet PDColoredProgressView *progressView;
@property (nonatomic,retain) IBOutlet UIView *mainView;
@property (nonatomic,retain) UIView *hdmAd;
@property (nonatomic,retain) UIView *vmmAd;
@property (nonatomic,retain) IBOutlet UIView *rmAd;
@end
