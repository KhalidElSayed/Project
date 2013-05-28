//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Upload.h"
#import "AppDelegate.h"
#import "URLConnection.h"

@class UploadOperation;

@protocol UploadOperationDelegate<NSObject>

- (void)uploadOperationDidFinish:(UploadOperation *)operation;
- (void)uploadOperationDidFail:(UploadOperation *)operation;
- (void)uploadOperationDidMakeProgress:(UploadOperation *)operation;
@end

@interface UploadOperation : NSOperation {
    AppDelegate *appDelegate;
@private
    NSMutableData *data_;
    Upload *upload_;
    id<UploadOperationDelegate> delegate_;
    URLConnection *connection_;
    NSInteger statusCode_;
    BOOL executing_;
    BOOL finished_;
    int try;
}

- (id)initWithUpload:(Upload *)upload delegate:(id<UploadOperationDelegate>)delegate;

@property (nonatomic, readonly) Upload *upload;
@property (nonatomic, readonly) NSData *data;

@end
