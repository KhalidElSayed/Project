//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import "FeedItemServices.h"
#import "ApplicationConstants.h"
#import "ApplicationUrls.h"
#import "SBJson.h"
#import "AFNetworking.h"
#import "Reachability.h"
#import "TSMessage.h"



/**
 category to add methods in NSURLRequest class.
 */
@interface NSURLRequest (DummyInterface)
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString *)host;
@end



@implementation FeedItemServices

#pragma mark - GET DATA EXAMPLE

- (void)getDataExample:(operationFinishedBlock)operationFinishedBlock {
	
    if (![self getStatusForNetworkConnectionAndShowUnavailabilityMessage : YES]) { operationFinishedBlock(nil); return; }

    NSString *url = [GET_REQUEST_EXAMPLE_URL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[[NSURL URLWithString:url]host]]];

    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:url
                                                      parameters:nil];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *responseDict = [self getParsedDataFrom:responseObject];
        operationFinishedBlock(responseDict);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);

        operationFinishedBlock(nil);
    }];

    [operation start];
}

#pragma mark - POST DATA EXAMPLE

- (void)postDataExample:(operationFinishedBlock)operationFinishedBlock {
	
    if (![self getStatusForNetworkConnectionAndShowUnavailabilityMessage : YES]) { operationFinishedBlock(nil); return; }

    NSString *url = [POST_REQUEST_EXAMPLE_URL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[[NSURL URLWithString:url]host]]];

    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:url
                                                      parameters:nil];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *responseDict = [self getParsedDataFrom:responseObject];

        operationFinishedBlock(responseDict);

        NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);

        operationFinishedBlock(nil);
    }];

    [operation start];
}

#pragma mark - common method to add authentication credentials in request

- (void)addCredentialsToRequest:(NSMutableURLRequest *)request {
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        NSString *host = [[NSURL URLWithString:@"https://54.235.108.239/devices"] host];
        if ([self isNotNull:host]) [NSMutableURLRequest setAllowsAnyHTTPSCertificate:YES forHost:host];
    });

    NSString *userName = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    NSString *password = [[NSUserDefaults standardUserDefaults]objectForKey:@"password"];

    NSLog(@"\n\n\nUSERNAME %@ \nPASSWORD %@\n\n\n", userName, password);

    if ([self isNotNull:userName] && [self isNotNull:password]) {
        [request addValue:[@"Basic "stringByAppendingFormat : @"%@", [self encode:[[NSString stringWithFormat:@"%@:%@", userName, password] dataUsingEncoding:NSUTF8StringEncoding]]] forHTTPHeaderField:@"Authorization"];
    }
}

#pragma mark - common method parse and return the data

- (id)getParsedDataFrom:(NSData *)dataReceived {
    return [[[SBJsonParser alloc]init] objectWithData:dataReceived];
}

#pragma mark - common method for Internet reachability checking

/*!
 @function	getStatusForNetworkConnectionAndShowUnavailabilityMessage
 @abstract	get internet reachability status and optionally can show network unavailability message.
 @param	showMessage
 to decide whether to show network unreachability message.
 */

- (BOOL)getStatusForNetworkConnectionAndShowUnavailabilityMessage:(BOOL)showMessage {
    AppDelegate *appDelegate = APPDELEGATE;

    if (([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)) {
        if (showMessage == NO) return NO;
        [self showNotificationInViewController:appDelegate.navigationController.topViewController withTitle:@"Connectivity" withMessage:@"Application requires an active internet connection.\nPlease check your network settings and try again." withType:TSMessageNotificationTypeError withDuration:2];
        return NO;
    }

    return YES;
}

#pragma mark - common method to show toast messages

- (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type
                            withDuration:(NSTimeInterval)duration {
    [TSMessage showNotificationInViewController:viewController
                                      withTitle:title
                                    withMessage:message
                                       withType:type
                                   withDuration:duration];
}

static char *alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (NSString *)encode:(NSData *)plainText {
    int encodedLength = (4 * (([plainText length] / 3) + (1 - (3 - ([plainText length] % 3)) / 3))) + 1;
    unsigned char *outputBuffer = malloc(encodedLength);
    unsigned char *inputBuffer = (unsigned char *)[plainText bytes];

    NSInteger i;
    NSInteger j = 0;
    int remain;

    for (i = 0; i < [plainText length]; i += 3) {
        remain = [plainText length] - i;

        outputBuffer[j++] = alphabet[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = alphabet[((inputBuffer[i] & 0x03) << 4) |
                                     ((remain > 1) ? ((inputBuffer[i + 1] & 0xF0) >> 4) : 0)];

        if (remain > 1)
            outputBuffer[j++] = alphabet[((inputBuffer[i + 1] & 0x0F) << 2)
                                         | ((remain > 2) ? ((inputBuffer[i + 2] & 0xC0) >> 6) : 0)];
        else outputBuffer[j++] = '=';

        if (remain > 2) outputBuffer[j++] = alphabet[inputBuffer[i + 2] & 0x3F];
        else outputBuffer[j++] = '=';
    }

    outputBuffer[j] = 0;

    NSString *result = [NSString stringWithCString:outputBuffer length:strlen(outputBuffer)];
    free(outputBuffer);

    return result;
}

@end
