//
//  EVVideoPlayer+Utility.h
//  Pods
//
//  Created by Esteban Vallejo on 16/8/15.
//
//

#import "EVVideoPlayer.h"

@interface EVVideoPlayer (Utility)

- (NSString *)statusAsString;

- (BOOL)canPlayVideo;
- (BOOL)canPauseVideo;
- (BOOL)canSeekVideo;

@end
