//
//  CKModel.h
//  FMDBHelper
//
//  Created by caydenk on 15/5/19.
//  Copyright (c) 2015年 caydenk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKConditionMaker;
@class CKQueryMaker;

@protocol CKPrimaryKey <NSObject>
@end

/**
 *  正序
 */
extern NSString * const kCKModelIndexAsc;
/**
 *  倒序
 */
extern NSString * const kCKModelIndexDesc;

@protocol CKFmdbOperate <NSObject>

@required
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
/**
 *  获取表结构
 *
 *  @param tableName 表名
 *
 *  @return 表字段数组
 */
+ (NSArray *)columnArrayWithTable:(NSString *)tableName;

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

/**
 *  查询任意自定义语句
 *
 *  @param sql 查询语句
 *
 *  @return 查询到的字典数组
 */
+ (NSArray *)queryDictArrayWithSql:(NSString *)sql;
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

@protocol CKFmdbJsonOperate <NSObject>

/**
 *  字典转换model
 *
 *  @param dict model字典
 *
 *  @return model
 */
+ (id<CKFmdbJsonOperate>)modelWithDictionary:(NSDictionary *)dict;
/**
 *  字典转换为数组模型
 *
 *  @param dicts 字典数组
 *
 *  @return 模型数组
 */
+ (NSArray *)modelsWithDictionarys:(NSArray *)dicts;
/**
 *  模型数组转换为字典数组
 *
 *  @param models 模型数组
 *
 *  @return 字典数组
 */
+ (NSArray *)modelDictnarysWithModels:(NSArray *)models;
/**
 *  模型数组转换为json
 *
 *  @param models 模型数组
 *
 *  @return json
 */
+ (NSString *)modelsJsonWithModels:(NSArray *)models;
/**
 *  根据字典赋值
 *
 *  @param dicts 模型字典
 */
- (void)setValuesFromDictionary:(NSDictionary *)dicts;
/**
 *  获取模型字典
 *
 *  @return 模型字典
 */
- (NSDictionary *)modelDictionary;
/**
 *  获取模型json
 *
 *  @return 模型json
 */
- (NSString *)modelJson;


@end

@protocol CKFmdbJsonSerializing <NSObject>
@required
/**
 *  json 解析Key mapping
 *
 *  @return mapping
 */
+ (NSDictionary *)jsonKeyPathMapping;

@end

/**
 *  FMDBHelperBaseModel
 */
@interface CKModel : NSObject<CKFmdbOperate,CKFmdbJsonOperate,NSCopying>

//根据字典初始化
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
