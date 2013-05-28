//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Download : NSObject {
    NSNumber *mediaId;
    NSURL *url;
    NSString *fileName;
    NSString *fileType;
    int percentageComplete;
    NSString *serverMD5CheckSum;
}

@property (nonatomic, readwrite) int percentageComplete;
@property (nonatomic, retain) NSNumber *mediaId;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *fileType;
@property (nonatomic, retain) NSString *serverMD5CheckSum;

- (id)initWithMediaId:(NSNumber *)mediaId_ WithUrl:(NSURL *)url_ WithFileName:(NSString *)fileName_ WithfileType:(NSString *)fileType_;

@end