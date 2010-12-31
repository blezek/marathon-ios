//
//  AlertPrompt.m
//  Prompt
//
//  Created by Jeff LaMarche on 2/26/09.

#import "AlertPrompt.h"

@implementation AlertPrompt
@synthesize textField;
@synthesize enteredText;
- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
  
  if (self = [super initWithTitle:title message:@"\n\n" delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil])
  {
    /*
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,40,260,25)];
    passwordLabel.font = [UIFont systemFontOfSize:18];
    passwordLabel.textColor = [UIColor whiteColor];
    passwordLabel.backgroundColor = [UIColor clearColor];
    passwordLabel.shadowColor = [UIColor blackColor];
    passwordLabel.shadowOffset = CGSizeMake(0,-1);
    passwordLabel.textAlignment = UITextAlignmentCenter;
    passwordLabel.text = message;
    [self addSubview:passwordLabel];
    */
    UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(16,40,252,34)];
    passwordField.font = [UIFont systemFontOfSize:20];
    passwordField.backgroundColor = [UIColor blackColor];
    passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
    passwordField.borderStyle = UITextBorderStyleRoundedRect;
    [self addSubview:passwordField];

    self.textField = passwordField;
    
    // [passwordAlert setTransform:CGAffineTransformMakeTranslation(0,109)];
    [self show];
    // [self release];
    [passwordField release];
    // [passwordLabel release];
    
  }
  return self;
}
- (void)show
{
  [textField becomeFirstResponder];
  [super show];
}
- (NSString *)enteredText
{
  return textField.text;
}
- (void)dealloc
{
  [textField release];
  [super dealloc];
}
@end
