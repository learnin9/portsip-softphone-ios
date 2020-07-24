//
//  HttpHelper.m
//  PortSIP
//
//  Created by PortSip on 2019/4/4.
//  Copyright © 2019 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Network/Network.h>
#import "HttpHelper.h"
#import <Photos/Photos.h>
#import "DataBaseManage.h"
#import "HSChatSession.h"
#import "VoiceConverter.h"
#import "NSString+HSFilterString.h"

@implementation HttpHelper

+(HttpHelper *)shareHttpHelperSingleton
{
    static HttpHelper *mhttpHelper= nil;
    @synchronized(self)
    {
        if (mhttpHelper == nil) {
            mhttpHelper = [[HttpHelper alloc]init];
            mhttpHelper.operations = [NSOperationQueue new];
            mhttpHelper.afManager = [AFHTTPSessionManager manager];
            mhttpHelper.afManager.requestSerializer = [AFJSONRequestSerializer serializer];
            //            mhttpHelper.afManager.responseSerializer = [AFJSONResponseSerializer serializer];
            
            mhttpHelper.afManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
            mhttpHelper.afManager.securityPolicy.allowInvalidCertificates = YES;
            [mhttpHelper.afManager.securityPolicy setValidatesDomainName:NO];
            
            mhttpHelper.afManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text//json",@"text/plain", @"text/html", nil];
            
        }
    }
    
    return mhttpHelper;
}

+ (NSString*)docFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    
    NSString *mediaFilePath = [docPath stringByAppendingPathComponent:MEDIAFILE_PAHT];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:mediaFilePath]){
        [fileManager createDirectoryAtPath:mediaFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return docPath;
}

+ (BOOL)saveImageToSandbox:(UIImage*)image sandBoxPath:(NSString*)filePath{
    NSLog(@"saveImageToSandbox filePath =%@",filePath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* directryPath = [filePath stringByDeletingLastPathComponent];
    
    if(![fileManager fileExistsAtPath:directryPath]){
        [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSData *imageData =UIImageJPEGRepresentation(image, 0.5);
    return [imageData writeToFile:filePath atomically:YES];
}

+ (BOOL)saveFileToSandbox:(NSURL*)file sandBoxPath:(NSString*)filePath{
    BOOL result =FALSE;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* directryPath = [filePath stringByDeletingLastPathComponent];
    
    if(![fileManager fileExistsAtPath:directryPath]){
        [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    BOOL canAccessingResource = [file startAccessingSecurityScopedResource];
    if(canAccessingResource) {
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:file options:0 error:&error byAccessor:^(NSURL *newURL) {
            NSData *fileData = [NSData dataWithContentsOfURL:newURL];
            //            NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            //            NSString *documentPath = [arr lastObject];
            //            NSString *desFileName = [documentPath stringByAppendingPathComponent:@"myFile"];
            [fileData writeToFile:filePath atomically:YES];
        }];
        if (error==nil) {
            result= TRUE;
        }
    } else {
        // startAccessingSecurityScopedResource fail
    }
    [file stopAccessingSecurityScopedResource];
    
    return result;
}

+ (void)saveAblumVideoToSandbox:(NSURL*)fileUrl sandBoxPath:(NSString*)filePath{
    NSLog(@"saveAblumVideoToSandbox filePath =%@",filePath);
    PHFetchResult* fetchResult = [PHAsset fetchAssetsWithALAssetURLs:fileUrl options:nil];
    if (fetchResult.count > 0) {
        
        PHAsset *assetNew = [fetchResult firstObject];
        
        if (assetNew.mediaType == PHAssetMediaTypeVideo) {
            
            [[PHImageManager defaultManager] requestExportSessionForVideo:assetNew options:nil exportPreset:AVAssetExportPresetPassthrough resultHandler:^(AVAssetExportSession *exportSession, NSDictionary *info) {
                NSURL *outputURL = [NSURL fileURLWithPath:filePath];
                NSLog(@"this is the fin;path %@",outputURL);
                exportSession.outputFileType=AVFileTypeMPEG4;
                exportSession.outputURL=outputURL;
                [exportSession exportAsynchronouslyWithCompletionHandler:^{if (exportSession.status == AVAssetExportSessionStatusFailed) {NSLog(@"failed");
                    
                } else if(exportSession.status == AVAssetExportSessionStatusCompleted){NSLog(@"completed!");
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                    });
                }
                    
                }];
                
            }];
            
        }
    }
}

-(NSString *)getFileURL:(Account*)account fileSvrPort:(int)port scheam:(NSString *)scheam{
    NSString * url;
    
    url  = [NSString stringWithFormat:@"%@%@:%d%@",HTTP_HEADER,
            account.SIPServer.length==0?account.userDomain:account.SIPServer,port,scheam];
    
    return [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

-(NSString *)getGetWayURL:(Account*)account scheam:(NSString *)scheam{
    NSString * url;
    url = [NSString stringWithFormat:@"%@%@:%d%@",HTTP_HEADER,GATEWAY_BASEURL,OFFLINE_MESSAGE_BASEURL_PORT,scheam];
    
    return [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

-(NSString *)getGetWaySecureURL:(Account*)account scheam:(NSString *)scheam{
    NSString * url;
    
    url  = [NSString stringWithFormat:@"%@%@:%d%@",HTTPS_HEADER,
            account.SIPServer.length==0?account.userDomain:account.SIPServer,OFFLINE_MESSAGE_BASEURL_HTTPSPORT,scheam];
    
    return [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

-(void)accountVerify:(Account*)account{
    if(self.accessOperation == NULL){
        self.accessOperation = [NSBlockOperation blockOperationWithBlock:^(void){
            @try {
                NSLog(@"accountVerify start");
                NSString* domain = account.userDomain.length>0?account.userDomain:account.SIPServer;
                NSString* name = account.userName;
                NSString* pwd = account.password;
                NSString * url  = [self getGetWaySecureURL:account scheam:SCHEAM_VERIFY];
                
                domain = [domain stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                name =  [name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                pwd =  [pwd stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                NSDictionary *parameters = @{VERIFY_KEY_DOMAIN:domain,
                                             VERIFY_KEY_NAME:name,
                                             VERIFY_KEY_PWD:pwd
                };
                
                [self.afManager POST:url parameters:parameters headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
                } success:^void(NSURLSessionDataTask * task, id responseObject) {
                    self.accesstoken = responseObject[KEY_ACCESSTOKEN];
                    self.apiVersion = responseObject[VERIFY_RESULT_KEY_API_VERSION];
                    self.extensionId = [responseObject[KEY_EXTENSIONID] isKindOfClass:NSNumber.class]?
                    ((NSNumber*)responseObject[KEY_EXTENSIONID]).longValue:(long)((NSString*)responseObject[KEY_EXTENSIONID]).longLongValue;
                    
                    
                    [self.afManager.requestSerializer setValue:self.accesstoken forHTTPHeaderField:KEY_ACCESSTOKEN];
                    [self.afManager.requestSerializer setValue:MEDIATYPE_JSON forHTTPHeaderField:UPLOAD_KEY_MEDIATYPE];
                    NSNumber* duration = responseObject[VERIFY_RESULT_KEY_EXPIRES];
                    self.accesstokenTime = [NSDate new].timeIntervalSince1970 + duration.longValue;
                    if(self.accessResultOperation != NULL){
                        [self.accessResultOperation start];
                    }
                    self.accessResultOperation = NULL;
                    self.accessOperation = NULL;
                    NSLog(@"offlinex accountVerify success responseObject = %@",responseObject);
                } failure:^void(NSURLSessionDataTask * task, NSError * error) {
                    if(self.accessResultOperation != NULL){
                        [self.accessResultOperation start];
                    }
                    self.accessResultOperation = NULL;
                    self.accessOperation = NULL;
                    
                    NSLog(@"offlinex accountVerify fasle error = %@, task = %@",error,task);
                }];
                
            } @catch (NSException *exception) {
                NSLog(@"offlinex accountVerify fasle exception = %@",exception);
            } @finally {
                
            }
        }];
        [self.accessOperation start];
    }
}

-(void) offlineMessageUpdata:(Account*)account messages:(NSArray*)messages{
    
    //NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^(void){
    if(messages.count==0){
        return;
    }
    @try {
        
        NSString * url  = [self getGetWaySecureURL:account scheam:SCHEAM_UPDATE];
        NSDictionary *parameters = @{@"msg_ids":messages};
        [self.afManager POST:url parameters:parameters headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        } success:^void(NSURLSessionDataTask * task, id responseObject) {
            NSLog(@"offlinex offlineMessageUpdata responseObject = %@",responseObject);
        } failure:^void(NSURLSessionDataTask * task, NSError * error) {
            NSLog(@"offlinex offlineMessageUpdata error = %@, task = %@",error,task);
        }];
    } @catch (NSException *exception) {
        NSLog(@"offlinex accountVerify fasle exception = %@",exception);
    } @finally {
        
    }
    //}];
}

-(void)offlineMessageContactList:(Account*)account pag:(NSString*)pag status:(NSString*)status{
    NSString * url  = [self getGetWaySecureURL:account scheam:SCHEAM_CONTACT_LIST];
    
    pag =  [pag stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    status =  [status stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSDictionary *parameters = @{UPDATE_KEY_PAG:pag,
                                 UPDATE_KEY_STATUS:status};
    
    [self.afManager GET:url parameters:parameters headers:nil
               progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^void(NSURLSessionDataTask * task, id responseObject) {
        
        int count = ((NSString*)responseObject[CONTACT_RESULT_KEY_COUNT]).intValue;
        if(count>0){
            NSDictionary* extensionNums = responseObject[CONTACT_RESULT_KEY_EXTENSIONS];
            NSString* domain = [NSString stringWithFormat:@"@%@",account.userDomain.length>0?account.userDomain:account.SIPServer];
            NSString* local = [account.userName stringByAppendingString:domain];
            domain =  [domain stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            local =  [local stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            for(NSDictionary* extension in extensionNums ){
                
                [self offlineMessageUnreadCount:account sender:[extension[CONTACT_RESULT_KEY_EXTENSION_NUM] stringByAppendingString:domain] receiver:local];
            }
        }
        
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"offlinex offlineMessageContactList error = %@, task = %@",error,task);
    }];
    
}

- (void)offlineMessageUnreadCount:(Account*)account sender:(NSString*)sender receiver:(NSString*)receiver{
    NSString * url  = [self getGetWaySecureURL:account scheam:SCHEAM_UNREAD_COUNT];
    
    NSDictionary *parameters = @{UNREAD_KEY_RECEIVER:receiver,
                                 UNREAD_KEY_SEND:sender,
    };
    [self.afManager GET:url parameters:parameters headers:nil
               progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^void(NSURLSessionDataTask * task, id responseObject) {
        int count = ((NSString*)responseObject[UNREAD_RESULT_KEY_COUNT]).intValue;
        long messageID =  [databaseManage getLastReceivedMessageID:sender receiver:receiver];
        
        if(messageID >0&&count>0 ){
            
            [self offlineMessageListAfter:account sender:sender receiver:receiver messageID:[NSNumber numberWithLong:messageID]];
        }else{
            if(count>=0){
                int page = count/100;
                while (page>=0) {
                    [self offlineMessageListNormal:account sender:sender receiver:receiver pag:[NSString stringWithFormat:@"%d",page]];
                    page--;
                }
                //[[url valueForKeyPath:UNREAD_KEY_SEND]
            }
            //            int end = [[NSDate date] timeIntervalSince1970];
            //            int start = [[NSDate dateWithTimeIntervalSinceNow:-7*24*60*60] timeIntervalSince1970];
            //            [self offlineMessageListBetween:account sender:sender receiver:receiver timeStart:[NSNumber numberWithInt:start]
            //                                    timeEnd:[NSNumber numberWithInt:end]];
        }
        //NSLog(@"offlinex offlineMessageUnreadCount responseObject = %@",responseObject);
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"offlinex offlineMessageUnreadCount error = %@, task = %@",error,task);
    }];
}

-(void)offlineMessageListAfter:(Account*)account sender:(NSString*)sender receiver:(NSString*)receiver
                     messageID:(NSNumber*)messageid{
    NSString * url  = [self getGetWaySecureURL:account scheam:SCHEAM_LIST];
    NSDictionary *parameters = @{LIST_KEY_MOD:SCHEAM_LIST_MOD_AFTER,
                                 LIST_KEY_SENDER:sender,
                                 LIST_KEY_RECEIVER:receiver,
                                 LIST_KEY_MESSAGEID:messageid,
                                 LIST_KEY_LIMITED_COUNT:[NSString stringWithFormat:@"%d",DEFAULT_COUNT_LIST_KEY_LIMITED_COUNT]
    };
    [self.afManager GET:url parameters:parameters headers:nil
               progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^void(NSURLSessionDataTask * task, id responseObject) {
        //responseObject[KEY_ACCESSTOKEN];
        //responseObject[KEY_EXPIRES]
        int count = ((NSString*)responseObject[UNREAD_RESULT_KEY_COUNT]).intValue;
        if(count>0){
            NSDictionary* messages = responseObject[LIST_RESULT_KEY_MESSAGES];
            NSMutableArray* msgIds = [NSMutableArray new];
            NSNumber* messageId;
            for(NSDictionary* message in messages ){
                long extensionid = [message[LIST_RESULT_KEY_MESSAGE_SENDID] isKindOfClass:NSNumber.class]?
                ((NSNumber*)message[LIST_RESULT_KEY_MESSAGE_SENDID]).longValue:
                (long)((NSString*)message[LIST_RESULT_KEY_MESSAGE_SENDID]).longLongValue;
                
                
                if(self.extensionId == extensionid){
                    
                }else{
                    messageId = [self processOfflineMessageResult:message sender:sender receiver:receiver];
                    [msgIds addObject:messageId];
                }
            }
            [self offlineMessageUpdata:account messages:msgIds];
            if(count==DEFAULT_COUNT_LIST_KEY_LIMITED_COUNT){
                [self offlineMessageListAfter:account sender:sender receiver:receiver messageID:messageId];
                NSLog(@"offlineMessageListAfter sender=%@ messageId=%@",sender,messageId);
            }
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"loadmessage" object:nil];
        
        NSLog(@"offlinex offlineMessageListAfter responseObject = %@",responseObject);
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"offlinex offlineMessageListAfter error = %@, task = %@",error,task);
    }];
}

-(void)offlineMessageListBetween:(Account*)account sender:(NSString*)sender receiver:(NSString*)receiver
                       timeStart:(NSNumber*)start timeEnd:(NSNumber*)end{
    
    NSString * url  = [self getGetWaySecureURL:account scheam:SCHEAM_LIST];
    
    NSDictionary *parameters = @{LIST_KEY_MOD:SCHEAM_LIST_MOD_TIME,
                                 LIST_KEY_SENDER:sender,
                                 LIST_KEY_RECEIVER:receiver,
                                 LIST_KEY_TIME_STAR:start,
                                 LIST_KEY_TIME_STOP:end
    };
    [self.afManager GET:url parameters:parameters headers:nil
               progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^void(NSURLSessionDataTask * task, id responseObject) {
        int count = ((NSString*)responseObject[UNREAD_RESULT_KEY_COUNT]).intValue;
        if(count>0){
            NSDictionary* messages = responseObject[LIST_RESULT_KEY_MESSAGES];
            NSMutableArray* msgIds = [NSMutableArray new];
            for(NSDictionary* message in messages ){
                long extensionid = [message[LIST_RESULT_KEY_MESSAGE_SENDID] isKindOfClass:NSNumber.class]?
                ((NSNumber*)message[LIST_RESULT_KEY_MESSAGE_SENDID]).longValue:
                (long)((NSString*)message[LIST_RESULT_KEY_MESSAGE_SENDID]).longLongValue;
                
                if(self.extensionId == extensionid){
                }else{
                    NSNumber* messageId = [self processOfflineMessageResult:message sender:sender receiver:receiver];
                    [msgIds addObject:messageId];
                }
                
            }
            [self offlineMessageUpdata:account messages:msgIds];
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"loadmessage" object:nil];
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
    }];
}

-(void)offlineMessageListNormal:(Account*)account sender:(NSString*)sender receiver:(NSString*)receiver
                            pag:(NSString*)pag{
    
    NSString * url  = [self getGetWaySecureURL:account scheam:SCHEAM_LIST];
    
    NSDictionary *parameters = @{LIST_KEY_MOD:SCHEAM_LIST_MOD_NORMAL,
                                 LIST_KEY_SENDER:sender,
                                 LIST_KEY_RECEIVER:receiver,
                                 LIST_KEY_PAG:pag
    };
    [self.afManager GET:url parameters:parameters headers:nil
               progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^void(NSURLSessionDataTask * task, id responseObject) {
        //responseObject[KEY_ACCESSTOKEN];
        //responseObject[KEY_EXPIRES]
        int count = ((NSString*)responseObject[UNREAD_RESULT_KEY_COUNT]).intValue;
        if(count>0){
            NSDictionary* messages = responseObject[LIST_RESULT_KEY_MESSAGES];
            NSMutableArray* msgIds = [NSMutableArray new];
            for(NSDictionary* message in messages ){
                long extensionid = [message[LIST_RESULT_KEY_MESSAGE_SENDID] isKindOfClass:NSNumber.class]?
                ((NSNumber*)message[LIST_RESULT_KEY_MESSAGE_SENDID]).longValue:
                (long)((NSString*)message[LIST_RESULT_KEY_MESSAGE_SENDID]).longLongValue;
                
                if(self.extensionId == extensionid){
                }else{
                    NSNumber* messageId = [self processOfflineMessageResult:message sender:sender receiver:receiver];
                    [msgIds addObject:messageId];
                }
            }
            [self offlineMessageUpdata:account messages:msgIds];
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"loadmessage" object:nil];
    } failure:^void(NSURLSessionDataTask * task, NSError * error) {
    }];
}

-(void) offlineMessage:(Account*)account{
    NSBlockOperation* offlineMessageOpration = [NSBlockOperation blockOperationWithBlock:^{
        [self offlineMessageContactList:account pag:@"0" status:@"UNREAD"];
    }];
    
    [self oprationCommit:account opration:offlineMessageOpration];
}

-(void)uploadFile:(Account*)account mediatype:(NSString*)mime fileurl:(NSURL*)file messageid:(long)messageid{
    NSBlockOperation* uploadFileOpration = [NSBlockOperation blockOperationWithBlock:^{
        NSString *doc =[HttpHelper docFilePath];
        NSString * url  = [self getFileURL:account fileSvrPort:FILE_BASEURL_PORT scheam:SCHEAM_FILE_UPLOAD];
        
        NSData * fileData;
        NSString * fileName = [file.path lastPathComponent];
        NSString* fileNameNoExtension = [fileName stringByDeletingPathExtension];//
        
        NSString *audiosandbox =[NSString stringWithFormat:@"%@/%@%@",MEDIAFILE_PAHT,fileNameNoExtension,MIME_MEDIA_AUDIO_AMR_EXT];
        NSString *videosandbox =[NSString stringWithFormat:@"%@/%@%@",MEDIAFILE_PAHT,fileNameNoExtension,MIME_MEDIA_VIDEO_MP4_EXT];
        NSString *jpgsandbox =[NSString stringWithFormat:@"%@/%@%@",MEDIAFILE_PAHT,fileNameNoExtension,MIME_MEDIA_IMAGE_JPG_EXT];
        
        NSString *audiofullfilePath = [doc stringByAppendingPathComponent:audiosandbox];
        NSString *videofullfilePath = [doc stringByAppendingPathComponent:videosandbox];
        NSString *jpgfullfilePath = [doc stringByAppendingPathComponent:jpgsandbox];
        
        if([mime hasSuffix:MIME_MEDIA_VIDEO_MOV]){
            
        }if([mime hasSuffix:MIME_MEDIA_AUDIO_WAV]){
            if([fileName hasSuffix:MIME_MEDIA_AUDIO_WAV_EXT]){
                if(![[NSFileManager defaultManager] fileExistsAtPath:audiofullfilePath]){
                    [VoiceConverter ConvertWavToAmr:file.path amrSavePath:audiofullfilePath];
                }
            }
            fileData = [NSData dataWithContentsOfFile:audiofullfilePath];
        }else{
            fileData = [NSData dataWithContentsOfFile:file.path];
        }
        if(fileData.length<=0){
            [databaseManage updateChatHistoryStatusByMessageid:messageid withStatus:OUTGOING_ATTACHFAILED];
            return ;
        }
        
        [self.afManager.requestSerializer setValue:MEDIATYPE_EXPORT_JSON forHTTPHeaderField:UPLOAD_KEY_MEDIATYPE];
        @try {
            [self.afManager POST:url parameters:nil headers:nil constructingBodyWithBlock:
             ^void(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:@"application/octet-stream"];
            } progress:^(NSProgress * _Nonnull uploadProgress) {
            } success:^void(NSURLSessionDataTask * task, id responseObject) {
                NSNumber* size = responseObject[FILEUPDATE_RESULT_KEY_SIZE];
                NSNumber* fileId= responseObject[FILEUPDATE_RESULT_KEY_ID ];
                
                NSString* fileUrl = responseObject[FILEUPDATE_RESULT_KEY_URL];
                NSString* fid =  responseObject[FILEUPDATE_RESULT_KEY_FID];
                NSString* fileName = responseObject[FILEUPDATE_RESULT_KEY_fILENAME];
                NSString* eTag = responseObject[FILEUPDATE_RESULT_KEY_ETAG];
                History* chat  = [databaseManage selectMessageByMessageId:messageid];
                
                if(chat!=nil)
                {
                    NSArray *array = [chat.mimeType componentsSeparatedByString:@"/"];
                    
                    NSString* mimetype =array[0];
                    NSString* subMimeType =array[1];
                    NSString* oldContent = chat.getContentAsString;
                    NSDictionary* dic = [History parserMessage:oldContent];
                    [dic setValue:fileUrl forKey:KEY_FILE_URL];
                    NSData* data = [History convertToJsonData:dic];
                    
                    HSChatSession *chatSession = [databaseManage findChatSessionById:chat.mSessionId];
                    if(self.offlineMsgDelegate!=nil){
                        long newMessageID = [self.offlineMsgDelegate sendOutOfDialogMessage:chatSession.mRemoteUri mimeType:mimetype subMimeType:subMimeType isSMS:NO message:data messageLength:(int)[data length]];
                        
                        [databaseManage updateHistoryStatusForFile:messageid replaceMessageId:newMessageID withStatus:OUTGOING_SUCESS messageContent:data];
                    }
                    
                }
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"loadmessage" object:nil];
                
            } failure:^void(NSURLSessionDataTask * task, NSError * error) {
                [databaseManage updateChatHistoryStatusByMessageid:messageid withStatus:OUTGOING_ATTACHFAILED];//
            }];
        } @catch (NSException *exception) {
        } @finally {
        }
    }];
    [self oprationCommit:account opration:uploadFileOpration];
}

-(BOOL) oprationCommit:(Account*)account opration:(NSBlockOperation*)opration{
    @synchronized(self){
        if([self accessTokenAvailable:account]){
            [self.operations addOperation:opration];
        }else{
            if(self.accessResultOperation==NULL){
                self.accessResultOperation = [NSBlockOperation blockOperationWithBlock:^{
                }];
            }
            [self accountVerify:account];
            [opration addDependency:self.accessResultOperation];
            [self.operations addOperation:opration];
            
        }
    }
    return true;
}

-(BOOL) accessTokenAvailable:(Account*)account{
    
    NSLog(@"accessTokenAvailable accesstokenTime=%ld now =%ld",self.accesstokenTime,[NSDate date].timeIntervalSince1970);
    NSString* userDomain = account.userDomain.length>0?account.userDomain:account.SIPServer;
    NSString* accUserDomain = self.accessAccount.userDomain.length>0?self.accessAccount.userDomain:self.accessAccount.SIPServer;
    if([self.accesstoken length]==0||self.accesstokenTime==0||self.accesstokenTime>[NSDate date].timeIntervalSince1970||![userDomain isEqualToString: accUserDomain]||![account.userName isEqualToString: self.accessAccount.userName]){
        return FALSE;
    }
    return TRUE;
}


-(void)downloadFile:(NSString*)fileUrl filepath:filePath mimetype:(NSString*)mimetype historyid:(int)historyid{
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    if(![fileUrl hasPrefix:@"http://"]&&![fileUrl hasPrefix:@"https://"]){
        fileUrl = [@"http://" stringByAppendingString:fileUrl];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
    
    NSString * fileName = [NSUUID new].UUIDString;
    
    if([mimetype hasPrefix:MIME_MEDIA_AUDIO]){//
        if([mimetype hasSuffix:MIME_MEDIA_AUDIO_AMR] )//amr
        {//
            fileName =[fileName stringByAppendingString: MIME_MEDIA_AUDIO_AMR_EXT];
        }else if([mimetype hasSuffix:MIME_MEDIA_AUDIO_WAV] )//amr
        {
            fileName =[fileName stringByAppendingString: MIME_MEDIA_AUDIO_WAV_EXT];
        }else{
            fileName =[fileName stringByAppendingString: MIME_MEDIA_AUDIO_WAV_EXT];
        }
    }else if([mimetype hasPrefix:MIME_MEDIA_VIDEO]){
        if([mimetype hasSuffix:MIME_MEDIA_VIDEO_MP4] )//amr
        {
            fileName =[fileName stringByAppendingString: MIME_MEDIA_VIDEO_MP4_EXT];
        }else{
            fileName =[fileName stringByAppendingString: MIME_MEDIA_VIDEO_MOV_EXT];
        }
        
    }else if([mimetype hasPrefix:MIME_MEDIA_IMAGE]){
        if([mimetype hasSuffix:MIME_MEDIA_IMAGE_JPG]||[mimetype hasSuffix:MIME_MEDIA_IMAGE_JPEG])//amr
        {
            fileName =[fileName stringByAppendingString: MIME_MEDIA_IMAGE_JPG_EXT];
        }else{
            fileName =[fileName stringByAppendingString: MIME_MEDIA_IMAGE_PNG_EXT];
        }
    }else if([mimetype hasPrefix:CUSTOM_MIME_MEDIA_FILE]){
        NSArray* mimes = [mimetype componentsSeparatedByString:@"/"];
        if(mimes.count==2){
            fileName = mimes[1];
        }
    }
    
    NSString *doc =[HttpHelper docFilePath];
    NSString *sandbox =[NSString stringWithFormat:@"%@/%@",MEDIAFILE_PAHT,fileName];
    NSString *fullfilePath = [doc stringByAppendingPathComponent:sandbox];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [NSURL fileURLWithPath:fullfilePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if(error==nil){
            if([mimetype hasSuffix:MIME_MEDIA_AUDIO_AMR]){
                NSLog(@"downloadFile %@",mimetype);
                NSString* wavFile= [[fullfilePath stringByDeletingPathExtension] stringByAppendingString:MIME_MEDIA_AUDIO_WAV_EXT];
                NSString* wavSandBox =[[sandbox stringByDeletingPathExtension] stringByAppendingString:MIME_MEDIA_AUDIO_WAV_EXT];
                int frameCount = [VoiceConverter ConvertAmrToWav:fullfilePath wavSavePath:wavFile];
                
                [databaseManage updateHistoryStatusDurationForDownLoad:historyid withStatus:INCOMING_SUCESS
                                                              duraiton:frameCount FilePath:wavSandBox];
            }else{
                NSLog(@"responseObject = %@",error);
                [databaseManage updateHistoryStatusForDownLoad:historyid withStatus:INCOMING_SUCESS
                                                      FilePath:sandbox];
            }
        }else{
            [databaseManage updateHistoryStatusForDownLoad:historyid withStatus:INCOMING_ATTACHFAILED
                                                  FilePath:sandbox];
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"loadmessage" object:nil];
        //fullfilePath
        //[self deleteFile:self.accesstoken fileId:@"3,050771078b80d6"];
    }];
    
    [downloadTask resume];
    
}

-(void)deleteFile:(Account*)account fileId:(NSString*)fileId{
    NSBlockOperation* deleteFileOpration = [NSBlockOperation blockOperationWithBlock:^{
        NSString * url  = [self getFileURL:account fileSvrPort:FILE_BASEURL_PORT scheam:SCHEAM_FILE_DELETE];
        
        NSDictionary *parameters = @{DELETE_KEY_FILEID:fileId};
        
        [self.afManager GET:url parameters:parameters headers:nil
                   progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^void(NSURLSessionDataTask * task, id responseObject) {
            NSLog(@"deleteFile responseObject = %@, task = %@",responseObject,task);
        } failure:^void(NSURLSessionDataTask * task, NSError * error) {
            NSLog(@"responseObject = %@, task = %@",error,task);
        }];
    }];
    
    [self oprationCommit:account opration:deleteFileOpration];
}

-(NSNumber*)processOfflineMessageResult:(NSDictionary*)messageData sender:(NSString*)sender receiver:(NSString*)receiver{
    NSObject* msgId = messageData[LIST_RESULT_KEY_MESSAGE_ID];
    NSObject* time = messageData[LIST_RESULT_KEY_MESSAGE_TIME];
    NSString* type = messageData[LIST_RESULT_KEY_MESSAGE_TYPE];
    NSString* body = messageData[LIST_RESULT_KEY_MESSAGE_BODY];
    long messageId,messagetime;
    
    NSArray* array =  [type componentsSeparatedByString:@"/"];
    if(array.count==2){
        NSString *mimeType,*subMimeType;
        mimeType = [array objectAtIndex:0];
        subMimeType = [array objectAtIndex:1];
        
        
        @try{
            messageId =[msgId isKindOfClass:NSNumber.class]?((NSNumber*)msgId).longValue:((long)((NSString*)msgId).longLongValue);
            messagetime =[time isKindOfClass:NSNumber.class]?((NSNumber*)time).longValue:((long)((NSString*)time).longLongValue);
        }@catch(NSException *exception){
            messageId = arc4random();
        }
        if(self.offlineMsgDelegate!=nil){
            NSString *sendDisName =  [sender getUriUsername:sender];
            [self.offlineMsgDelegate onRecvOfflineDialogMessage:messageId fromDisplayName:sendDisName from:sender
                                                  toDisplayName:receiver to:receiver mimeType:mimeType subMimeType:subMimeType messageData:body messageTime:messagetime];
        }
    }
    return [NSNumber numberWithLong:messageId];
}

-(void)cancelAll{
    if(self.accessResultOperation!= NULL){
        [self.accessResultOperation start];
    }
    
    [self.afManager.tasks makeObjectsPerformSelector:@selector(cancel)];
    //
}
@end
