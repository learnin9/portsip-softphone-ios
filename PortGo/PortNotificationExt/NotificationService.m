//
//  NotificationService.m
//  PortNotificationExt
//
//  Created by PortSip on 2019/11/15.
//  Copyright © 2019 PortSIP Solutions, Inc. All rights reserved.
//

#import "NotificationService.h"
//#import "AppDelegate.h"
#import "DataBaseManage.h"
#import "History.h"
#import "HttpHelper.h"
#import "NSString+HSFilterString.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...

    //[NSString stringWithFormat:@"_%@ ", self.bestAttemptContent.title];
    
    NSDictionary *aps = self.bestAttemptContent.userInfo[@"aps"];//
    
    NSString *msg_type = self.bestAttemptContent.userInfo[@"msg_type"];
    NSString *send_to = self.bestAttemptContent.userInfo[@"send_to"];
    NSString *send_from = self.bestAttemptContent.userInfo[@"send_from"];

    //NSData *data = [messageContent dataUsingEncoding:NSUTF8StringEncoding];
    if([msg_type isEqualToString:@"im"]){
        NSString *pushid = self.bestAttemptContent.userInfo[@"x-push-id"];
        NSString *message_id = self.bestAttemptContent.userInfo[@"message_id"];
        NSString *mime_type = self.bestAttemptContent.userInfo[@"mime_type"];
        NSTimeInterval recvTime = [[NSDate date] timeIntervalSince1970];
        NSArray *mimes = [mime_type componentsSeparatedByString:@"/"];
        NSDictionary* alterContent = aps[@"alert"];
        NSString* messageContent = alterContent[@"body"];
        message_id = pushid;
        
        if(mimes.count!=2){
            mimes = [[NSArray alloc] initWithObjects:@"text", @"plain",nil];
        }
        self.bestAttemptContent.title = [self onRecvOutOfDialogMessage:send_from from:send_from toDisplayName:send_to to:send_to mimeType:mimes[0]
                                                       subMimeType:mimes[1]
                                                       messageData:messageContent messageID:(long)[message_id longLongValue] messageTime:recvTime];
    }else{
        
    }
    self.contentHandler(self.bestAttemptContent);
}

- (NSString *)getShortRemoteParty:(NSString *)caller
                        andCallee:(NSString *)callee {
  NSString *remoteParty = caller; //[[NSString alloc] initWithCString:(const
  // char*)caller encoding:NSUTF8StringEncoding];
  NSString *localParty = callee; //[[NSString alloc] initWithCString:(const
                                 // char*)callee encoding:NSUTF8StringEncoding];

  // remove remote party "sip:", From sip:x@y:Port to x@y:Port
  if ([remoteParty hasPrefix:@"SIP:"] || [remoteParty hasPrefix:@"sip:"]) {
    remoteParty = [remoteParty substringFromIndex:4];
  } // remove local party "sip:"
  if ([localParty hasPrefix:@"SIP:"] || [localParty hasPrefix:@"sip:"]) {
    localParty = [localParty substringFromIndex:4];
  }

  // if has port ,remove it. From x@y:Port to x@y
  NSArray *separatByPort = [remoteParty componentsSeparatedByString:@":"];
  remoteParty = [separatByPort objectAtIndex:0];

  separatByPort = [localParty componentsSeparatedByString:@":"];
  localParty = [separatByPort objectAtIndex:0];

  return remoteParty;
}
- (NSString*)onRecvOutOfDialogMessage:(NSString *)fromDisplayName
                          from:(NSString *)from
                 toDisplayName:(NSString *)toDisplayName
                            to:(NSString *)to
                      mimeType:(NSString *)mimeType
                   subMimeType:(NSString *)subMimeType
                   messageData:(NSString *)messageData
                     messageID:(long)messageID
                   messageTime:(long)time {
    if (!([mimeType isEqualToString:@"text"] &&
          [subMimeType isEqualToString:@"plain"]) &&
        !([MIME_MEDIA_APP hasPrefix:mimeType] &&
          [MIME_MEDIA_APP_JSON hasPrefix:subMimeType])) {
      return @"";
    }

    History *message = [databaseManage selectMessageByMessageId:messageID];
    if (message != nil) //此ID对应的消息已经处理
      return @"";
    NSString *remoteParty = [self getShortRemoteParty:from andCallee:to];
    NSString *localParty = [self getShortRemoteParty:to andCallee:from];
    NSString *remoteDisplayName = fromDisplayName;

    if (remoteDisplayName == nil ||
        [remoteDisplayName
            stringByTrimmingCharactersInSet:[NSCharacterSet
                                                whitespaceAndNewlineCharacterSet]]
                .length == 0) {
      remoteDisplayName = [remoteParty getUriUsername:remoteParty];
    }
    ////////
    NSTimeInterval recvTime = time;

    NSData *data = [messageData dataUsingEncoding:NSUTF8StringEncoding];
    //Contact *contact = [contactView getContactByPhoneNumber:from];
    NSString *nickName = nil;
//    if (contact != nil) {
//      nickName = contact.displayName;
//    } else {
      nickName = remoteDisplayName;
//    }


    History *history =
        [[History alloc] initWithName:0
                        byRemoteParty:remoteParty
                        byDisplayName:nickName
                         byLocalParty:localParty
                   byLocalDisplayname:toDisplayName
                          byTimeStart:recvTime
                           byTimeStop:recvTime
                           byMediaype:MediaType_Chat
                         byCallStatus:INCOMING_SUCESS
                            byContent:data];

    int historyid = -1;
    NSDictionary *jsonConent = [History parserMessage:messageData];
    NSString *msgType = [jsonConent valueForKey:KEY_MESSAGE_TYPE];
    NSString *loadUrl = [jsonConent valueForKey:KEY_FILE_URL];
    NSString *fileName = [jsonConent valueForKey:KEY_FILE_NAME];

    NSString *totalMimetype =
        [mimeType stringByAppendingPathComponent:subMimeType];

    NSString *messageType = NSLocalizedString(@"Unknow_Message", "message");

    if ([MESSAGE_TYPE_AUDIO isEqualToString:msgType]) {
      messageType = NSLocalizedString(@"Audio_Message", "audio message");

      if (loadUrl == NULL || loadUrl == nil || loadUrl.length < 1) {
        history.mStatus = INCOMING_ATTACHFAILED;
      } else {
        history.mStatus = INCOMING_PROCESSING; //有附件需要处理
      }
      history.mRead = FALSE;
#if false
      historyid = [databaseManage insertChatHistory:messageID
                                        withHistory:history
                                           mimetype:totalMimetype
                                           playLong:0];
      if (historyid > 0 && history.mStatus == INCOMING_PROCESSING) {
        NSString *mime = [NSString
            stringWithFormat:@"%@%@", MIME_MEDIA_AUDIO, MIME_MEDIA_AUDIO_AMR];
        [httpHelper downloadFile:loadUrl
                        filepath:@""
                        mimetype:mime
                       historyid:historyid];
      }
#endif

    } else if ([MESSAGE_TYPE_VIDEO isEqualToString:msgType]) {

      messageType = NSLocalizedString(@"Video_Message", "video message");
#if false
      if (loadUrl == NULL || loadUrl == nil || loadUrl.length < 1) {
        history.mStatus = INCOMING_ATTACHFAILED;
      } else {
        history.mStatus = INCOMING_PROCESSING; //有附件需要处理
      }
      historyid = [databaseManage insertChatHistory:messageID
                                        withHistory:history
                                           mimetype:totalMimetype
                                           playLong:0];
      if (historyid > 0 && history.mStatus == INCOMING_PROCESSING) {
        NSString *mime = [NSString
            stringWithFormat:@"%@%@", MIME_MEDIA_VIDEO, MIME_MEDIA_VIDEO_MP4];
        [httpHelper downloadFile:loadUrl
                        filepath:@""
                        mimetype:mime
                       historyid:historyid];
      }
#endif

    } else if ([MESSAGE_TYPE_IMAGE isEqualToString:msgType]) {
      messageType = NSLocalizedString(@"Image_Message", "image message");
#if false
      if (loadUrl == NULL || loadUrl == nil || loadUrl.length < 1) {
        history.mStatus = INCOMING_ATTACHFAILED;
      } else {
        history.mStatus = INCOMING_PROCESSING; //有附件需要处理
      }
      historyid = [databaseManage insertChatHistory:messageID
                                        withHistory:history
                                           mimetype:totalMimetype
                                           playLong:0];
      if (historyid > 0 && history.mStatus == INCOMING_PROCESSING) {
        NSString *mime = [NSString
            stringWithFormat:@"%@%@", MIME_MEDIA_IMAGE, MIME_MEDIA_IMAGE_JPG];
        [httpHelper downloadFile:loadUrl
                        filepath:@""
                        mimetype:mime
                       historyid:historyid];
      }
#endif

    } else if ([MESSAGE_TYPE_FILE isEqualToString:msgType]) {

      messageType = NSLocalizedString(@"File_Message", "file message");
#if false
      if (loadUrl == NULL || loadUrl == nil || loadUrl.length < 1) {
        history.mStatus = INCOMING_ATTACHFAILED;
      } else {
        history.mStatus = INCOMING_PROCESSING; //有附件需要处理
      }
      historyid = [databaseManage insertChatHistory:messageID
                                        withHistory:history
                                           mimetype:totalMimetype
                                           playLong:0];
      if (historyid > 0 && history.mStatus == INCOMING_PROCESSING) {
        NSString *mime =
            [NSString stringWithFormat:@"%@%@", CUSTOM_MIME_MEDIA_FILE, fileName];
        [httpHelper downloadFile:loadUrl
                        filepath:@""
                        mimetype:mime
                       historyid:historyid];
      }
#endif
    } else { // text 或其他不处理的mime 直接设置为成功
#if false
      historyid = [databaseManage insertChatHistory:messageID
                                        withHistory:history
                                           mimetype:totalMimetype
                                           playLong:0];
#endif
    }

     NSString *alterMessage = [NSLocalizedString(
    @"Message_Tips", @"You have received a message from disname.")
    stringByReplacingOccurrencesOfString:@"disname"
                              withString:nickName];
    return [alterMessage stringByReplacingOccurrencesOfString:@"message" withString:messageType];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
