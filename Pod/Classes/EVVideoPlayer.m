//
//  EVVideoPlayer.m
//
//  Created by Esteban Vallejo on 10/08/15.
//  Copyright (c) 2015 Esteban Vallejo. All rights reserved.
//

#import "EVVideoPlayer.h"
#import <QuartzCore/QuartzCore.h>
#import "EVVideoPlayer+Utility.h"

static NSString * const kStatusKeyPath = @"status";
static CGFloat const kProgressUpdateFrecuency = 0.5f;
#define DEFAULT_GRAVITY AVLayerVideoGravityResizeAspectFill

#pragma mark - Private Properties
@interface EVVideoPlayer ()
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, readwrite, setter=setStatus:) EVVideoPlayerStatus status;
@property (strong, nonatomic) id timeObserver;
@end

#pragma mark - Initialization and Configuration
@implementation EVVideoPlayer
- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setup];
  }
  return self;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  [self setup];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self updateFrames];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self.player removeObserver:self forKeyPath:kStatusKeyPath];
  if (self.timeObserver) {
    [self.player removeTimeObserver:self.timeObserver];
  }}

- (void)setup {
  //Standard Configuration
  self.status = EVVideoPlayerStatusNew;
  [self setBackgroundColor:[UIColor blackColor]];
  self.gravity = DEFAULT_GRAVITY;
  self.startPlayingWhenReady = true;
  self.shouldLoop = true;
}

- (void)setStatus:(EVVideoPlayerStatus)status {
  self->_status = status;
  NSLog(@"Video player status: %@", [self statusAsString]);
}

- (void)setGravity:(NSString *)gravity {
  if (![gravity isEqualToString:AVLayerVideoGravityResizeAspectFill] &&
      ![gravity isEqualToString:AVLayerVideoGravityResize] &&
      ![gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
    NSLog(@"Gravity is WRONG!");
    self->_gravity = DEFAULT_GRAVITY; // Default
  } else {
    self->_gravity = gravity;
  }
  
  if (self.playerLayer) {
    [self.playerLayer setVideoGravity:self.gravity];
  }
}

- (void)updateFrames {
  if (self.playerLayer) {
    [self.playerLayer setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
  }
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  [self updateFrames];
}

- (void)setVideoURL:(NSURL *)videoURL {
  self->_videoURL = videoURL;
  [self loadVideo:self.videoURL];
}

- (void)removeFromSuperview {
  [self pauseVideo];
  [super removeFromSuperview];
}

#pragma mark - Public methods
#pragma mark Video Playback Controls
- (void)playVideo {
  
  if (![self canPlayVideo]) { return; }
  
  if (self.progress >= 1.0f) {
    [self seekToPercentage:0];
  }
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
  
  if (self.player) {
    self.player.rate = 1.0;
    self.status = EVVideoPlayerStatusPlaying;
  } else {
    NSLog(@"%@ - %@ :: %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), @"Video URL has not been set");
  }
}

- (void)pauseVideo {
  
  if (![self canPauseVideo]) { return; }
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  if (self.player) {
    self.player.rate = 0.0;
    self.status = EVVideoPlayerStatusPaused;
  } else {
    NSLog(@"%@ - %@ :: %@",NSStringFromClass(self.class), NSStringFromSelector(_cmd), @"Video URL has not been set");
  }
}

- (void)stopVideo {
  [self pauseVideo];
  [self seekToPercentage:0.0f];
  self.status = EVVideoPlayerStatusStopped;
}

- (void)seekToPercentage:(CGFloat)percentage {
  self.progress = percentage;
  if (self.player) {
    CMTime newTime = CMTimeMakeWithSeconds(percentage * self.playerItem.duration.value, self.playerItem.currentTime.timescale);
    [self.player seekToTime:newTime];
  } else {
    NSLog(@"%@ - %@ :: %@",NSStringFromClass(self.class), NSStringFromSelector(_cmd), @"Video URL has not been set");
  }
}

- (void)setVolumeWithPercentage:(CGFloat)volumePercentage {
  if ([self.player respondsToSelector:@selector(setVolume:)]) {
    [self.player setVolume:volumePercentage];
  } else {
    AVPlayerItem *mPlayerItem = [[self player] currentItem];
    NSArray *audioTracks = mPlayerItem.asset.tracks;
    
    // Mute all the audio tracks
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
      AVMutableAudioMixInputParameters *audioInputParams =[AVMutableAudioMixInputParameters audioMixInputParameters];
      [audioInputParams setVolume:volumePercentage atTime:CMTimeMake(-5, 60)];
      [audioInputParams setTrackID:[track trackID]];
      [allAudioParams addObject:audioInputParams];
    }
    AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
    [audioZeroMix setInputParameters:allAudioParams];
    
    [mPlayerItem setAudioMix:audioZeroMix];
  }
}

- (CGFloat)currentTime {
  CMTime time = self.playerItem.currentTime;
  return (CGFloat)time.value / (CGFloat)time.timescale;
}

#pragma mark - Gestures configuration
- (void)tapToPlayOrPauseEnabled:(BOOL)enabled {
  if (!self.playPauseTap && enabled) {
    self.playPauseTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playPauseTapAction:)];
    [self addGestureRecognizer:self.playPauseTap];
  }
  
  self.playPauseTap.enabled = enabled;
}

//- (void)panToSeekEnabled:(BOOL)enabled {
//  if (!self.seekPan && enabled) {
//    self.seekPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(seekPanAction:)];
//    [self addGestureRecognizer:self.seekPan];
//  }
//  
//  self.seekPan.enabled = enabled;
//}

#pragma mark - Private methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
  if (object == self.player && [keyPath isEqualToString:kStatusKeyPath]) {
    if (self.player.status == AVPlayerStatusReadyToPlay) {
      self.status = EVVideoPlayerStatusReadyToPlay;
      
      self.videoLenght = CMTimeGetSeconds(self.asset.duration);
      
      [self addTimeObserver];
      
      if (self.startPlayingWhenReady) {
        [self playVideo];
      } else {
        if (self.readyToPlayBlock) {
          self.readyToPlayBlock();
        } else if ([self.delegate respondsToSelector:@selector(videoPlayerIsReadyToPlay:)]) {
          [self.delegate videoPlayerIsReadyToPlay:self];
        }
      }
      
    } else if (self.player.status == AVPlayerStatusFailed) {
      self.status = EVVideoPlayerStatusError;
      
      NSError *playerError = self.player.error;
      if (!playerError) {
        playerError = [NSError errorWithDomain:@"Error loading video" code:99 userInfo:nil];
      }
      
      if (self.errorBlock) {
        self.errorBlock(playerError);
      } else if ([self.delegate respondsToSelector:@selector(videoPlayerErrorLoading:)]) {
        [self.delegate videoPlayerErrorLoading:self];
      }
    }
  }
}

- (void)addTimeObserver {
  if (self.timeObserver) {
    [self.player removeTimeObserver:self.timeObserver];
  }
  
  __weak typeof (self) weakSelf = self;
  self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(kProgressUpdateFrecuency, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
    if (weakSelf.status != EVVideoPlayerStatusPlaying) { return; }
    
    CGFloat currentTime = CMTimeGetSeconds(time);
    weakSelf.progress = currentTime / weakSelf.videoLenght;
    
    if (weakSelf.progressBlock) {
      weakSelf.progressBlock(weakSelf.progress);
    } else if ([weakSelf.delegate respondsToSelector:@selector(videoPlayer:didUpdateProgress:)]) {
      [weakSelf.delegate videoPlayer:weakSelf didUpdateProgress:weakSelf.progress];
    }
  }];
}

- (void)loadVideo:(NSURL *)url {
  self.asset = [AVURLAsset assetWithURL:url];
  
  if (!self.asset) {
    self.status = EVVideoPlayerStatusError;
    return;
  }
  
  self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
  self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
  
  [self.player addObserver:self forKeyPath:kStatusKeyPath options:0 context:nil];
  
  self.player.rate = 0;
  [self.playerLayer removeFromSuperlayer];
  
  self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
  [self.playerLayer setVideoGravity:self.gravity];
  
  [self.playerLayer setFrame:self.bounds];
  [self.layer addSublayer:self.playerLayer];
}

-(void)itemDidFinishPlaying:(NSNotification *) notification {
  
  if (self.finishedPlayingBlock) {
    self.finishedPlayingBlock();
  } else if ([self.delegate respondsToSelector:@selector(videoPlayerFinishedPlaying:)]){
    [self.delegate videoPlayerFinishedPlaying:self];
  }
  
  dispatch_async(dispatch_get_main_queue(), ^{
    if (notification.object == self.player.currentItem) {
      if (self.shouldLoop) {
        [self.player seekToTime:kCMTimeZero];
        [self.player setRate:1.0f];
      }
    }
  });
}

#pragma mark - UIGestureRecognizers Actions
- (void)playPauseTapAction:(UITapGestureRecognizer *)tap {
  if (tap != self.playPauseTap) { return; }
  
  switch (self.status) {
    case EVVideoPlayerStatusPlaying:
      [self pauseVideo];
      break;
    case EVVideoPlayerStatusReadyToPlay:
    case EVVideoPlayerStatusStopped:
    case EVVideoPlayerStatusPaused:
      [self playVideo];
      break;
    default:
      break;
  }
}

- (void)seekPanAction:(UIPanGestureRecognizer *)pan {
  if (pan != self.seekPan) { return; }
  
  CGPoint velocity = [pan velocityInView:self];
  UIGestureRecognizerState state = pan.state;
  
  if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
    if (velocity.x > 0) {
      // RWD
      CGFloat newSeconds = self.currentTime - 1;
      if (newSeconds < 0) {
        newSeconds = 0;
      }
      CMTime newTime = CMTimeMakeWithSeconds(newSeconds, self.playerItem.currentTime.timescale);
      [self.player seekToTime:newTime];
      
    } else if (velocity.x < 0) {
      // FWD
      CGFloat newSeconds = self.currentTime + 1;
      if (newSeconds > self.videoLenght) {
        newSeconds = self.videoLenght;
      }
      CMTime newTime = CMTimeMakeWithSeconds(newSeconds, self.playerItem.currentTime.timescale);
      [self.player seekToTime:newTime];
    }
  }
}

@end
