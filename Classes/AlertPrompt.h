//
//  AlertPrompt.h
//  Prompt
//
//  Created by Jeff LaMarche on 2/26/09.

#import <Foundation/Foundation.h>

@interface AlertPrompt : UIAlertView 
{
  UITextField *textField;
}
@property (nonatomic, retain) UITextField *textField;
@property (readonly) NSString *enteredText;
- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle;
@end