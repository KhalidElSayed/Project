//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>


@interface AKSCalendar : NSObject <EKEventEditViewDelegate>
{
    EKEventStore *eventStore;
    UIViewController *delegate;
}
@property (nonatomic, retain) UIViewController *delegate;

+ (AKSCalendar *)sharedAKSCalendarWithDelegate:(id)viewController;

- (void)addCalenderEventWithTitle:(NSString *)title WithStartDate:(NSDate *)startDate WithEndDate:(NSDate *)endDate;
- (void)addCalenderEventWithTitle:(NSString *)title WithStartDate:(NSDate *)startDate WithEndDate:(NSDate *)endDate WithCustomTag:(NSString *)tag WithAlarmDate:(NSDate *)alarmDate;
- (void)addCalenderEventProgrammatically:(EKEvent *)event;
- (void)addCalenderEventManually;
- (void)printEvent:(EKEvent *)event WithTag:(NSString *)info;
- (void)printEvent:(EKEvent *)event;
- (void)printEvents:(NSMutableArray *)arrayOfEvents;
- (void)updateEvent:(EKEvent *)event;
- (void)deleteEvent:(EKEvent *)event;
- (void)deleteEvents:(NSArray *)events;
- (NSArray *)returnAllEvents;
- (NSArray *)returnFutureEvents;
- (NSArray *)returnEventsForDate:(NSDate *)date;
- (EKEventStore *)eventStore;
@end
