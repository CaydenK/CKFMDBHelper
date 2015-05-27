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

/**
 *  正序
 */
static const NSString *kCKModelIndexAsc;
/**
 *  倒序
 */
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
+ (void)createIndex:(NSString *)indexName unique:(BOOL)isUnique columns:(NSString *)column,...;
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
+ (void)createIndex:(NSString *)indexName unique:(BOOL)isUnique columnDict:(NSDictionary *)aColumnDict;

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
/**
 *  条件查询单表
 *
 *  @param block 查询条件
 *
 *  @return Model列表
 */
+ (NSArray *)queryWithConditions:(id (^)(CKConditionMaker * maker))block;
/**
 *  函数查询（count()、max()等）
 *
 *  @param aQuery 函数语句
 *  @param block  条件语句
 *
 *  @return 查询结果
 */
+ (NSArray *)query:(id (^)(CKQueryMaker* maker))aQuery withConditions:(id (^)(CKConditionMaker * maker))block;
#pragma mark
#pragma mark - insert
/**
 *  多条数据插入
 *
 *  @param array 数据数组
 */
+ (void)insertWithArray:(NSArray *)array;
/**
 *  单条数据插入
 */
- (void)insert;

#pragma mark
#pragma mark - update
/**
 *  多数据条件更新（可设置唯一索引做唯一标识）
 *
 *  @param array 数据数组
 *  @param block 条件语句
 */
+ (void)updateWithArray:(NSArray *)array conditions:(id (^)(CKConditionMaker * maker))block;
/**
 *  单条数据更新
 *
 *  @param block 条件语句
 */
- (void)updateWithConditions:(id (^)(CKConditionMaker * maker))block;

#pragma mark
#pragma mark - replace
/**
 *  有则更新/无则插入语句 （多条数据）
 *
 *  @param array 数据数组
 */
+ (void)replaceWithArray:(NSArray *)array;
/**
 *  有则更新/无则插入语句 （单条数据）
 */
- (void)replace;

#pragma mark
#pragma mark - delete
/**
 *  删除多条数据（每个字段都唯一对应）
 *
 *  @param array 数据数组
 */
+ (void)deleteWithArray:(NSArray *)array;
/**
 *  条件删除数据
 *
 *  @param block 条件语句
 */
+ (void)deleteWithConditions:(id (^)(CKConditionMaker * maker))block;
/**
 *  单条数据删除
 */
- (void)delete;


@end
