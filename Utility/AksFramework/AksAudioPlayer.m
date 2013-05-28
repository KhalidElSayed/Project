//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import "AksAudioPlayer.h"

@interface AksAudioPlayer ()

@end

@implementation AksAudioPlayer

@synthesize filePath;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)setButtonImage:(NSString *)image for:(UIButton *)button {
    if ([self isNotNull:image]) {
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_f", image]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_f", image]] forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", image]] forState:UIControlStateDisabled];
    }
}

- (void)prepare {
    self.frame = [[UIScreen mainScreen]bounds];
    self.backgroundColor = [UIColor whiteColor];

    UITableView *tableViewForBackGround = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStyleGrouped];
    [self addSubview:tableViewForBackGround];
    [tableViewForBackGround setUserInteractionEnabled:FALSE];

    background = [[UIImageView alloc]initWithFrame:CGRectMake(75, 97, 170, 170)];
    [background setImage:[UIImage imageNamed:@"statusBackGroundImage"]];
    [self addSubview:background];

    statusDisplay = [[UILabel alloc]initWithFrame:CGRectMake(75, 150, 170, 57)];
    [statusDisplay setBackgroundColor:[UIColor clearColor]];
    [self addSubview:statusDisplay];

    timerDisplay = [[UILabel alloc]initWithFrame:CGRectMake(75, 195, 170, 30)];
    [timerDisplay setBackgroundColor:[UIColor clearColor]];
    [timerDisplay setTextAlignment:UITextAlignmentCenter];
    [timerDisplay setTextColor:[UIColor whiteColor]];
    [timerDisplay setFont:[UIFont fontWithName:FONT_BOLD size:25]];
    [self addSubview:timerDisplay];

    buttonClose = [[UIButton alloc]initWithFrame:CGRectMake(160, 431, 160, 49)];
    [self setButtonImage:@"close" for:buttonClose];
    [buttonClose addTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buttonClose];

    buttonMiddle = [[UIButton alloc]initWithFrame:CGRectMake(80, 350, 160, 49)];
    [buttonMiddle setImage:[UIImage imageNamed:@"RecorderPlay"] forState:UIControlStateNormal];
    [buttonMiddle addTarget:self action:@selector(middleButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buttonMiddle];

    buttonRight = [[UIButton alloc]initWithFrame:CGRectMake(80, 350, 160, 49)];
    [buttonRight setImage:[UIImage imageNamed:@"RecorderStop"] forState:UIControlStateNormal];
    [buttonRight addTarget:self action:@selector(rightButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buttonRight];


    statusDisplay.layer.cornerRadius = 10;
    [statusDisplay setFont:[UIFont fontWithName:FONT_REGULAR size:24]];
    [statusDisplay setTextColor:[UIColor whiteColor]];
    [statusDisplay setTextAlignment:NSTextAlignmentCenter];

    buttonRight.enabled = NO;
    buttonMiddle.enabled = YES;
}

- (void)updateTimeDisplayLabel {
    int progress = timeInSeconds;
    int minutes = floor(progress / 60);
    int seconds = round(progress - minutes * 60);
    if (seconds == 60) {
        seconds = 0;
        minutes = minutes + 1;
    }
    timerDisplay.text = [NSString stringWithFormat:@"%.2d:%.2d", minutes, seconds];
}

- (void)startTimer {
    timeInSeconds = 0;
    if ([self isNotNull:timer] && [timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(timeIncrement)
                                           userInfo:nil
                                            repeats:YES];
    [self updateTimeDisplayLabel];
}

- (void)timeIncrement {
    timeInSeconds++;
    [self updateTimeDisplayLabel];
}

- (void)stopTimer {
    timeInSeconds = 0;
    if ([self isNotNull:timer] && [timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    [self updateTimeDisplayLabel];
}

//play Button
- (void)middleButton:(id)sender {
    if (!buttonMiddle.enabled) return;
    [buttonRight setFrame:[buttonMiddle frame]];
    [self bringSubviewToFront:buttonRight];
    [buttonRight setHidden:FALSE];

    buttonRight.enabled = YES;
    buttonMiddle.enabled = NO;

    if (audioPlayer) {
        if (audioPlayer.isPlaying) {
            [self stopTimer];
            [audioPlayer stop];
            [statusDisplay setText:@"Stopped"];
        } else {
            [self startTimer];
            [audioPlayer play];
            [statusDisplay setText:@"Playing.."];
        }
        return;
    }

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

    //Override record to mix with other app audio, background audio not silenced on record
    OSStatus propertySetError = 0;
    UInt32 allowMixing = true;
    propertySetError = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(allowMixing), &allowMixing);

    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);

    NSLog(@"Mixing: %lx", propertySetError); // This should be 0 or there was an issue somewhere

    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:&error];
    [audioPlayer setDelegate:self];
    [audioPlayer play];

    [statusDisplay setText:@"Playing.."];
    [self startTimer];
}

//stop Button
- (void)rightButton:(id)sender {
    if (!buttonRight.enabled) return;
    buttonRight.enabled  = NO;
    buttonMiddle.enabled = YES;
    [buttonRight setHidden:TRUE];
    [audioPlayer stop];
    audioPlayer = nil;
    [self stopTimer];
    [statusDisplay setText:@"Stopped"];
}

- (void)closeButton:(id)sender {
    [self rightButton:nil];
    [self removeFromSuperview];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    buttonMiddle.enabled = YES;
    buttonRight.enabled = NO;
    [buttonRight setHidden:TRUE];
    [statusDisplay setText:@"Stopped"];
    [self stopTimer];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    buttonMiddle.enabled = YES;
    buttonRight.enabled = NO;
    [buttonRight setHidden:TRUE];
    [statusDisplay setText:@"Stopped"];
    [self stopTimer];
}

- (void)startPlaying {
    [self middleButton:nil];
}

@end
