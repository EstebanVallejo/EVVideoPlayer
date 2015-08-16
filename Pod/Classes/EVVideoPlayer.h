//
//  EVVideoPlayer.h
//
//  Created by Esteban Vallejo on 10/08/15.
//  Copyright (c) 2015 Esteban Vallejo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol EVVideoPlayerDelegate;

typedef void(^EVVideoPlayerProgressBlock)(CGFloat progress);
typedef void(^EVVideoPlayerReadyToPlayBlock)(void);
typedef void(^EVVideoPlayerErrorBlock)(NSError *error);
typedef void(^EVVideoPlayerFinishedPlayingBlock)(void);

typedef enum {
  EVVideoPlayerStatusNew = 0,
  EVVideoPlayerStatusReadyToPlay,
  EVVideoPlayerStatusPlaying,
  EVVideoPlayerStatusPaused,
  EVVideoPlayerStatusStopped,
  EVVideoPlayerStatusError = 99
} EVVideoPlayerStatus;

@interface EVVideoPlayer : UIView
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, assign) BOOL shouldLoop;
@property (nonatomic, strong) NSString *gravity;
@property (nonatomic, assign) BOOL startPlayingWhenReady;
@property (nonatomic, readonly) EVVideoPlayerStatus status;
@property (nonatomic, assign) CGFloat videoLenght;

// Blocks
@property (nonatomic, copy) EVVideoPlayerReadyToPlayBlock readyToPlayBlock;
@property (nonatomic, copy) EVVideoPlayerProgressBlock progressBlock;
@property (nonatomic, copy) EVVideoPlayerErrorBlock errorBlock;
@property (nonatomic, copy) EVVideoPlayerFinishedPlayingBlock finishedPlayingBlock;

// Gesture recognizers
@property (nonatomic, strong) UITapGestureRecognizer *playPauseTap;
@property (nonatomic, strong) UIPanGestureRecognizer *seekPan;

// Delegate
@property (nonatomic, assign) id<EVVideoPlayerDelegate> delegate;

// Video playback methods
- (void)playVideo;
- (void)pauseVideo;
- (void)stopVideo;
- (void)seekToPercentage:(CGFloat)percentage;
- (void)setVolumeWithPercentage:(CGFloat)volumePercentage;
- (CGFloat)currentTime;

// Gestures configuration
- (void)tapToPlayOrPauseEnabled:(BOOL)enabled;
//- (void)panToSeekEnabled:(BOOL)enabled;
@end

@protocol EVVideoPlayerDelegate <NSObject>
- (void)videoPlayerIsReadyToPlay:(EVVideoPlayer *)videoPlayer;
- (void)videoPlayerErrorLoading:(EVVideoPlayer *)videoPlayer;
- (void)videoPlayerFinishedPlaying:(EVVideoPlayer *)videoPlayer;
- (void)videoPlayer:(EVVideoPlayer *)videoPlayer didUpdateProgress:(CGFloat)progress;
@end
