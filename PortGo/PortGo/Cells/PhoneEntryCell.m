//
//  PhoneEntryCell.m
//  PortGo
//
//  Created by Joe Lepple on 4/10/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "PhoneEntryCell.h"

@implementation PhoneEntryCell
@synthesize labelPhoneType;
@synthesize labelPhoneValue;

-(NSString *)reuseIdentifier{
	return kPhoneEntryCellIdentifier;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setNumber:(NgnPhoneNumber *)number_{
	if((self->number = number_)){
		self.labelPhoneType.text = self.number.description;
		self.labelPhoneValue.text = self.number.number;
	}
}

-(NgnPhoneNumber*) number{
	return self->number;
}

@end
