//
//  AudioBuffersQueue.m
//  WeshApp-tunes
//
//  Created by Carlos Alonso on 18/10/2014.
//  Copyright (c) 2014 Foot Clan. All rights reserved.
//

#import "AudioBuffersQueue.h"
#import <AVFoundation/AVFoundation.h>

@implementation AudioBuffersQueue

+ (AudioBuffersQueue *) queue {
  return [[AudioBuffersQueue alloc] init];
}

- (instancetype) init {
  if (self = [super init]) {
    queue = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < 3; ++i) {
      queue[i] = [[WeshAudioBuffer alloc] init];
    }
    currentBuffer = 0;
  }
  return self;
}

- (WeshAudioBuffer *) nextFreeBuffer {
  if ([queue[currentBuffer] full] || [queue[currentBuffer] submitted]) {
    currentBuffer += 1;
    if (currentBuffer == [queue count]) {
      currentBuffer = 0;
    }
  }
  return queue[currentBuffer];
}

- (void) addData:(const void *)data length:(UInt32)length {
  WeshAudioBuffer *buf = [self nextFreeBuffer];
  UInt32 leftovers = (UInt32)[buf addData:data length:length];
  if (leftovers != 0) {
    // Submit buf
    [self addData:(const void *)(data + length - leftovers) length:leftovers];
  } else if([buf full]) {
    // Submit buf
  }
}

- (void) addData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDesc {
  WeshAudioBuffer *buf = [self nextFreeBuffer];
  if ([buf addData:data length:length packetDescription:packetDesc]) {
    if ([buf full]) {
      // Submit buf
    }
  } else {
    // Submit buf
    [self addData:data length:length packetDescription:packetDesc];
  }
}

@end
