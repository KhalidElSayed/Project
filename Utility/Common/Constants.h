//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//


/**
 Constants:-

 This header file holds all configurable constants specific  to this application.

 */


/*
 Flurry Product Api Key
 */
#define FlurryProductApiKey                               @"FLURRY API KEY"


/**
 In App purchase related
 */
#define ACTION_SHEET_TAG_INAPP_PURCHASE                   10
#define RECEIPT_FOR_LAST_PURCHASE                         @"ReceiptLastPurchase"
#define PRODUCT_IDENTIFIER_FOR_LAST_PURCHASE              @"ProductIdentifierLastPurchase"

/**
 return if no internet connection is available with and without error message
 */
#define RETURN_IF_NO_INTERNET_AVAILABLE_WITH_USER_WARNING if (![APPDELEGATE getStatusForNetworkConnectionAndShowUnavailabilityMessage:YES]) return;
#define RETURN_IF_NO_INTERNET_AVAILABLE                   if (![APPDELEGATE getStatusForNetworkConnectionAndShowUnavailabilityMessage:NO]) return;

/**
 get status of internet connection
 */
#define IS_INTERNET_AVAILABLE_WITH_USER_WARNING           [APPDELEGATE getStatusForNetworkConnectionAndShowUnavailabilityMessage:YES]
#define IS_INTERNET_AVAILABLE                             [APPDELEGATE getStatusForNetworkConnectionAndShowUnavailabilityMessage:NO]
