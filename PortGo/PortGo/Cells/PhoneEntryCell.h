//
//  PhoneEntryCell.h
//  PortGo
//
//  Created by Joe Lepple on 4/10/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

#undef kPhoneEntryCellIdentifier
#define kPhoneEntryCellIdentifier	@"PhoneEntryCell"

@interface PhoneEntryCell : UITableViewCell{
	UILabel *labelPhoneType;
	UILabel *labelPhoneValue;
	NgnPhoneNumber* number;
}

@property(nonatomic, readonly, copy) NSString *reuseIdentifier;
@property(nonatomic, retain)  NgnPhoneNumber *number;
@property (retain, nonatomic) IBOutlet UILabel *labelPhoneType;
@property (retain, nonatomic) IBOutlet UILabel *labelPhoneValue;

@end
