//
//  JoypadConstants.h
//
//  Created by Lou Zell on 6/1/11.
//  Copyright 2011 Joypad Inc. All rights reserved.
//
//  Please email questions to lzell11@gmail.com
//  __________________________________________________________________________
//

typedef struct
{
  float x;
  float y;
  float z;
}JoypadAcceleration;

typedef struct
{
  float angle;    // radians
  float distance;
}JoypadStickPosition;

typedef enum
{
  kJoyDpadButtonUp,
  kJoyDpadButtonRight,
  kJoyDpadButtonDown,
  kJoyDpadButtonLeft
}JoyDpadButton;

typedef enum
{
  kJoyButtonShapeSquare,
  kJoyButtonShapeRound,
  kJoyButtonShapePill
}JoyButtonShape;

typedef enum
{
  kJoyButtonColorBlue,
  kJoyButtonColorBlack
}JoyButtonColor;

typedef enum
{
  kJoyInputDpad1         = 0,
  kJoyInputDpad2         = 1,
  kJoyInputAnalogStick1  = 2,
  kJoyInputAnalogStick2  = 3,
  kJoyInputAccelerometer = 4,
  kJoyInputWheel         = 5,
  kJoyInputAButton       = 6,
  kJoyInputBButton       = 7,
  kJoyInputCButton       = 8,
  kJoyInputXButton       = 9,
  kJoyInputYButton       = 10,
  kJoyInputZButton       = 11,
  kJoyInputSelectButton  = 12,
  kJoyInputStartButton   = 13,
  kJoyInputLButton       = 14,
  kJoyInputRButton       = 15
}JoyInputIdentifier;

typedef enum
{
  kJoyControllerNES,
  kJoyControllerGBA,
  kJoyControllerSNES,
  kJoyControllerGenesis,
  kJoyControllerN64,
  kJoyControllerAnyPreinstalled,
  kJoyControllerCustom
}JoyControllerIdentifier;
