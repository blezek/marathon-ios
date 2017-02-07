//
//  JoypadLinkerHelper.m
//
//  Created by Lou Zell on 11/30/11.
//  Copyright 2011 Joypad Inc. All rights reserved.
//
//  Please email questions to lzell11@gmail.com
//  __________________________________________________________________________
//
//  If your deployment target is less than 4.0, please make sure this file is
//  included in your target's sources.  Otherwise you will receive a "dyld: 
//  Symbol not found" error when you test on a device running < 4.0.
//
//  You can safely delete this file if your deployment target is >= iOS 4.0.
// 
//  You may also delete this file if you add "-weak_framework UIKit" to 
//  Other Linker Flags in build settings.
//
//

#if TARGET_OS_IPHONE
#import <UIKit/UIApplication.h>
BOOL JOYLinkerHelper(void);  // Quiet compiler warning: missing prototype.
BOOL JOYLinkerHelper(void)
{
  BOOL bgAvailable = (&UIApplicationDidEnterBackgroundNotification != NULL);
  BOOL fgAvailable = (&UIApplicationWillEnterForegroundNotification != NULL);
  return (bgAvailable && fgAvailable);
}
#endif
