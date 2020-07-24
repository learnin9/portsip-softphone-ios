//
//  History.h
//  PortGo
//
//  Created by Joe Lepple on 3/27/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_MESSAGE_TYPE @"type"
#define KEY_TEXT_CONTENT @"content"
#define MESSAGE_TYPE_TEXT @"text"
#define MESSAGE_TYPE_AUDIO @"audio"
#define MESSAGE_TYPE_VIDEO @"video"
#define MESSAGE_TYPE_IMAGE @"image"
#define MESSAGE_TYPE_FILE @"file"
#define KEY_FILE_NAME @"fileName"
#define KEY_FILE_PATH @"filePath"
#define KEY_FILE_SIZE @"fileSize"
#define KEY_FILE_URL @"url"
#define KEY_MIME @"mime"
#define KEY_AV_DURATION @"duration"
#define KEY_RESOLUTION_WIDTH @"width"
#define KEY_RESOLUTION_HEIGHT @"height"


typedef enum HistoryEventStatus_e{
	HistoryEventStatus_Outgoing = 0x01<<0,
	HistoryEventStatus_Incoming = 0x01<<1,
	HistoryEventStatus_Missed = 0x01<<2,
	HistoryEventStatus_Failed = 0x01<<3,
    HistoryEventStatus_Processing = 0x01<<4,//处理中
    HistoryEventStatus_AttachFailed = 0x01<<5,//附件处理失败
    
    //消息写入数据库，但尚未发送。（多媒体文件，异步传送，而且要传送成功才能获取url，url为发送给对方必须的）
	
    HistoryEventStatus_All = 0xFFFF,
}

#define OUTGOING_SUCESS HistoryEventStatus_Outgoing
#define OUTGOING_FAILED HistoryEventStatus_Outgoing|HistoryEventStatus_Failed
#define OUTGOING_ATTACHFAILED HistoryEventStatus_Outgoing|HistoryEventStatus_AttachFailed
#define OUTGOING_PROCESSING HistoryEventStatus_Outgoing|HistoryEventStatus_Processing

#define INCOMING_SUCESS HistoryEventStatus_Incoming
#define INCOMING_FAILED (HistoryEventStatus_Incoming|HistoryEventStatus_Failed)
#define INCOMING_ATTACHFAILED (HistoryEventStatus_Incoming|HistoryEventStatus_AttachFailed)
#define INCOMING_PROCESSING (HistoryEventStatus_Incoming|HistoryEventStatus_Processing)

#define IS_EVENT_FAILED(status) ((status&HistoryEventStatus_Failed)>0)
#define IS_EVENT_ATTACHFAILED(status) ((status&HistoryEventStatus_AttachFailed)>0)

#define IS_EVENT_PROCESSING(status) ((status&HistoryEventStatus_Processing)>0)

#define IS_EVENT_OUTGOING(status) (status&HistoryEventStatus_Outgoing)>0
#define IS_EVENT_OUTGOING_SUCCESS(status) (status==HistoryEventStatus_Outgoing)
#define IS_EVENT_OUTGOING_ATTACHFAILED(status) (IS_EVENT_OUTGOING(status)&&IS_EVENT_ATTACHFAILED(status))
#define IS_EVENT_OUTGOING_FAILED(status)  (IS_EVENT_OUTGOING(status)&&IS_EVENT_FAILED(status))

#define IS_EVENT_INCOMING(status) ((status&HistoryEventStatus_Incoming)>0)
#define IS_EVENT_INCOMING_SUCESS(status) (status==HistoryEventStatus_Incoming)
#define IS_EVENT_INCOMING_ATTACHFAILED(status) (IS_EVENT_INCOMING(status)&&IS_EVENT_ATTACHFAILED(status))
#define IS_EVENT_INCOMING_FAILED(status) (IS_EVENT_INCOMING(status)&&IS_EVENT_FAILED(status))

HistoryEventStatus_t;

typedef enum MediaType_e {
	// Very Important: These values are stored in the data base and MUST never
	// be changed. If you want to add new type, please add it after "MediaType_Msrp"
	MediaType_None = 0,
	MediaType_Audio = (0x01<<0),
	MediaType_Video = (0x01<<1),
	MediaType_AudioVideo = MediaType_Audio | MediaType_Video,
	MediaType_SMS = (0x01<<2),
	MediaType_Chat = (0x01<<3),
	MediaType_FileTransfer = (0x01<<4),
    MediaType_IMMsg = (0x01<<5),
	MediaType_Msrp = MediaType_Chat | MediaType_FileTransfer,
	// --- Add you media type after THIS LINE ---
	
	// --- Add you media type before THIS LINE ---
    
    MediaType_Message = MediaType_Chat | MediaType_IMMsg,
	
	MediaType_All = MediaType_AudioVideo | MediaType_Msrp
}
MediaType_t;

@interface History : NSObject{

	NSString* mRemoteParty;
	NSString* mRemotePartyDisplayName;
    
    NSDictionary* mJsonContent;
    NSTimeInterval mTimeEnd;
    
    int     mMediaType;//
    int     duration;
    NSString* mDesc;
    NSData* mContent;
    NSString* contentAsString;
    int mPlayLong;
@private
    NSDateFormatter*  mHistoryEventDate;
}

@property int mHistoryID;
@property int historyCount;
@property (nonatomic,retain) NSString *mRemoteParty;
@property (nonatomic,retain) NSString *mRemotePartyDisplayName;
@property (nonatomic, copy) NSString *localParty;
@property (nonatomic, copy) NSString *localDisplayname;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic,assign)int mSessionId;
@property NSTimeInterval mTimeStart;
@property NSTimeInterval mTimeEnd;
@property int mMediaType;
@property int mStatus;
@property int mPlayDuration;

@property int mSendOut;
@property (readonly,nonatomic, copy,getter=getMessageDescription)NSString* mDesc;

@property Boolean mRead;
@property(readwrite,retain) NSData* mContent;

-(id) initWithName:(int)historyID
     byRemoteParty:(NSString*)remoteParty
     byDisplayName:(NSString*)remotePartyDisplayName
      byLocalParty:(NSString*)localParty
byLocalDisplayname:(NSString*)localDisplayname
       byTimeStart:(NSTimeInterval)timeStart
        byTimeStop:(NSTimeInterval)timeStop
        byMediaype:(int)mediaType
      byCallStatus:(int)status
         byContent:(NSData*)content;

-(NSString*) getTimeStart;
-(NSString*) getDetailsTimeStart;
-(NSString*) getTimeDuration;
-(NSString*)getContentAsString;
-(NSDictionary*)getJsonContent;

+(NSData *)convertToJsonData:(NSDictionary *)dict;
+(NSString *)convertToJsonString:(NSDictionary *)dict;
+(NSDictionary*) construtVideoMessage:(NSString*)filePath loadUrl:(NSString*)url mimeType:(NSString*)mime FileSize:(long)fileSize AVDuration:(int)duration;
+(NSDictionary*) construtAudioMessage:(NSString*)filePath loadUrl:(NSString*)url mimeType:(NSString*)mime FileSize:(long)fileSize AVDuration:(int)duration;
+(NSDictionary*) construtImageMessage:(NSString*)filePath loadUrl:(NSString*)url mimeType:(NSString*)mime FileSize:(long)fileSize ImageWidth:(int)width ImageHeight:(int)height;
+(NSDictionary*) construtTextMessage:(NSString*)text;
+(NSDictionary*) construtFileMessage:(NSString*)fileName FilePath:(NSString*)filePath loadUrl:(NSString*)url mimeType:(NSString*)mime FileSize:(long)fileSize;
+(NSDictionary*) parserMessage:(NSString*)message;
@end
