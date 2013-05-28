//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//


#import "AKSVideoAndImagePicker.h"
#import <QuartzCore/QuartzCore.h>
#import "NSObject+PE.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"

static AKSVideoAndImagePicker *aKSVideoAndImagePicker_ = nil;

@implementation AKSVideoAndImagePicker


+ (AKSVideoAndImagePicker *)sharedAKSVideoAndImagePicker {
    TCSTART

    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        if (aKSVideoAndImagePicker_ == nil) {
            aKSVideoAndImagePicker_ = [[AKSVideoAndImagePicker alloc]init];
        }
    });
    return aKSVideoAndImagePicker_;

    TCEND
}

+ (id)alloc {
    NSAssert(aKSVideoAndImagePicker_ == nil, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (void)needImage:(BOOL)imageNeeded needVideo:(BOOL)videoNeeded FromLibrary:(BOOL)fromLibrary delegate:(UIViewController *)viewController {
    delegate = viewController;

    [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/UnUpdatedItems/", [AKSMethods documentsDirectory]] withIntermediateDirectories:YES attributes:nil error:nil];

    imagePickerController                      = [[UIImagePickerController alloc]init];
    imagePickerController.videoQuality         = UIImagePickerControllerQualityTypeLow;
    imagePickerController.videoMaximumDuration = 1800;
    imagePickerController.delegate             = self;

    if (fromLibrary) imagePickerController.sourceType           = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    else imagePickerController.sourceType           = UIImagePickerControllerSourceTypeCamera;

    NSMutableArray *mediaType = [[NSMutableArray alloc]init];
    if (videoNeeded) [mediaType addObject:@"public.movie"];
    if (imageNeeded) [mediaType addObject:@"public.image"];

    imagePickerController.mediaTypes = mediaType;

    [viewController presentModalViewController:imagePickerController animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self didFinishPickingMediaWithInfo:info];
    });

    [picker dismissViewControllerAnimated:YES completion:nil];
	imagePickerController = nil;
}

- (void)didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:@"UIImagePickerControllerMediaType"];

    if ([mediaType isEqualToString:@"public.movie"]) {
        [self showActivityIndicatorWithText:@"optimising video for network use"];
        [self saveVideoInDocumentsTemporarily:info];
        [self compressVideo];
    } else if ([mediaType isEqualToString:@"public.image"]) {
        [self showActivityIndicatorWithText:@"optimising image for network use"];
        UIImage *image = [AKSMethods compressThisImage:info[UIImagePickerControllerOriginalImage]];
        if (image) {
            NSString *pathToUnupdatedDirectory = [self getFilePathToSaveUnUpdatedImage];
            [UIImageJPEGRepresentation(image, 0) writeToFile:pathToUnupdatedDirectory atomically:YES];

            if (delegate && [delegate conformsToProtocol:@protocol(AKSVideoAndImagePickerOperationDelegate)] && [delegate respondsToSelector:@selector(didFinishedGettingFileWithPath:withFileType:)]) {
                [delegate didFinishedGettingFileWithPath:pathToUnupdatedDirectory withFileType:@"image"];
            }
        }
        [self removeActivityIndicator];
    }
}

- (void)compressVideo {
    lastVideoPath = [self getFilePathToSaveUnUpdatedVideo];
    [self convertVideoToLowQuailtyWithInputURL:[NSURL fileURLWithPath:[self getTemporaryFilePathToSaveVideo]] outputURL:[NSURL fileURLWithPath:lastVideoPath] handler:^(AVAssetExportSession *exportSession){
		 [self performSelectorOnMainThread:@selector(compressionSuccessFull) withObject:nil waitUntilDone:NO];
	 }];
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL *)inputURL outputURL:(NSURL *)outputURL handler:(void (^)(AVAssetExportSession *))handler {
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetLowQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
		 handler(exportSession);
	 }];
}

- (void)compressionSuccessFull {
    [self removeActivityIndicator];
    if (delegate && [delegate conformsToProtocol:@protocol(AKSVideoAndImagePickerOperationDelegate)] && [delegate respondsToSelector:@selector(didFinishedGettingFileWithPath:withFileType:)]) {
        [delegate didFinishedGettingFileWithPath:lastVideoPath withFileType:@"video"];
    }
}

- (void)saveVideoInDocumentsTemporarily:(NSDictionary *)info {
    [[[NSData alloc] initWithContentsOfURL:info[UIImagePickerControllerMediaURL]] writeToFile:[[NSMutableString alloc] initWithString:[self getTemporaryFilePathToSaveVideo]] atomically:YES];
}

- (NSString *)getTemporaryFilePathToSaveVideo {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"capturedvideo.MOV"];
}

- (NSString *)getFilePathToSaveUnUpdatedVideo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    for (int i = 0; TRUE; i++) {
        if (![[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"%@/UnUpdatedItems/Video%d.mp4", directory, i]]) return [NSString stringWithFormat:@"%@/UnUpdatedItems/Video%d.mp4", directory, i];
    }
}

- (NSString *)getFilePathToSaveUnUpdatedImage {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    for (int i = 0; TRUE; i++) {
        if (![[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"%@/UnUpdatedItems/Image%d.jpg", directory, i]]) return [NSString stringWithFormat:@"%@/UnUpdatedItems/Image%d.jpg", directory, i];
    }
}

- (void)showActivityIndicatorWithText:(NSString *)text {
    [self removeActivityIndicator];
    MBProgressHUD *hud   = [MBProgressHUD showHUDAddedTo:APPDELEGATE.window animated:YES];
    hud.labelText        = text;
    hud.detailsLabelText = NSLocalizedString(@"Please Wait...", @"");
}

- (void)removeActivityIndicator {
    [MBProgressHUD hideHUDForView:APPDELEGATE.window animated:YES];
}

+ (void)resetCachedMediaFiles {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0) {
        NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *directory = [paths objectAtIndex:0];
        directory = [directory stringByAppendingString:@"/UnUpdatedItems/"];
        for (NSString *file in [fileManager contentsOfDirectoryAtPath : directory error : &error]) {
            NSString *filePath = [directory stringByAppendingPathComponent:file];
            BOOL fileDeleted = [fileManager removeItemAtPath:filePath error:&error];
            if (fileDeleted != YES || error != nil) {
                [AKSMethods printErrorMessage:error showit:NO];
            }
        }
    }
}

@end
