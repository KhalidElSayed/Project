//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedItemServices.h"
#import <MessageUI/MessageUI.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import <StoreKit/StoreKit.h>
#import "Download.h"
#import "DownloadManager.h"
#import "Upload.h"
#import "UploadManager.h"
#import "TSMessage.h"
#import "PayPalMobile.h"


/**
 Google Plus
 */
#import "GPPDeepLink.h"

/**

 AppDelegate:-

 Application delegate class

 */



@interface AppDelegate : UIResponder
<
  UIApplicationDelegate
, MFMailComposeViewControllerDelegate
, SKProductsRequestDelegate
, SKPaymentTransactionObserver
, SKRequestDelegate
, UIActionSheetDelegate
, DownloadManagerDelegate
, UploadManagerDelegate
, GPPDeepLinkDelegate
, PayPalPaymentDelegate
>
{	
    /**
     alert view object : it is used to show network un reachability message
     */
    UIAlertView *alertViewObject;

    /**
     navigation controller for the application
     */
    UINavigationController *navigationController;


    /**
     view controller responsible for showing required interface for sharing on facebook and twitter.
     */
    SLComposeViewController *mySLComposerSheet;

    /**
     productsRequest is responsible for requesting information about products for this application.
     */
    SKProductsRequest *productsRequest;

    /**
     validProductIdentifiers holds all validSKProducts.
     */
    NSArray *validSKProducts;

    /**
     bool to decide wether in app purchase request is in prosessing or not
     */
    BOOL isPurchasingNow;

    /**
     bool to decide wether application is showing purchase dailog or not
     */
    BOOL isShowingPurchaseDailog;
}



/**
 main window object
 */
@property (strong, nonatomic) UIWindow *window;

/**
 navigation controller for the application
 */
@property (strong, nonatomic) UINavigationController *navigationController;

/**
 bool to decide wether application is showing purchase dailog or not
 */
@property (nonatomic, readwrite) BOOL isShowingPurchaseDailog;






/**
 common method for playing video from throughout the application
 */

- (void)playVideo:(NSString *)url fromViewController:(UIViewController *)viewController;

/**
 common method to load purchase options
 */
- (void)loadPurchaseOptions;

/**
 method to check network reachability status and show proper alert message if required
 */
- (BOOL)getStatusForNetworkConnectionAndShowUnavailabilityMessage:(BOOL)showMessage;

/**
 common method to show mbprogresshud with custom text
 */
- (void)showActivityIndicatorWithText:(NSString *)text;

/**
 remove the mbprogresshud
 */
- (void)removeActivityIndicator;

/**
 method to change the background image of navigation bar
 */
- (void)setNavigationBarBackgroundImage:(NSString *)imageName;


/**
 method to change the background image of navigation bar
 */
- (void)setNavigationBarTitleImage:(NSString *)imageName WithViewController:(UIViewController *)caller;

/**
 common method for sharing on facebook
 */
- (void)shareViaFacebook:(NSMutableDictionary *)params;

/**
 common method for tweeting on twitter
 */
- (void)postToTwitter:(NSMutableDictionary *)params;

/**
 common method for send email
 */
- (void)emailInfo:(NSMutableDictionary *)info;

/**
 common method to clear unnecessary memory used in the application.

 it should be called whenever application receives a memory warning
 */
- (void)clearApplicationCaches;

/**
 common method to add navigation bar buttons
 */
- (void)addLeftNavigationBarButton:(UIViewController *)caller withImageName:(NSString *)imageName;
- (void)addRightNavigationBarButton:(UIViewController *)caller withImageName:(NSString *)imageName;

/**
 common method report events to flurry
 */
- (void)reportEventToFlurry:(NSString *)eventName withParameters:(NSMutableDictionary *)parameters;


/**
 common method to login via socials
 */
-(void)loginViaFacebook:(id)sender;
-(void)loginViaTwitter:(id)sender;
-(void)loginViaGooglePlus:(id)sender;
-(void)loginViaFourSquare:(id)sender;



/**
 common method to show toast messages to user
 */
- (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type
                            withDuration:(NSTimeInterval)duration;


-(void)showImageInFullScreen:(UIImageView*)imageView;


/**
 common method for paypal integration
 */
-(void)doPaypalWithPlayerId:(NSString*)playerId WithEmailAddress:(NSString*)email WithMoney:(NSString*)money WithCurrrencyCode:(NSString*)currency WithDescription:(NSString*)description;
-(void)verifyCompletedPayment:(PayPalPayment *)completedPayment;

@end
