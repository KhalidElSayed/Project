//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AksAudioPlayer : UIView <AVAudioPlayerDelegate>
{
    UIButton *buttonMiddle;
    UIButton *buttonRight;
    UIButton *buttonClose;
    UIImageView *background;
    UILabel *statusDisplay;
    UILabel *timerDisplay;
    NSTimer *timer;
    int timeInSeconds;

    NSString *filePath;
    AVAudioPlayer *audioPlayer;
}
@property (nonatomic, retain) NSString *filePath;
- (void)prepare;
- (void)startPlaying;
@end
