//
//  DownloadViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 9/8/10.
//  Copyright 2010 SDG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "PDColoredProgressView.h"


@interface DownloadViewController : UIViewController {
  PDColoredProgressView *progressView;
  UIView *expandingView;
  NSString *downloadPath;
  bool dataNetwork;
}

@property (nonatomic, retain) IBOutlet PDColoredProgressView *progressView;
@property (nonatomic, retain) IBOutlet UIView *expandingView;

- (void)downloadFinished:(ASIHTTPRequest*)request;
- (void)downloadOrchooseGame;
- (bool)isDownloadOrChooseGameNeeded;
- (void)downloadFailed:(ASIHTTPRequest*)request;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)startGame;
- (bool)isScenarioDownloaded;
- (void)downloadAndStart;
- (void)unzipAndStart;
@end
