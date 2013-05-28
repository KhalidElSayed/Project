//  CLLocation+LocationExtensions.m
//  Created by Sean Carpenter on 2/7/13.
//  Copyright (c) 2013 Clever Armadillo LLC. All rights reserved.

#import "LocationHelper.h"

@interface LocationHelper ()
@property (nonatomic) CLLocationManager *locationManager;
@property (copy) CallbackBlock callback;
@property (nonatomic) float lat;
@property (nonatomic) float lng;
@end

@implementation LocationHelper

+ (LocationHelper *)instance {
    static LocationHelper *instance;

    @synchronized(self) {
        if (!instance) instance = [[LocationHelper alloc] init];

        return instance;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.lat = newLocation.coordinate.latitude;
    self.lng = newLocation.coordinate.longitude;
    [manager stopUpdatingLocation];

    self.callback(self.lat, self.lng, nil);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    self.callback(self.lat, self.lng, error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusDenied:
            break;
        case kCLAuthorizationStatusRestricted:
            break;
        default:
            break;
    }
}

- (void)getLocation:(CallbackBlock)block {
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.delegate = self;
    self.callback = block;
    [self.locationManager startUpdatingLocation];
}

@end