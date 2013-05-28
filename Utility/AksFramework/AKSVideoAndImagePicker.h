//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AKSVideoAndImagePickerOperationDelegate <NSObject>
@required
- (void)didFinishedGettingFileWithPath:(NSString *)filePath withFileType:(NSString *)fileType;
@end

@interface AKSVideoAndImagePicker : NSObject
{
    UIImagePickerController *imagePickerController;
    NSString *lastVideoPath;
    id<AKSVideoAndImagePickerOperationDelegate> delegate;
}

+ (AKSVideoAndImagePicker *)sharedAKSVideoAndImagePicker;

- (void)needImage:(BOOL)imageNeeded needVideo:(BOOL)videoNeeded FromLibrary:(BOOL)fromLibrary delegate:(UIViewController *)viewController;
+ (void)resetCachedMediaFiles;

@end
