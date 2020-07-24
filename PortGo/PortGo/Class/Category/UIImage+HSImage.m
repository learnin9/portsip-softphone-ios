//
//  UIImage+HSImage.m
//  PortGo
//
//  Created by MrLee on 14-9-24.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "UIImage+HSImage.h"

@implementation UIImage (HSImage)
+ (UIImage*)stretchImageWithName:(NSString *)name
{
    UIImage *image = [UIImage imageNamed:name];
    float top = image.size.height * 0.3;
    float left = image.size.width * 0.3;
    float bottom = image.size.height * 0.3;
    float right = image.size.width * 0.3;
    return [image resizableImageWithCapInsets:(UIEdgeInsets){top, left, bottom, right} resizingMode:UIImageResizingModeStretch];
}
@end
