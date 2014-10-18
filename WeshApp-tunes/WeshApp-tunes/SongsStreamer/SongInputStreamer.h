//
//  SongInputStreamer.h
//  WeshApp-tunes
//
//  Created by Carlos Alonso on 18/10/2014.
//  Copyright (c) 2014 Foot Clan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioBuffersQueue.h"

@interface SongInputStreamer : NSObject <NSStreamDelegate> {
  AudioFileStreamID audioFileStreamID;
  AudioStreamBasicDescription basicDescription;
  AudioQueueRef audioQueue;
  BOOL discontinuous;
  AudioBuffersQueue *buffersQueue;
  NSInputStream *inStream;
}

@end
