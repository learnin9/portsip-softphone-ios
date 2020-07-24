//
//  DataBaseManage.m
//  telephony
//
//  Copyright 2011 HaveSoft Network. All rights reserved.
//

#import "DataBaseManage.h"
#import "GlobalSetting.h"
#import "AESCrypt/AESCrypt.h"
#import "JRDB.h"
#import "RemoteRecord.h"
#import "HSChatSession.h"

#define TABLE_OPTIONS	"globalinfo"
#define TABLE_ACCOUNT	"account_info"
#define TABLE_VERSION_NEW	"versionnew"

#define TABLE_HISTORY	"history"
#define TABLE_FAVORITES	"favorites"
#define TABLE_SIPFRIENDS "sipfriends"
#define TABLE_ATTACHMENT "attachment"//


//#define DB_OPTIONS_VERSION	"2.0.5.31"
#define DB_OPTIONS_VERSION_NEW  100
#define DB_ACCOUNT_VERSION_NEW  102
#define DB_HISTORY_VERSION_NEW  102
#define DB_FAVORITES_VERSION    100
#define DB_SIPFRIENDS_VERSION   100
#define DB_ATTACHMENT_VERSION   100

#define DB_REMOTER_VERSION   102
#define DB_CHATSESSION_VERSION   102
#define DB_CHATMESSAGE_VERSION   102

#define NOT_EXIST_INT_VALUE 0xFFFFFFFF
#define NOT_EXIST_TEXT_VALUE @"NOT_EXIST_TEXT_VALUE"

#define DB_PASWORD_KEY		@"P4ssw0rd"

@interface DataBaseManage(private)
-(void)initDatabase;
-(BOOL)openDatabase;
-(BOOL)isTableExist:(const char*)tableName;

-(int)loadIntOptionsItem:(const char*)optionName defaultValue:(int)defalutValue;
-(NSString*)loadTextOptionsItem:(const char*)optionName defaultValue:(NSString*)defalutValue;

-(void)saveIntOptionsItem:(const char*)optionName intValue:(int)optionValue;
-(void)saveTextOptionsItem:(const char*)optionName textValue:(NSString*)optionValue;

@end

@implementation DataBaseManage(private)

-(void)initDatabase
{
    if([self openDatabase])
    {
        //check DB version
        [self updateTableVersion];
        char sql[1024] = {0};
        sprintf(sql,"CREATE VIEW %s AS SELECT * FROM %s JOIN %s ON %s.%s=%s.%s",VIEW_CHATSESSION,TABLE_CHATSESSION,TABLE_REMOTER,TABLE_CHATSESSION, CLUMN_SESSION_REMOTE_ID,TABLE_REMOTER,CLUMN_REMOTE_ROWID);
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK){
            NSLog(@"%s error=%s",sql,mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
        
        memset(sql,0,1024);
        sprintf(sql,"create trigger insert_message after insert on %s for each row begin update %s set %s=new.%s, %s= new.%s where %s=new.%s; end;",TABLE_CHATMESSAGE,TABLE_CHATSESSION,CLUMN_SESSION_STATUS,CLUMN_MESSAGE_DESC,CLUMN_SESSION_LASTTIME,CLUMN_MESSAGE_TIME,CLUMN_SESSION_ID,CLUMN_MESSAGE_SESSIONID);
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK){
            NSLog(@"%s error=%s",sql,mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
        
        memset(sql,0,1024);
        sprintf(sql,"create trigger delete_session before update on %s for each row when new.%s>0 and old.%s<=0 begin delete from %s where %s=old.%s and %s<(select max(%s) from %s where %s=old.%s); update %s set %s=%d where %s=old.%s; end;",TABLE_CHATSESSION,CLUMN_SESSION_DELETE,CLUMN_SESSION_DELETE, TABLE_CHATMESSAGE,CLUMN_MESSAGE_SESSIONID,CLUMN_SESSION_ID,CLUMN_MESSAGE_ROWID,CLUMN_MESSAGE_ROWID,TABLE_CHATMESSAGE,CLUMN_MESSAGE_SESSIONID,CLUMN_SESSION_ID,TABLE_CHATMESSAGE,CLUMN_MESSAGE_REMOVED,1,CLUMN_MESSAGE_SESSIONID,CLUMN_SESSION_ID);
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK){
            NSLog(@"%s error=%s",sql,mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
        
        memset(sql,0,1024);
        sprintf(sql,
                "create trigger update_read before update on %s for each row when old.%s>0 AND new.%s<=0 begin update %s set %s=%s-1 where %s=new.%s and %s>0; end;",TABLE_CHATMESSAGE,CLUMN_MESSAGE_READ,CLUMN_MESSAGE_READ,TABLE_CHATSESSION,CLUMN_SESSION_UNREAD,CLUMN_SESSION_UNREAD,CLUMN_SESSION_ID,CLUMN_MESSAGE_SESSIONID,CLUMN_SESSION_UNREAD);
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK){
            NSLog(@"%s error=%s",sql,mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
        memset(sql,0,1024);
        sprintf(sql,"create trigger insert_unread after insert on %s for each row when new.%s>0 begin update %s set %s=%s+1 where %s=new.%s; end;",TABLE_CHATMESSAGE,CLUMN_MESSAGE_READ,TABLE_CHATSESSION,CLUMN_SESSION_UNREAD,CLUMN_SESSION_UNREAD,CLUMN_SESSION_ID,CLUMN_MESSAGE_SESSIONID);
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK){
            NSLog(@"%s error=%s",sql,mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
}

-(BOOL)openDatabase
{
    BOOL isSuccess = NO;
    if(mDatabase!=NULL){
        return true;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString * mDatabaseLocal =[documentsDir stringByAppendingPathComponent:mDatabaseName];
    
    isSuccess = [fileManager fileExistsAtPath:mDatabaseLocal];
    if(!isSuccess)
    {
        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:mDatabaseName];
        [fileManager copyItemAtPath:databasePathFromApp toPath:mDatabasePath error:nil];
    }else{
        [fileManager copyItemAtPath:mDatabaseLocal toPath:mDatabasePath error:nil];
    }
    
    NSLog(@" openDatabase path %@",mDatabasePath);
    if(sqlite3_open([mDatabasePath UTF8String], &mDatabase) == SQLITE_OK)
    {
        isSuccess = YES;
    }
    else
    {
        isSuccess = NO;
        NSLog(@" openDatabase Error");
    }
    return isSuccess;
}


-(void)closeDatabase
{
    if(mDatabase)
    {
        sqlite3_close(mDatabase);
        mDatabase = NULL;
    }
};

-(BOOL)addClumn:(const char*)tableName _:(const char*)clumnName _:(const char*)clumnDataType
{
    if(![self isTableExist:tableName]){
       return false;
    }
    if([self isClumnExist:tableName _:clumnName]){
        return true;
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"ALTER TABLE %s ADD COLUMN %s %s; ",tableName,clumnName,clumnDataType];
    
    const char *sqlStatement = [sql UTF8String];
    char*ERROR;
    if(sqlite3_exec(mDatabase, sqlStatement, NULL, NULL, &ERROR) == SQLITE_OK) {
        return true;
    }
    // select count(*) from sqlite_master where table=***
    return false;
}

-(BOOL)isTableExist:(const char*)tableName
{
    if (tableName == NULL || strlen(tableName) <= 0)
    {
        return false;
    }
    
    if(![self openDatabase]){
        return FALSE;
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"select * from %s",tableName];
    
    const char *sqlStatement = [sql UTF8String];
    
    char * erro = NULL;
    char ** result = NULL;
    int row = 0;
    int colum = 0;
    
    if (sqlite3_get_table(mDatabase, sqlStatement, &result,&row, &colum, &erro) != SQLITE_OK)
    {
        return false;
    }
    // select count(*) from sqlite_master where table=***
    return true;
}


-(BOOL)isClumnExist:(const char*)tableName _:(const char*)clumnName
{
    if(![self isTableExist:tableName]){
        return false;
    }
    
    if (clumnName== NULL || strlen(clumnName) <= 0)
    {
        return false;
    }
    
    if(![self openDatabase]){
        return FALSE;
    }
    
//    NSString *sql = [[NSString alloc] initWithFormat:@"select * from sqlite_master where name = '%s' and sql like '%s%s%s;'",tableName,"%",clumnName,"%"];
    NSString *sql = [[NSString alloc] initWithFormat:@"select * from sqlite_master where type = 'table' and name = '%s'",tableName];
    
    const char *sqlStatement = [sql UTF8String];
    
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {
        if(sqlite3_step(statement) == SQLITE_ROW) {
            const unsigned char* sql=  sqlite3_column_text(statement, 4);
            char*position =  strstr(sql, clumnName);
            return position!=NULL;
        }else{
            
        }
        sqlite3_finalize(statement);
    }
    
    return false;
}

-(int)loadIntOptionsItem:(const char*)optionName defaultValue:(int)defalutValue
{
    if(![self openDatabase]){
        return -0xffff;
    }
    char sqlStatement[1024] = {0};
    
    sprintf(sqlStatement, "SELECT optionsIntValue FROM %s where optionsName='%s'", TABLE_OPTIONS,optionName);
    
    sqlite3_stmt *statement;
    int returnValue = defalutValue;
    
    if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {

        if(sqlite3_step(statement) == SQLITE_ROW) {
            returnValue = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    
    return returnValue;
}

-(NSString*)loadTextOptionsItem:(const char*)optionName defaultValue:(NSString*)defalutValue
{
    if(![self openDatabase]){
        return @"";
    }
    char sqlStatement[1024] = {0};
    
    sprintf(sqlStatement, "SELECT optionsTextValue FROM %s where optionsName='%s'", TABLE_OPTIONS,optionName);
    
    sqlite3_stmt *statement;
    NSString* returnValue = defalutValue;
    
    if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {

        if(sqlite3_step(statement) == SQLITE_ROW) {
            returnValue = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
        }
        sqlite3_finalize(statement);
    }
    
    return returnValue;
}

-(void)saveIntOptionsItem:(const char*)optionName intValue:(int)optionValue
{
    if(![self openDatabase]){
        return;
    }
    
    BOOL hasOptionItem = NO;
    int oldValue = [self loadIntOptionsItem:optionName defaultValue:NOT_EXIST_INT_VALUE];
    
    if(oldValue == optionValue)
        return;
    
    if (oldValue != NOT_EXIST_INT_VALUE) {
        hasOptionItem = YES;
    }
    
    char query_stmt[1024] = {0};
    if(hasOptionItem)
    {//updateItem
        sprintf(query_stmt, "UPDATE %s set optionsIntValue = %d WHERE optionsName='%s'", TABLE_OPTIONS,optionValue,optionName);
    }
    else
    {//insertItem
        sprintf(query_stmt, "INSERT INTO %s(optionsName, optionsIntValue) VALUES('%s',%d)", TABLE_OPTIONS,optionName,optionValue);
    }
    
    if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) != SQLITE_OK)
    {
        NSLog(@"saveIntOptionsItem(optionName=%s) Error！%s",optionName,mErrorMsg);
        sqlite3_free(mErrorMsg);
    }
}

-(void)saveTextOptionsItem:(const char*)optionName textValue:(NSString*)optionValue
{
    BOOL hasOptionItem = NO;
    if(![self openDatabase]){
        return ;
    }
    
    NSString* oldValue = [self loadTextOptionsItem:optionName defaultValue:NOT_EXIST_TEXT_VALUE];
    
    if([oldValue isEqualToString:optionValue])
        return;
    
    if (![oldValue isEqualToString: NOT_EXIST_TEXT_VALUE]) {
        hasOptionItem = YES;
    }
    
    const char* query_stmt = NULL;
    if(hasOptionItem)
    {//updateItem
        NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %s set optionsTextValue = '%@' WHERE optionsName='%s'", TABLE_OPTIONS,optionValue,optionName];
        
        query_stmt = [sql UTF8String];
    }
    else
    {//insertItem
        NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO %s(optionsName, optionsTextValue) VALUES('%s','%@')",
                         TABLE_OPTIONS,optionName,optionValue];
        
        query_stmt = [sql UTF8String];
    }
    
    if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) != SQLITE_OK)
    {
        NSLog(@"saveIntOptionsItem(optionName=%s) Error！%s",optionName,mErrorMsg);
        sqlite3_free(mErrorMsg);
    }
}


@end

@interface DataBaseManage()
-(BOOL)insertAccount:(Account *)account;
-(BOOL)updateAccount:(Account*)account;
-(BOOL)resetActiveAccount;
@end

@implementation DataBaseManage
@synthesize mAccountArray;
@synthesize mHistoryArray;
@synthesize mOptions;
@synthesize mAccount;
@synthesize mSIPContacts;

-(id) init
{
    self = [super init];
    if (self)
    {
        mDatabaseName = @"PortGo.db";

//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSURL *groupURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.com.portsip.portgodata"];
//        mDatabasePath = [[groupURL URLByAppendingPathComponent:mDatabaseName] path];
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [documentPaths objectAtIndex:0];
        mDatabasePath = [documentsDir stringByAppendingPathComponent:mDatabaseName];
        
        [self initDatabase];
    }
    return self;
}


+(DataBaseManage *)shareDatabaseSingleton
{
    static DataBaseManage *myDatabase = nil;
    @synchronized(self)
    {
        if (myDatabase == nil) {
            myDatabase = [[DataBaseManage alloc]init];
        }
    }
    
    return myDatabase;
}

#pragma mark - Account functions

-(Account *)selectAccountByName:(NSString *)userName bySIPDomain:(NSString *)userDomain
{
    Account *account = nil;
    if([self openDatabase])
    {
        NSString *sql = [[NSString alloc] initWithFormat:@"SELECT accountid, username, displayname, authName, password, userDomain, SIPServer, SIPServerPort,transport,outboundServer,outboundServerPort, enableSTUN, STUNServer, STUNPort, presenceAgent, publishRefresh, subscribeRefresh, useCert,voiceMail,active FROM account_info WHERE username = '%@' and userDomain = '%@'",
                         userName, userDomain];
        
        const char *sqlStatement = [sql UTF8String];
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {

            if(sqlite3_step(statement) == SQLITE_ROW) {

                int accountid = sqlite3_column_int(statement, 0);
                NSString *username = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                NSString *displayname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                NSString *authName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                
                //NSString *password = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
                NSString *password = [AESCrypt decrypt:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)]  password:DB_PASWORD_KEY];
                
                NSString *userDomain = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
                NSString *SIPServer = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
                int SIPServerPort = sqlite3_column_int(statement, 7);
                NSString *transport = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)];
                NSString *outboundServer = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
                int outboundServerPort = sqlite3_column_int(statement, 10);
                int enableSTUN = sqlite3_column_int(statement, 11);
                NSString *STUNServer = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 12)];
                int STUNPort = sqlite3_column_int(statement, 13);
                
                int presenceAgent = sqlite3_column_int(statement, 14);
                int publishRefresh = sqlite3_column_int(statement, 15);
                int subscribeRefresh = sqlite3_column_int(statement, 16);
                int useCert = sqlite3_column_int(statement, 17);
                const unsigned char *vmail = sqlite3_column_text(statement, 18);
                NSString *voiceMail;
                if(vmail!=NULL){
                    voiceMail = [NSString stringWithUTF8String:vmail];
                }else{
                    voiceMail = @"";
                }
                int actived = sqlite3_column_int(statement, 19);

                account = [[Account alloc] initWithName:accountid
                                               UserName:username
                                            DisplayName:displayname
                                               AuthName:authName
                                               Password:password
                                             UserDomain:userDomain
                                              SIPServer:SIPServer
                                          SIPServerPort:SIPServerPort
                                          TransportType:transport
                                         OutboundServer:outboundServer
                                     OutboundServerPort:outboundServerPort
                                                Actived:actived];
                
                account.enableSTUN = enableSTUN;
                account.STUNServer = STUNServer;
                account.STUNPort = STUNPort;
                
                account.presenceAgent = presenceAgent;
                account.publishRefresh = publishRefresh;
                account.subscribeRefresh = subscribeRefresh;
                account.useCert = useCert;
                account.voiceMail = voiceMail;
                
            }
            sqlite3_finalize(statement);
        }
    }

    mAccount = account;
    return account;
}

-(BOOL)resetActiveAccount
{
    BOOL success = NO;
    if([self openDatabase])
    {
        
        NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE account_info SET active=0"];
        
        const char *query_stmt = [sql UTF8String];
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        } else {
            NSLog(@"updateAccount Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

    return success;
}

-(BOOL)insertAccount:(Account *)account
{
    BOOL success = NO;
    if([self openDatabase])
    {
        NSString *encodePassword = [AESCrypt encrypt:[account password] password:DB_PASWORD_KEY];
        
        NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO account_info(username, displayname, authName, password, userDomain,SIPServer, SIPServerPort,transport,outboundServer,outboundServerPort,enableSTUN,STUNServer,STUNPort, presenceAgent, publishRefresh, subscribeRefresh, useCert,voiceMail,active) VALUES ('%@','%@','%@','%@','%@','%@',%d,'%@','%@',%d,%d,'%@',%d,%d,%d,%d,%d,'%@',%d)",
                         [account userName], [account displayName], [account authName] , encodePassword,
                         [account userDomain], [account SIPServer], [account SIPServerPort],[account transportType],
                         [account outboundServer], [account outboundServerPort],[account enableSTUN],[account STUNServer],[account STUNPort],[account presenceAgent],[account publishRefresh],[account subscribeRefresh],[account useCert],account .voiceMail==NULL?@"":account.voiceMail,1];
        
        const char *query_stmt = [sql UTF8String];
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        } else {
            NSLog(@"insertAccount Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

    return success;
}

-(BOOL)deleteAccount:(int)accountID
{
    BOOL success = NO;

    if([self openDatabase])
    {
        NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM account_info WHERE (accountid=%d)", accountID];
        const char *query_stmt = [sql UTF8String];

        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        }
        else
        {
            NSLog(@"deleteAccount Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
    
    return success;
};

-(BOOL)updateAccount:(Account*)account
{
    BOOL success = NO;
    if([self openDatabase])
    {
        NSString *encodePassword = [AESCrypt encrypt:[account password] password:DB_PASWORD_KEY];
        
        NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE account_info SET username='%@',displayname='%@', authName='%@', password='%@', userDomain='%@',SIPServer='%@',SIPServerPort=%d, transport='%@',outboundServer='%@', outboundServerPort=%d,enableSTUN=%d, STUNServer='%@', STUNPort=%d, presenceAgent=%d, publishRefresh=%d, subscribeRefresh=%d, useCert=%d,voiceMail='%@',active=%d WHERE (accountid=%d) ",
                         [account userName], [account displayName], [account authName] , encodePassword,
                         [account userDomain], [account SIPServer], [account SIPServerPort],
                         [account transportType], [account outboundServer], [account outboundServerPort],[account enableSTUN],[account STUNServer],[account STUNPort],[account presenceAgent],[account publishRefresh],[account subscribeRefresh],[account useCert],account.voiceMail==NULL?@"":account.voiceMail,1,
                         [account accountId]];
        
        const char *query_stmt = [sql UTF8String];
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        } else {
            NSLog(@"updateAccount Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
    return success;
    
};

-(NSMutableArray*)selectAllAccount
{
    mAccountArray = [[NSMutableArray alloc] init];
    if([self openDatabase])
    {

        const char *sqlStatement = "SELECT accountid, username, displayname, authName, password, userDomain, SIPServer, SIPServerPort,transport,outboundServer,outboundServerPort,enableSTUN,STUNServer,STUNPort,presenceAgent,publishRefresh,subscribeRefresh,useCert,voiceMail,active FROM account_info";
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {
 
            while(sqlite3_step(statement) == SQLITE_ROW) {

                int accountid = sqlite3_column_int(statement, 0);
                NSString *username = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                NSString *displayname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                NSString *authName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                //NSString *password = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
                NSString *password = [AESCrypt decrypt:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)]  password:DB_PASWORD_KEY];
                NSString *userDomain = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
                NSString *SIPServer = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
                int SIPServerPort = sqlite3_column_int(statement, 7);
                NSString *transport = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)];
                NSString *outboundServer = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
                int outboundServerPort = sqlite3_column_int(statement, 10);
                
                int enableSTUN = sqlite3_column_int(statement, 11);
                NSString *STUNServer = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 12)];
                int STUNPort = sqlite3_column_int(statement, 13);
                
                int presenceAgent = sqlite3_column_int(statement, 14);
                int publishRefresh = sqlite3_column_int(statement, 15);
                int subscribeRefresh = sqlite3_column_int(statement, 16);
                int useCert = sqlite3_column_int(statement, 17);
                NSString *voiceMail = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 18)];
                int actived = sqlite3_column_int(statement, 19);
                

                Account *account = [[Account alloc] initWithName:accountid
                                                        UserName:username
                                                     DisplayName:displayname
                                                        AuthName:authName
                                                        Password:password
                                                      UserDomain:userDomain
                                                       SIPServer:SIPServer
                                                   SIPServerPort:SIPServerPort
                                                   TransportType:transport
                                                  OutboundServer:outboundServer
                                              OutboundServerPort:outboundServerPort
                                                         Actived:actived];
                
                account.enableSTUN = enableSTUN;
                account.STUNServer = STUNServer;
                account.STUNPort = STUNPort;
                
                account.presenceAgent = presenceAgent;
                account.publishRefresh = publishRefresh;
                account.subscribeRefresh = subscribeRefresh;
                account.useCert = useCert;
                account.voiceMail = voiceMail;

                [mAccountArray addObject:account];
            }
            sqlite3_finalize(statement);
        }
        else{
            
            NSLog(@"no ok =%d",sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL));
            
            
            
        }
    }

    return  mAccountArray;
};

-(Account*)selectActiveAccount
{
    Account *account = nil;
    if([self openDatabase])
    {

        const char *sqlStatement = "SELECT accountid, username, displayname, authName, password, userDomain, SIPServer,SIPServerPort,transport,outboundServer,outboundServerPort,enableSTUN,STUNServer,STUNPort,presenceAgent,publishRefresh,subscribeRefresh,useCert,voiceMail FROM account_info where active=1";
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {

            while(sqlite3_step(statement) == SQLITE_ROW) {

                int accountid = sqlite3_column_int(statement, 0);
                NSString *username = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                NSString *displayname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                NSString *authName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                //NSString *password = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
                NSString *password = [AESCrypt decrypt:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)]  password:DB_PASWORD_KEY];
                
                NSString *userDomain = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
                NSString *SIPServer = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
                int SIPServerPort = sqlite3_column_int(statement, 7);
                NSString *transport = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)];
                NSString *outboundServer = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
                int outboundServerPort = sqlite3_column_int(statement, 10);
                int enableSTUN = sqlite3_column_int(statement, 11);
                NSString *STUNServer = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 12)];
                int STUNPort = sqlite3_column_int(statement, 13);
                
                int presenceAgent = sqlite3_column_int(statement, 14);
                int publishRefresh = sqlite3_column_int(statement, 15);
                int subscribeRefresh = sqlite3_column_int(statement, 16);
                int useCert = sqlite3_column_int(statement, 17);
                NSString *voiceMail = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 18)];

                account = [[Account alloc] initWithName:accountid
                                               UserName:username
                                            DisplayName:displayname
                                               AuthName:authName
                                               Password:password
                                             UserDomain:userDomain
                                              SIPServer:SIPServer
                                          SIPServerPort:SIPServerPort
                                          TransportType:transport
                                         OutboundServer:outboundServer
                                     OutboundServerPort:outboundServerPort
                                                Actived:1];
                account.enableSTUN = enableSTUN;
                account.STUNServer = STUNServer;
                account.STUNPort = STUNPort;
                
                account.presenceAgent = presenceAgent;
                account.publishRefresh = publishRefresh;
                account.subscribeRefresh = subscribeRefresh;
                account.useCert = useCert;
                account.voiceMail = voiceMail;
                
                break;
                
            }
            sqlite3_finalize(statement);
        }
    }

    mAccount = account;
    return account;
};

-(void)saveActiveAccount:(Account*)account reset:(BOOL)reset
{
    if (reset) {
        [self resetActiveAccount];
    }
    Account* oldAccount = [self selectAccountByName:[account userName] bySIPDomain:[account userDomain]];
    if(oldAccount == nil)
    {
        [self insertAccount:account];
    }
    else
    {
        account.accountId = oldAccount.accountId;
        [self updateAccount:account];
    }
};





#pragma mark - History functions


-(BOOL)updateHisstory:(History*)history{
    
      BOOL success = NO;
    if([self openDatabase])
    {
        NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO %s(remoteParty, displayname, localParty, localDisplayname, start, end, mediaType, status ,content) VALUES ('%@','%@', '%@', '%@',%f,%f,%d,%d,'%@')",
                         TABLE_HISTORY,[history mRemoteParty], [history mRemotePartyDisplayName], [history localParty], [history localDisplayname], [history mTimeStart],
                         [history mTimeEnd], [history mMediaType], [history mStatus], [[history getContentAsString] stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
        
        const char *query_stmt = [sql UTF8String];
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        } else {
            NSLog(@"insertAccount Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }  
        
    }

    return success;
    
}

-(BOOL)insertHistory:(History *)history
{
    [self checkscroe:history.mTimeStart andend:history.mTimeEnd];
    

    BOOL success = NO;
    if([self openDatabase])
    {
        
        NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO %s(remoteParty, displayname, localParty, localDisplayname, start, end, mediaType, status ,content) VALUES ('%@','%@', '%@', '%@',%f,%f,%d,%d,'%@')",
                         TABLE_HISTORY,[history mRemoteParty], [history mRemotePartyDisplayName], [history localParty], [history localDisplayname], [history mTimeStart],
                         [history mTimeEnd], [history mMediaType], [history mStatus], [[history getContentAsString] stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
        
        
        
        
        const char *query_stmt = [sql UTF8String];
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        } else {
            NSLog(@"insertAccount Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }

    }
    return success;
}

//just find a remote record,if not find return nil
-(RemoteRecord*) findRemote:(NSString*)remoteUri{
    RemoteRecord *remote = nil;
    if([self openDatabase])
    {
        NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %s WHERE %s='%@'",
                         TABLE_REMOTER,CLUMN_REMOTE_URI,remoteUri];
        
        const char *sqlStatement = [sql UTF8String];
        sqlite3_stmt *statement;
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {
            while(sqlite3_step(statement) == SQLITE_ROW) {

                remote= [[RemoteRecord alloc] init];
                
                remote.mRowId = sqlite3_column_int(statement, 0);
                remote.mContactId= [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                remote.mContactType= sqlite3_column_int(statement, 2);
                remote.mRemoteUri= [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                remote.mRemoteDisName= [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];

                break;
            }
            sqlite3_finalize(statement);
        }
    }
    
    return remote;
}

//findRemote ,if can not find, create it:
-(RemoteRecord*)getRemote:(NSString*)remoteUri DisplayName:(NSString*)remoteDisName ContactId:(NSString*)remoteContactId{
    RemoteRecord *remote = nil;
    remote = [self findRemote:remoteUri];
    if(remote == nil&&[self openDatabase]){
       NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO %s('%s', '%s', '%s') VALUES ('%@','%@', '%@')",
                        TABLE_REMOTER,CLUMN_REMOTE_URI, CLUMN_REMOTE_DISPLAYNAME, CLUMN_REMOTE_CONTACTID,remoteUri,remoteDisName,remoteContactId];
       
       const char *query_stmt = [sql UTF8String];
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) != SQLITE_OK){
           NSLog(@"insert RemoteRecord Error！%s",mErrorMsg);
           sqlite3_free(mErrorMsg);
        }else{
            remote= [[RemoteRecord alloc] init];
            remote.mRowId = (int)sqlite3_last_insert_rowid(mDatabase);
            remote.mContactId = remoteContactId;
            remote.mRemoteDisName = remoteDisName;
            remote.mRemoteUri = remoteUri;
        }
    }
    return remote;
}

//Find a ChatSession record,if did not find,create it.if find a delete record .update it.
-(HSChatSession*)getChatSession:(NSString*)localUri RemoteUri:(NSString*)remoteUri DisplayName:(NSString*)disName ContactId:(NSString*)contactId{
    HSChatSession* session = [self findChatSession:localUri remoteUri:remoteUri];
     
    if(session==nil){
        RemoteRecord *remote = [self getRemote:remoteUri DisplayName:disName ContactId:0];
        
        if(remote != nil&&[self openDatabase]){
            NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO %s('%s', '%s') VALUES ('%d','%@')",TABLE_CHATSESSION,
                             CLUMN_SESSION_REMOTE_ID,CLUMN_SESSION_LOCAL_URI,remote.mRowId,localUri];
                            
            const char *query_stmt = [sql UTF8String];
            if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) != SQLITE_OK){
              NSLog(@"insert RemoteRecord Error！%s",mErrorMsg);
              sqlite3_free(mErrorMsg);
            }else{
               session = [HSChatSession new];
               session.mLocalUri = localUri;
               session.mRowid  = (int)sqlite3_last_insert_rowid(mDatabase);
               session.mRemoteUri = remote.mRemoteUri;
               session.mRemoteDisname = remote.mRemoteDisName;
            }
        }
    }else{
        if(session.mDelete>0&&[self openDatabase]){
            NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %s SET %s=%d where %s=%d",TABLE_CHATSESSION,
                             CLUMN_SESSION_DELETE,0,CLUMN_SESSION_ID,session.mRowid];
                            
            const char *query_stmt = [sql UTF8String];
            if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) != SQLITE_OK){
              NSLog(@"insert RemoteRecord Error！%s",mErrorMsg);
              sqlite3_free(mErrorMsg);
            }else{
               session.mDelete = 0;
            }
        }
    }
    
    return session;
}

//just find a ChatSession record,if not find return nil
-(HSChatSession*)findChatSession:(NSString*)localUri remoteUri:(NSString*)remoteUri{
    HSChatSession* session = nil;
    if([self openDatabase]){
        NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %s WHERE %s='%@' AND %s='%@'",
                         VIEW_CHATSESSION,CLUMN_REMOTE_URI,remoteUri,CLUMN_SESSION_LOCAL_URI,localUri];
    
        const char *sqlStatement = [sql UTF8String];
        sqlite3_stmt *statement;
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement,NULL) == SQLITE_OK) {
            while(sqlite3_step(statement) == SQLITE_ROW) {

                session = [[HSChatSession alloc] init];
                
                session.mRowid = sqlite3_column_int(statement, 0);
                //CLUMN_SESSION_LOCAL
                sqlite3_column_int(statement, 1);
                //CLUMN_SESSION_LOCAL_URI
                session.mLocalUri= [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                session.mRemoteid= sqlite3_column_int(statement, 3);//CLUMN_SESSION_REMOTE_ID
                session.mDelete= sqlite3_column_int(statement, 4);//CLUMN_SESSION_DELETE
                //CLUMN_SESSION_STATUS
                const char*status = (char *)sqlite3_column_text(statement, 5);
                if(status==NULL){
                    session.mStatus=@"";
                }else{
                    [NSString stringWithUTF8String:status];
                }
                session.mLastTimeConnect= sqlite3_column_int(statement, 6);
                session.mCount= sqlite3_column_int(statement, 7);//UnreadCount
                //TABLE_REMOTER
                //CLUMN_REMOTE_ROWID
                sqlite3_column_int(statement, 8);
                //CLUMN_REMOTE_CONTACTID
                session.mContactid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
                //CLUMN_REMOTE_CONTACTTYPE
                //sqlite3_column_int(statement, 10);
                //CLUMN_REMOTE_URI
                session.mRemoteUri= [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 11)];
                //CLUMN_REMOTE_DISPLAYNAME
                session.mRemoteDisname= [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 12)];

                break;
            }
            sqlite3_finalize(statement);
        }
    }
    
    return session;
}

//just find a ChatSession record,if not find return nil
-(HSChatSession*)findChatSessionById:(int)sessionId{
    HSChatSession* session = nil;
    if([self openDatabase]){
        NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %s WHERE %s='%d'",
                         VIEW_CHATSESSION,CLUMN_SESSION_ID,sessionId];
    
        const char *sqlStatement = [sql UTF8String];
        sqlite3_stmt *statement;
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement,NULL) == SQLITE_OK) {
            
            while(sqlite3_step(statement) == SQLITE_ROW) {

                session = [[HSChatSession alloc] init];
                
                session.mRowid = sqlite3_column_int(statement, 0);
                //CLUMN_SESSION_LOCAL
                sqlite3_column_int(statement, 1);
                //CLUMN_SESSION_LOCAL_URI
                session.mLocalUri= [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                session.mRemoteid= sqlite3_column_int(statement, 3);//CLUMN_SESSION_REMOTE_ID
                session.mDelete= sqlite3_column_int(statement, 4);//CLUMN_SESSION_DELETE
                //CLUMN_SESSION_STATUS
                const char*status = (char *)sqlite3_column_text(statement, 5);
                if(status==NULL){
                    session.mStatus=@"";
                }else{
                    [NSString stringWithUTF8String:status];
                }
                session.mLastTimeConnect= sqlite3_column_int(statement, 6);
                session.mCount= sqlite3_column_int(statement, 7);//UnreadCount
                //TABLE_REMOTER
                //CLUMN_REMOTE_ROWID
                sqlite3_column_int(statement, 8);
                //CLUMN_REMOTE_CONTACTID
                session.mContactid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
                //CLUMN_REMOTE_CONTACTTYPE
                //sqlite3_column_int(statement, 10);
                //CLUMN_REMOTE_URI
                session.mRemoteUri= [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 11)];
                //CLUMN_REMOTE_DISPLAYNAME
                session.mRemoteDisname= [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 12)];

                break;
            }
            sqlite3_finalize(statement);
        }
    }
    
    return session;
}

-(int)insertChatHistoryNew:(int)sessionId messageid:(long)messageId withHistory:(History *)history mimetype:(NSString*)mimetype playLong:(int)avlong{
    int historyId = -1;
    NSLog(@"for badge insertChatHistoryNew messageId = %ld,mimetype=%@",messageId,mimetype);
    if([self openDatabase])
    {

        
        NSString * messageContent = [[history getContentAsString] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO %s(%s, %s, %s, %s, %s,%s, %s,%s, %s,%s ,%s ,%s ) VALUES ('%f','%d', '%d', '%@','%@','%d','%d','%ld','%d','%d','%@','%d')",TABLE_CHATMESSAGE,CLUMN_MESSAGE_TIME,CLUMN_MESSAGE_SESSIONID,CLUMN_MESSAGE_STATUS,CLUMN_MESSAGE_CONTENT,CLUMN_MESSAGE_MIMETYPE,CLUMN_MESSAGE_PLAYDURATION,CLUMN_MESSAGE_READ,CLUMN_MESSAGE_ID,CLUMN_MESSAGE_REMOVED,CLUMN_MESSAGE_CONTENTLEN,CLUMN_MESSAGE_DESC,CLUMN_MESSAGE_SENDOUT,history.mTimeStart,sessionId,history.mStatus,messageContent, mimetype, history.mPlayDuration, history.mRead?0:1, messageId,0,(unsigned int)history.mContent.length, history.mDesc,history.mSendOut];

        const char *query_stmt = [sql UTF8String];
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            historyId = (int)sqlite3_last_insert_rowid(mDatabase);
            //historyId = [self getLastChatHistoryID:[history mMediaType] withRemoteParty:[history mRemoteParty]];
        } else {
            NSLog(@"insertChatHistoryNew messageId = %d,mimetype=%@,mErrorMsg=%s",messageId,mimetype,mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

    return historyId;
}

-(BOOL)deleteChatHistory:(int)historyID
{
    BOOL success = NO;

    if([self openDatabase])
    {
        NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %s SET %s=%d  WHERE (%s=%d)", TABLE_CHATMESSAGE,CLUMN_MESSAGE_REMOVED,1,CLUMN_MESSAGE_ROWID, historyID];
        const char *query_stmt = [sql UTF8String];

        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        }
        else
        {
            NSLog(@"deleteHistory Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
    return success;
}

-(BOOL)deleteHistory:(int)historyID
{
    BOOL success = NO;
    if([self openDatabase])
    {
        NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM %s WHERE (historyid=%d)", TABLE_HISTORY, historyID];
        const char *query_stmt = [sql UTF8String];
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        }
        else
        {
            NSLog(@"deleteHistory Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

    
    return success;
}

-(BOOL)deleteAllHistory:(int)mediaType withStatus:(int)status withRemoteParty:(NSString *)remoteParty {
    BOOL success = NO;
    
    if([self openDatabase])
    {
        NSString *sql = nil;
        
        if(remoteParty){
            sql = [[NSString alloc] initWithFormat:@"DELETE FROM %s WHERE (status=%d and mediaType=%d and remoteParty='%@')", TABLE_HISTORY, status, mediaType, remoteParty];
        }
        else
        {
            sql = [[NSString alloc] initWithFormat:@"DELETE FROM %s WHERE (status=%d and mediaType=%d)", TABLE_HISTORY, status, mediaType];
        }
        
        const char *query_stmt = [sql UTF8String];
        // 执行删除联系人的SQL语句
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        }
        else
        {
            NSLog(@"deleteAllHistory Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

    
    return success;
}

-(BOOL)deleteAllHistory:(int)mediaType withRemoteParty: (NSString*)remoteParty
{
    BOOL success = NO;
    
    if([self openDatabase])
    {
        NSString *sql = nil;
        
        if(remoteParty){
//            sql = [[NSString alloc] initWithFormat:@"DELETE FROM %s WHERE (mediaType=%d and remoteParty='%@')", TABLE_HISTORY, mediaType, remoteParty];

          sql = [[NSString alloc] initWithFormat:@"DELETE FROM %s WHERE (remoteParty='%@')", TABLE_HISTORY, remoteParty];
            
        }
        else
        {
            sql = [[NSString alloc] initWithFormat:@"DELETE FROM %s WHERE (mediaType=%d)", TABLE_HISTORY, mediaType];
        }
        
        
        NSLog(@"delete sql=============%@",sql);
        
        const char *query_stmt = [sql UTF8String];
        // 执行删除联系人的SQL语句
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        }
        else
        {
            NSLog(@"deleteAllHistory Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
    
    return success;
}

-(History *)selectMessageByHistoryId:(int)historyId{
    
    //    NSString* messageID = [[NSString alloc] initWithFormat:@"%d",messageId];
    History *history;
    if ([self openDatabase]) {
        
        char whereFiled[80] = {0};
        sprintf(whereFiled, "WHERE (%s=%d)", CLUMN_MESSAGE_ROWID,historyId);
        
        char sqlStatement[1024];
        sprintf(sqlStatement, "SELECT * FROM %s %s" ,TABLE_CHATMESSAGE,whereFiled);
        
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {
            
            while(sqlite3_step(statement) == SQLITE_ROW) {
                history = [self historyFromStatement:statement MediaType:MediaType_Chat];
                break;
                
            }
            sqlite3_finalize(statement);
        }
        
    }

    return  history;
}


-(NSMutableArray *)selectMessage:(int)topCount byMediaType:(int)mediaType remotePaty:(NSString *)remotparty orderBYDESC:(BOOL)desc needCount:(BOOL)isNeed {
    mHistoryArray = [[NSMutableArray alloc] init];
    
    if ([self openDatabase]) {
        char limit[20] = {0};
        if(topCount > 0)
        {
            sprintf(limit, "LIMIT %d", topCount);
        }
        
        char whereFiled[80] = {0};
        sprintf(whereFiled, "WHERE (mediaType=%d)",MediaType_Chat);
        
        char sqlStatement[1024];
        sprintf(sqlStatement, "SELECT historyid, remoteParty, displayname, localParty, localDisplayname, start, end, mediaType, status, content , %s , %s , %s FROM %s %s %s ORDER BY start",CLUMN_MIMETYPE,CLUMN_PLAYDURATION,CLUMN_READ, TABLE_HISTORY,whereFiled,limit);
        
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {
            
            while(sqlite3_step(statement) == SQLITE_ROW) {
                
                int historyid = sqlite3_column_int(statement, 0);
                NSString *remoteParty = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                NSString *displayname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                NSString *localParty = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                NSString *localDisplayname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
                double start = sqlite3_column_double(statement, 5);
                double end = sqlite3_column_double(statement, 6);
                
                int mediaType = sqlite3_column_int(statement, 7);
                int status = sqlite3_column_int(statement, 8);
                
                const void* content = sqlite3_column_blob(statement, 9);
                NSUInteger contentLength = sqlite3_column_bytes(statement, 9);
                const char* cStringMime = (char *)sqlite3_column_text(statement, 10);
                NSString *mimetype=@"";
                if(cStringMime!=NULL){
                    mimetype = [NSString stringWithUTF8String:cStringMime];
                }
                int duration = sqlite3_column_int(statement, 11);
                int read = sqlite3_column_int(statement, 12);
                
                // 创建一个新对像，并且初始化赋值
                History *history = [[History alloc] initWithName:historyid
                                                   byRemoteParty:remoteParty
                                                   byDisplayName:displayname
                                                    byLocalParty:localParty
                                              byLocalDisplayname:localDisplayname
                                                     byTimeStart:start
                                                      byTimeStop:end
                                                      byMediaype:mediaType
                                                    byCallStatus:status
                                                       byContent:[NSData dataWithBytes: content length: contentLength]];
                history.mimeType = mimetype;
                history.mPlayDuration = duration;
                history.mRead = read;
                history.historyCount = sqlite3_column_int(statement, 13);
                
                [mHistoryArray addObject:history];
            }
            sqlite3_finalize(statement);
        }
        
    }

    return  mHistoryArray;
}

-(History *)historyFromStatement:(sqlite3_stmt *)statement MediaType:(int)mediaType{
    
    //CLUMN_MESSAGE_ROWID
    int historyid = sqlite3_column_int(statement, 0);
    //CLUMN_MESSAGE_TIME
    double time = sqlite3_column_double(statement, 1);
    //CLUMN_MESSAGE_SESSIONID
    int sessionId = sqlite3_column_int(statement, 2);
    //CLUMN_MESSAGE_STATUS
    int status = sqlite3_column_int(statement, 3);
    //CLUMN_MESSAGE_CONTENT
    const void* content = sqlite3_column_blob(statement, 4);
    NSUInteger contentLength = sqlite3_column_bytes(statement, 4);
    //CLUMN_MESSAGE_MIMETYPE
    NSString* mimeType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
    //CLUMN_MESSAGE_PLAYDURATION
    int duration = sqlite3_column_int(statement, 6);
    //CLUMN_MESSAGE_READ
    int read = sqlite3_column_int(statement, 7);
    //CLUMN_MESSAGE_ID
    long messageid = sqlite3_column_int(statement, 8);
    //CLUMN_MESSAGE_REMOVED
    int deleted = sqlite3_column_int(statement, 9);
    //CLUMN_MESSAGE_CONTENTLEN
    //contentlen = sqlite3_column_int(statement, 10);
    //CLUMN_MESSAGE_DESC
    NSString*desc = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 11)];
    //CLUMN_MESSAGE_SENDOUT
    int sendout = sqlite3_column_int(statement, 12);
    
    // 创建一个新对像，并且初始化赋值
    History *history = [[History alloc] initWithName:historyid
                                    byRemoteParty:nil
                                    byDisplayName:nil
                                    byLocalParty:nil
                                  byLocalDisplayname:nil
                                         byTimeStart:time
                                          byTimeStop:time
                                          byMediaype:mediaType
                                        byCallStatus:status
                                           byContent:[NSData dataWithBytes: content length: contentLength]];
    history.mimeType = mimeType;
    history.mPlayDuration = duration;
    history.mRead = read>0?false:true;
    //history.historyCount = sqlite3_column_int(statement, 13);
    history.mSessionId =sessionId;
    return history;
}

-(void)updateSessionUnreadCount:(int)sessionId UnreadCount:(int)count{
    BOOL success = NO;
    
    if([self openDatabase])
    {
        NSString *sql = nil;
        sql = [[NSString alloc] initWithFormat:@"UPDATE %s SET %s=%d WHERE (%s=%d)", TABLE_CHATSESSION,CLUMN_SESSION_UNREAD,count, CLUMN_SESSION_ID, sessionId];
        
        const char *query_stmt = [sql UTF8String];
        //执行删除会话的语句
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        }
        else
        {
            NSLog(@"updateSessionUnreadCount Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
}

-(int)getAllUnreadMessageCount:(NSString*)localUri{
    int count =0;
    if([self openDatabase])
    {
        NSString *sql = nil;
        sql = [[NSString alloc] initWithFormat:@"select sum(%s) from %s where %s='%@'", CLUMN_SESSION_UNREAD, TABLE_CHATSESSION,CLUMN_SESSION_LOCAL_URI, localUri];
        
        const char *query_stmt = [sql UTF8String];
        sqlite3_stmt *statement;
        //count = sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) ;
        if(sqlite3_prepare_v2(mDatabase, query_stmt, -1, &statement,NULL) == SQLITE_OK) {
           while(sqlite3_step(statement) == SQLITE_ROW) {
               count = sqlite3_column_int(statement, 0);
           }
         }
        sqlite3_finalize(statement);
    }
    
    return count;
}
-(void)updateMessageReadStatusBySessionExceptAudio:(int)sessionId HasRead:(Boolean)read{
    BOOL success = NO;
    
    if([self openDatabase])
    {
        NSString *sql = nil;
        sql = [[NSString alloc] initWithFormat:@"UPDATE %s SET %s=%d WHERE (%s=%d AND %s='%s')", TABLE_CHATMESSAGE,CLUMN_MESSAGE_READ,read?0:1, CLUMN_MESSAGE_SESSIONID, sessionId,CLUMN_MESSAGE_MIMETYPE,"audio%"];
        
        const char *query_stmt = [sql UTF8String];
        //执行删除会话的语句
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        }
        else
        {
            NSLog(@"updateMessageReadStatusBySessionExceptAudio Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
}


-(void)updateMessageReadStatusByMessageRowId:(int)messageRowId HasRead:(Boolean)read{
   BOOL success = NO;
    
    if([self openDatabase])
    {
        NSString *sql = nil;
        sql = [[NSString alloc] initWithFormat:@"UPDATE %s SET %s=%d WHERE (%s=%d)", TABLE_CHATMESSAGE,CLUMN_MESSAGE_READ,read?0:1, CLUMN_MESSAGE_ROWID, messageRowId];
        
        const char *query_stmt = [sql UTF8String];
        //执行删除会话的语句
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        }
        else
        {
            NSLog(@"deleteChatSessionBySessionId Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
}
-(void)updateMessageReadStatusBySession:(int)sessionId HasRead:(Boolean)read{
    BOOL success = NO;
    
    if([self openDatabase])
    {
        NSString *sql = nil;
        sql = [[NSString alloc] initWithFormat:@"UPDATE %s SET %s=%d WHERE (%s=%d)", TABLE_CHATMESSAGE,CLUMN_MESSAGE_READ,read?0:1, CLUMN_MESSAGE_SESSIONID, sessionId];
        
        const char *query_stmt = [sql UTF8String];
        //执行删除会话的语句
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        }
        else
        {
            NSLog(@"deleteChatSessionBySessionId Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
}

-(NSMutableArray *)selectChatSessionByLocalUri:(NSString*)localUri{
    NSMutableArray* chatSessions = [[NSMutableArray alloc] init];
    if([self openDatabase]){
//        NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %s WHERE %s = '%@' AND %s == %d",
//                         VIEW_CHATSESSION,CLUMN_SESSION_LOCAL_URI,localUri,CLUMN_SESSION_DELETE,0];
        NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %s WHERE %s = '%@'",
                         VIEW_CHATSESSION,CLUMN_SESSION_LOCAL_URI,localUri];
        const char *sqlStatement = [sql UTF8String];
        sqlite3_stmt *statement;
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement,NULL) == SQLITE_OK) {
            
            while(sqlite3_step(statement) == SQLITE_ROW) {
                if(sqlite3_column_int(statement, 4)==1)
                    continue;//CLUMN_SESSION_DELETE
                HSChatSession* session = [[HSChatSession alloc] init];
                
                //TABLE_CHATSESSION
                //sqlite3_column_name(statement, <#int N#>)//
                session.mRowid = sqlite3_column_int(statement, 0);
                //CLUMN_SESSION_LOCAL
                sqlite3_column_int(statement, 1);
                //CLUMN_SESSION_LOCAL_URI
                session.mLocalUri= [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                session.mRemoteid= sqlite3_column_int(statement, 3);//CLUMN_SESSION_REMOTE_ID
                session.mDelete= sqlite3_column_int(statement, 4);//CLUMN_SESSION_DELETE
 
                //CLUMN_SESSION_STATUS
                const char*status = (char *)sqlite3_column_text(statement, 5);
                if(status==NULL){
                    session.mStatus=@"";
                }else{
                    session.mStatus=[NSString stringWithUTF8String:status];
                }
                session.mLastTimeConnect= sqlite3_column_int(statement, 6);
                session.mCount= sqlite3_column_int(statement, 7);//UnreadCount
                //TABLE_REMOTER
                //CLUMN_REMOTE_ROWID
                sqlite3_column_int(statement, 8);
                //CLUMN_REMOTE_CONTACTID
                session.mContactid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
                //CLUMN_REMOTE_CONTACTTYPE
                //sqlite3_column_int(statement, 10);
                //CLUMN_REMOTE_URI
                session.mRemoteUri= [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 11)];
                //CLUMN_REMOTE_DISPLAYNAME
                session.mRemoteDisname= [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 12)];

                [chatSessions addObject:session];
            }
            sqlite3_finalize(statement);
        }
    }
    
    return chatSessions;
}

-(void)deleteChatSessionBySessionId:(int)sessionId{
    BOOL success = NO;
    
    if([self openDatabase])
    {
        NSString *sql = nil;
        sql = [[NSString alloc] initWithFormat:@"UPDATE %s SET %s=%d , %s=%d WHERE (%s=%d)", TABLE_CHATSESSION,CLUMN_SESSION_UNREAD,0,CLUMN_SESSION_DELETE,1, CLUMN_SESSION_ID, sessionId];
        
        const char *query_stmt = [sql UTF8String];
        //执行删除会话的语句
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        }
        else
        {
            NSLog(@"deleteChatSessionBySessionId Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
}

-(NSMutableArray *)searchMessage:(NSString*)filter byMediaType:(int)mediaType Sessions:(NSMutableArray*)sessions orderBYDESC:(BOOL)desc {
    mHistoryArray = [[NSMutableArray alloc] init];
    
    if ([self openDatabase]&&sessions.count>0) {
        NSString *ns=[sessions componentsJoinedByString:@","];
        char whereFiled[1024] = {0};

        sprintf(whereFiled, "WHERE (%s in (%s) AND %s!=1)",CLUMN_MESSAGE_SESSIONID ,[ns cStringUsingEncoding:kCFStringEncodingUTF8],CLUMN_MESSAGE_REMOVED);

        char sqlStatement[1024];
        sprintf(sqlStatement, "SELECT * FROM %s %s ORDER BY %s", TABLE_CHATMESSAGE,whereFiled,CLUMN_MESSAGE_TIME);
        
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {
            
            while(sqlite3_step(statement) == SQLITE_ROW) {
                History * history = [self historyFromStatement:statement MediaType:mediaType];
                
                NSDictionary *jsonConent = [history getJsonContent];
                NSString *msgType = [jsonConent valueForKey:KEY_MESSAGE_TYPE];
                NSString *fileName = [jsonConent valueForKey:KEY_FILE_NAME];
                NSString* messageContent=@"" ;
                if([MESSAGE_TYPE_TEXT isEqualToString:msgType]){
                    messageContent = [jsonConent valueForKey:KEY_TEXT_CONTENT];
                    messageContent= (messageContent==nil?NSLocalizedString(@"UnknowFormat_UnknowFormat", @"UnknowFormat_UnknowFormat"):messageContent);
                }else if([MESSAGE_TYPE_FILE isEqualToString:msgType]){
                    messageContent = [jsonConent valueForKey:KEY_FILE_NAME];
                }
                if([messageContent containsString:filter]){
                    [mHistoryArray addObject:history];
                }
            }
            sqlite3_finalize(statement);
        }
        
    }

    return  mHistoryArray;
}

-(NSMutableArray *)selectMessageBySessionId:(int)topCount byMediaType:(int)mediaType Sessionid:(int)sessionId orderBYDESC:(BOOL)desc needCount:(BOOL)isNeed {
    mHistoryArray = [[NSMutableArray alloc] init];
    
    if ([self openDatabase]) {
        char limit[20] = {0};
        if(topCount > 0)
        {
            sprintf(limit, "LIMIT %d", topCount);
        }
        
        char whereFiled[80] = {0};
        sprintf(whereFiled, "WHERE (%s=%d AND %s!=1)",CLUMN_MESSAGE_SESSIONID ,sessionId,CLUMN_MESSAGE_REMOVED);
        
        char sqlStatement[1024];
        sprintf(sqlStatement, "SELECT * FROM %s %s %s ORDER BY %s", TABLE_CHATMESSAGE,whereFiled,limit,CLUMN_MESSAGE_TIME);
        
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {
            
            while(sqlite3_step(statement) == SQLITE_ROW) {
                History * history = [self historyFromStatement:statement MediaType:mediaType];
                
                [mHistoryArray addObject:history];
            }
            sqlite3_finalize(statement);
        }
        
    }

    return  mHistoryArray;
}

-(History *)selectMessageByMessageId:(long)messageId {
    History *history;
    
    if ([self openDatabase]) {
        
        char sqlStatement[1024];
        sprintf(sqlStatement, "SELECT * FROM %s WHERE %s=%ld", TABLE_CHATMESSAGE,CLUMN_MESSAGE_ID,messageId);
        
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {
            
            while(sqlite3_step(statement) == SQLITE_ROW) {
                history = [self historyFromStatement:statement MediaType:(int)MediaType_Chat];
            }
            sqlite3_finalize(statement);
        }
        
    }

    return  history;
}

-(NSMutableArray *)selectMessagenew:(int)topCount byMediaType:(int)mediaType remotePaty:(NSString *)remotparty orderBYDESC:(BOOL)desc needCount:(BOOL)isNeed {
    mHistoryArray = [[NSMutableArray alloc] init];
    
    if ([self openDatabase]) {
        char limit[20] = {0};
        if(topCount > 0)
        {
            sprintf(limit, "LIMIT %d", topCount);
        }
        
        char whereFiled[80] = {0};
        sprintf(whereFiled, "WHERE (mediaType=%d)",MediaType_Chat);
        
        char sqlStatement[1024];
        sprintf(sqlStatement, "SELECT * FROM %s %s %s ORDER BY %s", TABLE_CHATMESSAGE,whereFiled,limit,CLUMN_MESSAGE_TIME);
        
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {
            while(sqlite3_step(statement) == SQLITE_ROW) {
                History *history = [self historyFromStatement:statement MediaType:mediaType];
 
                [mHistoryArray addObject:history];
            }
            sqlite3_finalize(statement);
        }
        
    }

    return  mHistoryArray;
}


-(NSMutableArray *)selectMessageGroup:(int)topCount byMediaType:(int)mediaType bylocal:(NSString*)localUri orderBYDESC:(BOOL)desc needCount:(BOOL)isNeed {
    mHistoryArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    if ([self openDatabase]) {
        char limit[20] = {0};
        if(topCount > 0)
        {
            sprintf(limit, "LIMIT %d", topCount);
        }
        
        char whereFiled[80] = {0};
        sprintf(whereFiled, "WHERE (mediaType=%d AND localParty='%s')",mediaType,localUri.UTF8String);
        
        char sqlStatement[1024];
        sprintf(sqlStatement, "SELECT historyid, remoteParty, displayname, localParty, localDisplayname, start, end, mediaType, status, content, %s FROM %s %s %s ORDER BY start DESC", CLUMN_MIMETYPE,TABLE_HISTORY,whereFiled,limit);
        
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {

            while(sqlite3_step(statement) == SQLITE_ROW) {
                
                int historyid = sqlite3_column_int(statement, 0);
                NSString *remoteParty = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                NSString *displayname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                NSString *localParty = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                NSString *localDisplayname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
                double start = sqlite3_column_double(statement, 5);
                double end = sqlite3_column_double(statement, 6);
                
                int mediaType = sqlite3_column_int(statement, 7);
                int status = sqlite3_column_int(statement, 8);
                
                const void* content = sqlite3_column_blob(statement, 9);
                NSUInteger contentLength = sqlite3_column_bytes(statement, 9);
                
                NSString *mime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 10)];

                History *history = [[History alloc] initWithName:historyid
                                                   byRemoteParty:remoteParty
                                                   byDisplayName:displayname
                                                    byLocalParty:localParty
                                              byLocalDisplayname:localDisplayname
                                                     byTimeStart:start
                                                      byTimeStop:end
                                                      byMediaype:mediaType
                                                    byCallStatus:status
                                                       byContent:[NSData dataWithBytes: content length: contentLength]];
                history.historyCount = sqlite3_column_int(statement, 11);
                history.mimeType = mime;
                History * record = [dic objectForKey:history.mRemoteParty];
                if(record==nil){
                    [dic setValue:history forKey:history.mRemoteParty];
                }else{
                    if(history.mTimeStart>record.mTimeStart){
                        [dic setValue:history forKey:history.mRemoteParty];
                    }
                }

            }
            sqlite3_finalize(statement);
        }
        
    }
    [mHistoryArray addObjectsFromArray:[dic allValues]];
    return mHistoryArray;
}

-(NSMutableArray *)selectMessageGroup:(int)topCount byMediaType:(int)mediaType orderBYDESC:(BOOL)desc needCount:(BOOL)isNeed {
    mHistoryArray = [[NSMutableArray alloc] init];
    
    if ([self openDatabase]) {
        char limit[20] = {0};
        if(topCount > 0)
        {
            sprintf(limit, "LIMIT %d", topCount);
        }
        
        char whereFiled[80] = {0};
        sprintf(whereFiled, "WHERE (mediaType=%d)",mediaType);
        
        char sqlStatement[1024];
        sprintf(sqlStatement, "SELECT historyid, remoteParty, displayname, localParty, localDisplayname, start, end, mediaType, status, content, %s FROM %s %s %s GROUP BY remoteParty ORDER BY start DESC", CLUMN_MIMETYPE,TABLE_HISTORY,whereFiled,limit);
        
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {
            while(sqlite3_step(statement) == SQLITE_ROW) {
                
                int historyid = sqlite3_column_int(statement, 0);
                NSString *remoteParty = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                NSString *displayname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                NSString *localParty = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                NSString *localDisplayname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
                double start = sqlite3_column_double(statement, 5);
                double end = sqlite3_column_double(statement, 6);
                
                int mediaType = sqlite3_column_int(statement, 7);
                int status = sqlite3_column_int(statement, 8);
                
                const void* content = sqlite3_column_blob(statement, 9);
                NSUInteger contentLength = sqlite3_column_bytes(statement, 9);
                
                NSString *mime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 10)];

                History *history = [[History alloc] initWithName:historyid
                                                   byRemoteParty:remoteParty
                                                   byDisplayName:displayname
                                                    byLocalParty:localParty
                                              byLocalDisplayname:localDisplayname
                                                     byTimeStart:start
                                                      byTimeStop:end
                                                      byMediaype:mediaType
                                                    byCallStatus:status
                                                       byContent:[NSData dataWithBytes: content length: contentLength]];
                history.historyCount = sqlite3_column_int(statement, 11);
                history.mimeType = mime;

                [mHistoryArray addObject:history];
            }
            sqlite3_finalize(statement);
        }
        
    }

    return  mHistoryArray;
}

-(NSMutableArray*)selectHistory:(int)topCount byMediaType:(int)mediaType LocalUri:(NSString*)localUri orderBYDESC:(BOOL)desc needCount:(BOOL)isNeed
{
    mHistoryArray = [[NSMutableArray alloc] init];
    if([self openDatabase])
    {
        char limit[20] = {0};
        if(topCount > 0)
        {
            sprintf(limit, "LIMIT %d", topCount);
        }
        
        NSString * whereFiled;
        if ((mediaType != MediaType_None) && (mediaType != MediaType_All)) {
            if (mediaType == MediaType_AudioVideo) {
                whereFiled = [[NSString alloc] initWithFormat:@"WHERE (localParty='%@') AND (mediaType=%d OR mediaType=%d OR mediaType=%d)",localUri,MediaType_Audio, MediaType_Video,MediaType_AudioVideo];

            }
            else
            {
                whereFiled = [[NSString alloc] initWithFormat:@"WHERE (localParty='%@') AND (mediaType=%d)",localUri,mediaType];
            }
            
        }

        char sqlStatement[1024];
        if(desc)
        {
            if (isNeed) {
                sprintf(sqlStatement, "SELECT historyid, remoteParty, displayname, localParty, localDisplayname, start, end, mediaType, status, content, COUNT(*) as callcount FROM %s %s %s GROUP BY remoteParty ORDER BY start DESC", TABLE_HISTORY,[whereFiled UTF8String],limit);
            } else {
                sprintf(sqlStatement, "SELECT historyid, remoteParty, displayname, localParty, localDisplayname, start, end, mediaType, status, content FROM %s %s %s ORDER BY start DESC", TABLE_HISTORY,[whereFiled UTF8String],limit);
            }
        }
        else
        {
            if (isNeed) {
                sprintf(sqlStatement, "SELECT historyid, remoteParty, displayname, localParty, localDisplayname, start, end, mediaType, status, content, COUNT(*) as callcount FROM %s %s %s GROUP BY remoteParty ORDER BY start", TABLE_HISTORY,[whereFiled UTF8String],limit);
            } else {
                sprintf(sqlStatement, "SELECT historyid, remoteParty, displayname, localParty, localDisplayname, start, end, mediaType, status, content FROM %s %s %s ORDER BY start", TABLE_HISTORY,[whereFiled UTF8String],limit);
            }
            
        }
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {

            while(sqlite3_step(statement) == SQLITE_ROW) {
                
                int historyid = sqlite3_column_int(statement, 0);
                NSString *remoteParty = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                NSString *displayname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                NSString *localParty = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                NSString *localDisplayname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
                double start = sqlite3_column_double(statement, 5);
                double end = sqlite3_column_double(statement, 6);
                
                int mediaType = sqlite3_column_int(statement, 7);
                int status = sqlite3_column_int(statement, 8);
                
                const void* content = sqlite3_column_blob(statement, 9);
                NSUInteger contentLength = sqlite3_column_bytes(statement, 9);
                

                History *history = [[History alloc] initWithName:historyid
                                                   byRemoteParty:remoteParty
                                                   byDisplayName:displayname
                                                    byLocalParty:localParty
                                              byLocalDisplayname:localDisplayname
                                                     byTimeStart:start
                                                      byTimeStop:end
                                                      byMediaype:mediaType
                                                    byCallStatus:status
                                                       byContent:[NSData dataWithBytes: content length: contentLength]];
                history.historyCount = sqlite3_column_int(statement, 10);

                [mHistoryArray addObject:history];
            }
            sqlite3_finalize(statement);
        }
    }

    return  mHistoryArray;
}

-(long) getLastReceivedMessageID:(NSString*)sender receiver:(NSString*)receiver{
    long messageID = -1;
    HSChatSession *session = [self findChatSession:receiver remoteUri:sender];
    if (session!=nil&&[self openDatabase]) {

        char limit[20] = {0};
//        sprintf(limit, "LIMIT %d", 1);
        
        char whereFiled[256] = {0};
        sprintf(whereFiled, "WHERE (%s=%d AND status=%d OR status=%d OR status=%d OR status=%d)",CLUMN_MESSAGE_SESSIONID,session.mRowid ,INCOMING_SUCESS,INCOMING_ATTACHFAILED,INCOMING_FAILED,INCOMING_PROCESSING);
        
        char sqlStatement[1024];
        sprintf(sqlStatement, "SELECT %s FROM %s %s %s ORDER BY %s DESC",CLUMN_MESSAGE_MESSAGEID, TABLE_CHATMESSAGE,whereFiled,limit,CLUMN_MESSAGE_ID);
        
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {
            
            while(sqlite3_step(statement) == SQLITE_ROW) {
                
                messageID = sqlite3_column_int64(statement, 0);
            
                break;

            }
            sqlite3_finalize(statement);
        }
        
    }

    return messageID;
}

-(void)updateHistoryReadStatus:(int)historyID withStatus:(Boolean)read
{
    NSString* strHistoryID = [[NSString alloc] initWithFormat:@"%d",historyID];
    
    if([self openDatabase])
    {
        char query_stmt[1024];
        sprintf(query_stmt, "UPDATE %s SET %s=%d WHERE (historyid=%s) ",TABLE_HISTORY,CLUMN_READ,read,[strHistoryID UTF8String]);
        
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@"updateHistoryID Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

}


-(void)updateAllProcessingStatus2Fail{
    if([self openDatabase])
    {
        char query_stmt[1024];
        sprintf(query_stmt, "UPDATE %s SET status=%d WHERE (%s=%ld) ",TABLE_HISTORY,OUTGOING_FAILED,"status",OUTGOING_PROCESSING);
        
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@"updateHistoryID Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
        
        memset(query_stmt, 1024, sizeof(char));
        sprintf(query_stmt, "UPDATE %s SET status=%d WHERE (%s=%ld) ",TABLE_HISTORY,INCOMING_FAILED,"status",INCOMING_PROCESSING);
        
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@"updateHistoryID Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

}

-(void)updateHistoryStatus:(long)messageId withStatus:(int) mStatus
{
    NSLog(@"chat message updateHistoryStatus Id= %d",messageId);
    
    if([self openDatabase])
    {
        char query_stmt[1024];
        sprintf(query_stmt, "UPDATE %s SET status=%d WHERE (%s=%ld) ",TABLE_HISTORY,mStatus,CLUMN_MESSAGEID,messageId);
        
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@"updateHistoryID Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

}

-(void)updateChatHistoryStatusByRowid:(int)historyId withStatus:(int) mStatus
{
    
    if([self openDatabase])
    {
        char query_stmt[1024];
        
        sprintf(query_stmt, "UPDATE %s SET %s=%d WHERE (%s=%d) ",TABLE_CHATMESSAGE,CLUMN_MESSAGE_STATUS, mStatus, CLUMN_MESSAGE_ROWID, historyId);
        
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@"updateHistoryID Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

}

-(void)updateChatHistoryStatusByMessageid:(long)messageId withStatus:(int) mStatus
{
    
    if([self openDatabase])
    {
        char query_stmt[1024];
        
        sprintf(query_stmt, "UPDATE %s SET %s=%d WHERE (%s=%ld) ",TABLE_CHATMESSAGE,CLUMN_MESSAGE_STATUS, mStatus, CLUMN_MESSAGE_ID, messageId);
        
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@"updateHistoryID Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

}

-(void)updateHistoryStatusForFile:(long)messageId replaceMessageId:(long)newId withStatus:(int) mStatus messageContent:(NSData*)content
{
    NSLog(@"chat message updateHistoryStatusForFile Id= %ld",messageId);

    if([self openDatabase])
    {
        char query_stmt[1024];
        NSString* strContent = [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
        
        sprintf(query_stmt, "UPDATE %s SET %s=%d , %s='%s', %s=%ld WHERE (%s=%ld) ",TABLE_CHATMESSAGE,CLUMN_MESSAGE_STATUS, mStatus,CLUMN_MESSAGE_CONTENT,[strContent UTF8String], CLUMN_MESSAGE_ID,newId,CLUMN_MESSAGEID, messageId);
        
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@"updateHistoryID Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

}

-(void)updateHistoryStatusForDownLoad:(int)historyid withStatus:(int) mStatus FilePath:(NSString*)filePath
{
    NSLog(@"chat message updateHistoryStatusForDownLoad Id= %d",historyid);
    History*old = [self selectMessageByHistoryId:historyid];
    if([self openDatabase]&&old!=nil)
    {
        char query_stmt[1024];
        
        NSString* oldcontent = old.getContentAsString;
        NSDictionary* dic = [History parserMessage:oldcontent];
        [dic setValue:filePath forKey:KEY_FILE_PATH];
        NSData* newContent = [History convertToJsonData:dic];

        NSString* strContent = [[NSString alloc] initWithData:newContent encoding:NSUTF8StringEncoding];
        sprintf(query_stmt, "UPDATE %s SET %s=%d , %s='%s' WHERE (%s=%d) ",TABLE_CHATMESSAGE,CLUMN_MESSAGE_STATUS,mStatus,CLUMN_MESSAGE_CONTENT, [strContent UTF8String],CLUMN_MESSAGE_ROWID, historyid);
        
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@"updateHistoryID Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

}

-(void)updateHistoryDuration:(int)historyid duraiton:(int)duration
{
    
    if([self openDatabase])
    {
        char query_stmt[1024];
        sprintf(query_stmt, "UPDATE %s SET %s=%d WHERE (historyid=%d) ",TABLE_HISTORY,CLUMN_PLAYDURATION,duration,historyid);
        
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@"updateHistoryID Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
    
}

-(void)updateHistoryStatusDurationForDownLoad:(int)historyid withStatus:(int)mStatus duraiton:(int)duration FilePath:(NSString*)filePath
{
    History* old= [self selectMessageByHistoryId:historyid];
    if([self openDatabase]&&old!=nil)
    {
        char query_stmt[1024];
        
        NSString* oldcontent = old.getContentAsString;
        NSDictionary* dic = [History parserMessage:oldcontent];
        [dic setValue:filePath forKey:KEY_FILE_PATH];
        NSData* newContent = [History convertToJsonData:dic];
        
        NSString* strContent = [[NSString alloc] initWithData:newContent encoding:NSUTF8StringEncoding];
        sprintf(query_stmt, "UPDATE %s SET %s=%d , %s=%d , %s='%s' WHERE (%s=%d) ",TABLE_CHATMESSAGE,CLUMN_MESSAGE_STATUS, mStatus,CLUMN_MESSAGE_PLAYDURATION, duration,CLUMN_MESSAGE_CONTENT,[strContent UTF8String],CLUMN_MESSAGE_ROWID, historyid);
        
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@"updateHistoryID Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
    
}

- (Options*)loadNetworkOptions
{
    if(mOptions == nil)
        mOptions = [[Options alloc] init];
    mOptions.opratorDelegate = self.opratorDel;
    if([self openDatabase])
    {
        //
        mOptions.autoReg = [self loadIntOptionsItem:OPTIONS_AUTO_REG defaultValue:DEFALUT_OPTIONS_AUTO_REG];
        
        mOptions.SIPTransport = [self loadIntOptionsItem:OPTIONS_NETWORK_TRANSPORT defaultValue:DEFALUT_OPTIONS_NETWORK_TRANSPORT];
        mOptions.use3G = [self loadIntOptionsItem:OPTIONS_NETWORK_USE_3G defaultValue:DEFALUT_OPTIONS_NETWORK_USE_3G];
        mOptions.forceBackground = [self loadIntOptionsItem:OPTIONS_FORCE_BACGROUND defaultValue:DEFALUT_OPTIONS_FORCE_BACKGROUND];
        
        
        //mOptions.enableCallKit = [self loadIntOptionsItem:OPTIONS_ENABLE_CALLKIT defaultValue:DEFAULT_OPTIONS_ENABLE_CALLKIT];
        
        BOOL supportCallKit = [mOptions supportCallKit];//default
        mOptions.enableCallKit = [self loadIntOptionsItem:OPTIONS_ENABLE_CALLKIT defaultValue:supportCallKit];
        
        mOptions.useWIFI = [self loadIntOptionsItem:OPTIONS_NETWORK_USE_WIFI defaultValue:DEFALUT_OPTIONS_NETWORK_USE_WIFI];
        mOptions.useSRTP = [self loadIntOptionsItem:OPTIONS_NETWORK_USE_SRTP defaultValue:DEFALUT_OPTIONS_NETWORK_USE_SRTP];
        
        mOptions.enableSTUN = [self loadIntOptionsItem:OPTIONS_NATT_USE_STUN defaultValue:DEFALUT_OPTIONS_NATT_USE_STUN];
        mOptions.STUNServer = [self loadTextOptionsItem:OPTIONS_NATT_STUN_SERVER defaultValue:DEFALUT_OPTIONS_NATT_STUN_SERVER];
        mOptions.STUNPort = [self loadIntOptionsItem:OPTIONS_NATT_STUN_PORT defaultValue:DEFALUT_OPTIONS_NATT_STUN_PORT];
        
        mOptions.presenceAgent = [self loadIntOptionsItem:OPRIONS_NATT_PRESENCE_AGENT defaultValue:DEFALUT_OPTIONS_NATT_PRESENCE_AGENT];
        mOptions.publishRefresh = [self loadIntOptionsItem:OPTIONS_NATT_PUBLISH_REFRESH defaultValue:DEFAULT_OPTIONS_NATT_PUBLISH_REFRESH];
        mOptions.subscribeRefresh = [self loadIntOptionsItem:OPTIONS_NATT_SUBSCRIBE_REFRESH defaultValue:DEFAULT_OPTIONS_NATT_SUBSCRIBE_REFRESH];
        
        mOptions.useCert = [self loadIntOptionsItem:OPTIONS_NATT_USE_CERT defaultValue:DEFAULT_OPTIONS_NATT_USE_CERT];
    }
    
    return mOptions;
}

- (Options*)loadAVOptions
{
    if(mOptions == nil)
        mOptions = [[Options alloc] init];
    mOptions.opratorDelegate = self.opratorDel;
    if([self openDatabase])
    {
        
        //forward
        mOptions.enableForward = [self loadIntOptionsItem:OPTIONS_MEDIA_ENABLEFORWARD defaultValue:DEFALUT_OPTIONS_MEDIA_ENABLEFORWARD];
        mOptions.forwardTo = [self loadTextOptionsItem:OPTIONS_MEDIA_FORWARDTO defaultValue:nil];
        //audio features
        
        mOptions.rtpPortFrom = [self loadIntOptionsItem:OPTIONS_MEDIA_RTPPORTFROM defaultValue:DEFALUT_OPTIONS_MEDIA_RTPPORTFROM];
        
        mOptions.enableVAD = [self loadIntOptionsItem:OPTIONS_MEDIA_ENABLEVAD defaultValue:DEFALUT_OPTIONS_MEDIA_ENABLEVAD];
        mOptions.enableCNG = [self loadIntOptionsItem:OPTIONS_MEDIA_ENABLECNG defaultValue:DEFALUT_OPTIONS_MEDIA_ENABLECNG];
        mOptions.dtmfOfInfo = [self loadIntOptionsItem:OPTIONS_MEDIA_DTMF_OF_INFO defaultValue:DEFALUT_OPTIONS_MEDIA_DTMF_OF_INFO];
        mOptions.playDtmfTone = [self loadIntOptionsItem:OPTIONS_MEDIA_PLAY_DTMF_TONE defaultValue:DEFALUT_OPTIONS_MEDIA_PLAY_DTMF_TONE];
        
        //video features
        mOptions.videoBandwidth = [self loadIntOptionsItem:OPTIONS_PRECOND_BANDWIDTH defaultValue:DEFALUT_OPTIONS_PRECOND_BANDWIDTH];
        mOptions.videoFrameRate = [self loadIntOptionsItem:OPTIONS_MEDIA_PREFERRED_VIDEO_FPS
                                              defaultValue:DEFALUT_OPTIONS_MEDIA_PREFERRED_VIDEO_FPS];
        mOptions.videoResolution = [self loadIntOptionsItem:OPTIONS_MEDIA_PREFERRED_VIDEO_SIZE
                                               defaultValue:DEFALUT_OPTIONS_MEDIA_PREFERRED_VIDEO_SIZE];
        mOptions.videoNACK = [self loadIntOptionsItem:OPTIONS_MEDIA_PREFERRED_VIDEO_NACK
                                         defaultValue:DEFALUT_OPTIONS_MEDIA_PREFERRED_VIDEO_NACK];
        //load codec
        mOptions.codecG722 = [self loadIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_G722 defaultValue:DEFALUT_OPTIONS_MEDIA_CODEC_USE_G722];
        mOptions.codecG729 = [self loadIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_G729 defaultValue:DEFALUT_OPTIONS_MEDIA_CODEC_USE_G729];
        mOptions.codecAMR = [self loadIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_AMR defaultValue:DEFALUT_OPTIONS_MEDIA_CODEC_USE_AMR];
        mOptions.codecAMRwb = [self loadIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_AMRWB defaultValue:DEFALUT_OPTIONS_MEDIA_CODEC_USE_AMRWB];
        
        mOptions.codecGSM = [self loadIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_GSM defaultValue:DEFALUT_OPTIONS_MEDIA_CODEC_USE_GSM];
        mOptions.codecPCMA = [self loadIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_PCMA defaultValue:DEFALUT_OPTIONS_MEDIA_CODEC_USE_PCMA];
        mOptions.codecPCMU = [self loadIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_PCMU defaultValue:DEFALUT_OPTIONS_MEDIA_CODEC_USE_PCMU];
        mOptions.codecILBC = [self loadIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_ILBC defaultValue:DEFALUT_OPTIONS_MEDIA_CODEC_USE_ILBC];
        mOptions.codecSpeexNB = [self loadIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_SPEEX_NB defaultValue:DEFALUT_OPTIONS_MEDIA_CODEC_USE_SPEEX_NB];
        mOptions.codecSpeexWB = [self loadIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_SPEEX_WB defaultValue:DEFALUT_OPTIONS_MEDIA_CODEC_USE_SPEEX_WB];
        mOptions.codecOPUS = [self loadIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_OPUS defaultValue:DEFALUT_OPTIONS_MEDIA_CODEC_USE_OPUS];
        
        //Video codec
        mOptions.codecH263 = [self loadIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_H263 defaultValue:DEFALUT_OPTIONS_MEDIA_CODEC_USE_H263];
        mOptions.codecH263_1998 = [self loadIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_H263_1998 defaultValue:DEFALUT_OPTIONS_MEDIA_CODEC_USE_H263_1998];
        mOptions.codecH264 = [self loadIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_H264 defaultValue:DEFALUT_OPTIONS_MEDIA_CODEC_USE_H264];
        mOptions.codecVP8 = [self loadIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_VP8 defaultValue:DEFALUT_OPTIONS_MEDIA_CODEC_USE_VP8];
        
        mOptions.codecVP9 = [self loadIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_VP9 defaultValue:DEFALUT_OPTIONS_MEDIA_CODEC_USE_VP9];
        
        //Badge
        mOptions.mCallBadge = [self loadIntOptionsItem:OPTIONS_CALL_BADGE_COUNT defaultValue:DEFALUT_OPTIONS_CALL_BADGE_COUNT];
        mOptions.mMsgBadge = [self loadIntOptionsItem:OPTIONS_MESSAGE_BADGE_COUNT defaultValue:DEFALUT_OPTIONS_MESSAGE_BADGE_COUNT];
        [mOptions setAudioVideoCodec];
    }

    return mOptions;
}

- (void)saveOptions
{
    if(mOptions != nil)
    {
        if([self openDatabase])
        {
            [self saveIntOptionsItem:OPTIONS_AUTO_REG intValue:mOptions.autoReg];
            
            //Network
            [self saveIntOptionsItem:OPTIONS_NETWORK_TRANSPORT intValue:mOptions.SIPTransport];
            
            
            [self saveIntOptionsItem:OPTIONS_NETWORK_USE_3G intValue:mOptions.use3G];
            [self saveIntOptionsItem:OPTIONS_FORCE_BACGROUND intValue:mOptions.forceBackground];
            [self saveIntOptionsItem:OPTIONS_ENABLE_CALLKIT intValue:mOptions.enableCallKit];
            [self saveIntOptionsItem:OPTIONS_NETWORK_USE_WIFI intValue:mOptions.useWIFI];
            [self saveIntOptionsItem:OPTIONS_NETWORK_USE_SRTP intValue:mOptions.useSRTP];
            
            [self saveIntOptionsItem:OPTIONS_NATT_USE_STUN intValue:mOptions.enableSTUN];
            [self saveTextOptionsItem:OPTIONS_NATT_STUN_SERVER textValue:mOptions.STUNServer];
            [self saveIntOptionsItem:OPTIONS_NATT_STUN_PORT intValue:mOptions.STUNPort];
            
            [self saveIntOptionsItem:OPRIONS_NATT_PRESENCE_AGENT intValue:mOptions.presenceAgent];
            [self saveIntOptionsItem:OPTIONS_NATT_PUBLISH_REFRESH intValue:mOptions.publishRefresh];
            [self saveIntOptionsItem:OPTIONS_NATT_SUBSCRIBE_REFRESH intValue:mOptions.subscribeRefresh];
            
            [self saveIntOptionsItem:OPTIONS_NATT_USE_CERT intValue:mOptions.useCert];
            
            //forward
            [self saveIntOptionsItem:OPTIONS_MEDIA_ENABLEFORWARD intValue:mOptions.enableForward];
            [self saveTextOptionsItem:OPTIONS_MEDIA_FORWARDTO textValue:mOptions.forwardTo];
            
            //Audio features
            [self saveIntOptionsItem:OPTIONS_MEDIA_RTPPORTFROM intValue:mOptions.rtpPortFrom];
            
            [self saveIntOptionsItem:OPTIONS_MEDIA_ENABLEVAD intValue:mOptions.enableVAD];
            [self saveIntOptionsItem:OPTIONS_MEDIA_ENABLECNG intValue:mOptions.enableCNG];
            [self saveIntOptionsItem:OPTIONS_MEDIA_DTMF_OF_INFO intValue:mOptions.dtmfOfInfo];
            [self saveIntOptionsItem:OPTIONS_MEDIA_PLAY_DTMF_TONE intValue:mOptions.playDtmfTone];
            
            //Video features
            [self saveIntOptionsItem:OPTIONS_PRECOND_BANDWIDTH intValue:mOptions.videoBandwidth];
            [self saveIntOptionsItem:OPTIONS_MEDIA_PREFERRED_VIDEO_FPS intValue:mOptions.videoFrameRate];
            [self saveIntOptionsItem:OPTIONS_MEDIA_PREFERRED_VIDEO_SIZE intValue:mOptions.videoResolution];
            [self saveIntOptionsItem:OPTIONS_MEDIA_PREFERRED_VIDEO_NACK intValue:mOptions.videoNACK];
            
            //Audio codec
            [self saveIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_G722 intValue:mOptions.codecG722];
            [self saveIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_G729 intValue:mOptions.codecG729];
            [self saveIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_AMR intValue:mOptions.codecAMR];
            [self saveIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_AMRWB intValue:mOptions.codecAMRwb];
            [self saveIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_GSM intValue:mOptions.codecGSM];
            [self saveIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_PCMA intValue:mOptions.codecPCMA];
            [self saveIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_PCMU intValue:mOptions.codecPCMU];
            [self saveIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_ILBC intValue:mOptions.codecILBC];
            [self saveIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_SPEEX_NB intValue:mOptions.codecSpeexNB];
            [self saveIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_SPEEX_WB intValue:mOptions.codecSpeexWB];
            [self saveIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_OPUS intValue:mOptions.codecOPUS];
            
            //Video codec
            [self saveIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_H263 intValue:mOptions.codecH263];
            [self saveIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_H263_1998 intValue:mOptions.codecH263_1998];
            [self saveIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_H264 intValue:mOptions.codecH264];
            [self saveIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_VP8 intValue:mOptions.codecVP8];
            [self saveIntOptionsItem:OPTIONS_MEDIA_CODEC_USE_VP9 intValue:mOptions.codecVP9];
            
            
            //Badge
            [self saveIntOptionsItem:OPTIONS_CALL_BADGE_COUNT intValue:mOptions.mCallBadge];
            [self saveIntOptionsItem:OPTIONS_MESSAGE_BADGE_COUNT intValue:mOptions.mMsgBadge];
            
            [mOptions setAudioVideoCodec];
        }
        
    }
}

#pragma mark Favorites
-(NSMutableArray *)loadFavorites{
    mFavoritesArray = [[NSMutableArray alloc] init];
    if([self openDatabase])
    {
        const char *sqlStatement = "SELECT favoriteid, phonetype,typedescript,phonenum, name FROM favorites";
        
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {

            while(sqlite3_step(statement) == SQLITE_ROW) {
                
                
                int phonetype = sqlite3_column_int(statement, 1);
                char * typedescript = (char *)sqlite3_column_text(statement, 2);
                char * phonenum = (char *)sqlite3_column_text(statement, 3);
                char * name = (char *)sqlite3_column_text(statement, 4);
                
#ifdef __IPHONE_9_0
                char * identifier = (char *)sqlite3_column_text(statement, 0);
                Favorite* favorite = [[Favorite alloc] initWithIdentifi:[NSString stringWithUTF8String:identifier] type:phonetype typedescription:[NSString stringWithUTF8String:typedescript] num:[NSString stringWithUTF8String:phonenum] dispalyname:[NSString stringWithUTF8String:name]];
#else
                int favoriteid = sqlite3_column_int(statement, 0);

                Favorite* favorite = [[Favorite alloc] initWithID:favoriteid type:phonetype typedescription:[NSString stringWithUTF8String:typedescript] num:[NSString stringWithUTF8String:phonenum] dispalyname:[NSString stringWithUTF8String:name]];
#endif
                
                [mFavoritesArray addObject:favorite];
            }
            sqlite3_finalize(statement);
        }
    }else{
        
    }
    
    //NSLog(@"mFavoritesArray  mFavoritesArray mFavoritesArray= %@",mFavoritesArray);
    
    return  mFavoritesArray;
}

-(BOOL)insertFavorite:(Favorite*)favorite{
    BOOL success = NO;
    if([self openDatabase])
    {
#ifdef __IPHONE_9_0
        NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO favorites(favoriteid, phonetype,typedescript,phonenum,name) VALUES ('%@',%d,'%@','%@','%@')",favorite.mFavoriteIdentifi,favorite.mPhoneType,favorite.mTypeDescription,favorite.mPhoneNum,favorite.mDisplayName];
#else
        NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO favorites(favoriteid, phonetype,typedescript,phonenum,name) VALUES (%d,%d,'%@','%@','%@')",favorite.mFavoriteId,favorite.mPhoneType,favorite.mTypeDescription,favorite.mPhoneNum,favorite.mDisplayName];
#endif
        
        
        const char *query_stmt = [sql UTF8String];
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        } else {
            NSLog(@"insertFavorite Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
    return success;
    
}

-(BOOL)removeFavorite:(Favorite*)favorite{
    
    BOOL success = NO;
    
    if([self openDatabase])
    {
#ifdef __IPHONE_9_0
         NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM favorites WHERE (favoriteid='%@' and phonetype=%d and phonenum='%@')", favorite.mFavoriteIdentifi,favorite.mPhoneType,favorite.mPhoneNum];
#else
         NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM favorites WHERE (favoriteid=%d and phonetype=%d and phonenum='%@')", favorite.mFavoriteId,favorite.mPhoneType,favorite.mPhoneNum];
#endif
        
        const char *query_stmt = [sql UTF8String];
        
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        }
        else
        {
            NSLog(@"deletefavorite Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
    
    return success;
}


#pragma mark - SIPFriends
-(NSMutableArray *)loadSIPFriends {
    mSIPContacts = [[NSMutableArray alloc] init];
    if([self openDatabase])
    {
        const char *sqlStatement = "SELECT sipid, sipIdentifier,SunbscribeID, displayName,firstName,lastName, company, partment,jobtitle,creatDate,imNumber,comefrom,deleteflag, applystate,phoneNumbers, ipNumbers FROM sipfriends";
        
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(mDatabase, sqlStatement, -1, &statement, NULL) == SQLITE_OK) {
            while(sqlite3_step(statement) == SQLITE_ROW) {
                
                int sipID = sqlite3_column_int(statement, 0);
//                char * sipIdentifier = (char *)sqlite3_column_text(statement, 1);
                int subscribeid = sqlite3_column_int(statement, 2);
                char * displayName = (char *)sqlite3_column_text(statement, 3);
                char * firstName = (char *)sqlite3_column_text(statement, 4);
                char * lastName = (char *)sqlite3_column_text(statement, 5);
                char * company = (char *)sqlite3_column_text(statement, 6);
                char * partment = (char *)sqlite3_column_text(statement, 7);
                char * jobtitle = (char *)sqlite3_column_text(statement, 8);
                
                char * imNumber = (char *)sqlite3_column_text(statement, 10);
                int comefrom = sqlite3_column_int(statement, 11);
                int deletflag = sqlite3_column_int(statement, 12);
                int applystate = sqlite3_column_int(statement, 13);
                char * phoneNumbers = (char *)sqlite3_column_text(statement, 14);
                char * ipCallNumbers = (char *)sqlite3_column_text(statement, 15);
                
                
                Contact *contact = [[Contact alloc] initWithIdentifi:sipID SunbscribeID:subscribeid DisplayName:[NSString stringWithUTF8String:displayName] Firstname:[NSString stringWithUTF8String:firstName] Lastname:[NSString stringWithUTF8String:lastName] Company:[NSString stringWithUTF8String:company] Department:[NSString stringWithUTF8String:partment] Jobtitle:[NSString stringWithUTF8String:jobtitle] IMNumber:[NSString stringWithUTF8String:imNumber] Comfrom:comefrom DeletFlag:deletflag ApplyState:applystate PhoneNumbers:[NSString stringWithUTF8String:phoneNumbers] IPNumbers:[NSString stringWithUTF8String:ipCallNumbers]];
                
//                contact.ID = sipID;
                
                
                [mSIPContacts addObject:contact];
            }
            sqlite3_finalize(statement);
        }
    }else{
        
    }
    return  mSIPContacts;
}

-(BOOL)insertSipFriend:(Contact *)sipfriend {
    BOOL success = NO;
    if([self openDatabase])
    {
        NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO sipfriends(sipIdentifier, SunbscribeID ,displayName,firstName,lastName, company, partment,jobtitle,imNumber ,comefrom,deleteflag, applystate, phoneNumbers, ipNumbers) VALUES ('%@',%d,'%@','%@','%@','%@','%@','%@','%@',%d,%d,%d,'%@','%@')", @"",(int)sipfriend.subscribeID,sipfriend.displayName,sipfriend.firstName,sipfriend.lastName,sipfriend.company,sipfriend.partment,sipfriend.jobtitle,sipfriend.imNumber,sipfriend.comeFrom,sipfriend.deleteFlag,sipfriend.applyState,sipfriend.phoneNumberString,sipfriend.ipCallNumberString];
        
        const char *query_stmt = [sql UTF8String];
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        } else {
            NSLog(@"insertSipFriend Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

    return success;
}


-(void)updateSipFriend:(Contact *)sipFriend {
    
    if([self openDatabase])
    {
        
        NSString *sql = [NSString stringWithFormat:@"UPDATE %s SET SunbscribeID=%d,displayName='%@',firstName='%@',lastName='%@',company='%@',partment='%@',jobtitle='%@',creatDate='%@',imNumber='%@',comefrom=%d,deleteflag=%d,applystate=%d,phoneNumbers='%@',ipNumbers='%@' WHERE (displayName='%@')",TABLE_SIPFRIENDS,(int)sipFriend.subscribeID,sipFriend.displayName,sipFriend.firstName,sipFriend.lastName,sipFriend.company,sipFriend.partment,sipFriend.jobtitle,sipFriend.creatDate,sipFriend.imNumber,sipFriend.comeFrom,sipFriend.deleteFlag,sipFriend.applyState,sipFriend.phoneNumberString,sipFriend.ipCallNumberString,sipFriend.displayName];
        
        const char *query_stmt = [sql UTF8String];
        
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@"updateHistoryID Error！%s",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

}

-(BOOL)removeSipFriendWithDisplayName:(NSString *)displayName {
    BOOL success = NO;
    
    if([self openDatabase])
    {
        NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM sipfriends WHERE (displayName='%@')", displayName];
        const char *query_stmt = [sql UTF8String];
        
        if (sqlite3_exec(mDatabase, query_stmt, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {
            success = YES;
        }
        else
        {
            sqlite3_free(mErrorMsg);
        }
    }
    
    return success;
}



-(void)updateTableVersion
{
    char sql[1024] = {0};
    sprintf(sql, "select tablename,version from %s", TABLE_VERSION_NEW);
    sqlite3_stmt *statement;
    int accountTableVersion = 0;
    int optionsTableVersion = 0;
    int historyTableVersion = 0;
    int favoritesTableVersion = 0;
    int sipfriendsTableVersion = 0;
    int sessionTableVersion=0;
    int messageTableVersion=0;
    int remoteTableVersion=0;
    
    if(![self openDatabase]){
        return;
    }
    
    if(sqlite3_prepare_v2(mDatabase, sql, -1, &statement, NULL) == SQLITE_OK) {
        
        char tablename[32];
        int version = 100;
        
        while(sqlite3_step(statement) == SQLITE_ROW) {
            
            
            strcpy(tablename,    (char *)sqlite3_column_text(statement, 0));
            version = sqlite3_column_int(statement, 1);
            
            if(strcmp(tablename, TABLE_ACCOUNT) == 0)
            {
                accountTableVersion = version;
            }else if(strcmp(tablename, TABLE_OPTIONS) == 0){
                optionsTableVersion = version;
            }else if(strcmp(tablename,  TABLE_HISTORY) == 0){
                historyTableVersion = version;
            }else if(strcmp(tablename,  TABLE_FAVORITES) == 0){
                favoritesTableVersion = version;
            }else if(strcmp(tablename,  TABLE_SIPFRIENDS) == 0){
                sipfriendsTableVersion = version;
            }else if(strcmp(tablename,  TABLE_CHATSESSION) == 0){
                sessionTableVersion = version;
            }else if(strcmp(tablename,  TABLE_CHATMESSAGE) == 0){
                messageTableVersion = version;
            }else if(strcmp(tablename,  TABLE_REMOTER) == 0){
                remoteTableVersion = version;
            }
            
        }
        sqlite3_finalize(statement);
    }
    else
    {

        accountTableVersion =0;
        optionsTableVersion =0;
        historyTableVersion =0;
        favoritesTableVersion = 0;
        sipfriendsTableVersion =0;
        sessionTableVersion =0;
        messageTableVersion =0;
        remoteTableVersion =0;
    }
    
    [self updateAccountTable:accountTableVersion to:DB_ACCOUNT_VERSION_NEW];
    [self updateOptionsTable:optionsTableVersion to:DB_OPTIONS_VERSION_NEW];
    [self updateHistroyTable:historyTableVersion to:DB_HISTORY_VERSION_NEW];
    [self updateFavoriterTable:favoritesTableVersion to:DB_FAVORITES_VERSION];
    [self updateSipFriendTable:sipfriendsTableVersion to:DB_SIPFRIENDS_VERSION];
    
    
    [self updateRemoterTable:remoteTableVersion to:DB_REMOTER_VERSION];
    [self updateChatSessionTable:sessionTableVersion to:DB_CHATSESSION_VERSION];
    [self updateChatMessageTable:messageTableVersion to:DB_CHATMESSAGE_VERSION];
    
    if(![self isTableExist:TABLE_VERSION_NEW]){


        sprintf(sql, "CREATE TABLE IF NOT EXISTS %s(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, tablename TEXT,version INTEGER)",TABLE_VERSION_NEW);
        
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) == SQLITE_OK)
        {//创建成功,插入新记录
            sprintf(sql, "insert into %s (tablename,version) values('%s',%d)",TABLE_VERSION_NEW,TABLE_OPTIONS,DB_OPTIONS_VERSION_NEW);
            if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
            {
                sqlite3_free(mErrorMsg);
            }
            
            sprintf(sql, "insert into %s (tablename,version) values('%s',%d)",TABLE_VERSION_NEW,TABLE_HISTORY,DB_HISTORY_VERSION_NEW);
            if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
            {
                sqlite3_free(mErrorMsg);
            }
            
            sprintf(sql, "insert into %s (tablename,version) values('%s',%d)",TABLE_VERSION_NEW,TABLE_ACCOUNT,DB_ACCOUNT_VERSION_NEW);
            if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
            {
                sqlite3_free(mErrorMsg);
            }
            
            sprintf(sql, "insert into %s (tablename,version) values('%s',%d)",TABLE_VERSION_NEW,TABLE_FAVORITES,DB_FAVORITES_VERSION);
            if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
            {
                sqlite3_free(mErrorMsg);
            }
            
            sprintf(sql, "insert into %s (tablename,version) values('%s',%d)",TABLE_VERSION_NEW,TABLE_SIPFRIENDS,DB_SIPFRIENDS_VERSION);
            if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
            {
                sqlite3_free(mErrorMsg);
            }
        }else{
            
        }
    }
    
}

-(void)updateVersionCode:(char*)tableName to:(int)newVersionCode
{
    char sql[1024] = {0};
    sprintf(sql, "DELETE FROM %s WHERE (tablename=%s)",TABLE_VERSION_NEW,tableName);
    
    if(![self openDatabase]){
        return;
    }
    
    if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
    {
        NSLog(@"updateVersionCode Error！%s",mErrorMsg);
        sqlite3_free(mErrorMsg);
    }

    sprintf(sql, "insert into %s (tablename,version) values('%s',%d)",TABLE_VERSION_NEW,tableName,newVersionCode);
    if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
    {
        sqlite3_free(mErrorMsg);
    }
}

-(void)updateChatMessageTable:(int)from to:(int)dest{
    char sql[1024] = {0};
    
    if(from >= dest){
        if(dest==102){
            if(![self isClumnExist:TABLE_CHATMESSAGE _:CLUMN_MESSAGE_CONTENTLEN]){
                [self addClumn:TABLE_CHATMESSAGE _:CLUMN_MESSAGE_CONTENTLEN _:"INTEGER"];
            }
            if(![self isClumnExist:TABLE_CHATMESSAGE _:CLUMN_MESSAGE_DESC]){
                [self addClumn:TABLE_CHATMESSAGE _:CLUMN_MESSAGE_DESC _:"TEXT"];
            }
            if(![self isClumnExist:TABLE_CHATMESSAGE _:CLUMN_MESSAGE_SENDOUT]){
                [self addClumn:TABLE_CHATMESSAGE _:CLUMN_MESSAGE_SENDOUT _:"INTEGER"];
            }
        }
        return;
    }
    if(![self openDatabase]){
        return ;
    }
    
    if ([self isTableExist:TABLE_CHATMESSAGE]) {
        sprintf(sql, "drop table %s", TABLE_CHATMESSAGE);
        
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg)  != SQLITE_OK ){
            NSLog(@"DEL FAILED");
        }
    }
    

    if (![self isTableExist:TABLE_CHATMESSAGE]){
        sprintf(sql, "CREATE TABLE IF NOT EXISTS %s(%s INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, %s DOUBLE, %s INTEGER, %s INTEGER, %s BLOB, %s TEXT,%s INTEGER, %s INTEGER,%s INTEGER, %s INTEGER,%s INTEGER,%s TEXT,%s INTEGER)",TABLE_CHATMESSAGE,CLUMN_MESSAGE_ROWID,CLUMN_MESSAGE_TIME,CLUMN_MESSAGE_SESSIONID,CLUMN_MESSAGE_STATUS,CLUMN_MESSAGE_CONTENT,CLUMN_MESSAGE_MIMETYPE,CLUMN_MESSAGE_PLAYDURATION,CLUMN_MESSAGE_READ,CLUMN_MESSAGE_ID,CLUMN_MESSAGE_REMOVED,CLUMN_MESSAGE_CONTENTLEN,CLUMN_MESSAGE_DESC,CLUMN_MESSAGE_SENDOUT);
        
        NSLog(@" createTable %s",TABLE_CHATMESSAGE);
        
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@" createTable %s Error:%s ",TABLE_CHATMESSAGE,mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

    [self updateVersionCode:TABLE_CHATMESSAGE to:DB_CHATMESSAGE_VERSION];
}


-(void)updateChatSessionTable:(int)from to:(int)dest{
    char sql[1024] = {0};
    
    if(from >= dest){
        return;
    }
    
    if(![self openDatabase]){
        return ;
    }
    
    if ([self isTableExist:TABLE_CHATSESSION]) {
        sprintf(sql, "drop table %s", TABLE_CHATSESSION);
        
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg)  != SQLITE_OK ){
            NSLog(@"删除表失败");
        }
    }
    if (![self isTableExist:TABLE_CHATSESSION]){
        

        sprintf(sql, "CREATE TABLE IF NOT EXISTS %s(%s INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, %s INTEGER, %s TEXT,  %s INTEGER, %s INTEGER DEFAULT 0, %s TEXT,  %s INTEGER, %s INTEGER  DEFAULT 0)", TABLE_CHATSESSION,CLUMN_SESSION_ID,CLUMN_SESSION_LOCAL,CLUMN_SESSION_LOCAL_URI,CLUMN_SESSION_REMOTE_ID,CLUMN_SESSION_DELETE,CLUMN_SESSION_STATUS,CLUMN_SESSION_LASTTIME,CLUMN_SESSION_UNREAD);

        
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@" createTable %s Error:%s ",TABLE_CHATSESSION,mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

    [self updateVersionCode:TABLE_CHATSESSION  to:DB_CHATSESSION_VERSION];
}

-(void)updateRemoterTable:(int)from to:(int)dest{
    char sql[1024] = {0};
    
    if(from >= dest){
        return;
    }
    if(![self openDatabase]){
        return ;
    }
    if ([self isTableExist:TABLE_REMOTER]) {

        sprintf(sql, "drop table %s", TABLE_REMOTER);
        
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg)  != SQLITE_OK ){
            NSLog(@"DEL FAILED");
        }
    }
    if (![self isTableExist:TABLE_REMOTER]){

        sprintf(sql, "CREATE TABLE IF NOT EXISTS %s(%s INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, %s INTEGER, %s TEXT, %s TEXT, %s TEXT)",TABLE_REMOTER,CLUMN_REMOTE_ROWID,CLUMN_REMOTE_CONTACTID,
                CLUMN_REMOTE_CONTACTTYPE,CLUMN_REMOTE_URI,CLUMN_REMOTE_DISPLAYNAME);
        
        NSLog(@" createTable %s",TABLE_REMOTER);
        
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@" createTable %s Error:%s ",TABLE_REMOTER,mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

    [self updateVersionCode:TABLE_REMOTER to:DB_REMOTER_VERSION];
}

-(void)updateAccountTable:(int)from to:(int)dest{
    char sql[1024] = {0};

    if(from >= dest){
        return;
    }
    if(![self openDatabase]){
        return ;
    }
    if ([self isTableExist:TABLE_ACCOUNT]) {

        if(from==101 ){
            NSMutableArray *accountArray = [self selectAllAccount];
            for (Account* acc in accountArray) {
                if(acc.userDomain==nil||acc.userDomain.length==0){
                    acc.userDomain = acc.SIPServer;
                    if(acc.SIPServerPort ==5060){
                        acc.SIPServer=@"";
                    }
                    [self updateAccount:acc];
                }
            }
        }else {
            sprintf(sql, "drop table %s", TABLE_ACCOUNT);
            
            if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg)  != SQLITE_OK ){

            }
        }
    }
    
    if (![self isTableExist:TABLE_ACCOUNT]) {

        NSLog(@" createTable %s",TABLE_ACCOUNT);
        
        sprintf(sql, "CREATE TABLE IF NOT EXISTS %s(accountid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, username TEXT, displayname TEXT, authName TEXT, password TEXT, userDomain TEXT, SIPServer TEXT, SIPServerPort INTEGER, transport TEXT,outboundServer TEXT,outboundServerPort INTEGER, enableSTUN INTEGER, STUNServer TEXT, STUNPort INTEGER, presenceAgent INTEGER, publishRefresh INTEGER, subscribeRefresh INTEGER, useCert INTEGER, voiceMail TEXT, active INTEGER)", TABLE_ACCOUNT);
        
        
        
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@" createTable %s Error:%s ",TABLE_ACCOUNT,mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }

    [self updateVersionCode:TABLE_ACCOUNT to:DB_ACCOUNT_VERSION_NEW];
   
}

-(void)updateHistroyTable:(int)from to:(int)dest{
    
    char sql[1024] = {0};
    if(from>=dest)
        return;
    
    if(![self openDatabase]){
        return ;
    }
    
    if (from<100&&[self isTableExist:TABLE_HISTORY]) {

        sprintf(sql, "drop table %s", TABLE_HISTORY);

        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg)  != SQLITE_OK ){
            NSLog(@"DEL FAILED");
        }
    }
    
    if(![self isTableExist:TABLE_HISTORY]){
        from = dest;
        sprintf(sql, "CREATE TABLE IF NOT EXISTS %s(historyid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, remoteParty TEXT, %s TEXT, displayname TEXT, localParty TEXT, localDisplayname TEXT, start DOUBLE,  end DOUBLE, mediaType INTEGER, %s INTEGER, status INTEGER, content BLOB, %s INTEGER, %s INTEGER, %s INTEGER)", TABLE_HISTORY,CLUMN_MIMETYPE,CLUMN_PLAYDURATION,CLUMN_READ,CLUMN_MESSAGEID,CLUMN_REMOVED);
        
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@" createHistoryTable Error:%s ",mErrorMsg);
            sqlite3_free(mErrorMsg);
            return;
        }
    }
    
    switch(from){
        case 100://100->101
        {

            sprintf(sql, "ALTER TABLE %s ADD %s TEXT", TABLE_HISTORY,CLUMN_MIMETYPE);
            if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
            {
                NSLog(@" createHistoryTable Error:%s ",mErrorMsg);
                sqlite3_free(mErrorMsg);
                return;
            }
  
            sprintf(sql, "ALTER TABLE %s ADD %s INTEGER", TABLE_HISTORY,CLUMN_PLAYDURATION);
            if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
            {
                NSLog(@" createHistoryTable Error:%s ",mErrorMsg);
                sqlite3_free(mErrorMsg);
                return;
            }

            sprintf(sql, "ALTER TABLE %s ADD %s INTEGER", TABLE_HISTORY,CLUMN_READ);
            if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
            {
                NSLog(@" createHistoryTable Error:%s ",mErrorMsg);
                sqlite3_free(mErrorMsg);
                return;
            }
            
            sprintf(sql, "ALTER TABLE %s ADD %s INTEGER", TABLE_HISTORY,CLUMN_MESSAGEID);
            if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
            {
                NSLog(@" createHistoryTable Error:%s ",mErrorMsg);
                sqlite3_free(mErrorMsg);
                return;
            }
            
            //添加是否删除字段
            sprintf(sql, "ALTER TABLE %s ADD %s INTEGER", TABLE_HISTORY,CLUMN_REMOVED);
            if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
            {
                NSLog(@" createHistoryTable Error:%s ",mErrorMsg);
                sqlite3_free(mErrorMsg);
                return;
            }
    }
            break;
        case 101://101->102
        {
            NSMutableArray* historyArray;
            for (History *history in historyArray) {
                //history;
            }
        }
            break;
        case 102://102 - >103
            break;
        case 103:
            break;//.....
    }
    
    [self updateHistroyTable:from+1 to:dest];
    [self updateVersionCode:TABLE_HISTORY to:DB_HISTORY_VERSION_NEW];
    return;
}

-(void)updateOptionsTable:(int)from to:(int)dest{
    char sql[1024] = {0};
    if(from>=dest)//
        return;
    
    if(![self openDatabase]){
        return ;
    }
    
    if ([self isTableExist:TABLE_OPTIONS]) {

        sprintf(sql, "drop table %s", TABLE_OPTIONS);
        
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg)  != SQLITE_OK ){
            NSLog(@"DEL FAILED");
        }
    }
    

    if(![self isTableExist:TABLE_OPTIONS]){
        sprintf(sql, "CREATE TABLE IF NOT EXISTS %s(optionsid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, optionsName TEXT, optionsTextValue TEXT, optionsIntValue INTEGER, optionsOther TEXT)", TABLE_OPTIONS);
        
        
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@" createOptionTable Error:%s ",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
    
    [self updateVersionCode:TABLE_OPTIONS to:DB_OPTIONS_VERSION_NEW];
    
}


-(void)updateFavoriterTable:(int)from to:(int)dest{
    char sql[1024] = {0};
    if(from>=dest)
        return;
    
    if(![self openDatabase]){
        return ;
    }
    if ([self isTableExist:TABLE_FAVORITES]) {

        sprintf(sql, "drop table %s", TABLE_FAVORITES);
        
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg)  != SQLITE_OK ){
            NSLog(@"删除表失败");
        }
    }

    if(![self isTableExist:TABLE_FAVORITES]){
        sprintf(sql, "CREATE TABLE IF NOT EXISTS %s(favoriteid INTEGER NOT NULL, phonetype INTEGER, typedescript TEXT, phonenum TEXT,name TEXT, primary key(favoriteid,phonetype,phonenum))", TABLE_FAVORITES);

        
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@" createfavoriterTable Error:%s ",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
    
    [self updateVersionCode:TABLE_FAVORITES to:DB_FAVORITES_VERSION];

}

-(void)updateSipFriendTable:(int)from to:(int)dest{
    char sql[1024] = {0};
    if (from>=dest)
        return;
    
    if(![self openDatabase]){
        return ;
    }
    
    if ([self isTableExist:TABLE_SIPFRIENDS]) {
        sprintf(sql, "drop table %s", TABLE_SIPFRIENDS);
        
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg)  != SQLITE_OK ){
            NSLog(@"DEL FAILED");
        }
    }
    

    if(![self isTableExist:TABLE_SIPFRIENDS]){
        sprintf(sql, "CREATE TABLE IF NOT EXISTS %s(sipid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, sipIdentifier TEXT, SunbscribeID INTEGER, displayName TEXT, firstName TEXT, lastName TEXT,company TEXT,partment TEXT,jobtitle TEXT,creatDate TEXT,imNumber TEXT,comefrom INTEGER,deleteflag INTEGER, applystate INTEGER , phoneNumbers TEXT, ipNumbers TEXT)", TABLE_SIPFRIENDS);
        
        if (sqlite3_exec(mDatabase, sql, NULL, NULL, &mErrorMsg) != SQLITE_OK)
        {
            NSLog(@" createsipFriendTable Error:%s ",mErrorMsg);
            sqlite3_free(mErrorMsg);
        }
    }
    
     [self updateVersionCode:TABLE_SIPFRIENDS to:DB_SIPFRIENDS_VERSION];
}

-(void)dealloc
{
    mDatabase = NULL;
    
    //mDatabase info
    mDatabaseName = nil;
    mDatabasePath = nil;
    mErrorMsg = NULL;
    
    mAccountArray = nil;
    
    mOptions = nil;
}


#pragma mark-
#pragma mark
-(void)checkscroe:(NSTimeInterval)sta andend:(NSTimeInterval)end {
    
    
    BOOL  checkscore = [[NSUserDefaults standardUserDefaults]boolForKey:@"checkscore"];
    
    
    if (!checkscore) {
        
        NSInteger  second =  [self CalculateTheTimeDifference:sta andend:end];
        
        NSInteger  readyscoreAlertViewNot = [[NSUserDefaults standardUserDefaults]integerForKey:@"readyscoreAlertViewNot"];
        
        if (second  > 30) {
            
            readyscoreAlertViewNot ++;
            
            [[NSUserDefaults standardUserDefaults]setInteger:readyscoreAlertViewNot forKey:@"readyscoreAlertViewNot"];
            
            
            if (readyscoreAlertViewNot==3) {
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"readyscoreAlertViewNot" object:nil];
                
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"checkscore"];
                
            }
            
        }
        
        
    }
    
}

-(NSInteger)CalculateTheTimeDifference :(NSTimeInterval )time1  andend:(NSTimeInterval)time2{
    
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:time1];
    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:time2];
 
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    
//    unsigned int unitFlags = NSSecondCalendarUnit;

      unsigned int unitFlags = NSCalendarUnitSecond;
    
    NSDateComponents *d = [cal components:unitFlags fromDate:date1 toDate:date2 options:0];
 
    return  [d second];
}
    

-(NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *datenow = [NSDate date];

    NSString *currentTimeString = [formatter stringFromDate:datenow];

    return currentTimeString;
    
}
    
-(int)compareDate:(NSString*)date01 withDate:(NSString*)date02{
    int ci;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm"];
    NSDate *dt1 = [[NSDate alloc] init];
    NSDate *dt2 = [[NSDate alloc] init];
    dt1 = [df dateFromString:date01];
    dt2 = [df dateFromString:date02];
    NSComparisonResult result = [dt1 compare:dt2];
    switch (result)
    {
        case NSOrderedAscending:
        ci=1;
        
           return ci;
        
        break;
        case NSOrderedDescending:
        ci=-1;
        
           return ci;
        break;
        case NSOrderedSame:
        ci=0;
        
           return ci;
        break;
        
        default:
        
        
           return ci;
        NSLog(@"erorr dates %@, %@", dt2, dt1);
        break;
        
        
    }
 
}
@end

