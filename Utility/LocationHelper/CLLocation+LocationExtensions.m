//  CLLocation+LocationExtensions.m
//  Created by Sean Carpenter on 2/7/13.
//  Copyright (c) 2013 Clever Armadillo LLC. All rights reserved.

#import "CLLocation+LocationExtensions.h"
#import <tgmath.h>

@implementation CLLocation (LocationExtensions)

- (CLLocation *)locationAtDistance:(CLLocationDistance)distance andBearing:(CLLocationDegrees)bearing {
    const int R = 6371000;
    double bearingRad = bearing * M_PI / 180;
    double dOverR = distance / R;
    double currentLat = self.coordinate.latitude * M_PI / 180;
    double currentLon = self.coordinate.longitude * M_PI / 180;
    double newLat = asin(sin(currentLat) * cos(dOverR) + cos(currentLat) * sin(dOverR) * cos(bearingRad));
    double newLon = currentLon + atan2(sin(bearingRad) * sin(dOverR) * cos(currentLat), cos(dOverR) - sin(currentLat) * sin(newLat));
    return [[CLLocation alloc] initWithLatitude:newLat * 180 / M_PI longitude:newLon * 180 / M_PI];
}

- (CLLocationDegrees)bearingTo:(CLLocation *)otherPoint {
    double thisLat = self.coordinate.latitude * M_PI / 180;
    double thisLon = self.coordinate.longitude * M_PI / 180;
    double otherLat = otherPoint.coordinate.latitude * M_PI / 180;
    double otherLon = otherPoint.coordinate.longitude * M_PI / 180;
    double y = sin(otherLon - thisLon) * cos(otherLat);
    double x = cos(thisLat) * sin(otherLat) - sin(thisLat) * cos(otherLat) * cos(otherLon - thisLon);
    double bearing = atan2(y, x) * 180 / M_PI;
    return fmod(bearing + 360, 360.0);
}

@end
