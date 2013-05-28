//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Upload : NSObject {
    NSURL *url;
    NSString *fileName;
    NSString *fileType;
    NSString *filePath;
    NSData *serverResponseData;
    NSMutableDictionary *userInfo;
    int totalParts;
    int currentPart;
    int completedPartsCount;
    NSString *fileId;
    long long fileSize;
    long long MAXIMUM_PART_SIZE;

    NSString *clientMD5StringForCurrentPart;
    NSString *MD5StringForCompleteFile;
}

@property (nonatomic, retain) NSMutableDictionary *userInfo;
@property (nonatomic, retain) NSData *serverResponseData;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *fileType;
@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, readwrite) int totalParts;
@property (nonatomic, readwrite) int currentPart;
@property (nonatomic, readwrite) int completedPartsCount;
@property (nonatomic, readwrite) long long fileSize;
@property (nonatomic, readwrite) long long MAXIMUM_PART_SIZE;
@property (nonatomic, retain) NSString *fileId;

- (id)initWithUrl:(NSURL *)url_ WithFileName:(NSString *)fileName_ WithfileType:(NSString *)fileType_ WithfilePath:(NSString *)filePath_ WithUserInfo:(NSMutableDictionary *)userInfo_;

- (NSData *)getFileDataToSend;
- (BOOL)isCompleted;
- (NSString *)getCheckSumForCurrentPart;
- (NSString *)getCheckSumForCompleteFile;

@end
