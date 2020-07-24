//  telephony
//
//  Created by World on 12/15/11.
//  Copyright 2011 HaveSoft Network. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AddressBookUI/ABPeoplePickerNavigationController.h>

#import "Contact.h"

@class PeoplePicker;

@protocol PeoplePickerDelegate

@required
-(BOOL) peoplePicker: (PeoplePicker *)picker shouldContinueAfterPickingNumber: (NgnPhoneNumber*)number;
-(BOOL) peoplePicker: (PeoplePicker *)picker shouldContinueAfterPickingIPNumber: (NSDictionary*)ipNumber;
-(BOOL) peoplePicker: (PeoplePicker *)picker shouldContinueAfterPickingContact: (Contact*)pickerContact;

@end

typedef enum PickType_e
{
	PickType_Number,
	PickType_Contact
}
PickType_t;


@interface PeoplePicker:ABPeoplePickerNavigationController<ABPeoplePickerNavigationControllerDelegate> {
	UIViewController<PeoplePickerDelegate> *delegate;
}

@property(nonatomic,retain) UIViewController<PeoplePickerDelegate> *delegate;

@property (nonatomic) ABRecordRef recordRef;

-(void) pickNumber: (UIViewController<PeoplePickerDelegate> *)delegate;
-(void) pickContact: (UIViewController<PeoplePickerDelegate> *)delegate;
-(void) dismiss;

@end
