//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//


#ifndef ApplicationConstants_h
#define ApplicationConstants_h

#import "NSObject+PE.h"

#define OBSERVATION_POINT                               NSLog(@"\n%s EXECUTED upto %d\n", __PRETTY_FUNCTION__, __LINE__);

//////////////////////ADVANCED TRY CATCH SYSTEM////////////////////////////////////////
#ifndef UseTryCatch
#define UseTryCatch                                     1
#ifndef UsePTMName
#define UsePTMName                                      0 //USE 0 TO DISABLE AND 1 TO ENABLE PRINTING OF METHOD NAMES WHERE EVER TRY CATCH IS USED
#if UseTryCatch
#if UsePTMName
#define TCSTART                                         @try { NSLog(@"\n%s\n", __PRETTY_FUNCTION__);
#else
#define TCSTART                                         @try {
#endif
#define TCEND                                           } @catch (NSException *e) { NSLog(@"\n\n\n\n\n\n\
\n\n|EXCEPTION FOUND HERE...PLEASE DO NOT IGNORE\
\n\n|FILE NAME         %s\
\n\n|LINE NUMBER       %d\
\n\n|METHOD NAME       %s\
\n\n|EXCEPTION REASON  %@\
\n\n\n\n\n\n\n"    , strrchr(__FILE__, '/'), __LINE__, __PRETTY_FUNCTION__, e); };
#else
#define TCSTART                                         {
#define TCEND                                           }
#endif
#endif
#endif
//////////////////////ADVANCED TRY CATCH SYSTEM////////////////////////////////////////



#define IS_IPAD                                         (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_IPHONE                                       (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define IS_IPHONE_5                                     (fabs( (double)[ [ UIScreen mainScreen ] bounds ].size.height - (double)568) < DBL_EPSILON)

#define NAVIGATION_BAR_HEIGHT                           44

//THROUGH OUT THE APPLICATION I AM USING  showDebuggingMessage METHOD OF Aksmethods class for the purpose of debugging
//if ENABLED it will display some important status via popup messages
#define SHOW_DEBUGGING_MESSAGE                          FALSE

#define SCREEN_FRAME_RECT                               [[UIScreen mainScreen] bounds]

#define NAVIGATION_BAR_HEIGHT                           44

#define AUTO_DISMISS_ALERT_TIMING                       2



#define APPDELEGATE                                     ((AppDelegate *)[[UIApplication sharedApplication]delegate])



#define HIDE_NETWORK_ACTIVITY_INDICATOR                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];



#define SHOW_NETWORK_ACTIVITY_INDICATOR                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];



#define RETURN_IF_THIS_VIEW_IS_NOT_A_TOPVIEW_CONTROLLER if (self.navigationController) if (!(self.navigationController.topViewController == self)) return;

#define RETURN_IF_SHOWING_PURCHASE_DAILOG               if (APPDELEGATE.isShowingPurchaseDailog) return;

//macros for ios 6 orientation support
#ifndef ORIENTATION_SUPPORT_LANDSCAPE_RIGHT__ONLY
#define ORIENTATION_SUPPORT_LANDSCAPE_RIGHT__ONLY \
- (BOOL)shouldAutorotate { \
return NO; \
} \
- (NSUInteger)supportedInterfaceOrientations { \
return UIInterfaceOrientationMaskLandscapeRight; \
}

#endif

#ifndef ORIENTATION_SUPPORT_PORTRAIT_ONLY
#define ORIENTATION_SUPPORT_PORTRAIT_ONLY \
- (BOOL)shouldAutorotate { \
return NO; \
} \
- (NSUInteger)supportedInterfaceOrientations { \
return UIInterfaceOrientationMaskPortrait; \
}

#endif




#define SHOW_STATUS_BAR                    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

#define SHOW_NAVIGATION_BAR                [self.navigationController setNavigationBarHidden:FALSE];

#define HIDE_NAVIGATION_BAR                [self.navigationController setNavigationBarHidden:TRUE];


#define CURRENT_DEVICE_VERSION_FLOAT       [[UIDevice currentDevice]systemVersion].floatValue

#define CURRENT_DEVICE_VERSION_STRING      [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]


#define UITextAlignmentCenter              (CURRENT_DEVICE_VERSION_FLOAT < 6.0) ? UITextAlignmentCenter : NSTextAlignmentCenter
#define UITextAlignmentLeft                (CURRENT_DEVICE_VERSION_FLOAT < 6.0) ? UITextAlignmentLeft : NSTextAlignmentLeft
#define UITextAlignmentRight               (CURRENT_DEVICE_VERSION_FLOAT < 6.0) ? UITextAlignmentRight : NSTextAlignmentRight


#define FONT_REGULAR                       @"Solomon"
#define FONT_HEAVY                         @"Solomon-Heavy"
#define FONT_BOLD                          @"Solomon-Bold"


#define IOS_STANDARD_COLOR_BLUE            [UIColor colorWithHue:0.6 saturation:0.33 brightness:0.69 alpha:1]
#define APPLICATION_STANDARD_COLOR_BLUE    [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]
#define NON_EDITABLE_CELL_BACKGROUND_COLOR [UIColor clearColor]
#define EDITABLE_CELL_BACKGROUND_COLOR     [UIColor whiteColor]

#define CLEAR_NOTIFICATION_BADGE           [UIApplication sharedApplication].applicationIconBadgeNumber = 0;









#if __has_feature(objc_arc)
#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
static classname *shared##classname = nil; \
\
+ (classname *)shared##classname \
{ \
static dispatch_once_t pred; \
dispatch_once(&pred, ^{ shared##classname = [[self alloc] init]; }); \
return shared##classname; \
}
#else
#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
static classname *shared##classname = nil; \
\
+ (classname *)shared##classname \
{ \
static dispatch_once_t pred; \
dispatch_once(&pred, ^{ shared##classname = [[self alloc] init]; }); \
return shared##classname; \
} \
\
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return self; \
} \
\
- (id)retain \
{ \
return self; \
} \
\
- (NSUInteger)retainCount \
{ \
return NSUIntegerMax; \
} \
\
- (oneway void)release \
{ \
} \
\
- (id)autorelease \
{ \
return self; \
}
#endif



#endif