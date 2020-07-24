//
//  HSContactsDBManage.m
//  PortGo
//
//  Created by MrLee on 14/10/22.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSContactsDBManage.h"
#import <sqlite3.h>

#define DatabaseName @"contacts.db"
#define TableContacts @"contacts"

@interface HSContactsDBManage()
{
    sqlite3 *_db;
    NSString *_dbPath;
}

@end

@implementation HSContactsDBManage

single_implementation(HSContactsDBManage)

- (instancetype)init
{
    if (self = [super init]) {
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        _dbPath = [path stringByAppendingString:DatabaseName];
        
        if ([self openDatabase]) {
            if (![self isExistTable:TableContacts]) {
                
            }
        }
        
    }
    
    return self;
}

- (BOOL)openDatabase
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:_dbPath])
    {
        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DatabaseName];
        [fileManager copyItemAtPath:databasePathFromApp toPath:_dbPath error:nil];
    }
    
    
    if (SQLITE_OK == sqlite3_open(_dbPath.UTF8String, &_db)) {
        NSLog(@"create database(contacts.sqlite) successful...");
        return YES;
    }
    else{
        NSLog(@"create database(contacts.sqlite) failed...");
        return NO;
    }
}

-(void)closeDatabase
{
    if(_db)
    {
        sqlite3_close(_db);
        _db = NULL;
    }
};

- (void)executeSql:(NSString*)sql msg:(NSString*)msg
{
    char *errorMsg;
    if (SQLITE_OK == sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errorMsg)) {
        MLLog(@"%@ successful...", msg);
    }
    else{
        MLLog(@"%@ faliure...", msg);
    }
}

- (BOOL)isExistTable:(NSString*)tableName
{
    if (tableName == nil || tableName.length <= 0  || !_db)
    {
        return NO;
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"select * from %@",tableName];
    
    const char *sqlStatement = [sql UTF8String];
    
    char * erro = NULL;
    char ** result = NULL;
    int row = 0;
    int colum = 0;
    
    if (sqlite3_get_table(_db, sqlStatement, &result,&row, &colum, &erro) != SQLITE_OK)
    {
        return false;
    }
    return true;
}
@end
