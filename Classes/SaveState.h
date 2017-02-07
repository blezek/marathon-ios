/*
 *  SaveState.h
 *  AlephOne
 *
 *  Created by Daniel Blezek on 9/20/10.
 *  Copyright 2010 SDG Productions. All rights reserved.
 *
 */


#ifdef HAVE_OPENGL
struct SaveState {
  GLenum mState;
  bool mEnabled;
  SaveState ( GLenum state ) {
    mState = state;
    mEnabled = glIsEnabled ( state );
  }
  ~SaveState() {
    if ( mEnabled ) {
      glEnable ( mState );
    } else {
      glDisable ( mState );
    }
  }
};
#endif