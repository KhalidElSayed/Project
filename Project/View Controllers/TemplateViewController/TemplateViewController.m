//
//  TemplateViewController.m
//  Project
//
//  Created by Alok on 02/05/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import "TemplateViewController.h"
#import "AFNetworking.h"
#import "FTAnimation+UIView.h"

@interface TemplateViewController ()

@end

@implementation TemplateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - ViewController life cycle methods

- (void)viewWillAppear:(BOOL)animated {
    SHOW_STATUS_BAR
    SHOW_NAVIGATION_BAR
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForNotifications];
    [self startUpInitialisations];
    [self setUpForNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    if (firstTime) {
        firstTime = FALSE;
        [self updateScreen];
    }
}

- (void)updateScreen {
}

#pragma mark - Methods for initialising contents of this view controller

- (void)startUpInitialisations {
    firstTime = TRUE;
}

#pragma mark - methods to register for important notifications

- (void)registerForNotifications {
}

#pragma mark - Methods for preparing and handling Navigation Bar

- (void)setUpForNavigationBar {

}

- (void)onClickOfLeftNavigationBarButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onClickOfRightNavigationBarButton:(id)sender {
}

/**         UNCOMMENT IF U HAVE PLANNED TO USE TABLE VIEW CONTROLLER



 #pragma mark - TableView DataSource And Delegate Methods

 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
 {
 TCSTART

 return 1;

 TCEND
 }

 -(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 {
 return  0;
 }

 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 return  0;
 }

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {

 }


 -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 TCSTART

 TCEND
 }




 */

#pragma mark - life cycle methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Memory management methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
