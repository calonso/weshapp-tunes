//
//  SongInputStreamer.m
//  WeshApp-tunes
//
//  Created by Carlos Alonso on 18/10/2014.
//  Copyright (c) 2014 Foot Clan. All rights reserved.
//

#import "SongInputStreamer.h"
#import <UIKit/UIKit.h>

@implementation SongInputStreamer

void AudioFileStreamPropertyListener(void *inClientData, AudioFileStreamID inAudioFileStreamID, AudioFileStreamPropertyID inPropertyID, UInt32 *ioFlags) {
  SongInputStreamer *myClass = (__bridge SongInputStreamer *)inClientData;
  [myClass didChangeProperty:inPropertyID flags:ioFlags];
}

void AudioFileStreamPacketsListener(void *inClientData, UInt32 inNumberBytes, UInt32 inNumberPackets, const void *inInputData, AudioStreamPacketDescription *inPacketDescriptions) {
  SongInputStreamer *myClass = (__bridge SongInputStreamer *)inClientData;
  [myClass didReceivePackets:inInputData packetDescriptions:inPacketDescriptions numberOfPackets:inNumberPackets numberOfBytes:inNumberBytes];
}

void AudioQueueOutputCbk( void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer ) {
  
}

+ (void) playSongFrom:(NSInputStream *)inStream {
  SongInputStreamer *streamer = [[SongInputStreamer alloc] init];
  [streamer playFromStream:inStream];
}

- (instancetype) init {
  if (self = [super init]) {
    discontinuous = true;
    buffersQueue = [AudioBuffersQueue queue];
  }
  return self;
}

- (void) playFromStream:(NSInputStream *)inputStream {
  AudioFileStreamOpen((__bridge void *)self, AudioFileStreamPropertyListener, AudioFileStreamPacketsListener, 0, &audioFileStreamID);
  
  inStream = inputStream;
  inStream.delegate = self;
  [inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [inStream open];
}

- (void) stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
  switch (eventCode) {
    case NSStreamEventHasBytesAvailable: {
      uint8_t bytes[512];
      NSInteger length = [(NSInputStream *) aStream read:bytes maxLength:512];
      [self parse:bytes length:(UInt32)length];
    }
      break;
    case NSStreamEventEndEncountered:
      NSLog(@"Input Stream end reached!");
      break;
    case NSStreamEventErrorOccurred:
      NSLog(@"Input Stream error found!");
      break;
    default:
      break;
  }
}

- (void) parse:(uint8_t *)data length:(UInt32)length {
  if (discontinuous) {
    AudioFileStreamParseBytes(audioFileStreamID, length, data, kAudioFileStreamParseFlag_Discontinuity);
    discontinuous = false;
  } else {
    AudioFileStreamParseBytes(audioFileStreamID, length, data, kAudioFileStreamParseFlag_Discontinuity);
  }
}

- (void)didChangeProperty:(AudioFileStreamPropertyID)propertyID flags:(UInt32 *)flags {
  if (propertyID == kAudioFileStreamProperty_ReadyToProducePackets) {
    
    UInt32 basicDescriptionSize = sizeof(basicDescription);
    AudioFileStreamGetProperty(audioFileStreamID, kAudioFileStreamProperty_DataFormat, &basicDescriptionSize, &basicDescription);
    
    AudioQueueNewOutput(&basicDescription, AudioQueueOutputCbk, (__bridge void *)self, NULL, NULL, 0, &audioQueue);
  }
}

- (void)didReceivePackets:(const void *)packets packetDescriptions:(AudioStreamPacketDescription *)packetDescriptions numberOfPackets:(UInt32)numberOfPackets numberOfBytes:(UInt32)numberOfBytes {
  
  if (packetDescriptions) {
    for (NSUInteger i = 0; i < numberOfPackets; i++) {
      SInt64 packetOffset = packetDescriptions[i].mStartOffset;
      UInt32 packetSize = packetDescriptions[i].mDataByteSize;
      
      [buffersQueue addData:(const void *)(packets + packetOffset) length:packetSize packetDescription:(AudioStreamPacketDescription)packetDescriptions[i]];
    }
  } else {
    [buffersQueue addData:(const void *)packets length:numberOfBytes];
  }
  
}

@end
