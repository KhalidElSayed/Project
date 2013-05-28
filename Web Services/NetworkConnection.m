//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//


#import "NetworkConnection.h"
#import "NSObject+PE.h"
#import "SBJson.h"
#import "FeedItemServices.h"
#import "ApplicationUrls.h"
#import "AppDelegate.h"
#import "ApplicationConstants.h"

#define ApplicationDelegate ((AppDelegate *)[[UIApplication sharedApplication]delegate])

@implementation NetworkConnection

#pragma mark - GET DEVICE INFO

- (void)getDeviceInfo:(NSDictionary *)parameters {
    TCSTART

	appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);

    @autoreleasepool
    {
        NSDictionary *feedItemsDict = [parameters objectForKey:@"getDeviceInfo"];

        id caller = [parameters objectForKey:@"caller"];

        NSString *url  = [feedItemsDict objectForKey:@"urlToHit"];

        SBJsonParser *parser = [[SBJsonParser alloc] init];

        NSData *responseData = [self createNetworkConnection:url];

        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

        NSLog(@"\n\nREQUEST TYPE :- GET DEVICE INFO \n\nURL \n%@   \n\nRECEIVED RESPONSE FROM SERVER %@\n\n\n", url, responseString);

        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202 || currentStatusCode == 401) {
            networkStatusCode = 0;
            NSError *error;

            NSDictionary *responseDict = nil;

            TCSTART
			responseDict = [parser objectWithString:responseString error:&error];
            TCEND

            if (!error) {
                if ([self isNotNull:responseDict]) {
                    if (caller && [caller conformsToProtocol:@protocol(GetDeviceInfoOperationDelegate)] && [caller respondsToSelector:@selector(didFinishedGettingDeviceInfo:)]) {
                        [caller performSelectorOnMainThread:@selector(didFinishedGettingDeviceInfo:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    if (caller && [caller conformsToProtocol:@protocol(GetDeviceInfoOperationDelegate)] && [caller respondsToSelector:@selector(didFailGettingDeviceInfoWithError)]) {
                        [caller performSelectorOnMainThread:@selector(didFailGettingDeviceInfoWithError) withObject:nil waitUntilDone:NO];
                    }
                }
            } else {
                if (caller && [caller conformsToProtocol:@protocol(GetDeviceInfoOperationDelegate)] && [caller respondsToSelector:@selector(didFailGettingDeviceInfoWithError)]) {
                    [caller performSelectorOnMainThread:@selector(didFailGettingDeviceInfoWithError) withObject:nil waitUntilDone:NO];
                }
            }
        } else {
            if (caller && [caller conformsToProtocol:@protocol(GetDeviceInfoOperationDelegate)] && [caller respondsToSelector:@selector(didFailGettingDeviceInfoWithError)]) {
                [caller performSelectorOnMainThread:@selector(didFailGettingDeviceInfoWithError) withObject:nil waitUntilDone:NO];
            }
        }

        parser = nil;
        responseData = nil;
        responseString = nil;
    }

    TCEND
}

#pragma mark - REGISTER CURRENT DEVICE

- (void)registerCurrentDevice:(NSDictionary *)parameters {
    TCSTART

	appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);

    @autoreleasepool
    {
        NSDictionary *feedItemsDict = [parameters objectForKey:@"registerCurrentDevice"];

        id caller = [parameters objectForKey:@"caller"];

        SBJsonParser *parser = [[SBJsonParser alloc] init];

        NSString *url  = [feedItemsDict objectForKey:@"urlToHit"];
        NSString *body = [feedItemsDict objectForKey:@"body"];

        NSData *responseData = [self createNetworkConnection:url WithBody:body WithHTTPMethod:@"POST"];
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

        NSLog(@"\n\nREQUEST TYPE :- REGISTER CURRENT DEVICE \n\nURL \n%@  \n\nBODY  \n%@ \n\nRECEIVED RESPONSE FROM SERVER %@\n\n\n", url, body, responseString);

        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202 || currentStatusCode == 401) {
            networkStatusCode = 0;
            NSError *error;

            NSDictionary *responseDict = nil;

            TCSTART
			responseDict = [parser objectWithString:responseString error:&error];
            TCEND

            if (!error) {
                if ([self isNotNull:responseDict]) {
                    if (caller && [caller conformsToProtocol:@protocol(RegisterDeviceOperationDelegate)] && [caller respondsToSelector:@selector(didFinishedRegistration:)]) {
                        [caller performSelectorOnMainThread:@selector(didFinishedRegistration:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    if (caller && [caller conformsToProtocol:@protocol(RegisterDeviceOperationDelegate)] && [caller respondsToSelector:@selector(didFailRegistrationWithError)]) {
                        [caller performSelectorOnMainThread:@selector(didFailRegistrationWithError) withObject:nil waitUntilDone:NO];
                    }
                }
            } else {
                if (caller && [caller conformsToProtocol:@protocol(RegisterDeviceOperationDelegate)] && [caller respondsToSelector:@selector(didFailRegistrationWithError)]) {
                    [caller performSelectorOnMainThread:@selector(didFailRegistrationWithError) withObject:nil waitUntilDone:NO];
                }
            }
        } else {
            if (caller && [caller conformsToProtocol:@protocol(RegisterDeviceOperationDelegate)] && [caller respondsToSelector:@selector(didFailRegistrationWithError)]) {
                [caller performSelectorOnMainThread:@selector(didFailRegistrationWithError) withObject:nil waitUntilDone:NO];
            }
        }

        parser = nil;
        responseData = nil;
        responseString = nil;
    }

    TCEND
}
















#pragma mark CreateNetworkConnection with Body and httpmethod.
- (NSData *)createNetworkConnection:(NSString *)url WithBody:(NSString *)body WithHTTPMethod:(NSString *)httpMethod {
    TCSTART

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    NSData *requestData = [NSData dataWithBytes:[body UTF8String] length:[body length]];
    [request setHTTPMethod:httpMethod];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:requestData];
    [request setTimeoutInterval:30];

    [self addCredentialsToRequest:request];

    NSHTTPURLResponse *resp = nil;
    NSError *error = nil;
    NSData *response = nil;
    int try = 0;

    while (try < 2) {
        try++;

        response = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&error];

        if (error) {
            networkStatusCode = 1;
            currentStatusCode = 0;

            if ([error code] == -1012) {             //NSURLErrorUserCancelledAuthentication
                currentStatusCode = 401;
            } else if ([error code] == -1001) {             //NSURLErrorTimedOut
                currentStatusCode = 408;
                try = 100;
            } else {                  //check for error description which got throgh the responsse
                response = [[NSString stringWithFormat:@"{\"error\":\"%@\"}", [error localizedDescription]] dataUsingEncoding:NSUTF8StringEncoding];
                currentStatusCode = [error code];
            }
        } else if (resp) {
            currentStatusCode = [resp statusCode];
            NSLog(@"currentStatusCode %d", currentStatusCode);
        }

        // Try again for things like service unavailable and connection failure conditions.
        /*  503 - The Web server (running the Web site) is currently unable to handle the HTTP request due to a temporary overloading or maintenance of the server. The implication is that this is a temporary condition which will be alleviated after some delay. Some servers in this state may also simply refuse the socket connection, in which case a different error may be generated because the socket creation timed out.
         */
        if (currentStatusCode != 503 && currentStatusCode != 0) try = 100;
        else [NSThread sleepForTimeInterval:2];
    }

    NSData *returnValue = [response copy];
    response = nil;
    lastResponse = returnValue;
    requestData = nil;
    request = nil;

    return returnValue;

    TCEND
}

#pragma mark CreateNetworkConnection with Body and httpmethod.
- (NSData *)createPostConnectionWithRequest:(NSMutableURLRequest *)request {
    TCSTART

    [self addCredentialsToRequest : request];

    NSHTTPURLResponse *resp = nil;
    NSError *error = nil;
    NSData *response = nil;
    int try = 0;

    while (try < 2) {
        try++;

        response = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&error];

        if (error) {
            networkStatusCode = 1;
            currentStatusCode = 0;

            if ([error code] == -1012) {             //NSURLErrorUserCancelledAuthentication
                currentStatusCode = 401;
            } else if ([error code] == -1001) {             //NSURLErrorTimedOut
                currentStatusCode = 408;
                try = 100;
            } else {                  //check for error description which got throgh the responsse
                response = [[NSString stringWithFormat:@"{\"error\":\"%@\"}", [error localizedDescription]] dataUsingEncoding:NSUTF8StringEncoding];
                currentStatusCode = [error code];
            }
        } else if (resp) {
            currentStatusCode = [resp statusCode];
            NSLog(@"currentStatusCode %d", currentStatusCode);
        }

        // Try again for things like service unavailable and connection failure conditions.
        /*  503 - The Web server (running the Web site) is currently unable to handle the HTTP request due to a temporary overloading or maintenance of the server. The implication is that this is a temporary condition which will be alleviated after some delay. Some servers in this state may also simply refuse the socket connection, in which case a different error may be generated because the socket creation timed out.
         */
        if (currentStatusCode != 503 && currentStatusCode != 0) try = 100;
        else [NSThread sleepForTimeInterval:2];
    }

    NSData *returnValue = [response copy];
    response = nil;
    lastResponse = returnValue;
    request = nil;

    return returnValue;

    TCEND
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
- (NSData *)createNetworkConnection:(NSString *)url {
    TCSTART


    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];

    [self addCredentialsToRequest:request];

    NSHTTPURLResponse *resp = nil;
    NSError *error = nil;
    NSData *response = nil;
    int try = 0;

    while (try < 2) {
        try++;

        response = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&error];

        if (error) {
            networkStatusCode = 1;
            currentStatusCode = 0;

            if ([error code] == -1012) {             //NSURLErrorUserCancelledAuthentication
                currentStatusCode = 401;
            } else if ([error code] == -1001) {             //NSURLErrorTimedOut
                currentStatusCode = 408;
                try = 100;
            } else {                  //check for error description which got throgh the responsse
                response = [[NSString stringWithFormat:@"{\"error\":\"%@\"}", [error localizedDescription]] dataUsingEncoding:NSUTF8StringEncoding];
                currentStatusCode = [error code];
            }
        } else if (resp) {
            currentStatusCode = [resp statusCode];
            NSLog(@"currentStatusCode %d", currentStatusCode);
        }

        // Try again for things like service unavailable and connection failure conditions.
        /*  503 - The Web server (running the Web site) is currently unable to handle the HTTP request due to a temporary overloading or maintenance of the server. The implication is that this is a temporary condition which will be alleviated after some delay. Some servers in this state may also simply refuse the socket connection, in which case a different error may be generated because the socket creation timed out.
         */
        if (currentStatusCode != 503 && currentStatusCode != 0) try = 100;
        else [NSThread sleepForTimeInterval:2];
    }

    NSData *returnValue = [response copy];
    response = nil;
    lastResponse = returnValue;
    request = nil;

    return returnValue;

    TCEND
}
- (NSString *)returnError:(id)caller withObject:(NSDictionary *)responseDict {
    TCSTART

    NSDictionary *errorDict = [responseDict objectForKey:@"status"];
    NSString *str = [errorDict objectForKey:@"msg"];
    return str;

    TCEND
}
- (NSString *)returnError:(id)caller withObject:(NSDictionary *)responseMap withUrl:(NSString *)urlString {
    TCSTART

    NSURL *appUrl = [NSURL URLWithString:urlString];

    NSString *message = @"";

    if (currentStatusCode == 408) {
        message = @"";
    } else if (currentStatusCode == 500) {
        message = @"";
    } else if (currentStatusCode == 503) {
        NSString *body = [[NSString alloc] initWithData:lastResponse encoding:NSUTF8StringEncoding];

        NSString *url = [NSString stringWithFormat:@"%@/exceptions.json?exception[error_class]=%@&exception[error_message]=%@",
                         appUrl,
                         @"iPhone_503",
                         [body stringByAddingPercentEscapesUsingEncoding:
                          NSASCIIStringEncoding]];

        [self createNetworkConnection:url WithBody:@"" WithHTTPMethod:@"POST"];
        message = @"";
        body = nil;
    } else if ([self isNotNull:responseMap]) {
        if ([self isNotNull:[responseMap objectForKey:@"errors"]]
            && [[responseMap objectForKey:@"errors"] respondsToSelector:@selector(allKeys)]) {
            responseMap = [responseMap objectForKey:@"errors"];
        }

        NSArray *keys = [responseMap allKeys];

        for (NSString *key in keys) {
            NSString *value = [responseMap objectForKey:key];
            if ([key isEqualToString:@"error"]) message = [message stringByAppendingFormat:@"%@\n ", value];
            else if ([key isEqualToString:@"errors"]) message = [message stringByAppendingFormat:@"%@\n ", value];
            else message = [message stringByAppendingFormat:@"%@ %@\n ", [key capitalizedString], value];
        }
    }

    if ([message isEqualToString:@""]) {
        // If we ever reach this then we've got problems...
        message = [NSString stringWithFormat:@"Please try again in a few minutes.: Error #%d", currentStatusCode];
    }
    return message;

    TCEND
}
- (void)addCredentialsToRequest:(NSMutableURLRequest *)request {
    //ask alok to explain this


    //    TCSTART
    //
    //    NSString * host = [[NSURL URLWithString: @""] host];
    //
    //    if([self isNotNull:host])
    //        [NSMutableURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[[NSURL URLWithString: @""] host]];
    //
    //    TCEND
    //
    //
    //    NSString * udid = [[NSUserDefaults standardUserDefaults]objectForKey:@"UDID"];
    //    NSString * password = [[NSUserDefaults standardUserDefaults]objectForKey:@"PASSWORD"];
    //
    //    NSLog(@"\n\n\nUDID %@ \nPASSWORD %@\n\n\n",udid,password);
    //
    //	if([self isNotNull:udid]&&[self isNotNull:password])
    //	{
    //        [request addValue:[@"Basic "stringByAppendingFormat:@"%@",[self encode:[[NSString stringWithFormat:@"%@:%@",udid,password] dataUsingEncoding:NSUTF8StringEncoding]]] forHTTPHeaderField:@"Authorization"];
    //	}
}

@end
