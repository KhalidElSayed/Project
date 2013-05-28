//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AksAudioRecorder : UIView <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    UIButton *buttonLeft;
    UIButton *buttonMiddle;
    UIButton *buttonRight;
    UIButton *buttonClose;
    UIButton *useThisFile;

    UIImageView *background;

    UILabel *statusDisplay;
    UILabel *timerDisplay;

    NSTimer *timer;

    int timeInSeconds;
    int lastRecordedTimeInSeconds;
    BOOL fileRecordedOnce;

    NSString *filePath;

    AVAudioPlayer *audioPlayer;
    AVAudioPlayer *audioPlayerRecord;
    AVAudioRecorder *audioRecorder;

    id delegate;
}

@property (nonatomic, retain) id delegate;
- (void)prepare;
- (void)setUseButtonTitle:(NSString *)title;
- (void)setUseButtonImage:(NSString *)image;

@end

@protocol AksAudioRecorderDelegate <NSObject>
- (void)fileRecordedWithPath:(NSString *)filePath;
@end
