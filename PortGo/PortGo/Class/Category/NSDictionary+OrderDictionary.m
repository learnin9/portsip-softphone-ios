//
//  NSDictionary+OrderDictionary.m
//  PortGo
//
//  Created by 今言网络 on 2017/10/16.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "NSDictionary+OrderDictionary.h"

@implementation NSDictionary (OrderDictionary)
- (NSArray *)nk_ascendingComparedAllKeys
{
    NSArray *allKeys = [self keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 integerValue] > [obj2 integerValue])
        {
            return (NSComparisonResult)NSOrderedAscending;
        }
        if ([obj1 integerValue] < [obj2 integerValue])
        {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return allKeys;
}

- (NSArray *)nk_descendingComparedAllKeys
{
    NSArray *allKeys = [self keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 integerValue] < [obj2 integerValue])
        {
            return (NSComparisonResult)NSOrderedAscending;
        }
        if ([obj1 integerValue] > [obj2 integerValue])
        {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return allKeys;
}
@end
