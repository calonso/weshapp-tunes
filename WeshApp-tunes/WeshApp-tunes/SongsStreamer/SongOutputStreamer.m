//
//  SongOutputStreamer.m
//  WeshApp-tunes
//
//  Created by Carlos Alonso on 18/10/2014.
//  Copyright (c) 2014 Foot Clan. All rights reserved.
//

#import "SongOutputStreamer.h"

@implementation SongOutputStreamer

+ (SongOutputStreamer *) streamSong:(NSURL *)url to:(NSOutputStream *)oStream {
  SongOutputStreamer *streamer = [[SongOutputStreamer alloc] init];
  [streamer loadSongAt:url];
  [streamer streamTo:oStream];
  return streamer;
}

- (void) loadSongAt:(NSURL *)url {
  AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options: nil];
  NSError *error = nil;
  AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:asset error:&error];
  assetOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack: asset.tracks[0] outputSettings: nil];
  
  [assetReader addOutput:assetOutput];
  [assetReader startReading];
}

- (void) streamTo:(NSOutputStream *)oStream {
  self.oStream = oStream;
  self.oStream.delegate = self;
  [self.oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [self.oStream open];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
  switch (eventCode) {
    case NSStreamEventHasSpaceAvailable:
      NSLog(@"OutputStream has space!");
      [self pushData];
      break;
      
    case NSStreamEventErrorOccurred:
      NSLog(@"OutputStream error!");
      break;
      
    case NSStreamEventEndEncountered:
      NSLog(@"OutputStream end reached!");
      break;
      
    case NSStreamEventHasBytesAvailable:
      NSLog(@"OutptStream has byte!");
      break;
      
    case NSStreamEventNone:
      NSLog(@"OutputStream none!");
      break;
      
    case NSStreamEventOpenCompleted:
      NSLog(@"OutputStream opened!");
      break;
      
    default:
      NSLog(@"Output Stream other event");
      break;
  }
}

- (void)pushData {
  CMSampleBufferRef sampleBuffer = [assetOutput copyNextSampleBuffer];
  
  CMBlockBufferRef blockBuffer;
  AudioBufferList audioBufferList;
  
  CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(AudioBufferList), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &blockBuffer);
  
  for (NSUInteger i = 0; i < audioBufferList.mNumberBuffers; i++) {
    AudioBuffer audioBuffer = audioBufferList.mBuffers[i];
    NSLog(@"write!");
    [self.oStream write:audioBuffer.mData maxLength:audioBuffer.mDataByteSize];
  }
  
  CFRelease(blockBuffer);
  CFRelease(sampleBuffer);
  [self.oStream close];
}

@end
