//
//  HttpHelper.h
//  PortGo
//
//  Created by PortSip on 2019/4/4.
//  Copyright © 2019 PortSIP Solutions, Inc. All rights reserved.
//

#ifndef HttpHelper_h
#define HttpHelper_h
#import "AFNetworking-umbrella.h"
#import "Account.h"

#define MEDIATYPE_JSON @"application/json"
#define MEDIATYPE_EXPORT_JSON @"application/x-export-json"
#define MEDIAFILE_PAHT @"fiawefksdnv"
#define MEDIA_THUMBNAIL_FILE_PAHT @"thum"
#define HTTP_HEADER @"http://"
#define HTTPS_HEADER @"https://"
#define GATEWAY_BASEURL @"gateway.oncall.vn"
#define FILE_BASEURL @"file.oncall.vn"

#define OFFLINE_MESSAGE_BASEURL_PORT 8899
#define OFFLINE_MESSAGE_BASEURL_HTTPSPORT 8900
#define FILE_BASEURL_PORT 9333


#define KEY_ACCESSTOKEN @"access_token"
#define KEY_EXTENSIONID @"id"
#define SCHEAM_VERIFY @"/api/account/extension/sip/verify"
#define VERIFY_KEY_DOMAIN @"domain"
#define VERIFY_KEY_NAME @"extension_number"
#define VERIFY_KEY_PWD @"sip_password"
#define VERIFY_RESULT_KEY_EXPIRES @"expires"
#define VERIFY_RESULT_KEY_API_VERSION @"api_version"

#define SCHEAM_UPDATE @"/api/comm_message/update"
#define UPDATE_KEY_MSGID @"msg_ids"

#define SCHEAM_CONTACT_LIST @"/api/comm_message/contact_list"
#define UPDATE_KEY_PAG @"pagination"
#define UPDATE_KEY_STATUS @"status"

#define CONTACT_RESULT_KEY_COUNT @"count"
#define CONTACT_RESULT_KEY_EXTENSIONS @"extensions"
#define CONTACT_RESULT_KEY_EXTENSION_NUM @"extension_number"

#define SCHEAM_UNREAD_COUNT @"/api/comm_message/unread_count/show"

#define UNREAD_KEY_SEND @"sender_extension"
#define UNREAD_KEY_RECEIVER @"receiver_extension"
#define UNREAD_RESULT_KEY_COUNT @"count"


#define SCHEAM_LIST @"/api/comm_message/list"

#define SCHEAM_LIST_MOD_NORMAL @"NORMAL"
#define SCHEAM_LIST_MOD_AFTER @"SPECIFY_LIST_AFTER"
#define SCHEAM_LIST_MOD_BEFORE @"SPECIFY_LIST_BEFOR"
#define SCHEAM_LIST_MOD_TIME @"TIME_DISTANCE"

#define LIST_RESULT_KEY_MESSAGES @"messages"
#define LIST_RESULT_KEY_MESSAGE_ID @"id"
#define LIST_RESULT_KEY_MESSAGE_BODY @"msg_body"
#define LIST_RESULT_KEY_MESSAGE_TYPE @"msg_type"
#define LIST_RESULT_KEY_MESSAGE_TIME @"post_time"
#define LIST_RESULT_KEY_MESSAGE_SEND @"is_send"
#define LIST_RESULT_KEY_MESSAGE_SENDID @"sender_extension_id"
#define LIST_KEY_SENDER @"sender_extension"
#define LIST_KEY_RECEIVER @"receiver_extension"
#define LIST_KEY_PAG @"pagination"
#define LIST_KEY_MOD @"list_mode"

#define LIST_KEY_MESSAGEID @"specify_msg_id"
#define LIST_KEY_TIME_STAR @"time_start"
#define LIST_KEY_TIME_STOP @"time_end"
#define LIST_KEY_LIMITED_COUNT @"limit_count"
#define DEFAULT_COUNT_LIST_KEY_LIMITED_COUNT 100

#define SCHEAM_FILE_UPLOAD @"/submit"
#define UPLOAD_KEY_MEDIATYPE @"media_type"
#define FILEUPDATE_RESULT_KEY_FID @"fid"
#define FILEUPDATE_RESULT_KEY_FILEID @"fileid"
#define FILEUPDATE_RESULT_KEY_fILENAME @"fileName"
#define FILEUPDATE_RESULT_KEY_ETAG @"eTag"
#define FILEUPDATE_RESULT_KEY_SIZE @"size"
#define FILEUPDATE_RESULT_KEY_URL @"fileUrl"
#define FILEUPDATE_RESULT_KEY_ID @"id"

#define SCHEAM_FILE_DOWNLOAD @"/submit"
#define SCHEAM_FILE_DELETE @"/delete"
#define DELETE_KEY_FILEID @"fid"
#define DELETE_KEY_TENENTID @"tenantid"
#define httpHelper [HttpHelper shareHttpHelperSingleton]
@protocol OffLineMessageDelegate <NSObject>
- (void)onRecvOfflineDialogMessage:(long)messageId
                   fromDisplayName:(NSString*)fromDisplayName
                              from:(NSString*)from
                     toDisplayName:(NSString *)toDisplayName
                                to:(NSString *)to
                          mimeType:(NSString *)mimeType
                       subMimeType:(NSString *)subMimeType
                       messageData:(NSString *)messageData
                       messageTime:(long)time;
-(long)sendOutOfDialogMessage:(NSString *)sendTo
                     mimeType:(NSString *)mimetype
                  subMimeType:(NSString *)subMimeType
                        isSMS:(bool)smsMessage
                      message:(NSData*)data
                messageLength:(int)dataLength;
@end


@interface HttpHelper:NSObject{
//    NSOperationQueue* operations;
//    __block NSBlockOperation* accessOperation;
//
//    __block NSString* accesstoken;
//    __block long accesstokenTime;
//    Account* accessAccount;
}
@property (atomic, strong) __block NSBlockOperation * accessOperation;
@property (atomic, strong) __block NSBlockOperation * accessResultOperation;
@property (nonatomic, strong)__block NSOperationQueue * operations;
@property (nonatomic, strong) AFHTTPSessionManager * afManager;
@property __block NSString* accesstoken;
@property __block NSString* apiVersion;
@property __block long extensionId;
@property __block long accesstokenTime;
@property Account* accessAccount;
@property (nonatomic, weak)id<OffLineMessageDelegate> offlineMsgDelegate;

+(HttpHelper *)shareHttpHelperSingleton;

+ (NSString*)docFilePath;

+ (BOOL)saveImageToSandbox:(UIImage*)image sandBoxPath:(NSString*)filePath;
+ (BOOL)saveAblumVideoToSandbox:(NSURL*)fileUrl sandBoxPath:(NSString*)filePath;
+ (BOOL)saveFileToSandbox:(NSURL*)fileUrl sandBoxPath:(NSString*)filePath;

-(void) accountVerify:(Account*)account;
-(void) offlineMessageContactList:(Account*)account pag:(NSString*)pag status:(NSString*)status;
-(void)offlineMessageListNormal:(Account*)account sender:(NSString*)sender receiver:(NSString*)receiver pag:(NSString*)pag;
-(void)offlineMessageListBetween:(Account*)account sender:(NSString*)sender receiver:(NSString*)receiver
                       timeStart:(NSNumber*)start timeEnd:(NSNumber*)end;
-(void)offlineMessageListAfter:(Account*)account sender:(NSString*)sender receiver:(NSString*)receiver
                     messageID:(NSNumber*)messageid;

-(void) offlineMessageUpdata:(Account*)account messages:(NSArray*)messages;
-(void) offlineMessageUnreadCount:(Account*)account sender:(NSString*)sender receiver:(NSString*)receiver;

-(void) offlineMessage:(Account*)account;
-(void) uploadFile:(Account*)account mediatype:(NSString*)type fileurl:(NSURL*)file messageid:(long)messageId;
-(void)downloadFile:(NSString*)fileUrl filepath:filePath mimetype:(NSString*)mimetype historyid:(int)historyid;
-(void) deleteFile:(Account*)account;
-(void) cancelAll;
@end


#endif /* HttpHelper_h */
