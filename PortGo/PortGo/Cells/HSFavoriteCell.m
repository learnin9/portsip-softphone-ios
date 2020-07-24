//
//  HSFavoriteCell.m
//  PortGo
//
//  Created by portsip on 16/11/23.
//  Copyright © 2016年 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSFavoriteCell.h"
#import "Favoriter.h"
#import "Contact.h"

@implementation HSFavoriteCell

- (void)setFavorite:(Favorite *)favorite
{
    if(favorite){
        _mFavorite = favorite;
        _displayName.text = favorite.mDisplayName;
        _typeName.text = favorite.mTypeDescription;
    }
    
}

@end
