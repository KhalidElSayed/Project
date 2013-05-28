//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadOperation.h"

@class DownloadManager, Download;

@protocol DownloadManagerDelegate <NSObject>
@optional
- (void)downloadManager:(DownloadManager *)downloadManager didQueueDownload:(Download *)download;
- (void)downloadManager:(DownloadManager *)downloadManager didCancelDownload:(Download *)download;
- (void)downloadManager:(DownloadManager *)downloadManager didFinishDownload:(Download *)download withData:(NSData *)data;
- (void)downloadManager:(DownloadManager *)downloadManager didUpdateDownload:(Download *)download;
@end

@interface DownloadManager : NSObject <DownloadOperationDelegate> {
    NSMutableArray *downloads_;
    NSMutableArray *delegates_;
    NSOperationQueue *operationQueue_;
}
@property (nonatomic, readonly) NSMutableArray *downloads;
+ (id)sharedDownloadManager;
- (void)addDelegate:(id<DownloadManagerDelegate>)delegate;
- (void)removeDelegate:(id<DownloadManagerDelegate>)delegate;
- (BOOL)queueDownload:(Download *)download;
- (void)stopDownload:(Download *)download;
- (void)stopAllDownloads;
- (BOOL)isDownloadingDataWithMediaId:(int)mediaId;
@end