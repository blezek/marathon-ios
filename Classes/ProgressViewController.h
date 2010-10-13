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
  IBOutlet PDColoredProgressView *progressView;
  int currentProgress;
  int total;
}

- (void)startProgress:(int)t;
- (void)progressCallback:(int)d;  

@property (nonatomic,retain) IBOutlet PDColoredProgressView *progressView;
@end
