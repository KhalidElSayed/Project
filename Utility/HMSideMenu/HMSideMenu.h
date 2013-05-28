//
//  HMSideMenu.h
//  HMSideMenu
//
//  Created by Hesham Abd-Elmegid on 4/24/13.
//  Copyright (c) 2013 Hesham Abd-Elmegid. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HMSideMenuPositionLeft,
    HMSideMenuPositionRight,
    HMSideMenuPositionTop,
    HMSideMenuPositionBottom
} HMSideMenuPosition;

@interface HMSideMenu : UIView

/**
 Current state of the side menu.
 */
@property (nonatomic, assign, readonly) BOOL isOpen;

/**
 Spacing between each menu item and the next. This will be the horizontal spacing between items in case the menu is added on the top/bottom, or vertical spacing in case the menu is added on the left/right.
 */
@property (nonatomic, assign) CGFloat itemSpacing;

/**
 Duration of the opening/closing animation.
 */
@property (nonatomic, assign) CGFloat animationDuration;

/**
 Position the side menu will be added at.
 */
@property (nonatomic, assign) HMSideMenuPosition menuPosition;

/**
 Initialize the menu with an array of items.
 
 @param items An array of `UIView` objects.
 */
- (id)initWithItems:(NSArray *)items;

/**
 Show all menu items with animation.
 */
- (void)open;

/**
 Hide all menu items with animation.
 */
- (void)close;

@end

///--------------------------------
/// @name UIView+MenuActionHandlers
///--------------------------------

/**
 A category on UIView to attach a given block as an action for a single tap gesture.
 Credit: http://www.cocoanetics.com/2012/06/associated-objects/
 
 @param block The block to execute.
 */
@interface UIView (MenuActionHandlers)

- (void)setMenuActionWithBlock:(void (^)(void))block;

@end










/**
 
 __________

 HOW TO USE
 __________
 
 

 
 - (void)viewDidLoad
 {
 [super viewDidLoad];

 UIView *twitterItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
 [twitterItem setMenuActionWithBlock:^{
 NSLog(@"tapped twitter item");
 }];
 UIImageView *twitterIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
 [twitterIcon setImage:[UIImage imageNamed:@"twitter"]];
 [twitterItem addSubview:twitterIcon];

 UIView *emailItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
 [emailItem setMenuActionWithBlock:^{
 NSLog(@"tapped email item");
 }];
 UIImageView *emailIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30 , 30)];
 [emailIcon setImage:[UIImage imageNamed:@"email"]];
 [emailItem addSubview:emailIcon];

 UIView *facebookItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
 [facebookItem setMenuActionWithBlock:^{
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
 message:@"Tapped facebook item"
 delegate:nil
 cancelButtonTitle:@"Okay"
 otherButtonTitles:nil, nil];
 [alertView show];

 }];
 UIImageView *facebookIcon = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 35, 35)];
 [facebookIcon setImage:[UIImage imageNamed:@"facebook"]];
 [facebookItem addSubview:facebookIcon];

 UIView *browserItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
 [browserItem setMenuActionWithBlock:^{
 NSLog(@"tapped browser item");
 }];
 UIImageView *browserIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
 [browserIcon setImage:[UIImage imageNamed:@"browser"]];
 [browserItem addSubview:browserIcon];

 self.sideMenu = [[HMSideMenu alloc] initWithItems:@[twitterItem, emailItem, facebookItem, browserItem]];
 [self.sideMenu setItemSpacing:5.0f];
 [self.view addSubview:self.sideMenu];
 }

 - (IBAction)toggleMenu:(id)sender {
 if (self.sideMenu.isOpen)
 [self.sideMenu close];
 else
 [self.sideMenu open];
 }

 */















