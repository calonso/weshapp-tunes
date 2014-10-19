//
//  WeshAudioBuffer.h
//  WeshApp-tunes
//
//  Created by Carlos Alonso on 18/10/2014.
//  Copyright (c) 2014 Foot Clan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface WeshAudioBuffer : NSObject {
  UInt32 fillLevel;
  UInt32 numberOfPacketDescriptions;
  AudioStreamPacketDescription *packetDescriptions;
}

@property BOOL submitted;
@property (setter=setAudioQueueBuffer:) AudioQueueBufferRef audioQueueBuffer;

- (instancetype) initWithAudioQueue:(AudioQueueRef)audioQueue;
- (NSInteger) addData:(const void *)data length:(UInt32)length;
- (BOOL) addData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDescription;
- (BOOL) full;
- (void) submitTo:(AudioQueueRef)audioQueue;
- (void) free;

@end
