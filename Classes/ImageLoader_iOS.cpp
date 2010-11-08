/*
 *  ImageLoader_iOS.cpp
 *  AlephOne
 *
 *  Created by Daniel Blezek on 10/19/10.
 *  Copyright 2010 SDG Productions. All rights reserved.
 *
 */


#include "ImageLoader.h"
#include "FileHandler.h"

#define PVR_TEXTURE_FLAG_TYPE_MASK	0xff

static char gPVRTexIdentifier[5] = "PVR!";

enum
{
	kPVRTextureFlagTypePVRTC_2 = 24,
	kPVRTextureFlagTypePVRTC_4
};

typedef struct _PVRTexHeader
{
	uint32_t headerLength;
	uint32_t height;
	uint32_t width;
	uint32_t numMipmaps;
	uint32_t flags;
	uint32_t dataLength;
	uint32_t bpp;
	uint32_t bitmaskRed;
	uint32_t bitmaskGreen;
	uint32_t bitmaskBlue;
	uint32_t bitmaskAlpha;
	uint32_t pvrTag;
	uint32_t numSurfs;
} PVRTexHeader;


bool ImageDescriptor::LoadPVTCFromFile ( FileSpecifier& File ) {
  PVRTexHeader *header = NULL;
  uint32_t flags, pvrTag;
  uint32_t dataLength = 0, dataOffset = 0, dataSize = 0;
  uint32_t blockSize = 0, widthBlocks = 0, heightBlocks = 0;
  uint32_t width = 0, height = 0, bpp = 4;
  uint8_t *bytes = NULL;
  uint32_t formatFlags;

  std::string fn ( File.GetPath() );
  if ( fn.find ( ".pvrtc" ) != std::string::npos ) {
    printf ( "LoadPVRTCFromFile: %s\n", File.GetPath() );
  } else {
    return false;
  }
  
  OpenedFile pvtcFile;
  if (!File.Open(pvtcFile)) {
    return false;
  }
  
  
  // Slurp the entire file in
  int32 length;
  pvtcFile.GetLength ( length );
  uint8_t *contents = new uint8_t[length];

  pvtcFile.Read ( length, contents );

  if ( fn.find ( ".pvrtc" ) != std::string::npos ) {
    // First few bytes
    for ( int i = 0; i < 16; i++ ) {
      printf ( "contents[%d] = %d, (0x%x)\n", i, contents[i], contents[i] );
    }
  }

  header = (PVRTexHeader *)contents;
  pvrTag = CFSwapInt32LittleToHost(header->pvrTag);

  if (gPVRTexIdentifier[0] != ((pvrTag >>  0) & 0xff) ||
      gPVRTexIdentifier[1] != ((pvrTag >>  8) & 0xff) ||
      gPVRTexIdentifier[2] != ((pvrTag >> 16) & 0xff) ||
      gPVRTexIdentifier[3] != ((pvrTag >> 24) & 0xff)) {
    delete[] contents;
    return false;
  }
  
  flags = CFSwapInt32LittleToHost(header->flags);
  formatFlags = flags & PVR_TEXTURE_FLAG_TYPE_MASK;
  if (formatFlags == kPVRTextureFlagTypePVRTC_4 || formatFlags == kPVRTextureFlagTypePVRTC_2) {
    if (formatFlags == kPVRTextureFlagTypePVRTC_4) {
      Format = PVRTC4;
    } else if (formatFlags == kPVRTextureFlagTypePVRTC_2) {
      Format = PVRTC2;
    }
    Width = CFSwapInt32LittleToHost(header->width);
    Height = CFSwapInt32LittleToHost(header->height);

    dataLength = CFSwapInt32LittleToHost(header->dataLength);
    ContentLength = dataLength;
    uint8_t *bytes = ((uint8_t *)contents) + sizeof(PVRTexHeader);

    /*
    for ( int i = 0; i < 16; i++ ) {
      printf ( "bytes[%d] = %d, (0x%x)\n", i, contents[i], contents[i] );
    }
     */

    // How many 4-byte ints do we need (padded by 2)?
    int numberOfPixels = ( dataLength / 4 ) + 2;
    Pixels = new uint32[numberOfPixels];
    memcpy ( Pixels, bytes, dataLength );
    /*
    for ( int i = 0; i < 16; i++ ) {
      uint8_t *tmp = (uint8_t*) Pixels;
      printf ( "pixels[%d] = %d, (0x%x)\n", i, tmp[i], tmp[i] );
    }
    */

    MipMapCount = CFSwapInt32LittleToHost ( header->numMipmaps );
    delete[] contents;
    return true;
  }
  delete[] contents;
  return false;
}
