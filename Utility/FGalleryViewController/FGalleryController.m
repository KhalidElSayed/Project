//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//


#import "FGalleryController.h"

static FGalleryController *fGalleryController_ = nil;

@implementation FGalleryController

@synthesize imagesSources;
@synthesize captions;


+ (FGalleryController *)sharedController {
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        if (fGalleryController_ == nil) {
            fGalleryController_ = [[FGalleryController alloc]init];
        }
    });
    return fGalleryController_;
}

+ (id)alloc {
    NSAssert(fGalleryController_ == nil, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (void)showGalleryViewUsingImageSources:(NSMutableArray *)imageSources WithCaptions:(NSMutableArray *)captions FromViewController:(UIViewController *)viewController {
    FGalleryViewController *fGalleryViewController_ = [[FGalleryViewController alloc] initWithPhotoSource:self];
    [viewController.navigationController pushViewController:fGalleryViewController_ animated:YES];
}

#pragma mark - FGalleryViewControllerDelegate Methods


- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery {
    return imagesSources.count;
}

- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index {
    if ([NSURL URLWithString:[imagesSources objectAtIndex:index]]) return FGalleryPhotoSourceTypeNetwork;
    else return FGalleryPhotoSourceTypeLocal;
}

- (NSString *)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index {
    return (captions.count > index) ? ([captions objectAtIndex:index]) : @"";
}

- (NSString *)photoGallery:(FGalleryViewController *)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return (imagesSources.count > index) ? ([imagesSources objectAtIndex:index]) : @"";
}

- (NSString *)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return (imagesSources.count > index) ? ([imagesSources objectAtIndex:index]) : @"";
}

- (void)handleTrashButtonTouch:(id)sender {
}

- (void)handleEditCaptionButtonTouch:(id)sender {
}

@end