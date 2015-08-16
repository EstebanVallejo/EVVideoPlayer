//
//  EVViewController.m
//  EVVideoPlayer
//
//  Created by Esteban Vallejo on 08/15/2015.
//  Copyright (c) 2015 Esteban Vallejo. All rights reserved.
//

#import "EVViewController.h"
#import <EVVideoPlayer/EVVideoPlayer.h>

@interface EVViewController ()
@property (nonatomic, weak) IBOutlet EVVideoPlayer *videoPlayer;
@end

@implementation EVViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self configureVideoPlayer];
}

- (void)configureVideoPlayer {
  NSString *urlString = [[NSBundle mainBundle] pathForResource:@"BlackBerry" ofType:@"mp4"];
  NSURL *url = [[NSURL alloc] initFileURLWithPath:urlString];
  
  [self.videoPlayer tapToPlayOrPauseEnabled:true];
  
  [self.videoPlayer setVideoURL:url];
}

@end
