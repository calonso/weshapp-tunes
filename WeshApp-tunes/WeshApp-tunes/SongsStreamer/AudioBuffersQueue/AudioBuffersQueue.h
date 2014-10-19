//
//  AudioBuffersQueue.h
//  WeshApp-tunes
//
//  Created by Carlos Alonso on 18/10/2014.
//  Copyright (c) 2014 Foot Clan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeshAudioBuffer.h"

@interface AudioBuffersQueue : NSObject {
  NSMutableArray *queue;
  NSInteger currentBuffer;
  AudioQueueRef audioPlayingQueue;
  NSInteger count;
}

+ (AudioBuffersQueue *) queueForAudioQueue:(AudioQueueRef)audioQueue;
- (void) addData:(const void *)data length:(UInt32)length;
- (void) addData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDesc;
- (void) freeBuffer:(AudioQueueBufferRef)inBuffer;

@end
