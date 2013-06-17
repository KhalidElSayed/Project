//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

/**

 FeedItemServices:-

 This service class initiates and handles all server interaction related network connection.
 */

#import <Foundation/Foundation.h>

@class AppDelegate;


typedef void (^operationFinishedBlock)(id responseData);


@interface FeedItemServices : NSObject

/**
 method to get data
 */
- (void)getDataExample:(operationFinishedBlock)operationFinishedBlock;

/**
 method to post data
 */
- (void)postDataExample:(operationFinishedBlock)operationFinishedBlock;

@end




