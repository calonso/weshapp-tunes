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

- (instancetype) initWithAudioQueue:(AudioQueueRef)audioQueue {
  if (self = [super init]) {
    OSStatus err = AudioQueueAllocateBuffer(audioQueue, kBufferSize, &_audioQueueBuffer);
    if (err) {
      NSLog(@"In error");
    }
    fillLevel = 0;
    self.submitted = false;
    packetDescriptions = malloc(sizeof(AudioStreamPacketDescription) * kMaxPacketDescriptions);
  }
  return self;
}

- (NSInteger) addData:(const void *)data length:(UInt32)length {
  if (fillLevel + length <= kBufferSize) {
    // Chunk fits entirely in the buffer
    memcpy((char *)(self.audioQueueBuffer->mAudioData + fillLevel), (const char *)data, length);
    fillLevel += length;
    return 0;
  } else {
    // Chunk doesn't fit in the buffer
    NSUInteger bytesToCopy = kBufferSize - fillLevel;
    memcpy((char *)(self.audioQueueBuffer->mAudioData + fillLevel), (const char *)data, bytesToCopy);
    fillLevel = kBufferSize;
    return length - bytesToCopy;
  }
}

- (BOOL) addData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDescription {
  if (fillLevel + packetDescription.mDataByteSize > kBufferSize || numberOfPacketDescriptions == kMaxPacketDescriptions) {
    return NO;
  }
  memcpy((char *)(self.audioQueueBuffer->mAudioData + fillLevel), (const char *)(data + packetDescription.mStartOffset), packetDescription.mDataByteSize);
  
  packetDescriptions[numberOfPacketDescriptions] = packetDescription;
  packetDescriptions[numberOfPacketDescriptions].mStartOffset = fillLevel;
  numberOfPacketDescriptions++;
  
  fillLevel += packetDescription.mDataByteSize;
  
  return YES;
}

- (BOOL) full {
  return fillLevel == kBufferSize;
}

- (void) submitTo:(AudioQueueRef)audioQueue {
  self.submitted = true;
  self.audioQueueBuffer->mAudioDataByteSize = fillLevel;
  if(AudioQueueEnqueueBuffer(audioQueue, self.audioQueueBuffer, numberOfPacketDescriptions, packetDescriptions)) {
    NSLog(@"Error enqueuing!");
  }
}

- (void) free {
  fillLevel = 0;
  self.submitted = false;
}

@end
