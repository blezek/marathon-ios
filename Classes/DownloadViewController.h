//
//  DownloadViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 9/8/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"


@interface DownloadViewController : UIViewController {
  UIProgressView *progressView;
  NSString *downloadPath;
}

@property (nonatomic, retain) IBOutlet UIProgressView *progressView;

- (void)downloadFinished:(ASIHTTPRequest*)request;
- (void)downloadOrchooseGame;
- (bool)isDownloadOrChooseGameNeeded;
- (void)downloadFailed:(ASIHTTPRequest*)request;
@end
