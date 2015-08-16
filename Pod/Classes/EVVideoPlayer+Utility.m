//
//  EVVideoPlayer+Utility.m
//  Pods
//
//  Created by Esteban Vallejo on 16/8/15.
//
//

#import "EVVideoPlayer+Utility.h"

@implementation EVVideoPlayer (Utility)

- (NSString *)statusAsString {
  EVVideoPlayerStatus status = self.status;
  NSString *statusAsString = nil;
  
  switch (status) {
    case EVVideoPlayerStatusNew:
      statusAsString = @"New";
      break;
    case EVVideoPlayerStatusReadyToPlay:
      statusAsString = @"Ready to play";
      break;
    case EVVideoPlayerStatusStopped:
      statusAsString = @"Stopped";
      break;
    case EVVideoPlayerStatusPlaying:
      statusAsString = @"Playing";
      break;
    case EVVideoPlayerStatusPaused:
      statusAsString = @"Paused";
      break;
    case EVVideoPlayerStatusError:
      statusAsString = @"Error";
      break;
  }
  
  return statusAsString;
}

- (BOOL)canPlayVideo {
  BOOL canPlayVideo = false;
  
  switch (self.status) {
    case EVVideoPlayerStatusPlaying:
      NSLog(@"Can't play video - Already playing");
      break;
    case EVVideoPlayerStatusNew:
      NSLog(@"Can't play video - No video to play yet");
      break;
    case EVVideoPlayerStatusError:
      NSLog(@"Can't play video - An Error ocurred while loading video");
      break;
    default:
      canPlayVideo = true;
      break;
  }
  
  return canPlayVideo;
}

-(BOOL)canPauseVideo {
  BOOL canPauseVideo = false;
  
  switch (self.status) {
    case EVVideoPlayerStatusPaused:
      NSLog(@"Can't pause video - Already paused");
      break;
    case EVVideoPlayerStatusStopped:
      NSLog(@"Can't pause video - It is stopped");
      break;
    case EVVideoPlayerStatusReadyToPlay :
      NSLog(@"Can't pause video - It is ready to play");
      break;
    case EVVideoPlayerStatusError:
      NSLog(@"Can't pause video - An Error ocurred while loading video");
      break;
    default:
      canPauseVideo = true;
      break;
  }
  
  return canPauseVideo;
}

- (BOOL)canSeekVideo {
  BOOL canSeekVideo = false;
  
  switch (self.status) {
    case EVVideoPlayerStatusNew:
      NSLog(@"Can't seek video - No video yet");
      break;
    case EVVideoPlayerStatusError:
      NSLog(@"Can't pause video - An Error ocurred while loading video");
      break;
    default:
      canSeekVideo = true;
      break;
  }
  
  return canSeekVideo;
}

@end
