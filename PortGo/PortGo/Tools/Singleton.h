//
//  Singleton.h
//  SQLLite3基本操作
//
//  Created by MrLee on 14-9-22.
//  Copyright (c) 2014年 MrLee. All rights reserved.
//

#define single_interface(class) + (class *)shared##class;

#define single_implementation(class)\
static class *_instance; \
\
+ (class *)shared##class \
{\
    if(_instance == nil){ \
        _instance = [[self alloc] init]; \
    } \
    return _instance; \
} \
\
+ (id)allocWithZone:(NSZone*)zone \
{\
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        _instance = [super allocWithZone:zone]; \
    }); \
    return _instance; \
}
