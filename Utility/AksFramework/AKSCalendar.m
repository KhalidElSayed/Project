//
//  Project Template
//
//  Created by Alok on 2/04/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//


#import "AKSCalendar.h"
#import "AKSMethods.h"


#define MINIMUM_START_DATE [NSDate dateWithTimeIntervalSinceNow:-365 * (86400 * 1)]
#define MAXIMUM_END_DATE   [NSDate dateWithTimeIntervalSinceNow:365 * (86400 * 1)]

static AKSCalendar *AKSCalendar_ = nil;

@implementation AKSCalendar

@synthesize delegate;

+ (AKSCalendar *)sharedAKSCalendarWithDelegate:(id)viewController {
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        if (AKSCalendar_ == nil) {
            AKSCalendar_ = [[AKSCalendar alloc]init];
        }
    });

    [AKSCalendar_ initialSetup];
    AKSCalendar_.delegate = viewController;

    return AKSCalendar_;
}

+ (id)alloc {
    NSAssert(AKSCalendar_ == nil, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (void)initialSetup {
    if (!eventStore) eventStore = [[EKEventStore alloc] init];
    [self calendarAccessibility];
}

- (void)calendarAccessibility {
    __block BOOL accessGranted = NO;

    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    } else {
        accessGranted = YES;
    }
}

- (void)addCalenderEventManually {
    if (!delegate) return;

    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.title = @"Add event title";
    event.location = @"Add event location";
    event.startDate = [NSDate date];
    event.endDate = [NSDate dateWithTimeIntervalSinceNow:86400];
    event.notes = @"Add notes for this event";
    [event addAlarm:[EKAlarm alarmWithRelativeOffset:-15 * 60]];

    EKEventEditViewController *eventEditViewController = [[EKEventEditViewController alloc] init];
    eventEditViewController.editViewDelegate = self;
    eventEditViewController.event = event;
    eventEditViewController.eventStore = eventStore;

    [delegate presentModalViewController:eventEditViewController animated:YES];
}

- (void)addCalenderEventProgrammatically:(EKEvent *)event {
    NSError *error = nil;
    [eventStore saveEvent:event span:EKSpanThisEvent error:&error];
}

- (void)addCalenderEventWithTitle:(NSString *)title WithStartDate:(NSDate *)startDate WithEndDate:(NSDate *)endDate WithCustomTag:(NSString *)tag WithAlarmDate:(NSDate *)alarmDate {
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.title = title;
    event.startDate = startDate;
    event.notes = tag;
    event.endDate = endDate;
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
    event.alarms = [NSArray arrayWithObject:[EKAlarm alarmWithAbsoluteDate:alarmDate]];

    NSError *error = nil;
    BOOL iseventSaved = NO;

    iseventSaved = [eventStore saveEvent:event span:EKSpanThisEvent error:&error];

    if (iseventSaved) {
        NSLog(@"Event saved successfully");
    }
    if (error) {
        NSLog(@"error while saving calendar event %@", error);
    }

    [AKSMethods printErrorMessage:error showit:FALSE];
}

- (void)addCalenderEventWithTitle:(NSString *)title WithStartDate:(NSDate *)startDate WithEndDate:(NSDate *)endDate {
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.title = title;
    event.startDate = startDate;
    event.endDate = endDate;
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
    event.alarms = [NSArray arrayWithObject:[EKAlarm alarmWithAbsoluteDate:event.startDate]];

    NSError *error = nil;

    [eventStore saveEvent:event span:EKSpanThisEvent error:nil];
    [AKSMethods printErrorMessage:error showit:FALSE];
}

- (void)updateEvent:(EKEvent *)event {
    NSError *error = nil;
    [eventStore saveEvent:event span:EKSpanThisEvent error:&error];
    [AKSMethods printErrorMessage:error showit:FALSE];
}

- (void)deleteEvent:(EKEvent *)event {
    NSError *error = nil;
    [eventStore removeEvent:event span:EKSpanThisEvent error:&error];
    [AKSMethods printErrorMessage:error showit:FALSE];
}

- (void)deleteEvents:(NSArray *)events {
    NSError *error = nil;
    for (int i = 0; i < events.count; i++) {
        if ([[events objectAtIndex:i]isKindOfClass:[EKEvent class]]) [eventStore removeEvent:[events objectAtIndex:i] span:EKSpanThisEvent error:&error];
    }
    [AKSMethods printErrorMessage:error showit:FALSE];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action {
    NSError *error = nil;
    switch (action) {
        case EKEventEditViewActionCanceled:
            break;
        case EKEventEditViewActionSaved:
            [controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
            [AKSMethods printErrorMessage:error showit:FALSE];
            break;
        case EKEventEditViewActionDeleted:
            [controller.eventStore removeEvent:controller.event span:EKSpanThisEvent error:&error];
            [AKSMethods printErrorMessage:error showit:FALSE];
            break;
        default:
            break;
    }
    [controller dismissModalViewControllerAnimated:YES];
}

- (void)showInfo:(NSString *)infoMessage {
    [AKSMethods showMessage:infoMessage];
}

- (void)showErrorInfo:(NSError *)error {
    if (!error) return;
    NSDictionary *dict = [error userInfo];
    NSString *errorStr = [dict objectForKey:@"NSLocalizedDescription"];
    if (!errorStr) return;
    [AKSMethods showMessage:errorStr];
}

- (EKEventStore *)eventStore {
    return eventStore;
}

- (void)printEvent:(EKEvent *)event {
    NSLog(@"/n/n/nEvent Title : %@", event.title);
    NSLog(@"Event StartDate   : %@", [NSDateFormatter localizedStringFromDate:event.startDate
                                                                    dateStyle:NSDateFormatterShortStyle
                                                                    timeStyle:NSDateFormatterFullStyle]);
    NSLog(@"Event EndDate     : %@", [NSDateFormatter localizedStringFromDate:event.endDate
                                                                    dateStyle:NSDateFormatterShortStyle
                                                                    timeStyle:NSDateFormatterFullStyle]);
    NSLog(@"Event Notes       : %@", event.notes);
}

- (void)printEvent:(EKEvent *)event WithTag:(NSString *)info {
    NSLog(@"/n/n/n/nDescription : %@", info);
    NSLog(@"/nEvent Title : %@", event.title);
    NSLog(@"Event StartDate   : %@", [NSDateFormatter localizedStringFromDate:event.startDate
                                                                    dateStyle:NSDateFormatterShortStyle
                                                                    timeStyle:NSDateFormatterFullStyle]);
    NSLog(@"Event EndDate     : %@", [NSDateFormatter localizedStringFromDate:event.endDate
                                                                    dateStyle:NSDateFormatterShortStyle
                                                                    timeStyle:NSDateFormatterFullStyle]);
    NSLog(@"Event Notes       : %@", event.notes);
}

- (void)printEvents:(NSMutableArray *)arrayOfEvents {
    for (int i = 0; i < arrayOfEvents.count; i++) {
        if ([[arrayOfEvents objectAtIndex:i]isKindOfClass:[EKEvent class]]) [self printEvent:[arrayOfEvents objectAtIndex:i]];
    }
}

- (NSArray *)returnEventsForDate:(NSDate *)date {
	
    NSDate *start  = date;
    NSDate *finish = [NSDate dateWithTimeInterval:86400 sinceDate:start];
    NSMutableDictionary *eventsDict = [NSMutableDictionary dictionaryWithCapacity:1024];

    NSDate *currentStart = [NSDate dateWithTimeInterval:0 sinceDate:start];

    while ([currentStart compare:finish] == NSOrderedAscending) {
        NSDate *currentFinish = [NSDate dateWithTimeInterval:86400 sinceDate:currentStart];

        if ([currentFinish compare:finish] == NSOrderedDescending) {
            currentFinish = [NSDate dateWithTimeInterval:0 sinceDate:finish];
        }

        NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:currentStart endDate:currentFinish calendars:nil];
		
        [
		 eventStore enumerateEventsMatchingPredicate:predicate
		 usingBlock:^(EKEvent *event, BOOL *stop)
		 {
			 if (event) [eventsDict setObject:event forKey:event.eventIdentifier];
		 }
		 ];

        currentStart = [NSDate dateWithTimeInterval:(86400 + 1) sinceDate:currentStart];
    }

    return [eventsDict allValues];
}

- (NSArray *)returnAllEvents {
    EKEventStore *eventStore_ = [[AKSCalendar sharedAKSCalendarWithDelegate:self] eventStore];

    NSDate *startDate = MINIMUM_START_DATE;
    NSDate *endDate = MAXIMUM_END_DATE;

    EKCalendar *calendar = [eventStore_ defaultCalendarForNewEvents];

    NSArray *calendarArray = nil;

    if ([self isNotNull:calendar]) calendarArray = [NSArray arrayWithObject:calendar];
    else return [[NSArray alloc]init];

    NSPredicate *predicate = [eventStore_ predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendarArray];
    NSArray *events = [eventStore_ eventsMatchingPredicate:predicate];
    return events;
}

- (NSArray *)returnFutureEvents {
    EKEventStore *eventStore_ = [[AKSCalendar sharedAKSCalendarWithDelegate:self] eventStore];

    NSDate *startDate = MINIMUM_START_DATE;
    NSDate *endDate = MAXIMUM_END_DATE;

    EKCalendar *calendar = [eventStore_ defaultCalendarForNewEvents];

    NSArray *calendarArray = nil;

    if ([self isNotNull:calendar]) calendarArray = [NSArray arrayWithObject:calendar];
    else return [[NSArray alloc]init];

    NSPredicate *predicate = [eventStore_ predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendarArray];
    NSArray *events = [eventStore_ eventsMatchingPredicate:predicate];

    return events;
}

- (NSArray *)returnTodaysEvents {
    EKEventStore *eventStore_ = [[AKSCalendar sharedAKSCalendarWithDelegate:self] eventStore];

    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-1 * (86400 * 1)];
    NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:365 * (86400 * 1)];

    EKCalendar *calendar = [eventStore_ defaultCalendarForNewEvents];

    NSArray *calendarArray = nil;

    if ([self isNotNull:calendar]) calendarArray = [NSArray arrayWithObject:calendar];
    else return [[NSArray alloc]init];

    NSPredicate *predicate = [eventStore_ predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendarArray];
    NSArray *events = [eventStore_ eventsMatchingPredicate:predicate];

    return events;
}

@end
