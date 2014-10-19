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

+ (AudioBuffersQueue *) queueForAudioQueue:(AudioQueueRef)audioQueue {
  return [[AudioBuffersQueue alloc] initWithAudioQueue:audioQueue];
}

- (instancetype) initWithAudioQueue:(AudioQueueRef)audioQueue {
  if (self = [super init]) {
    audioPlayingQueue = audioQueue;
    queue = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < 3; ++i) {
      [queue addObject:[[WeshAudioBuffer alloc] initWithAudioQueue:audioPlayingQueue]];
    }
    currentBuffer = 0;
    count = 0;
  }
  return self;
}

- (WeshAudioBuffer *) nextFreeBuffer {
  @synchronized(self) {
    if ([queue[currentBuffer] full] || [queue[currentBuffer] submitted]) {
      currentBuffer = [queue count];
      [queue addObject:[[WeshAudioBuffer alloc] initWithAudioQueue:audioPlayingQueue]];
    }
  }
  return queue[currentBuffer];
}

- (void) addData:(const void *)data length:(UInt32)length {
  WeshAudioBuffer *buf = [self nextFreeBuffer];
  UInt32 leftovers = (UInt32)[buf addData:data length:length];
  if (leftovers != 0) {
    [self submitBuffer:buf];
    [self addData:(const void *)(data + length - leftovers) length:leftovers];
  } else if([buf full]) {
    [self submitBuffer:buf];
  }
}

- (void) addData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDesc {
  WeshAudioBuffer *buf = [self nextFreeBuffer];
  if ([buf addData:data length:length packetDescription:packetDesc]) {
    if ([buf full]) {
      [self submitBuffer:buf];
    }
  } else {
    [self submitBuffer:buf];
    [self addData:data length:length packetDescription:packetDesc];
  }
}

- (void) freeBuffer:(AudioQueueBufferRef)inBuffer {
  for (WeshAudioBuffer *buf in queue) {
    if (buf.audioQueueBuffer == inBuffer) {
      [buf free];
      break;
    }
  }
}

- (void) submitBuffer:(WeshAudioBuffer *)buf {
  @synchronized(self) {
  //  NSLog(@"%d", count);
    if (++count == 9) {
      NSLog(@"Playing!");
      if (AudioQueuePrime(audioPlayingQueue, 0, NULL)) {
        NSLog(@"Prime error!");
      }
      if (AudioQueueStart(audioPlayingQueue, NULL)) {
        NSLog(@"Start error!");
      }
    }
    [buf submitTo:audioPlayingQueue];
  }
}

@end
