//
//  FMDBDataAccess.m
//  Chanda
//
//  Created by Mohammad Azam on 10/25/11.
//  Copyright (c) 2011 HighOnCoding. All rights reserved.
//

#import "FMDBDataAccess.h"

@implementation FMDBDataAccess

#define DatabaseFileName          @"Project.sqlite"
#define DatabaseVersion           @"1.0"































-(NSString*)getDatabasePath
{
	static NSString * path = nil;
	if (path==nil)
		path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:DatabaseFileName];
	return path;
}

+(void)createAndCheckDatabase
{	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = paths[0];
	NSString *localDatabasePath = [documentsDirectory stringByAppendingPathComponent:DatabaseFileName];

	NSString *appDir = [[NSBundle mainBundle] resourcePath];
	NSString *projectDatabase = [appDir stringByAppendingPathComponent:DatabaseFileName];

	if (![[NSFileManager defaultManager] fileExistsAtPath:localDatabasePath]) {
		NSError *err = nil;

		BOOL copySuccess = [[NSFileManager defaultManager] copyItemAtPath:projectDatabase toPath:localDatabasePath error:&err];

		if (copySuccess) {
			[self saveVersion:DatabaseVersion ofDatabase:DatabaseFileName];
		} else {
			NSLog(@"NEW DB NOT COPIED!!!  %@", err);
		}
	} else {
		NSString *existingVersion = [self savedVersionOfDatabase:DatabaseFileName];

		if (!existingVersion || (![existingVersion isEqualToString:DatabaseVersion])) {
			if (!existingVersion) existingVersion = @"";
			NSString *oldDBPath = [documentsDirectory stringByAppendingPathComponent:DatabaseFileName];
			NSError *err = nil;
			if ([[NSFileManager defaultManager] fileExistsAtPath:oldDBPath]) {
				BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:oldDBPath error:&err];

				if (!removed) {
					NSLog(@"OLD DB NOT REMOVED!!! %@", err);
					err = nil;
				}
			}

			BOOL moved = [[NSFileManager defaultManager] moveItemAtPath:localDatabasePath toPath:oldDBPath error:&err];

			if (!moved) {
				NSLog(@"OLD DB NOT MOVED!!! %@", err);
				err = nil;
			}
			BOOL copySuccess = [[NSFileManager defaultManager] copyItemAtPath:projectDatabase toPath:localDatabasePath error:&err];
			if (copySuccess) {
				[self saveVersion:DatabaseVersion ofDatabase:DatabaseFileName];
			} else {
				NSLog(@"NEW DB NOT COPIED!!!  %@", err);
			}
		}
	}
}
+ (NSString *)savedVersionOfDatabase:(NSString *)databaseName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:databaseName];
}
+ (void)saveVersion:(NSString *)version ofDatabase:(NSString *)databaseName {
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:databaseName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
