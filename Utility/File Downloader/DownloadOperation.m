//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import "DownloadOperation.h"
#import "AppDelegate.h"

@implementation DownloadOperation

@synthesize download = download_;
@synthesize data = data_;

- (id) initWithDownload: (Download*) download delegate: (id<DownloadOperationDelegate>) delegate;
{
	appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
	if ((self = [super init]) != nil) {
		data_ = [NSMutableData new];
		download_ = [download retain];
		delegate_ = delegate;
	}
	return self;
}

- (void) dealloc
{
	[connection_ release];
	[data_ release];
	[download_ release];
	[super dealloc];
}

// This method is just for convenience. It cancels the URL connection if it
// still exists and finishes up the operation.
- (void)done
{
	if( connection_ ) {
		[connection_ cancel];
		[connection_ autorelease];
		connection_ = nil;
	}
	
	// If we have data, try and make an image
	if( data_ ) {
		[data_ autorelease];
		data_ = nil;
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

- (void) start
{
	if (![NSThread isMainThread]) 
	{ 
		[self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
		return;
	}
	if (![self isCancelled])
	{
		connection_ = [[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL: download_.url] delegate: self] retain];		
		if (connection_ != nil) 
		{
			[self willChangeValueForKey:@"isExecuting"];
			executing_ = YES;
			[self didChangeValueForKey:@"isExecuting"];
		} else 
		{
			[self willChangeValueForKey:@"isExecuting"];
			finished_ = YES;
			[self didChangeValueForKey:@"isExecuting"];
		}
	}
	else
	{
		// If it's already been cancelled, mark the operation as finished.
		[self willChangeValueForKey:@"isFinished"];
		{
			finished_ = YES;
		}
		[self didChangeValueForKey:@"isFinished"];
	}
}

- (BOOL) isConcurrent
{
	return YES;
}

- (BOOL) isExecuting
{
	return executing_;
}

- (BOOL) isFinished
{
  return finished_;
}

#pragma mark NSURLConnection Delegate Methods

- (void) connection: (NSURLConnection*) connection didReceiveData: (NSData*) data
{
	[data_ appendData: data];
	[delegate_ downloadOperationDidMakeProgress: self];
}

- (void)connection: (NSURLConnection*) connection didReceiveResponse: (NSHTTPURLResponse*) response
{
	statusCode_ = [response statusCode];
	
	NSDictionary * responseDictionary = [response allHeaderFields];
	
	[AKSMethods printDictionary:responseDictionary];
	
	if ([self isNotNull:responseDictionary]&&[responseDictionary objectForKey:@"md5Checksum"])
	{
		download_.serverMD5CheckSum = [responseDictionary objectForKey:@"md5Checksum"];
	}
}

- (void) connection: (NSURLConnection*) connection didFailWithError: (NSError*) error
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
	{
		finished_ = YES;
		executing_ = NO;
	}
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];	
	[delegate_ downloadOperationDidFail: self];
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
	{
		finished_ = YES;
		executing_ = NO;
	}
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];	

	if (statusCode_ == 200)
	{
		[delegate_ downloadOperationDidFinish: self];
	} 
	else 
	{
		[delegate_ downloadOperationDidFail: self];
	}
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge 
{
}
@end