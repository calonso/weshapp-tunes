//
//  ObjSong.m
//  WeshApp-tunes
//
//  Created by Carlos Alonso on 18/10/2014.
//  Copyright (c) 2014 Foot Clan. All rights reserved.
//

#import "ObjSong.h"
#import <AVFoundation/AVFoundation.h>

@implementation ObjSong

+ (NSOutputStream *) getSongBinary:(NSURL* )url {
  AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options: nil];
  NSError *error = nil;
  AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:asset error:&error];
  AVAssetReaderTrackOutput *assetOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack: asset.tracks[0] outputSettings: nil];
  
  [assetReader addOutput:assetOutput];
  [assetReader startReading];
  
  CMSampleBufferRef sampleBuffer = [assetOutput copyNextSampleBuffer];
  
  CMBlockBufferRef blockBuffer;
  AudioBufferList audioBufferList;
  
  CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(AudioBufferList), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &blockBuffer);
  
  NSOutputStream *audioStream = [NSOutputStream outputStreamToMemory];
  [audioStream open];
  
  for (NSUInteger i = 0; i < audioBufferList.mNumberBuffers; i++) {
    AudioBuffer audioBuffer = audioBufferList.mBuffers[i];
    [audioStream write:audioBuffer.mData maxLength:audioBuffer.mDataByteSize];
  }
  
  CFRelease(blockBuffer);
  CFRelease(sampleBuffer);
  
  return audioStream;
}

@end
