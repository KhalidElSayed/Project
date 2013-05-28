//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

/**

 FeedItemServices:-

 This service class initiates and handles all server interaction related network connection.
 */

#import <Foundation/Foundation.h>

@class AppDelegate;


/**

 Protocol : RegisterDeviceOperationDelegate :-

 This protocol is required to handle request and responses for registering the device at server for this application.
 */

@protocol RegisterDeviceOperationDelegate <NSObject>
@optional
- (void)didFinishedRegistration:(NSMutableDictionary *)results;
- (void)didFailRegistrationWithError;
@end

/**

 Protocol : GetDeviceInfoOperationDelegate :-

 This protocol is required to handle request and responses for getting updated device infotmation from server in this application.

 */

@protocol GetDeviceInfoOperationDelegate <NSObject>
@optional
- (void)didFinishedGettingDeviceInfo:(NSMutableDictionary *)results;
- (void)didFailGettingDeviceInfoWithError;
@end

@interface FeedItemServices : NSObject <
RegisterDeviceOperationDelegate,
GetDeviceInfoOperationDelegate
>
{
    /**
     caller/delegate of this network service.
     */
    id caller_;

    /**
     pointer to the application delegate class
     */
    AppDelegate *appDelegate;
}

/**
 method to allocate object of this service class with delegate.
 */
- (id)initWithCaller:(id)caller;

/**
 method to get updated device information from server.
 */
- (void)getDeviceInfo;

/**
 method to register current device information at server.
 */
- (void)registerCurrentDevice;
@end
