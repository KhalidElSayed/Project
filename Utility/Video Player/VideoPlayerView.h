//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VideoPlayerView : UIViewController
{
    NSURL *videoUrl;
    BOOL playerExited;
    MPMoviePlayerController *mediaPlayer;
    UIActivityIndicatorView *loadingIndicator;
    UIView *loadingView;
    BOOL firstTime;
}

@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) MPMoviePlayerController *mediaPlayer;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UIView *loadingView;

- (void)playVideo:(NSURL *)vidUrl;
- (void)stopLoadingView;
@end