//
//  SongOutputStreamer.m
//  WeshApp-tunes
//
//  Created by Carlos Alonso on 18/10/2014.
//  Copyright (c) 2014 Foot Clan. All rights reserved.
//

#import "SongOutputStreamer.h"
#import <AVFoundation/AVFoundation.h>

@interface SongOutputStreamer(Private)

@property(nonatomic) NSOutputStream *oStream;

@end

@implementation SongOutputStreamer

AVAssetReaderTrackOutput *assetOutput;
NSOutputStream *oStream;

+ (void) streamSong:(NSURL *)url to:(NSOutputStream *)oStream {
  SongOutputStreamer *streamer = [[SongOutputStreamer alloc] init];
  [streamer loadSongAt:url];
  [streamer streamTo:oStream];
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
      [self pushData];
      break;
      
    case NSStreamEventErrorOccurred:
      break;
      
    case NSStreamEventEndEncountered:
      break;
      
    default:
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
    [self.oStream write:audioBuffer.mData maxLength:audioBuffer.mDataByteSize];
  }
  
  CFRelease(blockBuffer);
  CFRelease(sampleBuffer);
}

@end
