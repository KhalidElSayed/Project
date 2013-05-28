//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import "AppDelegate.h"
#import "DCIntrospect.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "UIDevice+IdentifierAddition.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "Base64Converter.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "Flurry.h"
#import "VideoPlayerView.h"
#import "SBJson.h"
#import "LoginViaSocials.h"
#import "TSMessage.h"
#import "DatabaseHandler.h"
#import "GGFullScreenImageViewController.h"
#import "CJPAdController.h"
#import "TemplateViewController.h"
#import "SDURLCache.h"


#if DEBUG
#import "UIApplication+SimulatorRemoteNotifications.h"
#endif

/**
 Facebook
 */
NSString *const FBSessionStateChangedNotification = @"com.example.Login:FBSessionStateChangedNotification";


/**
 Google Plus
 */
#import "GPPSignIn.h"
#import "GPPURLHandler.h"
#import "GPPDeepLink.h"


@implementation AppDelegate

@synthesize navigationController;
@synthesize isShowingPurchaseDailog;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self setupSDURLCache];
    [self prepareForApplePushNotificationsService];
    [self initializeContents];
    [self initializeWindowAndStartUpViewController];
    [self setUpInAppPurchase];
    [self handleReceivedRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    [self setupFlurry];
    [self setupDCIntrospect];
    [self initializeGooglePlus];
    return YES;
}

#pragma mark - Methods for initialising basic contents

- (void)initializeContents {
    TCSTART

    [DatabaseHandler sharedObject];
    isPurchasingNow = FALSE;

    TCEND
}

#pragma mark - NSURLConnection related setup

- (void)setupSDURLCache {
	SDURLCache *urlCache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024*2 // 1 MB mem cache
														 diskCapacity:1024*1024*5 // 5 MB disk cache
															 diskPath:[SDURLCache defaultCachePath] enableForIOS5AndUp:YES];
	urlCache.ignoreMemoryOnlyStoragePolicy = YES;
	[NSURLCache setSharedURLCache:urlCache];
}

#pragma mark - Methods for initialising window and startup view controllers

- (void)initializeWindowAndStartUpViewController {
    TCSTART

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
	
    navigationController = [[UINavigationController alloc]init];

    [self.navigationController pushViewController:[[TemplateViewController alloc]initWithNibName:@"TemplateViewController" bundle:nil] animated:NO];


#define use_iAds 1

#if use_iAds

    [self.window setRootViewController:[[CJPAdController sharedManager] initWithContentViewController:self.navigationController]];

#else

    [self.window setRootViewController:navigationController];

#endif

    [self.window makeKeyAndVisible];

	[AKSMethods performSplashScreenAnimation:self.window];

    TCEND
}

#pragma mark - common method to show toast messages

- (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type
                            withDuration:(NSTimeInterval)duration {
    [TSMessage showNotificationInViewController:viewController
                                      withTitle:title
                                    withMessage:message
                                       withType:type
                                   withDuration:duration];
}

#pragma mark - setup DCIntrospect

- (void)setupDCIntrospect {
    UITapGestureRecognizer *defaultGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    defaultGestureRecognizer.cancelsTouchesInView = NO;
    defaultGestureRecognizer.delaysTouchesBegan = NO;
    defaultGestureRecognizer.delaysTouchesEnded = NO;
    defaultGestureRecognizer.numberOfTapsRequired = 3;
    defaultGestureRecognizer.numberOfTouchesRequired = 2;
    [DCIntrospect sharedIntrospector].invokeGestureRecognizer = defaultGestureRecognizer;
}

#pragma mark - setup Flurry

- (void)setupFlurry {
    [Flurry setAppVersion:CURRENT_DEVICE_VERSION_STRING];
    [Flurry setUserID:[[NSUserDefaults standardUserDefaults]objectForKey:@"UDID"]];
    [Flurry setEventLoggingEnabled:TRUE];
    [Flurry setShowErrorInLogEnabled:TRUE];
    [Flurry setSessionReportsOnCloseEnabled:TRUE];
    [Flurry setSessionReportsOnPauseEnabled:TRUE];
    [Flurry setSecureTransportEnabled:FALSE];
    [Flurry startSession:FlurryProductApiKey];
}

#pragma mark - InAppPurchase SetUp Methods

- (void)setUpInAppPurchase {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

#pragma mark - InAppPurchase Purchase Options Related Methods

- (void)performInAppRestoreOperation {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)loadPurchaseOptions {
    TCSTART

	RETURN_IF_NO_INTERNET_AVAILABLE_WITH_USER_WARNING

    [self loadPurchaseOptionsToUser];


    TCEND
}

- (void)loadPurchaseOptionsToUser {
    NSMutableArray *productsIdentifiers_ = [[NSMutableArray alloc]init];

    {
        //you need to add product identifiers here
    }

    NSSet *ProductIdentifiers_ = [[NSSet alloc]initWithArray:productsIdentifiers_];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:ProductIdentifiers_];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)showViewForPurchaseOptions {
    isShowingPurchaseDailog = TRUE;

    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Purchase Options"
								  delegate:self
								  cancelButtonTitle:@"Cancel"
								  destructiveButtonTitle:nil
								  otherButtonTitles:nil];

    for (int i =  0; i < validSKProducts.count; i++) {
        if ([[validSKProducts objectAtIndex:i] isKindOfClass:[SKProduct class]]) {
            SKProduct *product  = [validSKProducts objectAtIndex:i];
            [actionSheet addButtonWithTitle:product.localizedTitle];
        }
    }

    [actionSheet addButtonWithTitle:@"Restore"];
    [actionSheet setTag:ACTION_SHEET_TAG_INAPP_PURCHASE];
    [actionSheet showInView:self.navigationController.view];
}

#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    [self removeActivityIndicator];

    validSKProducts = [response products];
    if ([validSKProducts count] > 0) [self showViewForPurchaseOptions];
}

#pragma mark - UIActionSheet Delegate Method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    TCSTART

    if (actionSheet.tag == ACTION_SHEET_TAG_INAPP_PURCHASE && buttonIndex > 0) {
        RETURN_IF_NO_INTERNET_AVAILABLE_WITH_USER_WARNING

        if ([[[SKPaymentQueue defaultQueue] transactions]count] > 0) {
            [AKSMethods showMessage:@"Server busy. Please try again later"];
            return;
        }

        int optionIndex = buttonIndex - 1;

        if (optionIndex <= validSKProducts.count - 1) {
            if ([[validSKProducts objectAtIndex:optionIndex] isKindOfClass:[SKProduct class]]) {
                SKProduct *product_ = [validSKProducts objectAtIndex:optionIndex];
                SKPayment *payment = [SKPayment paymentWithProduct:product_];
                [[SKPaymentQueue defaultQueue] addPayment:payment];
            }
        } else if (optionIndex == validSKProducts.count) {
            [self performInAppRestoreOperation];
        }

        isShowingPurchaseDailog = FALSE;
    }

    TCEND
}

#pragma mark - Apple Push Notifications Service Methods

- (void)prepareForApplePushNotificationsService {

#if DEBUG
	[[UIApplication sharedApplication] listenForRemoteNotifications];
#endif

    CLEAR_NOTIFICATION_BADGE

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes :
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceTokenPushNotification = [self stringWithDeviceToken:deviceToken];

    if ([self isNotNull:deviceTokenPushNotification]) {
        [[NSUserDefaults standardUserDefaults]setObject:deviceTokenPushNotification forKey:@"DeviceToken"];
        [self updateDeviceTokenToApplicationServerForAPNS];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [AKSMethods printErrorMessage:error showit:NO];
}

- (NSString *)stringWithDeviceToken:(NSData *)deviceToken {
    const char *data = [deviceToken bytes];

    NSMutableString *token = [NSMutableString string];

    for (int i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }

    return token;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	[AKSMethods printDictionary:userInfo];
}

- (void)handleReceivedRemoteNotification:(NSDictionary *)userInfo {
    [AKSMethods printDictionary:userInfo];

    if ([self isNotNull:userInfo]) {
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) { // app was already in the foreground
        } else { // app was not in foreground
        }
    }
}

#pragma mark - Methods to send or update device token to server

- (void)updateDeviceTokenToApplicationServerForAPNS {
    if (IS_INTERNET_AVAILABLE && [self isNotNull:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"]]) {
    }
}

#pragma mark - InAppPurchase Transaction Related Methods

- (void)provideContent:(NSString *)productId {
}

// removes the transaction from the queue and posts a notification with the transaction result
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

// called when the transaction was successful
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    TCSTART

    [self provideContent : transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
    [Base64Converter initialize];

    NSString *receiptStr = [Base64Converter encode:transaction.transactionReceipt];
    NSString *productIdentifier = transaction.payment.productIdentifier;

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:receiptStr forKey:RECEIPT_FOR_LAST_PURCHASE];
    [standardUserDefaults setObject:productIdentifier forKey:PRODUCT_IDENTIFIER_FOR_LAST_PURCHASE];

    [AKSMethods syncroniseNSUserDefaults];



    //HERE WE HAVE TO MAKE REQUEST TO SERVER THAT BILLING FOR PARTICULAR PRODUCT HAS COMPLETED SUCCESSFULLY AND NOW THE SAME SERVER SHOULD MAINTAIN IN DATABASE

    TCEND
}

// called when a transaction has failed
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled) [self finishTransaction:transaction wasSuccessful:NO];
    else [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

// called when the transaction status is updated
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    for (SKPaymentTransaction *transaction in queue.transactions) {
        NSLog(@"resored product identifier %@", transaction.payment.productIdentifier);
    }
}

#pragma mark - Application Life Cycle Methods

- (void)applicationWillResignActive:(UIApplication *)application {
    [AKSMethods syncroniseNSUserDefaults];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [AKSMethods syncroniseNSUserDefaults];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSession.activeSession handleDidBecomeActive];
    CLEAR_NOTIFICATION_BADGE
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [FBSession.activeSession close];
}

#pragma mark - common method for playing video from throughout the application

- (void)playVideo:(NSString *)url fromViewController:(UIViewController *)viewController {
    if (!(url && url.length > 0 && viewController)) return;

    if (![[NSFileManager defaultManager] fileExistsAtPath:url]) return;

    VideoPlayerView *videoPlayView = [[VideoPlayerView alloc]initWithNibName:nil bundle:nil];
    videoPlayView.videoUrl = [NSURL fileURLWithPath:url];
    [viewController presentModalViewController:videoPlayView animated:YES];
}

#pragma mark - common method for setting navigation bar background image

- (void)setNavigationBarBackgroundImage:(NSString *)imageName {
    if ([self isNotNull:imageName] && [navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:[CommonFunctions getImageNameForName:imageName]]
                                                 forBarMetrics:UIBarMetricsDefault];
    }
}

#pragma mark - common method for setting navigation bar  title image view

- (void)setNavigationBarTitleImage:(NSString *)imageName WithViewController:(UIViewController *)caller {
    UIImage *imageToUse =   [UIImage imageNamed:[CommonFunctions getImageNameForName:imageName]];
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, imageToUse.size.width, imageToUse.size.height)];
    [AKSMethods print:titleView.frame];
    [titleView setImage:imageToUse];
    [caller.navigationItem setTitleView:titleView];
}

#pragma mark - Common method to add navigation bar buttons

/**
 common method to add navigation bar buttons
 */
- (void)addLeftNavigationBarButton:(UIViewController *)caller withImageName:(NSString *)imageName {
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarButton setImage:[UIImage imageNamed:[CommonFunctions getImageNameForName:imageName]] forState:UIControlStateNormal];
    [leftBarButton setImage:[UIImage imageNamed:[CommonFunctions getImageNameForName:[NSString stringWithFormat:@"%@_hover", imageName]]] forState:UIControlStateHighlighted];
    [leftBarButton setFrame:CGRectMake(0.0f, 0.0f, leftBarButton.imageView.image.size.width, NAVIGATION_BAR_HEIGHT)];

    if ([caller respondsToSelector:@selector(onClickOfLeftNavigationBarButton:)]) [leftBarButton addTarget:caller action:@selector(onClickOfLeftNavigationBarButton:) forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfLeftNavigationBarButton method\n", [AKSMethods getClassNameForObject:caller]);
    }

    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
									   target:nil action:nil];
    if (IsiPhone3p5Inch) {
        negativeSpacer.width = -5;
    } else if (IsiPhone4Inch) {
        negativeSpacer.width = -5;
    } else if (IsiPad) {
        negativeSpacer.width = -10;
    }

    caller.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, [[UIBarButtonItem alloc] initWithCustomView:leftBarButton], nil];
}

- (void)addRightNavigationBarButton:(UIViewController *)caller withImageName:(NSString *)imageName {
    UIButton *rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarButton setImage:[UIImage imageNamed:[CommonFunctions getImageNameForName:imageName]] forState:UIControlStateNormal];
    [rightBarButton setImage:[UIImage imageNamed:[CommonFunctions getImageNameForName:[NSString stringWithFormat:@"%@_hover", imageName]]] forState:UIControlStateHighlighted];
    [rightBarButton setFrame:CGRectMake(0.0f, 0.0f, rightBarButton.imageView.image.size.width, NAVIGATION_BAR_HEIGHT)];

    if ([caller respondsToSelector:@selector(onClickOfRightNavigationBarButton:)]) [rightBarButton addTarget:caller action:@selector(onClickOfRightNavigationBarButton:) forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfRightNavigationBarButton method\n", [AKSMethods getClassNameForObject:caller]);
    }

    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
									   target:nil action:nil];
    if (IsiPhone3p5Inch) {
        negativeSpacer.width = -5;
    } else if (IsiPhone4Inch) {
        negativeSpacer.width = -5;
    } else if (IsiPad) {
        negativeSpacer.width = -10;
    }

    caller.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, [[UIBarButtonItem alloc] initWithCustomView:rightBarButton], nil];
}

#pragma mark - common method for showing MBProgressHUD Activity Indicator

/*!
 @function	showActivityIndicatorWithText
 @abstract	shows the MBProgressHUD with custom text for information to user.
 @discussion
 MBProgressHUD will be added to window . hence complete ui will be blocked from any user interaction.
 @param	text
 the text which will be shown while showing progress
 */

- (void)showActivityIndicatorWithText:(NSString *)text {
    TCSTART

    [self removeActivityIndicator];

    MBProgressHUD *hud   = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.labelText        = text;
    hud.detailsLabelText = NSLocalizedString(@"Please Wait...", @"");

    TCEND
}

/*!
 @function	removeActivityIndicator
 @abstract	removes the MBProgressHUD (if any) from window.
 */

- (void)removeActivityIndicator {
    TCSTART

    [MBProgressHUD hideHUDForView : self.window animated : YES];

    TCEND
}

#pragma mark - common method for Internet reachability checking

/*!
 @function	getStatusForNetworkConnectionAndShowUnavailabilityMessage
 @abstract	get internet reachability status and optionally can show network unavailability message.
 @param	showMessage
 to decide whether to show network unreachability message.
 */

- (BOOL)getStatusForNetworkConnectionAndShowUnavailabilityMessage:(BOOL)showMessage {
    TCSTART

    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        if (showMessage == NO) return NO;

        if ([self isNotNull:alertViewObject]) {
            [NSTimer scheduledTimerWithTimeInterval:AUTO_DISMISS_ALERT_TIMING
                                             target:self
                                           selector:@selector(autoDismissAlertView)
                                           userInfo:nil
                                            repeats:NO];

            return NO;
        }

        [NSTimer scheduledTimerWithTimeInterval:AUTO_DISMISS_ALERT_TIMING
                                         target:self
                                       selector:@selector(autoDismissAlertView)
                                       userInfo:nil
                                        repeats:NO];

        alertViewObject = [[UIAlertView alloc]
                           initWithTitle:nil
						   message:@"\n\nApplication requires an active internet connection . \n Please check your network settings and try again"
						   delegate:nil
						   cancelButtonTitle:nil otherButtonTitles:nil];
        [alertViewObject show];

        return NO;
    }

    TCEND

    return YES;
}

- (void)showAutoDismissAlertViewWithText:(NSString *)textMessage {
    if ([self isNotNull:alertViewObject]) [self autoDismissAlertView];

    [NSTimer scheduledTimerWithTimeInterval:AUTO_DISMISS_ALERT_TIMING
                                     target:self
                                   selector:@selector(autoDismissAlertView)
                                   userInfo:nil
                                    repeats:NO];

    alertViewObject = [[UIAlertView alloc]
                       initWithTitle:nil
					   message:[NSString stringWithFormat:@"\n\n%@\n", textMessage]
					   delegate:nil
					   cancelButtonTitle:nil otherButtonTitles:nil];
    [alertViewObject show];
}

- (void)autoDismissAlertView {
    if ([self isNotNull:alertViewObject]) {
        [alertViewObject dismissWithClickedButtonIndex:0 animated:NO];
        alertViewObject = nil;
    }
}

#pragma mark - Sharing Via Email Related Methods

- (void)emailInfo:(NSMutableDictionary *)info {
    TCSTART

    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Email Configuration"
							  message:@"We cannot send an email right now because your device's email account is not configured. Please configure an email account from your device's Settings, and try again."
							  delegate:nil
							  cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }

    MFMailComposeViewController *emailer = [[MFMailComposeViewController alloc] init];
    emailer.mailComposeDelegate = self;

    NSString *subject = [info objectForKey:@"subject"];
    NSString *matterText = [info objectForKey:@"matterText"];

    if ([self isNotNull:subject]) [emailer setSubject:subject];

    if ([self isNotNull:matterText]) [emailer setMessageBody:matterText isHTML:NO];

    NSMutableArray *attachments = [info objectForKey:@"attachments"];

    if ([self isNotNull:attachments]) {
        for (int i = 0; i < attachments.count; i++) {
            NSMutableDictionary *attachment = [attachments objectAtIndex:i];

            NSData *attachmentData = [attachment objectForKey:@"attachmentData"];
            NSString *attachmentFileName = [attachment objectForKey:@"attachmentFileName"];
            NSString *attachmentFileMimeType = [attachment objectForKey:@"attachmentFileMimeType"];

            [emailer addAttachmentData:attachmentData mimeType:attachmentFileMimeType fileName:attachmentFileName];
        }
    }

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        emailer.modalPresentationStyle = UIModalPresentationPageSheet;
    }

    [self.navigationController.topViewController presentViewController:emailer animated:YES completion:nil];

    TCEND
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultFailed) {
        [AKSMethods showMessage:@"Failed to send email. Please try again."];
    }

    [self.navigationController.topViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - FACEBOOK SDK + Sharing Related Methods

- (void)shareViaFacebook:(NSMutableDictionary *)params {
    [self postToFacebookORTwitter:params TforTwitterFforFacebook:FALSE];
}

#pragma mark - TWITTER SDK + Sharing Related Methods

- (void)postToTwitter:(NSMutableDictionary *)params {
    [self postToFacebookORTwitter:params TforTwitterFforFacebook:TRUE];
}

- (void)postToFacebookORTwitter:(NSMutableDictionary *)params TforTwitterFforFacebook:(BOOL)TforTwitterFforFacebook {
    TCSTART

    /**
	 params
	 ex:-
	 NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
	 @"https://developers.facebook.com/ios", @"link",
	 @"https://developers.twitter.com/attachment/iossdk_logo.png", @"picture",
	 @"hi this is a message",@"message",
	 nil];
     */

	RETURN_IF_NO_INTERNET_AVAILABLE_WITH_USER_WARNING

    if ([params objectForKey:@"picture"]) {
        [self showActivityIndicatorWithText:@""];

        __block UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo"]];
        __block BOOL isCompletedWithInFiveSeconds = FALSE;
        __block BOOL isNeedToCancelOperation = FALSE;

        isCompletedWithInFiveSeconds = FALSE;
        isNeedToCancelOperation = FALSE;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
					   {
						   if (isCompletedWithInFiveSeconds) return;

						   NSLog(@"image was not able to load. hence loading with default image");

						   isNeedToCancelOperation = TRUE;

						   SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:TforTwitterFforFacebook ? SLServiceTypeTwitter:SLServiceTypeFacebook];
						   if ([params objectForKey:@"message"]) [composeViewController setInitialText:[params objectForKey:@"message"]];
						   if (imageView.image) [composeViewController addImage:imageView.image];
						   if ([params objectForKey:@"link"]) [composeViewController addURL:[NSURL URLWithString:[params objectForKey:@"link"]]];
						   [self.navigationController.topViewController presentViewController:composeViewController animated:YES completion:nil];
						   [self removeActivityIndicator];
					   });

        [imageView setImageWithURL:[NSURL URLWithString:[params objectForKey:@"picture"]]
                  placeholderImage:[UIImage imageNamed:@"logo"]
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
		 {
			 if (isNeedToCancelOperation) return;

			 NSLog(@"image loaded successfully....");

			 isCompletedWithInFiveSeconds = TRUE;

			 SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:TforTwitterFforFacebook ? SLServiceTypeTwitter:SLServiceTypeFacebook];
			 if ([params objectForKey:@"message"]) [composeViewController setInitialText:[params objectForKey:@"message"]];
			 if (imageView.image) [composeViewController addImage:imageView.image];
			 if ([params objectForKey:@"link"]) [composeViewController addURL:[NSURL URLWithString:[params objectForKey:@"link"]]];
			 [self.navigationController.topViewController presentViewController:composeViewController animated:YES completion:nil];
			 [self removeActivityIndicator];
		 }];
    } else {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:TforTwitterFforFacebook ? SLServiceTypeTwitter:SLServiceTypeFacebook];

        if ([params objectForKey:@"message"]) [composeViewController setInitialText:[params objectForKey:@"message"]];

        if (TforTwitterFforFacebook == FALSE) [composeViewController addImage:[UIImage imageNamed:@"logo"]];

        if ([params objectForKey:@"link"]) [composeViewController addURL:[NSURL URLWithString:[params objectForKey:@"link"]]];

        [self.navigationController.topViewController presentViewController:composeViewController animated:YES completion:nil];
    }

    TCEND
}

#pragma mark - download manager delegate methods

- (void)downloadManager:(DownloadManager *)downloadManager didCancelDownload:(Download *)download {
    TCSTART

	TCEND
}

- (void)downloadManager:(DownloadManager *)downloadManager didFinishDownload:(Download *)download withData:(NSData *)data {
    TCSTART

    NSString *filePath = [NSString stringWithFormat:@"%@/%@.%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], download.mediaId, download.fileType];

    NSLog(@"file downloaded at path = %@", filePath);

    [data writeToFile:filePath atomically:YES];

    TCEND
}

#pragma mark - upload manager delegate methods

- (void)uploadManager:(UploadManager *)uploadManager didQueueUpload:(Upload *)upload {
    TCSTART

	TCEND
}

- (void)uploadManager:(UploadManager *)uploadManager didCancelUpload:(Upload *)upload {
    TCSTART


	TCEND
}

- (void)uploadManager:(UploadManager *)uploadManager didFinishUpload:(Upload *)upload withData:(NSData *)data {
    NSString *responseString = [[NSString alloc]initWithData:upload.serverResponseData encoding:NSUTF8StringEncoding];
    SBJsonParser *parser = [[SBJsonParser alloc]init];
    NSError *error;
    NSDictionary *responseDictionary = [parser objectWithString:responseString error:&error];
}

- (void)uploadManager:(UploadManager *)uploadManager didUpdateUpload:(Upload *)upload {
}

#pragma mark - Flurry Reporting Methods

- (void)reportEventToFlurry:(NSString *)eventName withParameters:(NSMutableDictionary *)parameters {
    TCSTART

    [Flurry logEvent : eventName withParameters : parameters];

    TCEND
}

#pragma mark---
#pragma mark---Google Plus Implementation


- (void)initializeGooglePlus {
    [GPPSignIn sharedInstance].clientID = @"763637970149.apps.googleusercontent.com";
    [GPPDeepLink setDelegate:self];
    [GPPDeepLink readDeepLinkAfterInstall];
}

#pragma mark---
#pragma mark---FaceBook Implementation

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen :
            if (!error) NSLog(@"User session found");
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }

    [[NSNotificationCenter defaultCenter]postNotificationName:FBSessionStateChangedNotification object:session];

    if (error) [[[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"email", @"user_likes", @"user_birthday", nil];
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
											 [self sessionStateChanged:session
																 state:state
																 error:error];
										 }];
}

- (void)didReceiveDeepLink:(GPPDeepLink *)deepLink {
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (FBSession.activeSession) [FBSession.activeSession handleOpenURL:url];
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

- (void)loginViaFacebook:(id)sender {
    [[LoginViaSocials sharedController] setDelegate:self];
    [[LoginViaSocials sharedController] loginViaFacebook];
}

- (void)loginViaTwitter:(id)sender {
    [[LoginViaSocials sharedController] setDelegate:self];
    [[LoginViaSocials sharedController] loginViaTwitter];
}

- (void)loginViaGooglePlus:(id)sender {
    [[LoginViaSocials sharedController] setDelegate:self];
    [[LoginViaSocials sharedController] loginViaGooglePlus];
}

- (void)loginViaFourSquare:(id)sender {
    [[LoginViaSocials sharedController] setDelegate:self];
    [[LoginViaSocials sharedController] loginViaFourSquare];
}

- (void)didFinishedLoginViaSocials:(NSMutableDictionary *)results {
    if ([[results objectForKey:@"LoginType"] isEqualToString:@"Facebook"]) {
        NSString *facebookId = [results valueForKey:@"id"];
        NSString *emailId    = [results valueForKey:@"email"];
        NSString *name       = [results valueForKey:@"name"];
        NSString *username   = [results valueForKey:@"username"];
        NSString *gender     = [results valueForKey:@"gender"];

        NSLog(@"facebookId :  %@", facebookId);
        NSLog(@"emailId    :  %@", emailId);
        NSLog(@"name       :  %@", name);
        NSLog(@"username   :  %@", username);
        NSLog(@"gender     :  %@", gender);
    } else if ([[results objectForKey:@"LoginType"] isEqualToString:@"GooglePlus"]) {
        NSString *googleID = [results valueForKey:@"googleID"];
        NSString *name     = [results valueForKey:@"name"];
        NSString *username = [results valueForKey:@"username"];
        NSString *emailId  = [results valueForKey:@"email"];
        NSString *gender   = [results valueForKey:@"gender"];

        NSLog(@"googleID          :  %@", googleID);
        NSLog(@"emailId           :  %@", emailId);
        NSLog(@"name              :  %@", name);
        NSLog(@"username          :  %@", username);
        NSLog(@"gender            :  %@", gender);
    } else if ([[results objectForKey:@"LoginType"] isEqualToString:@"Twitter"]) {
        NSString *twitterID       = [results valueForKey:@"id"];
        NSString *name            = [results valueForKey:@"name"];
        NSString *username        = [results valueForKey:@"screen_name"];
        NSString *emailId         = [results valueForKey:@"email"];
        NSString *gender          = [results valueForKey:@"gender"];
        NSString *location        = [results valueForKey:@"location"];
        NSString *profilePicUrl   = [results valueForKey:@"profile_image_url"];

        NSLog(@"twitterID         :  %@", twitterID);
        NSLog(@"emailId           :  %@", emailId);
        NSLog(@"name              :  %@", name);
        NSLog(@"username          :  %@", username);
        NSLog(@"gender            :  %@", gender);
        NSLog(@"location          :  %@", location);
        NSLog(@"profilePicUrl     :  %@", profilePicUrl);
    } else if ([[results objectForKey:@"LoginType"] isEqualToString:@"FourSquare"]) {
        NSString *fourSquareID = [results valueForKey:@"fourSquareID"];
        NSString *name         = [results valueForKey:@"name"];
        NSString *username     = [results valueForKey:@"username"];
        NSString *emailId      = [results valueForKey:@"email"];
        NSString *gender       = [results valueForKey:@"gender"];

        NSLog(@"fourSquareID      :  %@", fourSquareID);
        NSLog(@"emailId           :  %@", emailId);
        NSLog(@"name              :  %@", name);
        NSLog(@"username          :  %@", username);
        NSLog(@"gender            :  %@", gender);
    }
}

- (void)didFailLoginViaSocialsWithError {
    NSLog(@"Last Login Trail Failed");
}

#pragma mark - Show Image In Full Screen

- (void)showImageInFullScreen:(UIImageView *)imageView {
    GGFullscreenImageViewController *fullscreenImageViewController_ = [[GGFullscreenImageViewController alloc] init];
    fullscreenImageViewController_.liftedImageView = imageView;
    [self.navigationController.topViewController presentViewController:fullscreenImageViewController_ animated:YES completion:nil];
}


#pragma mark - common method for paypal integration

#warning "Enter your credentials"
#define kPayPalClientId @"YOUR CLIENT ID HERE"
#define kPayPalReceiverEmail @"YOUR_PAYPAL_EMAIL@yourdomain.com"

-(void)doPaypalWithPlayerId:(NSString*)playerId WithEmailAddress:(NSString*)email WithMoney:(NSString*)money WithCurrrencyCode:(NSString*)currency WithDescription:(NSString*)description
{
	TCSTART
	
	PayPalPayment *payment = [[PayPalPayment alloc] init];
	payment.amount = [[NSDecimalNumber alloc] initWithString:money];
	payment.currencyCode = currency;
	payment.shortDescription = description;
	/**
	 PayPalEnvironmentProduction;
	 PayPalEnvironmentSandbox;
	 PayPalEnvironmentNoNetwork;
	 */
	[PayPalPaymentViewController setEnvironment:PayPalEnvironmentNoNetwork];
	PayPalPaymentViewController * payPalPaymentViewController = [[PayPalPaymentViewController alloc] initWithClientId:kPayPalClientId receiverEmail:kPayPalReceiverEmail payerId:playerId payment:payment delegate:self];
	[self.navigationController.topViewController presentViewController:payPalPaymentViewController animated:YES completion:nil];

	TCEND
}

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
	NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
}

- (void)verifyCompletedPayment:(PayPalPayment *)completedPayment {
	NSData *confirmation = [NSJSONSerialization dataWithJSONObject:completedPayment.confirmation
														   options:0
															 error:nil];
	// Send confirmation to your server; your server should verify the proof of payment
	// and give the user their goods or services. If the server is not reachable, save
	// the confirmation and try again later.
}

#pragma mark - PayPalPaymentDelegate methods

- (void)payPalPaymentDidComplete:(PayPalPayment *)completedPayment {
	NSLog(@"PayPal Payment Success!");
	[self sendCompletedPaymentToServer:completedPayment];
	[self.navigationController.topViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel {
	NSLog(@"PayPal Payment Canceled");
	[self.navigationController.topViewController dismissViewControllerAnimated:YES completion:nil];
}





#pragma mark - Memory management methods

- (void)clearApplicationCaches {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] cleanDisk];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [self clearApplicationCaches];
}

@end
