//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import "AksAudioRecorder.h"
#import <AudioToolbox/AudioServices.h>

@interface AksAudioRecorder ()

@end

@implementation AksAudioRecorder

@synthesize delegate;

- (void)setUseButtonTitle:(NSString *)title {
    if ([self isNotNull:title]) [AKSMethods customizeThisButton:useThisFile Withtext:[NSString stringWithString:title]];
}

- (void)setUseButtonImage:(NSString *)image {
    if ([self isNotNull:image]) {
        [useThisFile setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_f", image]] forState:UIControlStateNormal];
        [useThisFile setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_f", image]] forState:UIControlStateHighlighted];
        [useThisFile setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", image]] forState:UIControlStateDisabled];
    }
}

- (void)setButtonImage:(NSString *)image for:(UIButton *)button {
    if ([self isNotNull:image]) {
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_f", image]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_f", image]] forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", image]] forState:UIControlStateDisabled];
    }
}

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

- (void)prepare {
    TCSTART

	fileRecordedOnce = FALSE;

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


    useThisFile = [[UIButton alloc]initWithFrame:CGRectMake(0, 431, 160, 49)];
    [useThisFile addTarget:self action:@selector(useThisFileClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self setButtonImage:@"attach" for:useThisFile];
    [self addSubview:useThisFile];
    useThisFile.enabled = NO;

    buttonClose = [[UIButton alloc]initWithFrame:CGRectMake(160, 431, 160, 49)];
    [self setButtonImage:@"close" for:buttonClose];
    [buttonClose addTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buttonClose];

    buttonLeft = [[UIButton alloc]initWithFrame:CGRectMake(80, 290, 160, 49)];
    [buttonLeft setImage:[UIImage imageNamed:@"RecorderRecord"] forState:UIControlStateNormal];
    [buttonLeft addTarget:self action:@selector(leftButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buttonLeft];

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
    [statusDisplay setTextAlignment:UITextAlignmentCenter];

    buttonRight.enabled = NO;
    buttonRight.hidden  = TRUE;

    buttonMiddle.enabled = NO;

    TCEND
}

//record Button
- (void)leftButton:(id)sender {
    TCSTART

    if (!buttonLeft.enabled) return;

    buttonRight.enabled = YES;
    buttonRight.hidden  = FALSE;


    buttonMiddle.enabled = NO;
    buttonMiddle.hidden  = TRUE;
    buttonLeft.enabled = NO;
    buttonClose.enabled = NO;
    useThisFile.enabled = NO;

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

    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] initWithCapacity:0];

    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM]  forKey:AVFormatIDKey];

    //i changed it to 16000 which was 44100.0AVAudioQualityMin
    [recordSetting setValue:[NSNumber numberWithFloat:16000]              forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:1]                      forKey:AVNumberOfChannelsKey];
    //i changed it to 8 which was 16
    [recordSetting setValue:[NSNumber numberWithInt:8]                     forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue:[NSNumber numberWithBool:NO]                    forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue:[NSNumber numberWithBool:NO]                    forKey:AVLinearPCMIsFloatKey];

    NSURL *url = [NSURL fileURLWithPath:[self decideFilePath]];

    NSError *error = nil;
    audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&error];

    if ([audioRecorder prepareToRecord]) [audioRecorder record];

    [statusDisplay setText:@"Recording.."];
    [self startTimer];

    TCEND
}

- (void)updateTimeDisplayLabel {
    int progress = timeInSeconds;

    if (progress == 0) progress = lastRecordedTimeInSeconds;

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

- (void)stopTimer:(BOOL)isWhileRecording {
    if (isWhileRecording) lastRecordedTimeInSeconds = timeInSeconds;

    timeInSeconds = 0;

    if ([self isNotNull:timer] && [timer isValid]) {
        [timer invalidate];
        timer = nil;
    }

    [self updateTimeDisplayLabel];
}

//play Button
- (void)middleButton:(id)sender {
    TCSTART

    if (!buttonMiddle.enabled) return;

    buttonRight.enabled = YES;
    buttonRight.hidden  = FALSE;

    buttonMiddle.enabled = NO;
    buttonMiddle.hidden  = TRUE;

    buttonLeft.enabled = NO;
    buttonClose.enabled = NO;

    if (audioPlayer) {
        if (audioPlayer.isPlaying) [audioPlayer stop];
        else [audioPlayer play];
        return;
    }

    //	//Initialize playback audio session
    //	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //	[audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];

    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:&error];
    [audioPlayer setDelegate:self];
    [audioPlayer play];

    [statusDisplay setText:@"Playing.."];
    [self startTimer];

    TCEND
}

//stop Button
- (void)rightButton:(id)sender {
    TCSTART

    if (!buttonRight.enabled) return;

    buttonRight.enabled = NO;
    buttonRight.hidden  = TRUE;

    buttonMiddle.enabled = YES;
    buttonMiddle.hidden  = FALSE;

    buttonLeft.enabled   = YES;


    if ([audioRecorder isRecording]) {
        [audioRecorder stop];
        useThisFile.enabled = YES;
    }

    if (!audioPlayer) [self stopTimer:TRUE];
    else {
        [self stopTimer:FALSE];
        [audioPlayer stop];
    }

    audioPlayer = nil;

    [statusDisplay setText:@"Recorded"];

    buttonClose.enabled = YES;

    TCEND
}

- (void)closeButton:(id)sender {
    if (!buttonClose.enabled) return;

    [self rightButton:nil];

    TCSTART


    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath_ = [self decideFilePath];

    if ([fileManager fileExistsAtPath:filePath_]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath_ error:&error];
    }

    [self removeFromSuperview];

    TCEND
}

- (void)useThisFileClicked:(id)sender {
    TCSTART

    if (!useThisFile.isEnabled) return;

    useThisFile.enabled = NO;

    if (filePath && [[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        if (delegate && [delegate conformsToProtocol:@protocol(AksAudioRecorderDelegate)] && [delegate respondsToSelector:@selector(fileRecordedWithPath:)]) [delegate fileRecordedWithPath:filePath];
    }

    TCEND
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    TCSTART

    buttonLeft.enabled = YES;

    buttonMiddle.enabled = YES;
    buttonMiddle.hidden  = FALSE;

    buttonRight.enabled = NO;
    buttonRight.hidden  = TRUE;

    buttonClose.enabled = YES;

    [statusDisplay setText:@"Recorded"];

    [self stopTimer:FALSE];

    TCEND
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    TCSTART

    buttonMiddle.enabled = YES;
    buttonMiddle.hidden  = FALSE;

    buttonRight.enabled = NO;
    buttonRight.hidden  = TRUE;

    [statusDisplay setText:@"Stopped"];

    [self stopTimer:FALSE];

    [AKSMethods printErrorMessage:error showit:NO];

    TCEND
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    fileRecordedOnce = TRUE;
    if (filePath && [[NSFileManager defaultManager]fileExistsAtPath:filePath]) useThisFile.enabled = YES;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    buttonMiddle.enabled = YES;
    buttonMiddle.hidden  = FALSE;
    buttonRight.enabled = NO;
    buttonRight.hidden  = TRUE;

    [statusDisplay setText:@"Stopped"];

    [self stopTimer:FALSE];

    [AKSMethods printErrorMessage:error showit:NO];
}

- (NSString *)decideFilePath {
    //this is a static path for storing the temporary recorded audio file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    filePath = [NSString stringWithFormat:@"%@/Audio.caf", directory];
    return filePath;
}

@end
