//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//


#import "AKSMethods.h"
#import <QuartzCore/QuartzCore.h>
#import "NSObject+PE.h"
#import "Reachability.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <MediaPlayer/MediaPlayer.h>
#import "lame.h"

static AKSMethods *AKSMethods_ = nil;

@implementation AKSMethods


+ (AKSMethods *)sharedAKSMethods {
    TCSTART

    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        if (AKSMethods_ == nil) {
            AKSMethods_ = [[AKSMethods alloc]init];
        }
    });
    return AKSMethods_;

    TCEND
}

+ (id)alloc {
    NSAssert(AKSMethods_ == nil, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

+ (CGRect)transformRect:(CGRect)Rect WithTransformation:(double)transformation {
    int centerPointX = Rect.origin.x + Rect.size.width / 2;
    int centerPointY = Rect.origin.y + Rect.size.height / 2;
    Rect.size.width *= transformation;
    Rect.size.height *= transformation;
    Rect.origin.x = centerPointX - Rect.size.width / 2;
    Rect.origin.y = centerPointY - Rect.size.height / 2;
    return Rect;
}

+ (float)modOffloat:(float)floatData {
    TCSTART

    if (floatData < 0) floatData = -floatData;
    return floatData;

    TCEND
}

+ (int)modOfint:(int)intData {
    TCSTART

    if (intData < 0) intData = -intData;
    return intData;

    TCEND
}

+ (CGPoint)centerForRect:(CGRect)rect {
    return CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
}

+ (void)print:(CGRect)rect {
    NSLog(@"(%f,%f,%f,%f)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

+ (void)printCGPoint:(CGPoint)point WithTag:(NSString *)tag {
    NSLog(@"\n\n%@ value (%f,%f)\n", tag, point.x, point.y);
}

+ (void)printErrorMessage:(NSError *)error showit:(BOOL)show {
    TCSTART

    if (error) {
        NSLog(@"[error localizedDescription]        : %@", [error localizedDescription]);
        NSLog(@"[error localizedFailureReason]      : %@", [error localizedFailureReason]);
        NSLog(@"[error localizedRecoverySuggestion] : %@", [error localizedRecoverySuggestion]);

        if (show) [AKSMethods showMessage:[error localizedDescription]];
    }

    TCEND
}

+ (void)printFreeMemory {
    TCSTART

    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;

    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);

    vm_statistics_data_t vm_stat;

    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) NSLog(@"Failed to fetch vm statistics"); ;

    /* Stats in bytes */
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    natural_t mem_total = mem_used + mem_free;
    NSLog(@"used: %u free: %u total: %u", mem_used / 100000, mem_free / 100000, mem_total / 100000);

    TCEND
}

+ (NSString *)getClassNameForObject:(id)object {
    return [NSString stringWithFormat:@"%s", class_getName([object class])];
}

+ (void)showMessage:(NSString *)msg {
    if (!(msg && msg.length > 0)) return;
    [self performSelectorOnMainThread:@selector(messageFromMainThread:) withObject:msg waitUntilDone:NO];
}

+ (void)showDebuggingMessage:(NSString *)msg {
    if (SHOW_DEBUGGING_MESSAGE == FALSE) return;

    if (!(msg && msg.length > 0)) return;
    [self performSelectorOnMainThread:@selector(messageFromMainThread:) withObject:msg waitUntilDone:NO];
}

+ (void)messageFromMainThread:(NSString *)msg {
    TCSTART

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Information"
						  message:msg
						  delegate:nil
						  cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];

    TCEND
}

+ (void)printDictionary:(NSDictionary *)dictionary {
    TCSTART

    for (int i = 0; i < [dictionary allKeys].count; i++) {
        if ([[dictionary objectForKey:[[dictionary allKeys] objectAtIndex:i]] isKindOfClass:[NSMutableString class]]) NSLog(@"%@", [dictionary objectForKey:[[dictionary allKeys] objectAtIndex:i]]);
    }

    TCEND
}

+ (void)removeAllKeysHavingNullValue:(NSMutableDictionary *)dictionary {
    TCSTART

    NSSet *nullSet = [dictionary keysOfEntriesWithOptions:NSEnumerationConcurrent passingTest:^BOOL (id key, id obj, BOOL *stop) {
        return [obj isEqual:[NSNull null]] ? YES : NO;
    }];

    [dictionary removeObjectsForKeys:[nullSet allObjects]];

    TCEND
}

+ (NSMutableString *)documentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
}

+ (BOOL)validateEmailWithString:(NSString *)email WithIdentifier:(NSString *)identifier {
    TCSTART

    if (email == nil) {
        [AKSMethods showMessage:[NSMutableString stringWithFormat:@"please enter %@ emailId", identifier]];
        return FALSE;
    }

    if (email.length == 0) {
        [AKSMethods showMessage:[NSMutableString stringWithFormat:@"please enter %@ emailId", identifier]];
        return FALSE;
    }


    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

    if (![emailTest evaluateWithObject:email]) {
        [AKSMethods showMessage:[NSMutableString stringWithFormat:@"please enter valid %@ emailId", identifier]];
        return FALSE;
    } else return TRUE;

    TCEND
}

+ (BOOL)validateNameWithString:(NSString *)name WithIdentifier:(NSString *)identifier {
    TCSTART

    if (name == nil) {
        [AKSMethods showMessage:[NSMutableString stringWithFormat:@"please enter %@ name", identifier]];
        return FALSE;
    }

    if (name.length == 0) {
        [AKSMethods showMessage:[NSMutableString stringWithFormat:@"please enter %@ name", identifier]];
        return FALSE;
    }


    NSString *nameRegex = @"[a-zA-Z0-9_. ]+$";
    NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];

    if (![nameTest evaluateWithObject:name]) {
        [AKSMethods showMessage:[NSMutableString stringWithFormat:@"please enter valid %@ name", identifier]];
        return FALSE;
    } else return TRUE;

    TCEND
}

+ (BOOL)validatePhoneNumberWithString:(NSString *)number WithIdentifier:(NSString *)identifier {
    TCSTART

    if (number == nil) {
        [AKSMethods showMessage:[NSMutableString stringWithFormat:@"please enter %@ phone number", identifier]];
        return FALSE;
    }

    if (number.length == 0) {
        [AKSMethods showMessage:[NSMutableString stringWithFormat:@"please enter %@ phone number", identifier]];
        return FALSE;
    }

    if (number.length > 24) {
        [AKSMethods showMessage:[NSMutableString stringWithFormat:@"please enter valid %@ phone number", identifier]];
        return FALSE;
    }

    NSString *numberRegex = @"[0-9]+$";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];

    if (![numberTest evaluateWithObject:number]) {
        [AKSMethods showMessage:[NSMutableString stringWithFormat:@"please enter valid %@ phone number", identifier]];
        return FALSE;
    } else return TRUE;

    TCEND
}

+ (NSString *)limitThis:(NSString *)string ForLengthUpto:(int)maxLength {
    if (string && string.length > maxLength) return [NSString stringWithFormat:@"%@...", [string substringToIndex:maxLength - 4]];
    return string;
}

+ (UIImage *)compressThisImage:(UIImage *)image {
    int width = image.size.width / 4;
    int height = image.size.height / 4;

    if (width < 320) width = 320;
    if (height < 480) height = 480;

    UIImage *compressed = [[UIImage imageWithData:UIImageJPEGRepresentation(image, 0)] scaleToSize:CGSizeMake(width, height)];
    if (compressed) return compressed; else return image;
}

+ (NSURL *)smartURLForString:(NSString *)str {
    NSURL *result;
    NSString *trimmedStr;
    NSRange schemeMarkerRange;
    NSString *scheme;

    assert(str != nil);

    result = nil;

    trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (trimmedStr != nil) && (trimmedStr.length != 0) ) {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];

        if (schemeMarkerRange.location == NSNotFound) {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", trimmedStr]];
        } else {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);

            if ( ([scheme compare:@"http"  options:NSCaseInsensitiveSearch] == NSOrderedSame)
				|| ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                result = [NSURL URLWithString:trimmedStr];
            } else {
                // It looks like this is some unsupported URL scheme.
            }
        }
    }

    return result;
}

+ (NSMutableString *)namedFormatForDate:(NSDate *)date {
    TCSTART

    NSDateFormatter *FormatDate = [[NSDateFormatter alloc] init];

    [FormatDate setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"]];

    [FormatDate setDateFormat:@"EE, d MMM yy"];

    NSMutableString *date_ = [NSMutableString stringWithString:[FormatDate stringFromDate:date]];

    if (date_) return date_;
    else return [NSMutableString stringWithString:@""];

    TCEND
}

+ (void)highlightAllLabelsOfThisView:(UIView *)view {
    NSArray *subviews = [view subviews];
    for (int i = 0; i < subviews.count; i++) {
        if ([[subviews objectAtIndex:i] isKindOfClass:[UILabel class]]) [((UILabel *)[subviews objectAtIndex:i])setBackgroundColor :[UIColor lightGrayColor]];
    }
}

+ (NSString *)StringWithAlphaNumericCharacters:(NSString *)string {
    return [[string componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet]invertedSet]]
            componentsJoinedByString:@" "];
}

+ (void)showThisAlertViewByWorkAroundForParallelButtons:(UIAlertView *)alertView {
    [alertView addButtonWithTitle:@"Fake"];

    for (int i = 0; i < alertView.subviews.count; i++) {
        if ([[AKSMethods getClassNameForObject:[alertView.subviews objectAtIndex:i]] isEqualToString:@"UIAlertButton"]) {
            if ([((UIButton *)[alertView.subviews objectAtIndex:i]).titleLabel.text isEqualToString : @"Fake"]) {
                [((UIButton *)[alertView.subviews objectAtIndex:i])setHidden : TRUE];
            }
        }
    }

    [alertView show];
}

+ (void)syncroniseNSUserDefaults {
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (void)customizeThisButton:(UIButton *)button Withtext:(NSString *)title {
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateHighlighted];

    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];

    // Set default backgrond color
    [button setBackgroundColor:IOS_STANDARD_COLOR_BLUE];

    // Add Custom Font
    [[button titleLabel] setFont:[UIFont systemFontOfSize:button.frame.size.height / 2]];

    // Round button corners
    CALayer *buttonLayer = [button layer];
    [buttonLayer setMasksToBounds:YES];
    [buttonLayer setCornerRadius:3.0f];
    [[button layer] setMasksToBounds:YES];
}

+ (void)customizeThisButton:(UIButton *)button WithImage:(NSString *)imageName {
    if (imageName) [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];

    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

    // Set default backgrond color
    [button setBackgroundColor:[UIColor blackColor]];

    // Add Custom Font
    [[button titleLabel] setFont:[UIFont fontWithName:FONT_REGULAR size:button.frame.size.height / 3]];

    // Draw a custom gradient
    CAGradientLayer *buttonGradient = [CAGradientLayer layer];
    buttonGradient.frame = button.bounds;
    buttonGradient.colors = [NSArray arrayWithObjects:
                             (id)[[UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f] CGColor],
                             (id)[[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f] CGColor],
                             nil];
    [button.layer insertSublayer:buttonGradient atIndex:0];

    // Round button corners
    CALayer *buttonLayer = [button layer];
    [buttonLayer setMasksToBounds:YES];
    [buttonLayer setCornerRadius:5.0f];

    // Apply a 1 pixel, black border around Buy Button
    [buttonLayer setBorderWidth:1.0f];
    [buttonLayer setBorderColor:[[UIColor blackColor] CGColor]];
    [[button layer] setMasksToBounds:YES];
}

+ (void)customizeThisTextField:(UITextField *)textField {
    textField.backgroundColor = [UIColor whiteColor];
    textField.textColor = [UIColor blackColor];
    [textField setFont:[UIFont fontWithName:FONT_REGULAR size:textField.frame.size.height - 2]];
    [textField setTextAlignment:UITextAlignmentLeft];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.layer.cornerRadius = 3;
    textField.layer.borderWidth = 1;
}

+ (void)customizeThisLabel:(UILabel *)label {
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor blackColor];
    [label setFont:[UIFont fontWithName:FONT_REGULAR size:label.frame.size.height - 2]];
    [label setTextAlignment:UITextAlignmentLeft];
}

#pragma mark - Methods for Showing and Handling WebView

- (void)showWebViewWithUrl:(NSURL *)url FromViewController:(UIViewController *)viewController {
    webViewHolderView = [[UIView alloc]initWithFrame:viewController.view.frame];
    [webViewHolderView setBackgroundColor:[UIColor clearColor]];



    UIView *viewForFadeEffect = [[UIView alloc]initWithFrame:viewController.view.frame];
    [viewForFadeEffect setBackgroundColor:[UIColor blackColor]];
    viewForFadeEffect.layer.opacity = 0.7;




    UIButton *closeButton = [[UIButton alloc]init];
    [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(onClickOfWebViewCloseButton) forControlEvents:UIControlEventTouchUpInside];
    closeButton.layer.borderWidth = 2;
    closeButton.layer.masksToBounds = TRUE;
    closeButton.layer.cornerRadius  = 2;
    closeButton.layer.borderColor = [UIColor whiteColor].CGColor;





    CGRect webViewRect;

    if (IsiPhone3p5Inch) webViewRect = CGRectInset([[UIScreen mainScreen] bounds], 15, 53);
    else if (IsiPhone4Inch) webViewRect = CGRectInset([[UIScreen mainScreen] bounds], 15, 65);
    else if (IsiPad) webViewRect = CGRectInset([[UIScreen mainScreen] bounds], 90, 128);

    UIWebView *webView = [[UIWebView alloc]initWithFrame:webViewRect];
    [webView setDelegate:self];
    [webView loadRequest:[[NSURLRequest alloc]initWithURL:url]];
    [webView setBackgroundColor:[UIColor whiteColor]];
    webView.layer.borderColor = IOS_STANDARD_COLOR_BLUE.CGColor;
    webView.layer.borderWidth = 2;
    webView.layer.masksToBounds = TRUE;
    webView.layer.cornerRadius  = 4;
    [webView setScalesPageToFit:YES];





    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    [activity startAnimating];
    [activity setCenter:[AKSMethods centerForRect:CGRectMake(0, 0, webView.frame.size.width, webView.frame.size.height)]];
    [activity setTag:10];
    [webView addSubview:activity];


    [closeButton setFrame:CGRectMake(webViewRect.origin.x + 2, webViewRect.origin.y + 2, 22, 22)];


    [webViewHolderView addSubview:viewForFadeEffect];
    [webViewHolderView addSubview:webView];
    [webViewHolderView addSubview:closeButton];
    [viewController.view addSubview:webViewHolderView];

    [[AksAnimations sharedAksAnimations]fadeInThisView:[[NSArray alloc]initWithObjects:webViewHolderView, nil] duration:0.75];
}

- (void)onClickOfWebViewCloseButton {
    [[AksAnimations sharedAksAnimations]fadeOutThisView:[[NSArray alloc]initWithObjects:webViewHolderView, nil] duration:0.5];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [webViewHolderView removeFromSuperview];
        webViewHolderView = nil;
    });
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([webView viewWithTag:10]) [[webView viewWithTag:10] removeFromSuperview];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([webView viewWithTag:10]) [[webView viewWithTag:10] removeFromSuperview];
}

+ (UIImage *)getfirstFrameForVideo:(NSString *)filePath {
    return [[[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:filePath]] thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
}

+ (UIView *)getCapturedImageAsView {
    UIView *mainView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];

    UIImageView *imageView  = [[UIImageView alloc]initWithImage:[AKSMethods getScreenCapture]];
    [imageView setFrame:[[UIScreen mainScreen]bounds]];
    [mainView addSubview:imageView];

    UIView *blackTranslucentView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    [blackTranslucentView setBackgroundColor:[UIColor blackColor]];
    [blackTranslucentView setOpaque:NO];
    [blackTranslucentView.layer setOpacity:0.5];
    [mainView addSubview:blackTranslucentView];

    return mainView;
}

+ (UIImage *)getScreenCapture {
    UIImage *image = nil;
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContextWithOptions([keyWindow bounds].size, NO, 0.0);
    [keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Methods to perform animation with splash screen

+ (void)performSplashScreenAnimation:(UIView *)applicationMainWindow {
    UIView *fakeSplashScreenView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
    [fakeSplashScreenView setFrame:applicationMainWindow.bounds];
    [applicationMainWindow addSubview:fakeSplashScreenView];
    [applicationMainWindow bringSubviewToFront:fakeSplashScreenView];

    [UIView beginAnimations:@"CWFadeIn" context:(void *)fakeSplashScreenView];
    [UIView setAnimationDelegate:[AKSMethods sharedAKSMethods]];
    [UIView setAnimationDidStopSelector:
     @selector(animationDidStop:finished:context:)];
    [UIView setAnimationDuration:1.0f];
    fakeSplashScreenView.alpha = 0;
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [(__bridge UIView *)context removeFromSuperview];
}

+ (void)convertCafToMp3WithSourceFilePath:(NSString *)sourceFilePath WithDestinationFilePath:(NSString *)destinationFilePath {
    FILE *pcm = fopen([sourceFilePath cStringUsingEncoding:NSUTF8StringEncoding],"rb");
    FILE *mp3 = fopen([destinationFilePath cStringUsingEncoding:NSUTF8StringEncoding],"wb");
    const int PCM_SIZE = 8192;
    const int MP3_SIZE = 8192;

    short int pcm_buffer[PCM_SIZE * 2];
    unsigned char mp3_buffer[MP3_SIZE];

    lame_t lame = lame_init();
    lame_set_in_samplerate(lame, 44100);
    lame_init_params(lame);

    do {
        size_t read = fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
        if (read == 0) fwrite(mp3_buffer, lame_encode_flush(lame, mp3_buffer, MP3_SIZE), 1, mp3);
        else fwrite(mp3_buffer, lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE), 1, mp3);
    } while (read != 0);

    lame_close(lame);
    fclose(mp3);
    fclose(pcm);
}

@end