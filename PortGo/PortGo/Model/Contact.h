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

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import "SipFriend.h"

typedef enum NgnPhoneNumberType_e
{
	NgnPhoneNumberType_Unknown,
	NgnPhoneNumberType_Mobile,
	NgnPhoneNumberType_Email,
    NgnPhoneNumberType_IPCall
}
NgnPhoneNumberType_t;

#define kABPersonPhonePropertyIndex 0
#define kABPersonEmailPropertyIndex 1

@interface NgnPhoneNumber : NSObject {
@protected
	NSString* number;
	NSString* description;
	NgnPhoneNumberType_t type;
	
@private
	// to be used for any purpose (e.g. category)
	id opaque;
}

@property(readonly) NSString* number;
@property(readonly) BOOL emailAddress;
@property(readonly) NgnPhoneNumberType_t type;
@property(readonly) NSString* description;
@property(readwrite, retain, nonatomic) id opaque;

-(NgnPhoneNumber*) initWithNumber:(NSString*)_number andDescription:(NSString*)_desciption andType:(NgnPhoneNumberType_t)type;
-(NgnPhoneNumber*) initWithNumber:(NSString*)_number andDescription:(NSString*)_desciption;

@end

@interface Contact : NSObject {
@protected
    NSString *contdentifier;
	int32_t contactId;
    long subscribeId;
	NSString* displayName;
	NSString* firstName;
	NSString* lastName;
    NSString* company;
    NSString* partment;
    NSString* jobtitle;
	NSMutableArray* phoneNumbers;
    NSMutableArray* IPCallNumbers;
    NSString *IMNumber;
	NSData* picture;
    NSDate* creatDate;
    PS_ApplyState lineState;
    NSString *onlineState;
	
@private
	// to be used for any purpose (e.g. category)
	NSObject* opaque;
}

#if TARGET_OS_IPHONE
-(Contact *)initWithSipFriend:(SipFriend *)sipFriend;

-(id)initWithIdentifi:(int32_t)identifi SunbscribeID:(long)subscribeid DisplayName:(NSString *)displayName Firstname:(NSString *)firstName Lastname:(NSString *)lastName Company:(NSString *)company Department:(NSString *)department Jobtitle:(NSString *)jobtitle IMNumber:(NSString *)imNumber Comfrom:(int)comefrom DeletFlag:(int)deleteFlag ApplyState:(PS_ApplyState)applyState PhoneNumbers:(NSString *)phoneNumbers IPNumbers:(NSString *)ipNumbers;

-(Contact *)initWithCNContact:(CNContact *)cnContact;
-(Contact*)initWithABRecordRef: (const ABRecordRef) record;
//-(NSMutableArray *)getContactGroupsWith:(Contact *)contact;
#elif TARGET_OS_MAC
-(Contact*)initWithABPerson:(const ABPerson*)person;
#endif /* TARGET_OS_IPHONE */

@property(readonly) NSString *contdentifier;
@property(readonly) int32_t contactId;
@property(readonly) long subscribeId;
@property(readonly) NSString* displayName;
@property(readonly) NSString* firstName;
@property(readonly) NSString* lastName;
@property(readonly) NSString* company;
@property(readonly) NSString* partment;
@property(readonly) NSString* jobtitle;
@property(readonly) NSMutableArray* phoneNumbers;
@property(readonly) NSMutableArray* IPCallNumbers;
@property(nonatomic, strong) NSString* IMNumber;
@property(nonatomic, strong) NSString *onlineState;
@property(readwrite, retain, nonatomic) NSObject* opaque;

@property (nonatomic,strong)NSString *stateText;


//自定义数据库
//@property int customContactID;
@property long subscribeID;
@property long outSubscribeId;
@property(nonatomic, strong) NSString* phoneNumberString;
@property(nonatomic, strong) NSString* ipCallNumberString;
@property(nonatomic, strong) NSData* picture;
@property(nonatomic, strong) NSDate* creatDate;
@property(nonatomic, strong) NSString *imNumber; //IMNumber

@property int comeFrom;
@property int deleteFlag;
@property (nonatomic, assign) PS_ApplyState applyState;

@property (nonatomic, strong)NSString *teststr;


@end
