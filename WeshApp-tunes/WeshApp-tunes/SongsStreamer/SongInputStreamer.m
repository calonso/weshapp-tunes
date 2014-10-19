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

void AudioQueueOutputCbk(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
  SongInputStreamer *myClass = (__bridge SongInputStreamer *)inUserData;
  [myClass.buffersQueue freeBuffer:inBuffer];
}

+ (SongInputStreamer *) playSongFrom:(NSInputStream *)inStream {
  SongInputStreamer *streamer = [[SongInputStreamer alloc] init];
  [streamer playFromStream:inStream];
  return streamer;
}

- (instancetype) init {
  if (self = [super init]) {
    discontinuous = true;
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
    case NSStreamEventOpenCompleted:
      NSLog(@"InputStream opened!");
      break;
    case NSStreamEventHasSpaceAvailable:
      NSLog(@"Space Available");
      break;
    case NSStreamEventNone:
      NSLog(@"None Event");
      break;
    default:
      NSLog(@"Another event");
      break;
  }
}

- (void) parse:(uint8_t *)data length:(UInt32)length {
  if (discontinuous) {
    AudioFileStreamParseBytes(audioFileStreamID, length, data, kAudioFileStreamParseFlag_Discontinuity);
    discontinuous = false;
  } else {
    AudioFileStreamParseBytes(audioFileStreamID, length, data, 0);
  }
}

- (void)didChangeProperty:(AudioFileStreamPropertyID)propertyID flags:(UInt32 *)flags {
  if (propertyID == kAudioFileStreamProperty_ReadyToProducePackets) {
    
    AudioStreamBasicDescription basicDescription;
    UInt32 basicDescriptionSize = sizeof(basicDescription);
    OSStatus err = AudioFileStreamGetProperty(audioFileStreamID, kAudioFileStreamProperty_DataFormat, &basicDescriptionSize, &basicDescription);
    
    if (err) {
      NSLog(@"Error retrieving data format!");
    }
    
    Boolean writeable;
    UInt32 magicCookieLength;
    void *magicCookieData = nil;
    err = AudioFileStreamGetPropertyInfo(audioFileStreamID, kAudioFileStreamProperty_MagicCookieData, &magicCookieLength, &writeable);
    
    if (!err) {
      NSLog(@"Error getting cookie!");
      magicCookieData = calloc(1, magicCookieLength);
      AudioFileStreamGetProperty(audioFileStreamID, kAudioFileStreamProperty_MagicCookieData, &magicCookieLength, magicCookieData);
    };
    
    err = AudioQueueNewOutput(&basicDescription, AudioQueueOutputCbk, (__bridge void *)self, NULL, NULL, 0, &audioQueue);
    if (err) {
      NSLog(@"Error creating output!");
    }
    if (magicCookieData != nil) {
      err = AudioQueueSetProperty(audioQueue, kAudioQueueProperty_MagicCookie, magicCookieData, magicCookieLength);
      if (err) {
        NSLog(@"Error setting magic cookie!");
      }
      free(magicCookieData);
    }
    
    err = AudioQueueSetParameter(audioQueue, kAudioQueueParam_Volume, 1.0);
    
    if (err) {
      NSLog(@"Error setting volume");
    }
    self.buffersQueue = [AudioBuffersQueue queueForAudioQueue:audioQueue];
  }
}

- (void)didReceivePackets:(const void *)packets packetDescriptions:(AudioStreamPacketDescription *)packetDescriptions numberOfPackets:(UInt32)numberOfPackets numberOfBytes:(UInt32)numberOfBytes {
  
  if (packetDescriptions) {
    for (NSUInteger i = 0; i < numberOfPackets; i++) {
      SInt64 packetOffset = packetDescriptions[i].mStartOffset;
      UInt32 packetSize = packetDescriptions[i].mDataByteSize;
      
      [self.buffersQueue addData:(const void *)(packets + packetOffset) length:packetSize packetDescription:(AudioStreamPacketDescription)packetDescriptions[i]];
    }
  } else {
    [self.buffersQueue addData:(const void *)packets length:numberOfBytes];
  }
  
}

@end
