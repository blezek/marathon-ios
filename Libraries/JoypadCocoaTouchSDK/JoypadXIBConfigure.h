//
//  JoypadXIBConfigure.h
//  JoypadCocoaTouchSample
//
//  Created by Daniel Blezek on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JoypadSDK.h"

/* JoypadXIBConfigure enables Joypad configurations to be built using Interface Builder / Xcode.
 To construct layout, create an XIB layout of 480x320 and place UI elements.  Each element is mapped
 to a Joypad construct using the item's tag.  The Tag is used to indicate which
 input element to use from the JoyInputIdentifier list.

 Generic Mapping:
 UIView -> Dpad and AnalogStick, using tag and frame
 UIButton -> Button (A,B,C,X,Y,Z,Select,Start,L or R) based on tag,
             frame, label text, label font size, and backgroundColor
             shape is kJoyButtonShapeSquare
 
 Specific Mapping:
 JPAccelerometer -> addAccelerometer
 JPDpad -> Dpad, centerView is used to set the center, if present
 JPAnalogStick -> addAnalogStic
 JPWheel -> current unused
 JPSquareButton -> as UIButton, but shape is square
 JPRoundButton -> as UIButton, but shape is round
 JPPillButton -> as UIButton, but shape is pill
 
 Construct the NIB, then use configureLayout to load and construct
 the custom layout.
 */


@interface JoypadXIBConfigure : NSObject {
  IBOutlet UIView *view;
}

@property(nonatomic,retain) UIView* view;
- (JoypadControllerLayout*) configureLayout:(NSString*)xibName;

@end

@interface JPDpad : UIView {
}
@property(nonatomic,retain) IBOutlet UIView* centerView;
@end

@interface JPAnalogStick : UIView {
}
@end
@interface JPAccelerometer : UIView {
}
@end

@interface JPWheel : UIView {
}
@end
@interface JPSquareButton : UIButton {
}
@end
@interface JPRoundButton : UIButton {
}
@end
@interface JPPillButton : UIButton {
}
@end
