//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import "UploadOperation.h"
#import "AppDelegate.h"
#import "SBJson.h"

@implementation UploadOperation

@synthesize upload = upload_;
@synthesize data   = data_;

- (id)initWithUpload:(Upload *)upload delegate:(id<UploadOperationDelegate>)delegate {
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if ((self = [super init]) != nil) {
        upload_ = [upload retain];
        delegate_ = delegate;
    }
    return self;
}

- (void)dealloc {
    [connection_ release];
    [upload_ release];
    [super dealloc];
}

// This method is just for convenience. It cancels the URL connection if it
// still exists and finishes up the operation.
- (void)done {
    if (connection_) {
        [connection_ cancel];
        [connection_ autorelease];
        connection_ = nil;
    }

    // Alert anyone that we are finished
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    executing_ = NO;
    finished_  = YES;
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

- (NSMutableURLRequest *)getPreparedRequest {
    TCSTART

    //	NSString * contentType = nil;
    //	NSString * fileId      = nil;
    //
    //	if ([self isNotNull:upload_.fileId])
    //	{
    //		fileId = [NSString stringWithFormat:@"&fileId=%@",upload_.fileId];
    //	}
    //	else
    //	{
    //		fileId = @"";
    //	}
    //
    //	if([upload_.fileType rangeOfString:SEARCH_IMAGE_MIME_TYPE options:NSCaseInsensitiveSearch].length != 0)
    //		contentType = IMAGE_MIME_TYPE;
    //	else if([upload_.fileType rangeOfString:SEARCH_VIDEO_MIME_TYPE options:NSCaseInsensitiveSearch].length != 0)
    //		contentType = VIDEO_MIME_TYPE;
    //	else if([upload_.fileType rangeOfString:SEARCH_AUDIO_MIME_TYPE options:NSCaseInsensitiveSearch].length != 0)
    //		contentType = AUDIO_MIME_TYPE;
    //
    //
    //	//////////////////////////////PREPARING URL//////////////////////////////////////////////////////////
    //	NSString * checkSumInformation = [NSString stringWithFormat:@"&finalChecksum=%@&partChecksum=%@",[upload_ getCheckSumForCompleteFile],[upload_ getCheckSumForCurrentPart]];
    //
    //	NSString * urlToHit  = [NSString stringWithFormat:@"%@&totalPart=%d&partNo=%d&contentType=%@&fileName=%@%@%@",[upload_.url absoluteString],upload_.totalParts,upload_.currentPart,contentType,upload_.fileName,fileId,checkSumInformation];
    //	//////////////////////////////PREPARING URL//////////////////////////////////////////////////////////
    //
    //
    //
    //	//////////////////////////////PREPARING POST REQUEST BODY/////////////////////////////////////////////
    //
    //	NSString *boundary = @"AaB03x";
    //	NSMutableData *postbody = [NSMutableData data];
    //
    //	[postbody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //
    //	if([upload_.fileType rangeOfString:SEARCH_IMAGE_MIME_TYPE options:NSCaseInsensitiveSearch].length != 0)
    //	{
    //		[postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"imageFile.png\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    //		[postbody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",IMAGE_MIME_TYPE] dataUsingEncoding:NSUTF8StringEncoding]];
    //	}
    //	else if([upload_.fileType rangeOfString:SEARCH_VIDEO_MIME_TYPE options:NSCaseInsensitiveSearch].length != 0)
    //	{
    //		[postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"videoFile.mp4\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    //		[postbody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",VIDEO_MIME_TYPE] dataUsingEncoding:NSUTF8StringEncoding]];
    //	}
    //	else if([upload_.fileType rangeOfString:SEARCH_AUDIO_MIME_TYPE options:NSCaseInsensitiveSearch].length != 0)
    //	{
    //		[postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"audioFile.caf\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    //		[postbody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",AUDIO_MIME_TYPE] dataUsingEncoding:NSUTF8StringEncoding]];
    //	}
    //
    //	[postbody appendData:[upload_ getFileDataToSend]];
    //	[postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //
    //	//////////////////////////////PREPARING POST REQUEST BODY/////////////////////////////////////////////
    //
    //
    //
    //	NSMutableURLRequest *uploadRequest = [[NSMutableURLRequest alloc]
    //										  initWithURL:[NSURL URLWithString:urlToHit]
    //										  cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
    //										  timeoutInterval:45];
    //
    //	[uploadRequest setHTTPMethod:@"POST"];
    //	[uploadRequest setValue:@"multipart/form-data; boundary=AaB03x" forHTTPHeaderField:@"Content-Type"];
    //	[uploadRequest setHTTPBody:postbody];
    //
    //	return uploadRequest;

    TCEND
}

- (void)uploadProcess {
    if ([appDelegate statusForNetworkConnectionWithOutMessage]) {
        if (try < 5 && ![upload_ isCompleted]) {
            try++;

            connection_ = [[URLConnection alloc]initWithRequest:[self getPreparedRequest] delegate:self andtag:nil];

            if (!connection_) {
                [self uploadCompleted];
            }
        }
    } else {
        [self uploadCompleted];
    }
}

- (void)uploadCompleted {
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];

    if ([upload_ isCompleted]) {
        upload_.serverResponseData = data_;
        [delegate_ uploadOperationDidFinish:self];
    } else {
        [delegate_ uploadOperationDidFail:self];
    }

    // Alert anyone that we are finished
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    executing_ = NO;
    finished_  = YES;
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

#pragma mark -

- (void)start {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    if (![self isCancelled]) {
        [self willChangeValueForKey:@"isExecuting"];
        executing_ = YES;
        [self didChangeValueForKey:@"isExecuting"];

        if ([appDelegate statusForNetworkConnectionWithOutMessage]) {
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:TRUE];
            [self uploadProcess];
        } else {
            [self uploadCompleted];
        }
    } else {
        // If it's already been cancelled, mark the operation as finished.
        [self willChangeValueForKey:@"isFinished"];
        {
            finished_ = YES;
        }
        [self didChangeValueForKey:@"isFinished"];
    }
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return executing_;
}

- (BOOL)isFinished {
    return finished_;
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    URLConnection *conn = (URLConnection *)connection;
    conn.responseData = [NSMutableData data];
    statusCode_ = [response statusCode];
    [conn.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    URLConnection *conn = (URLConnection *)connection;
    [conn.responseData appendData:data];
    [delegate_ uploadOperationDidMakeProgress:self];

    NSLog(@"receiving .....");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [AKSMethods printErrorMessage:error showit:NO];

    if (try > 5 || [upload_ isCompleted]) {
        [self uploadCompleted];
    } else {
        [self uploadProcess];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    URLConnection *conn = (URLConnection *)connection;

    data_ = conn.responseData;

    NSString *responseString = [[NSString alloc]initWithData:conn.responseData encoding:NSUTF8StringEncoding];

    NSLog(@"\n\n\nresponse received from server %@\n\n\n", responseString);

    SBJsonParser *parser = [[SBJsonParser alloc]init];

    NSError *error;

    NSDictionary *responseDictionary = [parser objectWithString:responseString error:&error];

    if ([self isNotNull:responseDictionary]) {
        NSLog(@"FILE_UPLOAD_RESPONSE_RECEIVED %@", responseDictionary);
        //update upload object with this response

        if ([responseDictionary objectForKey:@"fileId"]) {
            upload_.fileId = [responseDictionary objectForKey:@"fileId"];
            try = 0;
            upload_.currentPart++;
            upload_.completedPartsCount++;
        } else if ([responseDictionary objectForKey:@"code"]) {
            [self uploadCompleted];
        }
    }


    if (try > 5 || [upload_ isCompleted]) {
        [self uploadCompleted];
    } else {
        [self uploadProcess];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
}

@end
