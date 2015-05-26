//
//  CKModel.h
//  FMDBHelper
//
//  Created by tcyx on 15/5/19.
//  Copyright (c) 2015年 tcyx. All rights reserved.
//

#import "Mantle.h"

@class CKConditionMaker;
@class CKQueryMaker;

static const NSString *kCKModelIndexAsc;
static const NSString *kCKModelIndexDesc;

/**
 *  FMDBHelperBaseModel
 */
@interface CKModel : MTLModel

#pragma mark
#pragma mark - Table Operate

#pragma mark - Create
/**
 *  创建表
 *
 *  @return 成功/失败
 */
+ (void)createTable;
/**
 *  创建索引
 *
 *  @param indexName 索引名称
 *  @param isUnique  是否唯一
 *  @param column    字段列表
 *
 *  @return 是否成功
 */
+ (void)createIndex:(NSString *)indexName Unique:(BOOL)isUnique Columns:(NSString *)column,...;
/**
 *  创建索引
 *
 *  @param indexName   索引名称
 *  @param isUnique  是否唯一
 *  @param aColumnDict 字段列表、是否排序格式如下：
 *  @{"column1":@"asc",@"column2":@"desc"}
 *
 *  @return 是否成功
 */
+ (void)createIndex:(NSString *)indexName Unique:(BOOL)isUnique ColumnDict:(NSDictionary *)aColumnDict;

#pragma mark - Drop
/**
 *  删除表
 *
 *  @return 是否成功
 */
+ (void)dropTable;
/**
 *  删除索引
 *
 *  @param indexName 索引名称
 *
 *  @return 是否成功
 */
+ (void)dropIndex:(NSString *)indexName;

#pragma mark - Alert
/**
 *  修改表名
 *
 *  @param oldName 旧表名
 *
 *  @return 是否修改成功
 */
+ (void)renameTableWithOldName:(NSString *)oldName;
/**
 *  表结构更新到最新
 *
 *  @return 是否成功
 */
+ (void)updateColumn;

#pragma mark
#pragma mark - Content Operate

#pragma mark
#pragma mark - Select
+ (NSArray *)queryWithConditions:(id (^)(CKConditionMaker * maker))block;
+ (NSDictionary *)query:(id (^)(CKQueryMaker* maker))aQuery withConditions:(id (^)(CKConditionMaker * maker))block;
#pragma mark
#pragma mark - insert
+ (void)insertWithArray:(NSArray *)array;
- (void)insert;

#pragma mark
#pragma mark - update
+ (void)updateWithArray:(NSArray *)array Conditions:(id (^)(CKConditionMaker * maker))block;
- (void)updateWithConditions:(id (^)(CKConditionMaker * maker))block;

#pragma mark
#pragma mark - replace
+ (void)replaceWithArray:(NSArray *)array;
- (void)replace;

#pragma mark
#pragma mark - delete
+ (void)deleteWithArray:(NSArray *)array;
+ (void)deleteWithConditions:(id (^)(CKConditionMaker * maker))block;
- (void)delete;


@end
