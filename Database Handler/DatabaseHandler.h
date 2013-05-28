//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "sqlite3.h"


@interface DatabaseHandler : NSObject
{
    sqlite3 *database;
    BOOL isDatabaseOpen;
}
@property BOOL isDatabaseOpen;

+ (DatabaseHandler *)sharedObject;

@end
