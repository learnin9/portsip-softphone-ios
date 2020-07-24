/* Copyright (C) 2010-2011, Mamadou Diop.
 * Copyright (c) 2011, Doubango Telecom. All rights reserved.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango(dot)org>
 *       
 * This file is part of iDoubs Project ( http://code.google.com/p/idoubs )
 *
 * idoubs is free software: you can redistribute it and/or modify it under the terms of 
 * the GNU General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 *       
 * idoubs is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 * See the GNU General Public License for more details.
 *       
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 */

#import "Contact.h"

#define NgnRelease(x) if(x){ CFRelease(x),x=NULL; }

@implementation NgnPhoneNumber

@synthesize number;
@synthesize description;
@synthesize opaque;
@synthesize type;

-(NgnPhoneNumber*) initWithNumber:(NSString*)number_ andDescription:(NSString*)desciption_ andType:(NgnPhoneNumberType_t)type_{
	if((self = [super init])){
		self->number = number_ ;
		self->description = desciption_;
		self->type = type_;
	}
	return self;
}

-(NgnPhoneNumber*) initWithNumber:(NSString*)number_ andDescription:(NSString*)desciption_{
	return [self initWithNumber:number_ andDescription:desciption_ andType:NgnPhoneNumberType_Mobile];
}

-(BOOL) emailAddress{
	return (self->type == NgnPhoneNumberType_Email);
}


@end


@implementation Contact

@synthesize contdentifier;
@synthesize contactId;
@synthesize subscribeId;
@synthesize displayName;
@synthesize firstName;
@synthesize lastName;
@synthesize company;
@synthesize partment;
@synthesize jobtitle;
@synthesize phoneNumbers;
@synthesize IPCallNumbers;
@synthesize IMNumber;
@synthesize onlineState;
@synthesize picture;
@synthesize creatDate;
@synthesize opaque;

#if TARGET_OS_IPHONE

-(Contact *)initWithCNContact:(CNContact *)cnContact {
    if ((self = [super init]) && cnContact) {
        self->phoneNumbers = [[NSMutableArray alloc] init];
        self->IPCallNumbers = [NSMutableArray array];
        
        self->contdentifier = cnContact.identifier;
        if (![cnContact.givenName isEqualToString:@""] && ![cnContact.familyName isEqualToString:@""]) {
            self->displayName = [NSString stringWithFormat:@"%@ %@",cnContact.givenName,cnContact.familyName];
        } else {
            if (![cnContact.givenName isEqualToString:@""]) {
                self->displayName = cnContact.givenName;
            }else if (![cnContact.familyName isEqualToString:@""]) {
                self->displayName = cnContact.familyName;
            }else if (![cnContact.organizationName isEqualToString:@""]) {
                self->displayName = cnContact.organizationName;
            }else{
                self->displayName = NSLocalizedString(@"Unknown", @"unknow");
            }
        }
        
        self->firstName = cnContact.familyName;
        self->lastName = cnContact.givenName;
        self->company = cnContact.organizationName;
        self->partment = cnContact.departmentName;
        self->jobtitle = cnContact.jobTitle;
        
   //     self->subscribeId = [cnContact.note integerValue];
        
        
        if (cnContact.imageDataAvailable && cnContact.imageData) {
            self->picture = cnContact.imageData;
        }
        
        if (cnContact.instantMessageAddresses.count > 0) {
            CNLabeledValue *labelValue = cnContact.instantMessageAddresses[0]; // 默认使用第一个SIP号码作为此联系人的IM账号
            CNInstantMessageAddress *IMaddress = labelValue.value;
            self->IMNumber = IMaddress.username;
        }
        
    //    NSLog(@"self.IMNumber520=======%@",self.IMNumber);
        
        NSArray *ipNumbers = cnContact.socialProfiles;
        
        for (CNLabeledValue *labeValue in ipNumbers) {
            CNSocialProfile *profile = labeValue.value;
            if (profile.urlString && profile.service) {
                NSDictionary *dict = [NSDictionary dictionaryWithObject:profile.urlString forKey:profile.service];
                [self->IPCallNumbers addObject:dict];
            }
        }
        NSArray *mobileNumbers = cnContact.phoneNumbers;
        NgnPhoneNumber* ngnPhoneNumber;
        for (CNLabeledValue *labelValue in mobileNumbers) {
            CNPhoneNumber *phonenumber = labelValue.value;
            ngnPhoneNumber = [[NgnPhoneNumber alloc] initWithNumber:phonenumber.stringValue andDescription:[CNLabeledValue localizedStringForLabel:labelValue.label] andType:NgnPhoneNumberType_Mobile];
            [self->phoneNumbers addObject:ngnPhoneNumber];
        }
        
    }
    return self;
}

-(Contact*)initWithABRecordRef: (const ABRecordRef) record
{
    if((self = [super init]) && record){
        self->phoneNumbers = [[NSMutableArray alloc] init];
        self->IPCallNumbers = [NSMutableArray array];
//        self.mGroups = [[NSMutableArray alloc] init];
        
        self->contactId = ABRecordGetRecordID(record);
        self->displayName = (__bridge NSString *)ABRecordCopyCompositeName(record);
        self->firstName = (__bridge NSString*)ABRecordCopyValue(record, kABPersonFirstNameProperty);
        self->lastName = (__bridge NSString*)ABRecordCopyValue(record, kABPersonLastNameProperty);
        self->company = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonOrganizationProperty));
        self->partment = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonDepartmentProperty));
        self->jobtitle = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonJobTitleProperty));
        self->creatDate = (__bridge NSDate*)ABRecordCopyValue(record, kABPersonCreationDateProperty);
        if(ABPersonHasImageData(record)){
            self->picture = (__bridge NSData*)ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatThumbnail);
            
        }
        
        /*
            IPCall
         */
        ABMultiValueRef profiles = ABRecordCopyValue(record, kABPersonSocialProfileProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(profiles); i ++) {
            NSDictionary *profileDic = CFBridgingRelease(ABMultiValueCopyValueAtIndex(profiles, i));
            [self->IPCallNumbers addObject:profileDic];
        }
        NgnRelease(profiles);
        
        //
        //    Phone numbers
        //
        ABPropertyID properties[2] = { kABPersonPhoneProperty, kABPersonEmailProperty };

        for(int k=0; k< sizeof(properties)/sizeof(ABPropertyID); k++){
            CFStringRef phoneNumber, phoneNumberLabel, phoneNumberLabelValue;
            NgnPhoneNumber* ngnPhoneNumber;
            ABMutableMultiValueRef multi = ABRecordCopyValue(record, properties[k]);
            for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++) {
                phoneNumberLabel = ABMultiValueCopyLabelAtIndex(multi, i);
                phoneNumberLabelValue = ABAddressBookCopyLocalizedLabel(phoneNumberLabel);
                phoneNumber      = ABMultiValueCopyValueAtIndex(multi, i);
            
                ngnPhoneNumber = [[NgnPhoneNumber alloc] initWithNumber:(__bridge NSString*)phoneNumber
                                                         andDescription:(__bridge NSString*)phoneNumberLabelValue
                                                         andType:(k==kABPersonEmailPropertyIndex) ? NgnPhoneNumberType_Email : NgnPhoneNumberType_Mobile
                                  ];
                [self->phoneNumbers addObject: ngnPhoneNumber];

                NgnRelease(phoneNumberLabelValue);
                NgnRelease(phoneNumberLabel);
                NgnRelease(phoneNumber);
            }
            NgnRelease(multi);
        }
        
        /*
         contactGroups
        */
    }
    return self;
}

-(id)initWithIdentifi:(int32_t)identifi SunbscribeID:(long)subscribeid DisplayName:(NSString *)displayName Firstname:(NSString *)firstName Lastname:(NSString *)lastName Company:(NSString *)company Department:(NSString *)department Jobtitle:(NSString *)jobtitle IMNumber:(NSString *)imNumber Comfrom:(int)comefrom DeletFlag:(int)deleteFlag ApplyState:(PS_ApplyState)applyState PhoneNumbers:(NSString *)phoneNumbers IPNumbers:(NSString *)ipNumbers {
    if (self = [super init]) {
        _ipCallNumberString = ipNumbers;
        if (![_ipCallNumberString isEqualToString:@""]) {
            NSArray *strs = [_ipCallNumberString componentsSeparatedByString:@"|"];
            NSMutableArray *tempArr = [NSMutableArray array];
            for (NSString *json in strs) {
                if (json && ![json isEqualToString:@""]) {
                    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                    if (dic) {
                        [tempArr addObject:dic];
                    }
                }
            }
            self->IPCallNumbers = tempArr;
        }
        self->contactId = identifi;
        self->subscribeId = subscribeid;
        self->IMNumber = imNumber;
        self->contdentifier = @""; //保留
        self->displayName = displayName;
        self->firstName = firstName;
        self->lastName = lastName;
        self->company = company;
        self->partment = department;
        self->jobtitle = jobtitle;
        self->lineState = applyState;
        _comeFrom = comefrom;
        _deleteFlag = deleteFlag;
        
        
        if (!self.onlineState || [self.onlineState isEqualToString:@""]) {
            self.onlineState = @"Offline";
        }
    }
    return self;
}

-(Contact *)initWithSipFriend:(SipFriend *)sipFriend {
    if ((self = [super init]) && sipFriend) {
        if (![sipFriend.ipCallNumbers isEqualToString:@""]) {
            NSArray *strs = [sipFriend.ipCallNumbers componentsSeparatedByString:@"|"];
            NSMutableArray *tempArr = [NSMutableArray array];
            for (NSString *json in strs) {
                if (json && ![json isEqualToString:@""]) {
                    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                    if (dic) {
                        [tempArr addObject:dic];
                    }
                }
            }
            self->IPCallNumbers = tempArr;
        }
        
        self->contactId = sipFriend.ID;
        self->subscribeId = sipFriend.subscribeID;
        self->IMNumber = sipFriend.imNumber;
        self->contdentifier = sipFriend.sipIdentifier;
        self->displayName = sipFriend.displayName;
        self->firstName = sipFriend.firstName;
        self->lastName = sipFriend.lastName;
        self->company = sipFriend.company;
        self->partment = sipFriend.partment;
        self->jobtitle = sipFriend.jobtitle;
        self->lineState = sipFriend.applyState;
        
        if (!self.onlineState || [self.onlineState isEqualToString:@""]) {
            self.onlineState = @"Offline";
        }
    }
    return self;
}

#elif TARGET_OS_MAC

-(Contact*)initWithABPerson:(const ABPerson*)person
{
	if((self = [super init]) && person){
		self->phoneNumbers = [[NSMutableArray alloc] init];
		self->firstName = [[person valueForProperty:kABFirstNameProperty] retain];
		self->lastName = [[person valueForProperty:kABLastNameProperty] retain];
	}
	return self;
}

#endif


@end


