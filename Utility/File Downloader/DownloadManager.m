    //
    //  Project Template
    //
    //  Created by Alok on 2/04/13.
    //  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
    //

#import "DownloadManager.h"
#import "DownloadOperation.h"

#define CONCURRENT_DOWNLOADS_COUNT 1

static DownloadManager *sSharedDownloadManager = nil;

@implementation DownloadManager

@synthesize downloads = downloads_;

+ (id)sharedDownloadManager {
    @synchronized(self) {
        if (sSharedDownloadManager == nil) {
            sSharedDownloadManager = [DownloadManager new];
        }
    }

    return sSharedDownloadManager;
}

#pragma mark -

- (id)init {
    if ((self = [super init]) != nil) {
        downloads_ = [NSMutableArray new];
        delegates_ = [NSMutableArray new];
        operationQueue_ = [NSOperationQueue new];
        [operationQueue_ setMaxConcurrentOperationCount:CONCURRENT_DOWNLOADS_COUNT];
    }
    return self;
}

- (void)dealloc {
    [operationQueue_ release];
    [downloads_ release];
    [delegates_ release];
    [super dealloc];
}

#pragma mark -

- (void)addDelegate:(id<DownloadManagerDelegate>)delegate {
    NSValue *delegateValue = [NSValue valueWithPointer:delegate];
    [delegates_ addObject:delegateValue];
}

- (void)removeDelegate:(id<DownloadManagerDelegate>)delegate {
    NSValue *delegateValue = [NSValue valueWithPointer:delegate];
    [delegates_ removeObjectIdenticalTo:delegateValue];
}

#pragma mark -

- (BOOL)queueDownload:(Download *)download {
    BOOL IsAlreadyExists = FALSE;

    for (int i = 0; i < downloads_.count; i++) {
        if ([((Download *)[downloads_ objectAtIndex:i]).url isEqual : download.url] && (((Download *)[downloads_ objectAtIndex:i]).mediaId.intValue == download.mediaId.intValue)) {
            IsAlreadyExists = TRUE;
            break;
        }
    }

    if (IsAlreadyExists) {
        [AKSMethods showMessage:@"File is already being downloading."];
        return FALSE;
    }

    [downloads_ addObject:download];

    for (NSValue *delegateValue in delegates_) {
        id<DownloadManagerDelegate> delegate = [delegateValue pointerValue];
        if ([delegate respondsToSelector:@selector(downloadManager:didQueueDownload:)] == YES) {
            [delegate downloadManager:self didQueueDownload:download];
        }
    }
    DownloadOperation *downloadOperation = [[[DownloadOperation alloc] initWithDownload:download delegate:self] autorelease];
    [operationQueue_ addOperation:downloadOperation];
    return TRUE;
}

- (void)stopDownload:(Download *)download {
    if ([downloads_ containsObject:download]) {
        [download retain];

        [downloads_ removeObject:download];

        for (NSValue *delegateValue in delegates_) {
            id<DownloadManagerDelegate> delegate = [delegateValue pointerValue];
            if ([delegate respondsToSelector:@selector(downloadManager:didCancelDownload:)] == YES) {
                [delegate downloadManager:self didCancelDownload:download];
            }
        }

        [download release];
    }
}

- (void)stopAllDownloads {
    [operationQueue_ cancelAllOperations];
    Download *download;
    for (int i = 0; i < downloads_.count; i++) {
        download = [downloads_ objectAtIndex:i];
        [download retain];
        [downloads_ removeObject:download];
        [download release];
    }
}

- (BOOL)isDownloadingDataWithMediaId:(int)mediaId {
    for (int i = 0; i < downloads_.count; i++) {
        Download *object_  = [downloads_ objectAtIndex:i];
        if (object_.mediaId.intValue == mediaId) return YES;
    }

    return NO;
}

#pragma mark DownloadManagerDelegate Methods

- (void)downloadOperationDidFinish:(DownloadOperation *)operation {
    if ([downloads_ containsObject:operation.download]) {
        for (NSValue *delegateValue in delegates_) {
            id<DownloadManagerDelegate> delegate = [delegateValue pointerValue];
            if ([delegate respondsToSelector:@selector(downloadManager:didFinishDownload:withData:)] == YES) {
                [delegate downloadManager:self didFinishDownload:operation.download withData:operation.data];
            }
        }
        [downloads_ removeObject:operation.download];
    }
}

- (void)downloadOperationDidFail:(DownloadOperation *)operation {
    if ([downloads_ containsObject:operation.download]) {
        [downloads_ removeObject:operation.download];

        for (NSValue *delegateValue in delegates_) {
            id<DownloadManagerDelegate> delegate = [delegateValue pointerValue];
            if ([delegate respondsToSelector:@selector(downloadManager:didCancelDownload:)] == YES) {
                [delegate downloadManager:self didCancelDownload:operation.download];
            }
        }
    }
}

- (void)downloadOperationDidMakeProgress:(DownloadOperation *)operation {
    for (NSValue *delegateValue in delegates_) {
        id<DownloadManagerDelegate> delegate = [delegateValue pointerValue];
        if ([delegate respondsToSelector:@selector(downloadManager:didUpdateDownload:)] == YES) {
            [delegate downloadManager:self didUpdateDownload:operation.download];
        }
    }
}

@end