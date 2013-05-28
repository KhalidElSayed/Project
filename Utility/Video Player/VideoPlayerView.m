//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import "VideoPlayerView.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation VideoPlayerView

@synthesize videoUrl, mediaPlayer, loadingView, loadingIndicator;

#pragma mark -
#pragma mark View cycle

- (void)viewDidLoad {
    firstTime = TRUE;
    [super viewDidLoad];
}

- (void)takeStartUp {
    if (firstTime) {
        firstTime = FALSE;
        [self showLoadingScreen];
        [self playVideo:videoUrl];
    }
}

- (void)showLoadingScreen {
    if (loadingView) {
        [loadingView removeFromSuperview];
        loadingView = nil;
    }

    if (loadingView == nil) {
        int height = [[UIScreen mainScreen]bounds].size.height;
        int width = [[UIScreen mainScreen]bounds].size.width;

        loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 480, 320)];
        loadingView.backgroundColor = [UIColor clearColor];


        UILabel *loadingLbl = [[UILabel alloc]initWithFrame:CGRectMake((width - 200) / 2, (height - 120) / 2, 200, 40)];
        loadingLbl.text = @"Loading...";
        [loadingLbl setTextColor:[UIColor whiteColor]];
        [loadingLbl setBackgroundColor:[UIColor clearColor]];
        loadingLbl.textAlignment = UITextAlignmentCenter;


        loadingIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((width - 40) / 2, (height - 60) / 2, 40, 40)];
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [loadingIndicator hidesWhenStopped];


        UIButton *stopLoadingBtn = [ UIButton buttonWithType:UIButtonTypeCustom];
        stopLoadingBtn.frame = CGRectMake((width - 120) / 2, (height) / 2, 120, 30);
        [stopLoadingBtn addTarget:self action:@selector(stopLoadingView) forControlEvents:UIControlEventTouchUpInside];
        [self customizeThisButton:stopLoadingBtn Withtext:@"Cancel"];

        [loadingView addSubview:stopLoadingBtn];
        [loadingView addSubview:loadingLbl ];
        [loadingView addSubview:loadingIndicator];
        [loadingIndicator startAnimating];
        [self.view addSubview:loadingView];
    }
}

- (void)customizeThisButton:(UIButton *)button Withtext:(NSString *)title {
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateHighlighted];

    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];

    // Set default backgrond color
    [button setBackgroundColor:IOS_STANDARD_COLOR_BLUE];

    // Add Custom Font
    [[button titleLabel] setFont:[UIFont systemFontOfSize:button.frame.size.height / 2]];

    // Round button corners
    CALayer *buttonLayer = [button layer];
    [buttonLayer setMasksToBounds:YES];
    [buttonLayer setCornerRadius:3.0f];
    [[button layer] setMasksToBounds:YES];
}

- (void)removeLoadingScreen {
    if (loadingView) {
        [loadingView removeFromSuperview];
        loadingView = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [self takeStartUp];
}

//Method for Cancel Button on the Loading view.
- (void)stopLoadingView {
    playerExited = YES;
    [mediaPlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:mediaPlayer];
    [mediaPlayer pause];
    mediaPlayer = nil;

    SHOW_STATUS_BAR
    [self dismissModalViewControllerAnimated : YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        NSArray *array = touch.gestureRecognizers;
        for (UIGestureRecognizer *gesture in array) {
            if (gesture.enabled && [gesture isMemberOfClass:[UIPinchGestureRecognizer class]]) {
                gesture.enabled = NO;
            }
        }
    }
}

#pragma mark -
#pragma mark Movie Player initialization Method
- (void)playVideo:(NSURL *)vidUrl {
    mediaPlayer = [[MPMoviePlayerController alloc]initWithContentURL:vidUrl];

    if (!mediaPlayer) return;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerLoadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:mediaPlayer];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:mediaPlayer];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerScalingModeChanged:)
                                                 name:MPMoviePlayerScalingModeDidChangeNotification
                                               object:mediaPlayer];


    //Checking for the Osversion Prior to version 4.0
    if ((CURRENT_DEVICE_VERSION_FLOAT >= 2.0) && (CURRENT_DEVICE_VERSION_FLOAT < 3.2)) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePreloadDidFinish:)
                                                     name:MPMoviePlayerContentPreloadDidFinishNotification
                                                   object:mediaPlayer];
    }


    if (CURRENT_DEVICE_VERSION_FLOAT >= 4.0) { //Case for Osversions higher to 4.0
        [mediaPlayer prepareToPlay];
        mediaPlayer.shouldAutoplay = YES;
        [mediaPlayer setControlStyle:MPMovieControlStyleFullscreen];
        [mediaPlayer setFullscreen:YES];
    } else { //Case for osVersions Prior to 4.0.
        mediaPlayer.movieControlMode = MPMovieControlModeDefault;
        [mediaPlayer play];
    }
}

#pragma mark -
#pragma mark MPMoviePlayer notifications
- (void)moviePlayBackDidFinish:(NSNotification *)notification {
    playerExited = YES;
    [mediaPlayer stop];
    NSDictionary *userInfo = [notification userInfo];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:mediaPlayer];
    [mediaPlayer pause];

    if (userInfo != nil) {
        [mediaPlayer pause];
        [mediaPlayer.view removeFromSuperview];
        mediaPlayer = nil;

        SHOW_STATUS_BAR
        [self dismissModalViewControllerAnimated : YES];
    }
}

//this will be called for devices which has os below 3.1.3
- (void)moviePreloadDidFinish:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerContentPreloadDidFinishNotification
                                                  object:nil];
    [mediaPlayer play];
}

- (void)moviePlayerScalingModeChanged:(NSNotification *)notification {
    MPMoviePlayerController *scalingnotification = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerScalingModeDidChangeNotification
                                                  object:scalingnotification];
}

////this will be called for devices which has os above 3.2
- (void)moviePlayerLoadStateChanged:(NSNotification *)notification {
    if ([[notification object] loadState] == MPMovieLoadStateUnknown) return;

    // Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerLoadStateDidChangeNotification object:[notification object]];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    // Rotate the view for landscape playback
    [[self view] setBounds:CGRectMake(0, 0, 480, 320)];
    [[self view] setCenter:CGPointMake(160, 240)];
    [[self view] setTransform:CGAffineTransformMakeRotation(M_PI / 2)];

    // Set frame of movie player
    [[mediaPlayer view] setFrame:CGRectMake(0, 0, 480, 320)];
    [mediaPlayer play];
    [self.view addSubview:mediaPlayer.view];
}

#pragma mark
#pragma mark Memory related Methods
//// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ( (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ) {
        mediaPlayer.view.frame = self.view.bounds;
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

ORIENTATION_SUPPORT_LANDSCAPE_RIGHT__ONLY

@end
