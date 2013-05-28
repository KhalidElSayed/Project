//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import "CommonFunctions.h"
#import "AppDelegate.h"

@implementation CommonFunctions


+ (NSString *)documentsDirectory {
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    return [paths objectAtIndex:0];
}

+ (void)openEmail:(NSString *)address {
    NSString *url = [NSString stringWithFormat:@"mailto://%@", address];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (void)openPhone:(NSString *)number {
    NSString *url = [NSString stringWithFormat:@"tel://%@", number];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (void)openSms:(NSString *)number {
    NSString *url = [NSString stringWithFormat:@"sms://%@", number];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (void)openBrowser:(NSString *)url {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (void)openMap:(NSString *)address {
    NSString *addressText = [address stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", addressText];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (void)alertTitle:(NSString *)aTitle withMessage:(NSString *)aMsg withDelegate:(id)delegate {
    [[[UIAlertView alloc] initWithTitle:aTitle
                                message:aMsg
                               delegate:delegate
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}

+ (void)alertTitle:(NSString *)aTitle withMessage:(NSString *)aMsg {
    [self alertTitle:aTitle withMessage:aMsg withDelegate:nil];
}

+ (BOOL)isRetinaDisplay {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        return YES;
    } else {
        return NO;
    }
}

+ (int)getDeviceType {
#define IS_IPAD     (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_IPHONE   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define IS_IPHONE_5 (fabs( (double)[ [ UIScreen mainScreen ] bounds ].size.height - (double)568) < DBL_EPSILON)

    static int deviceType = 0;
    if (deviceType == 0) {
        if (IS_IPAD) deviceType = IPAD;
        else if (IS_IPHONE && IS_IPHONE_5) deviceType = IPHONE4INCH;
        else if (IS_IPHONE) deviceType = IPHONE3P5INCH;
    }
    return deviceType;
}

+ (NSString *)getImageNameForName:(NSString *)name {
    return [NSString stringWithFormat:IS_IPAD ? @"%@_iPad":@"%@", name];
}

+ (NSString *)getNibNameForName:(NSString *)name {
    if (IsiPhone4Inch) {
        NSString *possibleNibName = [NSString stringWithFormat:@"%@_iPhone4Inch", name];
        if ([[NSBundle mainBundle] pathForResource:possibleNibName ofType:@"nib"] != nil) {
            return possibleNibName;
        }
    }

    return [NSString stringWithFormat:IS_IPAD ? @"%@_iPad":@"%@", name];
}

+ (void)showAlertWithInfo:(NSDictionary *)infoDic {
    int tag = 0;

    if ([infoDic objectForKey:@"tag"]) tag = [[infoDic objectForKey:@"tag"] intValue];

    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:[infoDic objectForKey:@"title"]
                               message:[infoDic objectForKey:@"message"]
                              delegate:[infoDic objectForKey:@"delegate"]
                     cancelButtonTitle:[infoDic objectForKey:@"cancel"]
                     otherButtonTitles:[infoDic objectForKey:@"other"], nil];
    [alertView setTag:tag];
    [alertView show];
}

@end
