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
  AVAsset *asset = [AVAsset assetWithURL:url];
  NSError *error = nil;
  assetReader = [AVAssetReader assetReaderWithAsset:asset error:&error];
  
  if (error) {
    NSLog(@"Error creating reader! %@", error.localizedDescription);
  }
  AVAsset *localAsset = assetReader.asset;
  
  AVAssetTrack *audioTrack = [[localAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
  
  trackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
  trackOutput.alwaysCopiesSampleData = NO;
  
  if ([assetReader canAddOutput:trackOutput]) {
    [assetReader addOutput:trackOutput];
    [assetReader startReading];
    NSLog(@"Read!");
  } else {
    NSLog(@"Not Reading!");
  }
}

- (void) streamTo:(NSOutputStream *)oStream {
  self.oStream = oStream;
  self.oStream.delegate = self;
  [self.oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [self.oStream open];
  NSLog(@"Opening output stream...");
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
/*
  CMSampleBufferRef sampleBuffer = [assetOutput copyNextSampleBuffer];
  
  CMBlockBufferRef blockBuffer;
  AudioBufferList audioBufferList;
  
  CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(AudioBufferList), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &blockBuffer);
  
  for (NSUInteger i = 0; i < audioBufferList.mNumberBuffers; i++) {
    AudioBuffer audioBuffer = audioBufferList.mBuffers[i];
    NSLog(@"write!");
    NSInteger written = [self.oStream write:audioBuffer.mData maxLength:audioBuffer.mDataByteSize];
    if (written == -1) {
      NSLog(@"An error happened writing!");
    } else {
      NSLog(@"Written %d", (int)written);
    }
  }
  
  CFRelease(blockBuffer);
  CFRelease(sampleBuffer);
  [self.oStream close];*/
  BOOL done = false;
  
  while (!done) {
    CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];
    
    if (sampleBuffer) {
      
      //READ
      CMBlockBufferRef blockBuffer;
      AudioBufferList audioBufferList;
      
      CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(AudioBufferList), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &blockBuffer);
      
      for (NSUInteger i = 0; i < audioBufferList.mNumberBuffers; i++) {
        AudioBuffer audioBuffer = audioBufferList.mBuffers[i];
        NSLog(@"write!");
        NSInteger written = [self.oStream write:audioBuffer.mData maxLength:audioBuffer.mDataByteSize];
        if (written == -1) {
          NSLog(@"An error happened writing!");
        } else {
          NSLog(@"Written %d", (int)written);
        }
      }
      
      CFRelease(sampleBuffer);
      sampleBuffer = NULL;
    } else {
      if (assetReader.status == AVAssetReaderStatusFailed) {
        NSLog(@"Error reading! %@", assetReader.error.localizedDescription);
      } else {
        done = true;
      }
    }
  }
  
  [self.oStream close];
}

@end
