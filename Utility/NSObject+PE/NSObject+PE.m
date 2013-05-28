//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//


#import "NSObject+PE.h"


@implementation NSObject (PE)

- (BOOL)isNull:(NSObject *)object {
    if (!object) return YES;
    else if (object == [NSNull null]) return YES;
    else if ([object isKindOfClass:[NSString class]]) {
        return ([((NSString *)object)isEqualToString : @""]
                || [((NSString *)object)isEqualToString : @"null"]
                || [((NSString *)object)isEqualToString : @"<null>"]);
    }
    return NO;
}

- (BOOL)isNotNull:(NSObject *)object {
    return ![self isNull:object];
}

- (NSString *)stringByTruncatingStringWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(UILineBreakMode)lineBreakMode {
    NSMutableString *resultString = [self mutableCopy];
    NSRange range = { resultString.length - 1, 1 };

    while ([resultString sizeWithFont:font forWidth:FLT_MAX lineBreakMode:lineBreakMode].width > width || range.location == 0) {
        // delete the last character
        [resultString deleteCharactersInRange:range];

        if (range.location > 0) range.location--;
    }

    if (resultString.length < ((NSString *)self).length) {
        NSRange newRange = { resultString.length - 3, 3 };
        [resultString replaceCharactersInRange:newRange withString:@"..."];
    }

    return resultString;
}

@end
