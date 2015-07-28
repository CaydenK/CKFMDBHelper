//
//  CKDictionary.m
//  GameCenter
//
//  Created by caydenk on 15/7/28.
//  Copyright (c) 2015年 CaydenK. All rights reserved.
//

#import "CKFMDBHelper.h"
#import "CKManager.h"
#import <FMDB/FMDB.h>

//键 列名
#define CK_DICT_KEY @"ckkey"
//值 列名
#define CK_DICT_VALUE @"ckvalue"

@interface CKDictionary ()
{
    CFMutableDictionaryRef _dictionary;
}

@property (nonatomic, strong) dispatch_queue_t dictQueue;

@end

@implementation CKDictionary

+ (CKDictionary *)shareInstance {
    static CKDictionary *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.dictQueue = dispatch_queue_create("ck_dict_serial_queue", DISPATCH_QUEUE_SERIAL);
    });
    return instance;
}

/**
 *  创建表,并创建唯一索引
 */
+ (void)createTable{
    NSString *createTableSql = [NSString stringWithFormat:@"create table if not exists '%@' (%@ text default '' NOT NULL,%@ text default '' NOT NULL)",CKDICTIONARY,CK_DICT_KEY,CK_DICT_VALUE];
    NSMutableString *createIndexSql = [NSMutableString stringWithFormat:@"create unique index '%@_index' on '%@' (%@)",CKDICTIONARY,CKDICTIONARY,CK_DICT_KEY];
    FMDatabase *db = [[CKManager shareManager] databaseWithName:CKDBNAME];
    [db open];
    [db executeUpdate:createTableSql];
    [db executeUpdate:createIndexSql];
    [db close];
}

+ (id)valueFromDBForKey:(id<NSCopying>)aKey {
    NSString *querySql = [NSString stringWithFormat:@"select %@ from %@ where %@ = '%@'",CK_DICT_VALUE,CKDICTIONARY,CK_DICT_KEY,aKey];
    id value = nil;
    FMDatabase *db = [[CKManager shareManager] databaseWithName:CKDBNAME];
    [db open];
    FMResultSet *rs = [db executeQuery:querySql];
    while ([rs next]) {
        value = [rs objectForColumnName:CK_DICT_VALUE];
    }
    [db close];
    return value;
}

#pragma mark
#pragma mark - NSMutableDictionary
- (id)init {
    self = [super init];
    if (self)
    {
        _dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0,
                                                &kCFTypeDictionaryKeyCallBacks,
                                                &kCFTypeDictionaryValueCallBacks);
       
        NSString *querySql = [NSString stringWithFormat:@"select %@ from %@",CK_DICT_VALUE,CKDICTIONARY];
        FMDatabase *db = [[CKManager shareManager] databaseWithName:CKDBNAME];
        [db open];
        FMResultSet *rs = [db executeQuery:querySql];
        while ([rs next]) {
            id key = [rs objectForColumnName:CK_DICT_KEY];
            id value = [rs objectForColumnName:CK_DICT_VALUE];
            CFDictionarySetValue(_dictionary, (__bridge const void *)key, (__bridge const void *)value);
        }
        [db close];

    }
    return self;
}
- (NSUInteger)count {
    NSUInteger count = CFDictionaryGetCount(_dictionary);
    return count;
}
- (id)objectForKey:(id)aKey {
    NSAssert(aKey, @"key cannot be nil");
    id result = CFDictionaryGetValue(_dictionary, (__bridge const void *)(aKey));
    if (!result) {
        result = [[self class] valueFromDBForKey:aKey];
        CFDictionarySetValue(_dictionary, (__bridge const void *)aKey, (__bridge const void *)result);
    }
    return result;
}
- (NSEnumerator *)keyEnumerator {
    id result = [(__bridge id)_dictionary keyEnumerator];
    return result;
}
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    NSAssert(anObject, @"object cannot be nil");
    NSAssert(aKey, @"key cannot be nil");
    CFDictionarySetValue(_dictionary, (__bridge const void *)aKey, (__bridge const void *)anObject);
    [[[CKManager shareManager] databaseQueueWithName:CKDBNAME] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL success = [db executeUpdate:[NSString stringWithFormat:@"replace into %@ ([%@],[%@]) values ('%@','%@')",CKDICTIONARY,CK_DICT_KEY,CK_DICT_VALUE,aKey,anObject]];
        if (!success) {
            NSArray *columnArray = [CKModel columnArrayWithTable:CKDICTIONARY];
            if (columnArray.count == 0) {
                [[self class] createTable];
            }
            [db executeUpdate:[NSString stringWithFormat:@"replace into %@ ([%@],[%@]) values ('%@','%@')",CKDICTIONARY,CK_DICT_KEY,CK_DICT_VALUE,aKey,anObject]];
        }

    }];
}
- (void)removeObjectForKey:(id)aKey {
    NSAssert(aKey, @"key cannot be nil");
    CFDictionaryRemoveValue(_dictionary, (__bridge const void *)aKey);
    [[[CKManager shareManager] databaseQueueWithName:CKDBNAME] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where [%@] = '%@'",CKDICTIONARY,CK_DICT_KEY,aKey]];
    }];
}
- (void)removeAllObjects {
    CFDictionaryRemoveAllValues(_dictionary);
    [[[CKManager shareManager] databaseQueueWithName:CKDBNAME] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:[NSString stringWithFormat:@"delete from %@",CKDICTIONARY]];
    }];
}
- (void)dealloc {
    if (_dictionary)
    {
        CFRelease(_dictionary);
        _dictionary = NULL;
    }
}

@end
