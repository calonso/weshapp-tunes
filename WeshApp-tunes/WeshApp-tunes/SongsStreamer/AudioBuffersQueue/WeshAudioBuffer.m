//
//  WeshAudioBuffer.m
//  WeshApp-tunes
//
//  Created by Carlos Alonso on 18/10/2014.
//  Copyright (c) 2014 Foot Clan. All rights reserved.
//

#import "WeshAudioBuffer.h"

static UInt32 kBufferSize = 2048;
static UInt32 kMaxPacketDescriptions = 512;

@implementation WeshAudioBuffer

- (instancetype) init:(AudioQueueRef)audioQueue {
  if (self = [super init]) {
    AudioQueueAllocateBuffer(audioQueue, kBufferSize, &audioQueueBuffer);
    fillLevel = 0;
    self.submitted = false;
  }
  return self;
}

- (NSInteger) addData:(const void *)data length:(UInt32)length {
  if (fillLevel + length <= kBufferSize) {
    // Chunk fits entirely in the buffer
    memcpy((char *)(audioQueueBuffer->mAudioData + fillLevel), (const char *)data, length);
    fillLevel += length;
    return 0;
  } else {
    // Chunk doesn't fit in the buffer
    NSUInteger bytesToCopy = kBufferSize - fillLevel;
    memcpy((char *)(audioQueueBuffer->mAudioData + fillLevel), (const char *)data, bytesToCopy);
    fillLevel = kBufferSize;
    return length - bytesToCopy;
  }
}

- (BOOL) addData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDescription {
  if (fillLevel + packetDescription.mDataByteSize > kBufferSize || numberOfPacketDescriptions == kMaxPacketDescriptions) {
    return NO;
  }
  
  memcpy((char *)(audioQueueBuffer->mAudioData + fillLevel), (const char *)(data + packetDescription.mStartOffset), packetDescription.mDataByteSize);
  
  packetDescriptions[numberOfPacketDescriptions] = packetDescription;
  packetDescriptions[numberOfPacketDescriptions].mStartOffset = fillLevel;
  numberOfPacketDescriptions++;
  
  fillLevel += packetDescription.mDataByteSize;
  
  return YES;
}

- (BOOL) full {
  return fillLevel == kBufferSize;
}

@end
