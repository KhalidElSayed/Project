//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import "Download.h"

@implementation Download

@synthesize mediaId, url, fileName, fileType, percentageComplete, serverMD5CheckSum;

#pragma mark -

- (id)initWithMediaId:(NSNumber *)mediaId_ WithUrl:(NSURL *)url_ WithFileName:(NSString *)fileName_ WithfileType:(NSString *)fileType_ {
    if ((self = [super init]) != nil) {
        mediaId = [mediaId_ copy];
        url = [url_ copy];
        fileName = [fileName_ copy];
        fileType = [fileType_ copy];
    }
    return self;
}

- (void)dealloc {
    [mediaId release];
    [url release];
    [fileName release];
    [fileType release];
    [super dealloc];
}

@end