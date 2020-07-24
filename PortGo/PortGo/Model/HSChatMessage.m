//
//  HSChatMessage.m
//  PortGo
//
//  Created by MrLee on 14-10-8.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSChatMessage.h"
#import "UIImage+PKShortVideoPlayer.h"
#import "HttpHelper.h"

bool UrlTest = false;
@implementation HSChatMessage
- (id)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.historyId = [dict[@"historyId"] intValue];
        self.nickName = dict[@"nickName"];
        self.sendTime = dict[@"sendTime"];
        self.msgBody = dict[@"msgBody"];
        self.status = [dict[@"status"] intValue];
        self.mimetype = dict[KEY_MIMETYPE];
        self.msglen = [dict[@"msglen"] intValue];
        if(self.mimetype.length==0){
            self.mimetype=@"text/plain";//default
        }
        self.jsonContent = [History parserMessage:self.msgBody];
        self.isFirstRow = NO;
        self.msgRead = [dict[KEY_MESSAGE_READ] intValue];
    }
    return self;
}

-(UIImage*)getImage{
    NSString* messageType= [self.jsonContent valueForKey:KEY_MESSAGE_TYPE];
    NSString * docsdir = [HttpHelper docFilePath];
    UIImage* image;
    if([MESSAGE_TYPE_VIDEO isEqualToString:messageType]){
        NSString *dataFilePath = [docsdir stringByAppendingPathComponent:[self.jsonContent valueForKey:KEY_FILE_PATH]];
        NSURL *videoFileUrl =  [NSURL fileURLWithPath:dataFilePath];
        dataFilePath =[dataFilePath stringByReplacingOccurrencesOfString:@".MP4" withString:@".jpeg"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir;
        BOOL existing =[fileManager fileExistsAtPath:dataFilePath isDirectory:&isDir];
        if (!existing) {
            if([fileManager fileExistsAtPath:videoFileUrl.path isDirectory:&isDir]){
                image = [UIImage pk_previewImageWithVideoURL:videoFileUrl];
                if(image!=NULL){
                    [HttpHelper saveImageToSandbox:image sandBoxPath:dataFilePath];
                }
            }
        }else{
            image =[UIImage imageWithContentsOfFile:dataFilePath];
        }
        if(image==nil||image==NULL){
            image = [UIImage imageNamed:@"pic_fail"];
        }
        
    }else if([MESSAGE_TYPE_IMAGE isEqualToString:messageType]){
        NSString *dataFilePath = [docsdir stringByAppendingPathComponent:[self.jsonContent valueForKey:KEY_FILE_PATH]];
        image =[UIImage imageWithContentsOfFile:dataFilePath];
        if(image == NULL){
            image = [UIImage imageNamed:@"pic_failed"];
        }
        
    }
    return image;
}

@end
