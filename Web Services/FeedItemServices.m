//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import "FeedItemServices.h"
#import "NetworkConnection.h"
#import "ApplicationConstants.h"
#import "ApplicationUrls.h"
#import "SBJson.h"



@implementation FeedItemServices

- (id)initWithCaller:(id)caller {
    if (self = [super init]) {
        caller_ = caller;
        appDelegate = ((AppDelegate *)[[UIApplication sharedApplication]delegate]);
    }
    return self;
}

#pragma mark - GET DEVICE INFO

- (void)getDeviceInfo {
    TCSTART

    NSString *udid = [[NSUserDefaults standardUserDefaults]objectForKey:@"UDID"];

    NSString *url = [[NSString stringWithFormat:GET_REQUEST_EXAMPLE_URL, udid] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

    NSDictionary *feedRequestDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"getDeviceInfo", @"requestfor", url, @"urlToHit", nil];

    [self networkCall:feedRequestDictionary];

    TCEND
}

- (void)didFinishedGettingDeviceInfo:(NSMutableDictionary *)results {
    TCSTART

    if (caller_ && [caller_ conformsToProtocol:@protocol(GetDeviceInfoOperationDelegate)] && [caller_ respondsToSelector:@selector(didFinishedGettingDeviceInfo:)]) {
        [caller_ didFinishedGettingDeviceInfo:results];
    }

    TCEND
}

- (void)didFailGettingDeviceInfoWithError {
    TCSTART

    if (caller_ && [caller_ conformsToProtocol:@protocol(GetDeviceInfoOperationDelegate)] && [caller_ respondsToSelector:@selector(didFailGettingDeviceInfoWithError)]) {
        [caller_ didFailGettingDeviceInfoWithError];
    }

    TCEND
}

#pragma mark - REGISTER CURRENT DEVICE

- (void)registerCurrentDevice {
    TCSTART

    NSString *url = [POST_REQUEST_EXAMPLE_URL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

    NSMutableDictionary *bodyData = [[NSMutableDictionary alloc]init];
    NSString *udid     = [[NSUserDefaults standardUserDefaults]objectForKey:@"UDID"];
    NSString *password = [[NSUserDefaults standardUserDefaults]objectForKey:@"PASSWORD"];

    [bodyData setObject:udid forKey:@"udid"];
    [bodyData setObject:password forKey:@"password"];

    SBJsonWriter *writer = [SBJsonWriter new];

    NSString *jsonformattedString = [writer stringWithObject:bodyData];

    NSDictionary *feedRequestDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"registerCurrentDevice", @"requestfor", url, @"urlToHit", jsonformattedString, @"body", nil];

    [self networkCall:feedRequestDictionary];

    TCEND
}

- (void)didFinishedRegistration:(NSMutableDictionary *)results {
    TCSTART

    if (caller_ && [caller_ conformsToProtocol:@protocol(RegisterDeviceOperationDelegate)] && [caller_ respondsToSelector:@selector(didFinishedRegistration:)]) {
        [caller_ didFinishedRegistration:results];
    }

    TCEND
}

- (void)didFailRegistrationWithError {
    TCSTART

    if (caller_ && [caller_ conformsToProtocol:@protocol(RegisterDeviceOperationDelegate)] && [caller_ respondsToSelector:@selector(didFailRegistrationWithError)]) {
        [caller_ didFailRegistrationWithError];
    }

    TCEND
}

#pragma mark NetWork Call
- (void)networkCall:(NSDictionary *)requestParams {
    TCSTART

    // Create a network request
    NetworkConnection *networkConn = [[NetworkConnection alloc] init];

    if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"registerCurrentDevice"]) {
        [NSThread detachNewThreadSelector:@selector(registerCurrentDevice:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"registerCurrentDevice", self, @"caller", nil]];
    } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"getDeviceInfo"]) {
        [NSThread detachNewThreadSelector:@selector(getDeviceInfo:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"getDeviceInfo", self, @"caller", nil]];
    }

    networkConn = nil;

    TCEND
}

@end
