//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FGalleryViewController.h"

@interface FGalleryController : NSObject <FGalleryViewControllerDelegate>
{
    NSMutableArray *imagesSources;
    NSMutableArray *captions;
}

@property (nonatomic, retain) NSMutableArray *imagesSources;
@property (nonatomic, retain) NSMutableArray *captions;

+ (FGalleryController *)sharedController;
- (void)showGalleryViewUsingImageSources:(NSMutableArray *)imageSources WithCaptions:(NSMutableArray *)captions FromViewController:(UIViewController *)viewController;

@end
