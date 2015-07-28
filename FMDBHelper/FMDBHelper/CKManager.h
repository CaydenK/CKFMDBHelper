//
//  CKManager.h
//  FMDBHelper
//
//  Created by caydenk on 15/5/19.
//  Copyright (c) 2015年 caydenk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class FMDatabaseQueue;
/**
 *  数据库助手类
 */
@interface CKManager : NSObject

@property (nonatomic, copy) NSString *dbPath;

/**
 *  获取当前单例
 *
 *  @return 当前单例
 */
+ (CKManager *)shareManager;

/**
 *  根据库名获取FMDatabase
 *
 *  @param dbName 数据库名称
 *
 *  @return FMDatabase
 */
- (FMDatabase *)databaseWithName:(NSString *)dbName;
/**
 *  根据库名获取FMDatabaseQueue
 *
 *  @param dbName 数据库名称
 *
 *  @return FMDatabaseQueue
 */
- (FMDatabaseQueue *)databaseQueueWithName:(NSString *)dbName;

@end
