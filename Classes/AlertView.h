//
//  AlertView.h
//  AlephOne
//
//  Created by Daniel Blezek on 7/25/11.
//  Copyright 2011 SDG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AlertView : UIAlertView <UIAlertViewDelegate> {
  void(^completionBlock)(NSInteger buttonIndex );
  
}
- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSArray *)otherButtonTitles
         completion:(void(^)(NSInteger buttonIndex ))completion;

- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
      okButtonTitle:(NSString *)okButtonTitle
         completion:(void(^)(NSInteger buttonIndex ))completion;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;


@end
