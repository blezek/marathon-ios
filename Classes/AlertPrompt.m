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
    UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(16,40,252,34)];
    passwordField.font = [UIFont systemFontOfSize:20];
    passwordField.backgroundColor = [UIColor blackColor];
    passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
    passwordField.borderStyle = UITextBorderStyleRoundedRect;
    [self addSubview:passwordField];

    self.textField = passwordField;
    
    [self show];
    [passwordField release];
    
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  AlertPrompt *p = (AlertPrompt*)alertView;
  completionBlock ( p.enteredText );
}
- (id)initWithTitle:(NSString *)title
  cancelButtonTitle:(NSString *)cancelButtonTitle
      okButtonTitle:(NSString *)okayButtonTitle
         completion:(void(^)(NSString*))completion {
  completionBlock = completion;
  return [self initWithTitle:title
                    delegate:self
           cancelButtonTitle:cancelButtonTitle
               okButtonTitle:okayButtonTitle];
}


- (void)dealloc
{
  [textField release];
  [super dealloc];
}
@end
