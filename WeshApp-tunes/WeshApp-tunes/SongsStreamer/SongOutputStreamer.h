//
//  SongOutputStreamer.h
//  WeshApp-tunes
//
//  Created by Carlos Alonso on 18/10/2014.
//  Copyright (c) 2014 Foot Clan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SongOutputStreamer : NSObject <NSStreamDelegate> {
  AVAssetReaderTrackOutput *assetOutput;
}

+ (SongOutputStreamer *) streamSong:(NSURL *)url to:(NSOutputStream *)oStream;

@property(nonatomic) NSOutputStream *oStream;

@end
