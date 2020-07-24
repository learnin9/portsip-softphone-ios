//
//  DataBase.m
//  FMDBDemo
//
//  Created by Zeno on 16/5/18.
//  Copyright © 2016年 zenoV. All rights reserved.
//

#import "DataBase.h"

#import "FMDB.h"



#import "Person.h"

static DataBase *_DBCtl = nil;

@interface DataBase()<NSCopying,NSMutableCopying>{
    FMDatabase  *_db;
    
}




@end

@implementation DataBase

+(instancetype)sharedDataBase{
    
    if (_DBCtl == nil) {
        
        _DBCtl = [[DataBase alloc] init];
        
        [_DBCtl initDataBase];
        
    }
    
    return _DBCtl;
    
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    
    if (_DBCtl == nil) {
        
        _DBCtl = [super allocWithZone:zone];
        
    }
    
    return _DBCtl;
    
}

-(id)copy{
    
    return self;
    
}

-(id)mutableCopy{
    
    return self;
    
}

-(id)copyWithZone:(NSZone *)zone{
    
    return self;
    
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    
    return self;
    
}


-(void)initDataBase{
    // 获得Documents目录路径
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    // 文件路径
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"model.sqlite"];
    
    // 实例化FMDataBase对象
    
    _db = [FMDatabase databaseWithPath:filePath];
    
    [_db open];
    
    // 初始化数据表
    NSString *personSql = @"CREATE TABLE 'person' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'person_id' VARCHAR(255),'name' VARCHAR(255),'str1' VARCHAR(255),'str2'VARCHAR(255),'str3'VARCHAR(255)) ";
  
    
    [_db executeUpdate:personSql];
  
    
    [_db close];

}
#pragma mark - 接口

- (void)addPerson:(Person *)person{
    [_db open];
    
    NSNumber *maxID = @(0);
    
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM person "];
    //获取数据库中最大的ID
    while ([res next]) {
        
        NSLog(@"id======%@",[res stringForColumn:@"person_id"]);
        
        if ([maxID integerValue] < [[res stringForColumn:@"person_id"] integerValue]) {
            maxID = @([[res stringForColumn:@"person_id"] integerValue] ) ;
        }
        
    }
    maxID = @([maxID integerValue] + 1);
    
    NSLog(@"maxID====%@",maxID);
    
    [_db executeUpdate:@"INSERT INTO person(person_id,name,str1,str2,str3)VALUES(?,?,?,?,?)",maxID,person.name,person.str1,person.str2,person.str3];
    
    
    
    [_db close];
    
}

- (void)deletePerson:(Person *)person{
    [_db open];
    
    [_db executeUpdate:@"DELETE FROM person WHERE person_id = ?",person.ID];

    [_db close];
}

- (void)updatePerson:(Person *)person{
    [_db open];
    
    [_db executeUpdate:@"UPDATE 'person' SET name = ?  WHERE person_id = ? ",person.name,person.ID];
     [_db executeUpdate:@"UPDATE 'person' SET str1 = ?  WHERE person_id = ? ",person.str1,person.ID];
      [_db executeUpdate:@"UPDATE 'person' SET str2 = ?  WHERE person_id = ? ",person.str2,person.ID];
      [_db executeUpdate:@"UPDATE 'person' SET str3 = ?  WHERE person_id = ? ",person.str3,person.ID];
    
    [_db close];
}

- (NSMutableArray *)getAllPerson{
    [_db open];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM person"];
    
    while ([res next]) {
        Person *person = [[Person alloc] init];
        person.ID = @([[res stringForColumn:@"person_id"] integerValue]);
        person.name = [res stringForColumn:@"name"];
        person.str1 = [res stringForColumn:@"str1"] ;
          person.str2 = [res stringForColumn:@"str2"] ;
          person.str3 = [res stringForColumn:@"str3"] ;
        
        [dataArray addObject:person];
        
    }
    
    [_db close];
    
    
    
    return dataArray;
    
    
}


@end
