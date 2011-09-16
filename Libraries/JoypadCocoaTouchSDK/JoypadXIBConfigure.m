//
//  JoypadXIBConfigure.m
//  JoypadCocoaTouchSample
//
//  Created by Daniel Blezek on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JoypadXIBConfigure.h"
#import "JoypadSDK.h"

@implementation JoypadXIBConfigure
@synthesize view;

- (JoypadControllerLayout*) configureLayout:(NSString*)nibName {
  if ( [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] == NO ) {
    NSLog(@"Error loading nib %@!", nibName);
    return nil;
  }
  JoypadControllerLayout *customLayout = [[JoypadControllerLayout alloc] init];
  [customLayout setName:nibName];

  for ( UIView* item in view.subviews ) {
    NSLog(@"Found an %@; Tag %d", item, item.tag );
    
    // Start with most specific
    if ( [item class] == [JPAccelerometer class] ) {
      [customLayout addAccelerometer];
    } else if ( [item class] == [JPDpad class] ) {
      JPDpad *pad = (JPDpad*)item;
      // Create a dpad
      if ( pad.tag != kJoyInputDpad1 && pad.tag != kJoyInputDpad2 ) {
        NSLog(@"ERROR---- Must have a tag for Dpad1 or Dpad2!" );
        pad.tag = kJoyInputDpad1;
      }
      if ( pad.centerView != nil ) {
        [customLayout addDpadWithFrame:pad.frame
                            dpadOrigin:pad.centerView.center
                            identifier:pad.tag];
      } else {
        [customLayout addDpadWithFrame:pad.frame
                            identifier:pad.tag];
      }
    } else if ( [item isKindOfClass:[UIButton class]] ) {
      JoyButtonShape shape = kJoyButtonShapeSquare;
      JoyButtonColor color = kJoyButtonColorBlue;
      if ( [item class] == [JPRoundButton class] ) { shape = kJoyButtonShapeRound; }
      if ( [item class] == [JPPillButton class] ) { shape = kJoyButtonShapePill; }
      if ( item.backgroundColor == [UIColor blackColor] ) {
        color = kJoyButtonColorBlack;
      }
      UIButton *button = (UIButton*)item;
      [customLayout addButtonWithFrame:button.frame 
                                 label:button.titleLabel.text
                              fontSize:button.titleLabel.font.pointSize
                                 shape:shape
                                 color:color
                            identifier:button.tag];      
    } else if ( [item isKindOfClass:[JPAnalogStick class]] ) {
      if ( item.tag == kJoyInputAnalogStick1 || item.tag == kJoyInputAnalogStick2 ) {
      [customLayout addAnalogStickWithFrame:item.frame identifier:item.tag];
      }
    } else {
      NSLog(@"ERROR: Unknown tag (%d)!", item.tag );
      NSLog(@"ERROR: Unknown UI element %@", item);
    }
  }
                 
  return customLayout;
                 
}


@end



@implementation JPDpad 
@synthesize centerView;
@end
@implementation JPAnalogStick
@end
@implementation JPAccelerometer
@end
@implementation JPWheel
@end
@implementation JPSquareButton
@end
@implementation JPRoundButton
@end
@implementation JPPillButton
@end
