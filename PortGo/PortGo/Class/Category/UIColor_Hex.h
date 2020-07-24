//
//  UIColor+UIColor_Hex.h
//  PortGo
//
//  Created by portsip on 17/5/2.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constatnts.h"

#define RGBA_COLOR(R, G, B, A) [UIColor colorWithRed:((R) / 255.0f) green:((G) / 255.0f) blue:((B) / 255.0f) alpha:A]
#define RGB_COLOR(R,G,B) [UIColor colorWithRed:((R) / 255.0f) green: ((G) / 255.0f) blue:((B) / 255.0f) alpha: 1.0f]

@interface UIColor (UIColor_Hex)

// 从十六进制字符串获取颜色，
// color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
+ (UIColor *) colorWithHexString:(NSString *)color;

+(UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end
