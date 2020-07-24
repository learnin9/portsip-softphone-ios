//  telephony
//
//  Created by World on 12/15/11.
//  Copyright 2011 HaveSoft Network. All rights reserved.
//
#import "PeoplePicker.h"

#import <AddressBook/AddressBook.h>


@implementation PeoplePicker

@synthesize delegate;

-(void) viewDidLoad{
	[super viewDidLoad];
	
//	self.displayedProperties = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty], nil];
}

#pragma mark ABPeoplePickerNavigationControllerDelegate methods
// Displays the information of a selected person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)picker shouldContinueAfterSelectingPerson:(ABRecordRef)person{

	Contact* pickerContact = [[Contact alloc] initWithABRecordRef:person];
	BOOL shoudContinue = [self.delegate peoplePicker:self  shouldContinueAfterPickingContact:pickerContact];

	return shoudContinue;
}


// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)picker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    if (property != kABPersonPhoneProperty && property != kABPersonEmailProperty && property != kABPersonSocialProfileProperty) {
        return NO;
    }
    _recordRef = person;
	BOOL shoudContinue = NO;
	NgnPhoneNumber* ngnPhoneNumber = nil;
    NSDictionary *ipNumberDic = nil;

	if(kABPersonPhoneProperty == property && kABPersonPhoneProperty == identifier){
		ABMultiValueRef phoneProperty = ABRecordCopyValue(person,property);
		CFIndex idx = ABMultiValueGetIndexForIdentifier (phoneProperty, identifier);
		CFStringRef label = ABMultiValueCopyLabelAtIndex(phoneProperty, idx);
		CFStringRef description = (CFStringRef)ABAddressBookCopyLocalizedLabel(label);
		CFStringRef number = (CFStringRef)ABMultiValueCopyValueAtIndex(phoneProperty, idx);

        ngnPhoneNumber = [[NgnPhoneNumber alloc] initWithNumber:(__bridge NSString *)number andDescription:(__bridge NSString*)description];
		//ngnPhoneNumber = [[NgnPhoneNumber alloc] initWithNumber: (NSString*)number andDescription: (NSString*)description];

		CFRelease(phoneProperty);
		CFRelease(label);
		CFRelease(description);
		CFRelease(number);

        shoudContinue = [self.delegate peoplePicker:self shouldContinueAfterPickingNumber:ngnPhoneNumber];

    } else if (kABPersonSocialProfileProperty == property && kABPersonPhoneProperty == identifier) {
        ABMultiValueRef ipCallProperty = ABRecordCopyValue(person, property);
        CFIndex idx = ABMultiValueGetIndexForIdentifier(ipCallProperty, identifier);
        CFDictionaryRef ipNumber = (CFDictionaryRef)ABMultiValueCopyValueAtIndex(ipCallProperty, idx);

        ipNumberDic = (__bridge NSDictionary *)ipNumber;

        shoudContinue = [self.delegate peoplePicker:self shouldContinueAfterPickingIPNumber:ipNumberDic];
    }

	return shoudContinue;
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if (property != kABPersonPhoneProperty && property != kABPersonEmailProperty && property != kABPersonSocialProfileProperty) {
        return;
    }

    _recordRef = person;
    NgnPhoneNumber* ngnPhoneNumber = nil;
    NSDictionary *ipNumberDic = nil;

    if(kABPersonPhoneProperty == property){
        ABMultiValueRef phoneProperty = ABRecordCopyValue(person,property);
        CFIndex idx = ABMultiValueGetIndexForIdentifier (phoneProperty, identifier);
        CFStringRef label = ABMultiValueCopyLabelAtIndex(phoneProperty, idx);
        CFStringRef description = (CFStringRef)ABAddressBookCopyLocalizedLabel(label);
        CFStringRef number = (CFStringRef)ABMultiValueCopyValueAtIndex(phoneProperty, idx);

        ngnPhoneNumber = [[NgnPhoneNumber alloc] initWithNumber:(__bridge NSString *)number andDescription:(__bridge    NSString*)description];
    //ngnPhoneNumber = [[NgnPhoneNumber alloc] initWithNumber: (NSString*)number andDescription: (NSString*)description];

        CFRelease(phoneProperty);
        CFRelease(label);
        CFRelease(description);
        CFRelease(number);

        [self.delegate peoplePicker:self shouldContinueAfterPickingNumber:ngnPhoneNumber];

    } else if (kABPersonSocialProfileProperty == property) {
        ABMultiValueRef ipNumberProperty = ABRecordCopyValue(person, property);
        CFIndex idx = ABMultiValueGetIndexForIdentifier (ipNumberProperty, identifier);
        CFDictionaryRef ipNumber = (CFDictionaryRef)ABMultiValueCopyValueAtIndex(ipNumberProperty, idx);

        ipNumberDic = (__bridge NSDictionary *)ipNumber;

        [self.delegate peoplePicker:self shouldContinueAfterPickingIPNumber:ipNumberDic];
    }
}


// Dismisses the people picker and shows the application when users tap Cancel.
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)picker;{
	[self dismiss];
}

-(void) pickNumber: (UIViewController<PeoplePickerDelegate> *)delegate_{
	self.peoplePickerDelegate = self;
	self.delegate = delegate_;
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.delegate presentViewController:self animated:YES completion:nil];
}

-(void) pickContact: (UIViewController<PeoplePickerDelegate> *)delegate_{
	self.peoplePickerDelegate = self;
	self.delegate = delegate_;
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.delegate presentViewController:self animated:YES completion:nil];
}

-(void) dismiss{
    [self.delegate dismissViewControllerAnimated:YES completion:nil];
}

@end
