    //
    //  Project Template
    //
    //  Created by Alok on 2/04/13.
    //  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
    //

#import <Foundation/Foundation.h>

@interface URLConnection : NSURLConnection
{
    NSString *tagInfo;
    NSHTTPURLResponse *response;
    NSMutableData *responseData;
    NSMutableDictionary *userInfo;
}
@property (nonatomic, strong) NSString *tagInfo;
@property (nonatomic, strong) NSMutableDictionary *userInfo;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSMutableData *responseData;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate andtag:(NSString *)tag;
@end