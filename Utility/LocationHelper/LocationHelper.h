//  CLLocation+LocationExtensions.m
//  Created by Sean Carpenter on 2/7/13.
//  Copyright (c) 2013 Clever Armadillo LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^CallbackBlock)(float, float, NSError *);
@interface LocationHelper : NSObject <CLLocationManagerDelegate>
+ (LocationHelper *)instance;
- (void)getLocation:(CallbackBlock)block;
@end
