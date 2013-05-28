//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface AKSMethods : NSObject
{
    UIView *webViewHolderView;
}
+ (AKSMethods *)sharedAKSMethods;
+ (CGRect)transformRect:(CGRect)Rect WithTransformation:(double)transformation;
+ (float)modOffloat:(float)floatData;
+ (int)modOfint:(int)intData;
+ (CGPoint)centerForRect:(CGRect)rect;
+ (void)print:(CGRect)rect;
+ (void)printCGPoint:(CGPoint)point WithTag:(NSString *)tag;
+ (void)printErrorMessage:(NSError *)error showit:(BOOL)show;
+ (void)showMessage:(NSString *)msg;
+ (void)showDebuggingMessage:(NSString *)msg;
+ (void)printDictionary:(NSDictionary *)dictionary;
+ (void)removeAllKeysHavingNullValue:(NSMutableDictionary *)dictionary;
+ (NSMutableString *)documentsDirectory;
+ (BOOL)validateEmailWithString:(NSString *)email WithIdentifier:(NSString *)identifier;
+ (BOOL)validateNameWithString:(NSString *)name WithIdentifier:(NSString *)identifier;
+ (BOOL)validatePhoneNumberWithString:(NSString *)number WithIdentifier:(NSString *)identifier;
+ (UIImage *)compressThisImage:(UIImage *)image;
+ (NSString *)limitThis:(NSString *)string ForLengthUpto:(int)maxLength;
+ (NSURL *)smartURLForString:(NSString *)str;
+ (void)printFreeMemory;
+ (NSString *)getClassNameForObject:(id)object;
+ (NSMutableString *)namedFormatForDate:(NSDate *)date;
+ (void)highlightAllLabelsOfThisView:(UIView *)view;
+ (NSString *)StringWithAlphaNumericCharacters:(NSString *)string;
+ (void)showThisAlertViewByWorkAroundForParallelButtons:(UIAlertView *)alertView;
+ (void)syncroniseNSUserDefaults;
+ (void)customizeThisButton:(UIButton *)button Withtext:(NSString *)title;
+ (void)customizeThisButton:(UIButton *)button WithImage:(NSString *)imageName;
+ (void)customizeThisTextField:(UITextField *)textField;
+ (void)customizeThisLabel:(UILabel *)label;
- (void)showWebViewWithUrl:(NSURL *)url FromViewController:(UIViewController *)viewController;
+ (UIImage *)getfirstFrameForVideo:(NSString *)filePath;
+ (UIImage *)getScreenCapture;
+ (UIView *)getCapturedImageAsView;
+ (void)performSplashScreenAnimation:(UIView *)applicationMainWindow;
+ (void)convertCafToMp3WithSourceFilePath:(NSString *)sourceFilePath WithDestinationFilePath:(NSString *)destinationFilePath;

@end



@interface NSString (Helpers)

- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet *)set;

@end

@implementation NSString (Helpers)

- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet *)set {
    NSArray *components = [self componentsSeparatedByCharactersInSet:set];
    return [components componentsJoinedByString:@""];
}

@end


@implementation NSArray (Reverse)

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end

@implementation NSMutableArray (Reverse)

- (void)reverse {
    if ([self count] == 0) return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];

        i++;
        j--;
    }
}

@end


@interface UIImage (scale)

- (UIImage *)scaleToSize:(CGSize)size;

@end

@implementation UIImage (scale)

- (UIImage *)scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end