//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDelegate;

@interface NetworkConnection : NSObject<NSURLConnectionDelegate>
{
    int currentStatusCode;
    NSData *lastResponse;
    int networkStatusCode;
    AppDelegate *appDelegate;
}

/**
 method to create and handle network connection and responses in order to  register current device information at server.
 */
- (void)registerCurrentDevice:(NSDictionary *)parameters;

/**
 method to create and handle network connection and responses in order to get updated device information from server.
 */
- (void)getDeviceInfo:(NSDictionary *)parameters;

@end





/**
 category to add methods in NSURLRequest class.
 */
@interface NSURLRequest (DummyInterface)
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString *)host;
@end