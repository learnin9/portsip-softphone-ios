//
//  History.m
//  PortGo
//
//  Created by Joe Lepple on 3/27/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "History.h"
#import "PPStickerDataManager.h"

// private implementation
@interface History(Private)
-(NSComparisonResult)compareEntryByDate:(History *)otherEntry;
@end

@implementation History(Private)

-(NSComparisonResult)compareEntryByDate:(History *)otherEntry{
    NSTimeInterval diff = self.mTimeStart - otherEntry.mTimeStart;
	return diff==0 ? NSOrderedSame : (diff > 0 ?  NSOrderedAscending : NSOrderedDescending);
}

@end

@implementation History
@synthesize mHistoryID;
@synthesize mRemoteParty;
@synthesize mRemotePartyDisplayName;
@synthesize mTimeStart;
@synthesize mTimeEnd;
@synthesize mMediaType;
@synthesize mStatus;
@synthesize mContent;

-(id) initWithName:(int)historyID
     byRemoteParty:(NSString*)remoteParty
     byDisplayName:(NSString*)remotePartyDisplayName
      byLocalParty:(NSString*)localParty
byLocalDisplayname:(NSString*)localDisplayname
       byTimeStart:(NSTimeInterval)timeStart
        byTimeStop:(NSTimeInterval)timeStop
        byMediaype:(int)mediaType
      byCallStatus:(int)status
         byContent:(NSData*)content
{
    self = [super init];
    if (self)
    {
        mHistoryID = historyID;
        mRemoteParty = remoteParty;
        mRemotePartyDisplayName = remotePartyDisplayName;
        _localParty = localParty;
        _localDisplayname = localDisplayname;
        mTimeStart = timeStart;
        mTimeEnd = timeStop;
        mMediaType = mediaType;
        mStatus = status;
        mContent = content;
        _mimeType = nil;
        mPlayLong = 0;
        _mRead = 1;
        mHistoryEventDate = [[NSDateFormatter alloc] init];
        [mHistoryEventDate setTimeStyle:NSDateFormatterShortStyle];
        [mHistoryEventDate setDateStyle:NSDateFormatterShortStyle];
    }
    return self;
}

-(NSString*) getTimeStart
{
    NSDate *start = [NSDate dateWithTimeIntervalSince1970:[self mTimeStart]];
    NSTimeInterval timeStart = [self mTimeStart];
    NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
    //NSDate *dateNow = [[NSDate alloc] init];
    
    NSTimeInterval timeToday = timeNow - ((long)timeNow % 86400);
    NSTimeInterval timeThisWeek = timeNow - ((long)timeNow % 86400) - (86400 * 6);
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    if(timeStart > timeToday)
    {
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    }
    else if(timeStart > timeThisWeek)
    {
        [dateFormatter setDateFormat:@"EEEE"];   
    }
    else
    {
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    
    return [dateFormatter stringFromDate:start];
    //return [mHistoryEventDate stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self mTimeStart]]];
}

-(NSString*) getDetailsTimeStart
{
    return [mHistoryEventDate stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self mTimeStart]]];
}

-(NSString*) getTimeDuration
{
    NSTimeInterval callTime = [self mTimeEnd] - [self mTimeStart];
    return [NSString stringWithFormat:@"%02li:%02li:%02li",
                        lround(floor(callTime / 3600.)) % 100,
                        lround(floor(callTime / 60.)) % 60,
                        lround(floor(callTime)) % 60];
}

-(NSString*)getContentAsString{
	if(!contentAsString && mContent){
		contentAsString = [[NSString alloc] initWithData:mContent encoding:NSUTF8StringEncoding];
	}
	return contentAsString;
}

+(NSString *)convertToJsonString:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
//
    return jsonString;
}

+(NSData *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    if (!jsonData) {
        NSLog(@"%@",error);
    }
    
    return jsonData;
}
+(NSDictionary*) construtVideoMessage:(NSString*)filePath loadUrl:(NSString*)url mimeType:(NSString*)mime FileSize:(long)fileSize AVDuration:(int)duration{
    NSArray* keys = @[KEY_MESSAGE_TYPE,KEY_FILE_URL,KEY_FILE_PATH,KEY_FILE_NAME,KEY_MIME, KEY_AV_DURATION,KEY_FILE_SIZE];
    NSArray* values = @[MESSAGE_TYPE_VIDEO,url,filePath,[filePath lastPathComponent],mime,[NSNumber numberWithInt:duration],[NSNumber numberWithLong:duration]];
    NSDictionary* diction= [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    return diction;
}
+(NSDictionary*) construtAudioMessage:(NSString*)filePath loadUrl:(NSString*)url mimeType:(NSString*)mime FileSize:(long)fileSize AVDuration:(int)duration{
    NSArray* keys = @[KEY_MESSAGE_TYPE,KEY_FILE_URL,KEY_FILE_PATH,KEY_FILE_NAME,KEY_MIME,KEY_AV_DURATION,KEY_FILE_SIZE];
    NSArray* values = @[MESSAGE_TYPE_AUDIO,url,filePath,[filePath lastPathComponent],mime,[NSNumber numberWithInt:duration],[NSNumber numberWithLong:duration]];
    NSDictionary* diction= [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    return diction;
}
+(NSDictionary*) construtImageMessage:(NSString*)filePath loadUrl:(NSString*)url mimeType:(NSString*)mime FileSize:(long)fileSize ImageWidth:(int)width ImageHeight:(int)height{
    NSArray* keys = @[KEY_MESSAGE_TYPE,KEY_FILE_URL,KEY_FILE_PATH,KEY_FILE_NAME,KEY_MIME,KEY_FILE_SIZE,KEY_RESOLUTION_WIDTH,KEY_RESOLUTION_HEIGHT];
    NSArray* values = @[MESSAGE_TYPE_IMAGE,url,filePath,[filePath lastPathComponent],mime,[NSNumber numberWithLong:fileSize],[NSNumber numberWithInt:width],[NSNumber numberWithInt:height]];
    NSDictionary* diction= [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    return diction;
}
+(NSDictionary*) construtTextMessage:(NSString*)text{
    NSArray* keys = @[KEY_MESSAGE_TYPE,KEY_TEXT_CONTENT];
    NSArray* values = @[MESSAGE_TYPE_TEXT,text==nil?NSLocalizedString(@"UnknowFormat_UnknowFormat", @"UnknowFormat_UnknowFormat"):text];
    NSDictionary* diction= [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    return diction;
}
+(NSDictionary*) construtFileMessage:(NSString*)fileName FilePath:(NSString*)filePath loadUrl:(NSString*)url mimeType:mime  FileSize:(long)fileSize{
    NSArray* keys = @[KEY_MESSAGE_TYPE,KEY_FILE_URL,KEY_FILE_PATH,KEY_FILE_NAME,KEY_MIME, KEY_FILE_SIZE];
    NSArray* values = @[MESSAGE_TYPE_FILE,url,filePath,fileName,mime,[NSNumber numberWithLong:fileSize]];
    NSDictionary* diction= [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    return diction;
}
+(NSDictionary*) parserMessage:(NSString*)message{
    if (message == nil) {
        return nil;
    }
    
    NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *diction = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        return [History construtTextMessage:message];
    }
    return diction;
}
-(NSDictionary*)getJsonContent{
    if(mJsonContent==nil){
        mJsonContent = [History parserMessage:self.getContentAsString];
    }
    return mJsonContent;
}

-(NSString*)getMessageDescription{
    NSString* messageDesc=nil;
    NSString* msgType = [[self getJsonContent] valueForKey:KEY_MESSAGE_TYPE];

    if ([MESSAGE_TYPE_TEXT isEqualToString:msgType]) {
        NSString* messageContent = [mJsonContent valueForKey:KEY_TEXT_CONTENT];
        messageContent= (messageContent==nil?NSLocalizedString(@"UnknowFormat_UnknowFormat", @"UnknowFormat_UnknowFormat"):messageContent);
        messageDesc = [PPStickerDataManager.sharedInstance getDescString:messageContent];
    }else if ([MESSAGE_TYPE_AUDIO isEqualToString:msgType]){
        messageDesc = NSLocalizedString(@"VoiceMessage_VoiceMessage", @"VoiceMessage_VoiceMessage");
    }else if ([MESSAGE_TYPE_IMAGE isEqualToString:msgType])
    {
        messageDesc = NSLocalizedString(@"imageimage_imageimage", @"imageimage_imageimage");
    }else if ([MESSAGE_TYPE_VIDEO isEqualToString:msgType]){
        messageDesc= NSLocalizedString(@"shortvideo_shortvideo", @"shortvideo_shortvideo");
    }else if([MESSAGE_TYPE_FILE isEqualToString:msgType])
    {//文件格式，使用文本内容
        messageDesc = [mJsonContent valueForKey:KEY_FILE_NAME];//NSLocalizedString(@"FileMessage_FileMessage", @"FileMessage_FileMessage");
    }else{
        messageDesc = NSLocalizedString(@"UnknowFormat_UnknowFormat", @"UnknowFormat_UnknowFormat");
    }
    return messageDesc;
}

-(void) dealloc
{
    self.mRemoteParty = nil;
    self.mRemotePartyDisplayName = nil;
    _localParty = nil;
    _localDisplayname = nil;
    self.mimeType = nil;
}
@end
