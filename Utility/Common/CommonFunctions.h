//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>


#define IsiPhone3p5Inch ([CommonFunctions getDeviceType] == IPHONE3P5INCH)
#define IsiPhone4Inch   ([CommonFunctions getDeviceType] == IPHONE4INCH)
#define IsiPad          ([CommonFunctions getDeviceType] == IPAD)
#define IsiPadMini      ([CommonFunctions getDeviceType] == IPAD_MINI)

#define IPHONE3P5INCH   10
#define IPHONE4INCH     11
#define IPAD            12
#define IPAD_MINI       13


/**

 CommonFunctions:-

 This singleton class implements some generic methods which are frequently needed in application.

 */
@interface CommonFunctions : NSObject
{
}

/**
 returns the document directory path
 */
+ (NSString *)documentsDirectory;

/**
 opens the email editor
 */
+ (void)openEmail:(NSString *)address;

/**
 dials the specified number
 */
+ (void)openPhone:(NSString *)number;

/**
 opens message editor
 */
+ (void)openSms:(NSString *)number;

/**
 opens default browser with url
 */
+ (void)openBrowser:(NSString *)url;

/**
 opens default map with address
 */
+ (void)openMap:(NSString *)address;

/**
 show alert view with Ok button with delegate
 */
+ (void)alertTitle:(NSString *)aTitle withMessage:(NSString *)aMsg withDelegate:(id)delegate;

/**
 show alert view with Ok button with out delegate
 */
+ (void)alertTitle:(NSString *)aTitle withMessage:(NSString *)aMsg;

/**
 show alert view based upon the information passed in dictionary
 */
+ (void)showAlertWithInfo:(NSDictionary *)infoDic;

/**
 tells whether current device is having retina display support or not.
 */
+ (BOOL)isRetinaDisplay;


/**
 decides and returns the image name based on the current device.

 for ex:-

 [CommonFunctions getImageNameForName:@"Konstant"]

 this method will return

 @"Konstant" for iphone

 @"Konstant_iPad" for ipad

 */
+ (NSString *)getImageNameForName:(NSString *)name;



/**
 decides and returns the image name based on the current device.

 for ex:-

 [CommonFunctions getImageNameForName:@"Konstant"]

 this method will return

 @"Konstant" for iphone

 @"Konstant_iPad" for ipad

 */
+ (NSString *)getNibNameForName:(NSString *)name;

/**
 decides and returns the the current device type.

 #define IPHONE3P5INCH 10
 #define IPHONE4INCH 11
 #define IPAD 12
 #define IPAD_MINI 13
 */
+ (int)getDeviceType;

@end
