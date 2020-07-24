//
//  NSDictionary+OrderDictionary.h
//  PortGo
//
//  Created by 今言网络 on 2017/10/16.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (OrderDictionary)

- (NSArray *)nk_ascendingComparedAllKeys;
- (NSArray *)nk_descendingComparedAllKeys;
@end
