//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import "Upload.h"
#import "NSData+MD5.h"


@implementation Upload

@synthesize url, fileName, fileType, filePath, serverResponseData, userInfo, completedPartsCount, totalParts, currentPart, fileSize, fileId, MAXIMUM_PART_SIZE;

#pragma mark -

- (id)initWithUrl:(NSURL *)url_ WithFileName:(NSString *)fileName_ WithfileType:(NSString *)fileType_ WithfilePath:(NSString *)filePath_ WithUserInfo:(NSMutableDictionary *)userInfo_ {
    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath_]) {
        NSLog(@"\n\n\nfile not found.......\n\n");
        return nil;
    }

    if ((self = [super init]) != nil) {
        if (url_) {
            url = [url_ copy];
        }
        if (fileName_) {
            fileName = [fileName_ copy];
        }
        if (fileType_) {
            fileType = [fileType_ copy];
        }
        if (filePath_) {
            filePath = [filePath_ copy];
        }
        if (userInfo_) {
            userInfo = [userInfo_ copy];
        }

		MAXIMUM_PART_SIZE = 1024 * 64;

        fileSize = 0;

        fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath_ error:nil][NSFileSize] longLongValue];

        currentPart = 1;

        if (fileSize <= MAXIMUM_PART_SIZE) {
            totalParts = 1;
        } else {
            totalParts = fileSize / MAXIMUM_PART_SIZE;
            if ((fileSize - (totalParts * MAXIMUM_PART_SIZE)) > 0) totalParts++;
        }

        NSLog(@"\n totalParts %d\n", totalParts);
        NSLog(@"\n fileSize %lld\n", fileSize);

        fileId  = nil;
        completedPartsCount = 0;

        MD5StringForCompleteFile = [[NSString alloc]initWithString:[[NSData dataWithContentsOfFile:filePath_] MD5]];

        NSLog(@"clientMD5StringForCurrentPart %@", clientMD5StringForCurrentPart);
        NSLog(@"MD5StringForComplete file     %@", MD5StringForCompleteFile);

        [self getFileDataToSend];
    }
    return self;
}

- (NSData *)getFileDataToSend {
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];

    TCSTART
    if (currentPart > 1) {
        [fileHandle seekToFileOffset:MAXIMUM_PART_SIZE * (currentPart - 1)];
    }
    TCEND

    NSData *data = [fileHandle readDataOfLength:MAXIMUM_PART_SIZE];

    NSLog(@"%u", data.length);

    return data;
}

- (NSString *)getCheckSumForCurrentPart {
    return clientMD5StringForCurrentPart = [[NSString alloc]initWithString:[[self getFileDataToSend] MD5]];
}

- (NSString *)getCheckSumForCompleteFile {
    return MD5StringForCompleteFile;
}

- (BOOL)isCompleted {
    if (completedPartsCount == totalParts) return YES;
    return NO;
}

- (void)dealloc {
    [url release];
    [fileName release];
    [fileType release];
    [filePath release];
    [userInfo release];
    [super dealloc];
}

@end
