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
  AudioQueueBufferRef audioQueueBuffer;
  UInt32 fillLevel;
  NSInteger numberOfPacketDescriptions;
  AudioStreamPacketDescription *packetDescriptions;
}

@property BOOL submitted;

- (NSInteger) addData:(const void *)data length:(UInt32)length;
- (BOOL) addData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDescription;
- (BOOL) full;

@end
