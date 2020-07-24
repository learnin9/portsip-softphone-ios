//
//  DataBaseManage.h
//  telephony
//
//  Copyright 2011 HaveSoft Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "Account.h"
#import "History.h"
#import "Options.h"
#import "Favoriter.h"
#import "SipFriend.h"
#import "Contact.h"
#import "HSChatSession.h"
#import "RemoteRecord.h"

#define databaseManage [DataBaseManage shareDatabaseSingleton]


#define CUSTOM_MIME_MEDIA_FILE @"file/"


#define MIME_MEDIA_AUDIO @"audio/"
#define MIME_MEDIA_VIDEO @"video/"
#define MIME_MEDIA_IMAGE @"image/"
#define MIME_MEDIA_TEXT @"text/"
#define MIME_MEDIA_APP @"application/"

#define MIME_MEDIA_TEXT_PLAIN @"plain"

#define MIME_MEDIA_AUDIO_AMR @"amr"
#define MIME_MEDIA_AUDIO_WAV @"wav"
#define MIME_MEDIA_APP_JSON @"json"

#define MIME_MEDIA_IMAGE_JPG @"jpg"
#define MIME_MEDIA_IMAGE_PNG @"png"

#define MIME_MEDIA_IMAGE_JPEG @"jpeg"
#define MIME_MEDIA_VIDEO_MP4 @"mp4"
#define MIME_MEDIA_VIDEO_MPEG @"mp4"
#define MIME_MEDIA_VIDEO_MOV @"quicktime"

#define MIME_MEDIA_VIDEO_MP4_EXT @".MP4"
#define MIME_MEDIA_VIDEO_MOV_EXT @".MOV"

#define MIME_MEDIA_AUDIO_AMR_EXT @".amr"
#define MIME_MEDIA_AUDIO_WAV_EXT @".wav"

#define MIME_MEDIA_IMAGE_JPG_EXT @".jpg"
#define MIME_MEDIA_IMAGE_PNG_EXT @".png"


#define TABLE_REMOTER "remoteUser"

#define CLUMN_REMOTE_ROWID "remoteid"
#define CLUMN_REMOTE_CONTACTID "cotactid"
#define CLUMN_REMOTE_CONTACTTYPE "cotacttype"
#define CLUMN_REMOTE_URI "remoteuri"
#define CLUMN_REMOTE_DISPLAYNAME "disName"


#define TABLE_CHATSESSION "chatSession"
#define CLUMN_SESSION_ID "sid"
#define CLUMN_SESSION_LOCAL "sLocal"
#define CLUMN_SESSION_LOCAL_URI "sLocalUri"
#define CLUMN_SESSION_REMOTE_ID "sRemoteid"
#define CLUMN_SESSION_DELETE "sDelete"
#define CLUMN_SESSION_STATUS "sStatus"
#define CLUMN_SESSION_LASTTIME "sLast"
#define CLUMN_SESSION_UNREAD "sUnread"

#define VIEW_CHATSESSION "view_chatSession_remoter"

#define TABLE_CHATMESSAGE "chatmessage"
#define CLUMN_MESSAGE_MIMETYPE "mimetype"
#define CLUMN_MESSAGE_PLAYDURATION "playtime"
#define CLUMN_MESSAGE_READ "readstatus"
#define CLUMN_MESSAGE_MESSAGEID "messageid"
#define CLUMN_MESSAGE_REMOVED "removed"
#define CLUMN_MESSAGE_ROWID "id"
#define CLUMN_MESSAGE_TIME "messagetime"
#define CLUMN_MESSAGE_ID "messageid"
#define CLUMN_MESSAGE_STATUS "status"
#define CLUMN_MESSAGE_CONTENT "content"
#define CLUMN_MESSAGE_CONTENTLEN "contentlen"
#define CLUMN_MESSAGE_SESSIONID "sessionid"
#define CLUMN_MESSAGE_SENDOUT "sendout"
#define CLUMN_MESSAGE_DESC "description"

#define CLUMN_MIMETYPE "mimetype"
#define CLUMN_PLAYDURATION "playtime"
#define CLUMN_READ "readstatus"
#define CLUMN_MESSAGEID "messageid"
#define CLUMN_REMOVED "removed"

@interface DataBaseManage : NSObject
{
    sqlite3 *mDatabase;
    
    //mDatabase info
	NSString *mDatabaseName;
	NSString *mDatabasePath;
    char *mErrorMsg;

    NSMutableArray *mAccountArray;
    NSMutableArray *mHistoryArray;
    NSMutableArray *mFavoritesArray;
    Options *mOptions;
    
//    NSMutableDictionary *sendingMessage;//messageID => HistoryID
    
    NSMutableArray *mSIPContacts;
}


@property (nonatomic,retain) NSMutableArray *mAccountArray;
@property (nonatomic,retain) NSMutableArray *mHistoryArray;
@property (nonatomic,retain) NSMutableArray *mFavoritersArray;
@property (nonatomic,retain) Options *mOptions;
@property (nonatomic,retain) Account *mAccount;
@property (nonatomic,retain) NSMutableDictionary *sendingMessage;
@property (nonatomic,retain) NSMutableArray *mSIPContacts;
@property (nonatomic,weak)id<OptionOperatorDelegate> opratorDel;

+(DataBaseManage *)shareDatabaseSingleton;

// Account functions
-(BOOL)deleteAccount:(int)accountID;
-(NSMutableArray*)selectAllAccount;
-(Account*)selectActiveAccount;
-(void)saveActiveAccount:(Account*)account reset:(BOOL)reset;
-(void)closeDatabase;
// History functions
-(BOOL)insertHistory:(History *)history;
-(int)insertChatHistory:(long)messageId withHistory:(History *)history mimetype:(NSString*)mimetype playLong:(int)avlong;
-(BOOL)deleteHistory:(int)historyID;
-(BOOL)deleteAllHistory:(int)mediaType withRemoteParty: (NSString*)remoteParty;

//

-(BOOL)deleteChatHistory:(int)historyID;
-(void)deleteChatSessionBySessionId:(int)sessionId;
-(BOOL)deleteAllHistory:(int)mediaType withStatus:(int)status withRemoteParty:(NSString *)remoteParty;
-(NSMutableArray*)selectHistory:(int)topCount byMediaType:(int)mediaType LocalUri:(NSString*)localUri orderBYDESC:(BOOL)desc needCount:(BOOL)isNeed;
-(NSMutableArray *)selectMessage:(int)topCount byMediaType:(int)mediaType remotePaty:(NSString *)remotparty orderBYDESC:(BOOL)desc needCount:(BOOL)isNeed;
-(History *)selectMessageByMessageId:(long)messageId;
-(History *)selectMessageByHistoryId:(int)historyId;
-(NSMutableArray *)searchMessage:(NSString*)filter byMediaType:(int)mediaType Sessions:(NSMutableArray*)sessions orderBYDESC:(BOOL)desc;
-(NSMutableArray *)selectMessageBySessionId:(int)topCount byMediaType:(int)mediaType Sessionid:(int)sessionId orderBYDESC:(BOOL)desc needCount:(BOOL)isNeed;
-(NSMutableArray *)selectMessageGroup:(int)topCount byMediaType:(int)mediaType orderBYDESC:(BOOL)desc needCount:(BOOL)isNeed;
-(NSMutableArray *)selectMessageGroup:(int)topCount byMediaType:(int)mediaType  bylocal:(NSString*)localUri orderBYDESC:(BOOL)desc needCount:(BOOL)isNeed;
-(void)updateHistoryStatus:(long)messageId withStatus:(int) mStatus;
-(void)updateHistoryStatusForFile:(long)messageId replaceMessageId:(long)newId withStatus:(int) mStatus messageContent:(NSData*)content;
-(void)updateHistoryStatusForDownLoad:(int)historyid withStatus:(int) mStatus FilePath:(NSString*)filePath;
-(void)updateHistoryStatusDurationForDownLoad:(int)historyid withStatus:(int)mStatus duraiton:(int)duration FilePath:(NSString*)filePath;
-(void)updateChatHistoryStatusByRowid:(int)historyId withStatus:(int) mStatus;
-(void)updateChatHistoryStatusByMessageid:(long)messageId withStatus:(int) mStatus;
-(void)updateHistoryReadStatus:(int)historyID withStatus:(Boolean)read;
-(void)updateMessageReadStatusBySession:(int)sessionId HasRead:(Boolean)read;
-(void)updateMessageReadStatusByMessageRowId:(int)messageRowId HasRead:(Boolean)read;
-(int)getAllUnreadMessageCount:(NSString*)localUri;

-(void)updateSessionUnreadCount:(int)sessionId UnreadCount:(int)count;
-(void)updateMessageReadStatusBySessionExceptAudio:(int)sessionId HasRead:(Boolean)read;
    
-(void)updateAllProcessingStatus2Fail;
-(long) getLastReceivedMessageID:(NSString*)sender receiver:(NSString*)receiver;

-(void)updateTableVersion;

//-(void)checkupdate;

-(void)updateAccountTable:(int)from to:(int)dest;


// Options founctions
- (Options*)loadNetworkOptions;
- (Options*)loadAVOptions;
- (void)saveOptions;

// Options founctions
-(NSMutableArray *)loadFavorites;
-(BOOL)insertFavorite:(Favorite*)favorite;
-(BOOL)removeFavorite:(Favorite*)favorite;

//SIPFriends functions
-(NSMutableArray *)loadSIPFriends;
-(BOOL)insertSipFriend:(Contact *)sipfriend;
-(BOOL)removeSipFriendWithDisplayName:(NSString *)displayName;
-(void)updateSipFriend:(Contact *)sipFriend;

-(HSChatSession*)getChatSession:(NSString*)localUri RemoteUri:(NSString*)remoteUri
                    DisplayName:(NSString*)disName ContactId:(NSString*)contactId;
-(HSChatSession*)findChatSessionById:(int)sessionId;
-(RemoteRecord*)getRemote:(NSString*)remoteUri DisplayName:(NSString*)remoteDisName
                ContactId:(NSString*)remoteContactId;
-(int)insertChatHistoryNew:(int)sessionId messageid:(long)messageId withHistory:(History *)history
                  mimetype:(NSString*)mimetype playLong:(int)avlong;
-(NSMutableArray *)selectChatSessionByLocalUri:(NSString*)localUri;

@end
