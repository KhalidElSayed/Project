//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadOperation.h"

@class UploadManager, Upload;

@protocol UploadManagerDelegate <NSObject>
@optional
- (void)uploadManager:(UploadManager *)uploadManager didQueueUpload:(Upload *)upload;
- (void)uploadManager:(UploadManager *)uploadManager didCancelUpload:(Upload *)upload;
- (void)uploadManager:(UploadManager *)uploadManager didFinishUpload:(Upload *)upload withData:(NSData *)data;
- (void)uploadManager:(UploadManager *)uploadManager didUpdateUpload:(Upload *)upload;
@end

@interface UploadManager : NSObject <UploadOperationDelegate> {
    NSMutableArray *uploads_;
    NSMutableArray *delegates_;
    NSOperationQueue *operationQueue_;
}
@property (nonatomic, readonly) NSMutableArray *uploads;
+ (id)sharedUploadManager;
- (void)addDelegate:(id<UploadManagerDelegate>)delegate;
- (void)removeDelegate:(id<UploadManagerDelegate>)delegate;
- (BOOL)queueUpload:(Upload *)upload;
- (void)stopUpload:(Upload *)upload;
- (void)stopAllUploads;
@end
